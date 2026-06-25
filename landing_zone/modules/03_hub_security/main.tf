data "alicloud_zones" "available" {
  available_resource_creation = "VSwitch"
}

# Hub VPC
resource "alicloud_vpc" "hub" {
  vpc_name   = "${var.environment}-hub-vpc"
  cidr_block = var.hub_vpc_cidr
  tags       = var.tags
  
  lifecycle {
    prevent_destroy = true
  }
}

# VSwitches
resource "alicloud_vswitch" "untrusted" {
  vpc_id       = alicloud_vpc.hub.id
  cidr_block   = cidrsubnet(var.hub_vpc_cidr, 8, 1)
  zone_id      = data.alicloud_zones.available.zones[0].id
  vswitch_name = "${var.environment}-untrusted"
  tags         = var.tags
}

resource "alicloud_vswitch" "trusted" {
  vpc_id       = alicloud_vpc.hub.id
  cidr_block   = cidrsubnet(var.hub_vpc_cidr, 8, 2)
  zone_id      = data.alicloud_zones.available.zones[0].id
  vswitch_name = "${var.environment}-trusted"
  tags         = var.tags
}

resource "alicloud_vswitch" "mgmt" {
  vpc_id       = alicloud_vpc.hub.id
  cidr_block   = cidrsubnet(var.hub_vpc_cidr, 8, 3)
  zone_id      = data.alicloud_zones.available.zones[0].id
  vswitch_name = "${var.environment}-mgmt"
  tags         = var.tags
}

# KMS Key
# resource "alicloud_kms_key" "hub" {
#   description            = "Central KMS for at-rest encryption"
#   pending_window_in_days = 7
#   status                 = "Enabled"
# }

# ============================================
# PALO ALTO FIREWALL (MOCK)
# ============================================
# Security Group for Palo Alto
resource "alicloud_security_group" "fw" {
  security_group_name = "${var.environment}-palo-alto-sg"
  vpc_id              = alicloud_vpc.hub.id
  tags                = var.tags
}

resource "alicloud_security_group_rule" "mgmt_https_from_bastion" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.fw.id
  cidr_ip           = "10.10.30.0/24"  # only allow traffic from CyberArk Bastion
  description       = "Palo Alto Mgmt HTTPS from CyberArk Bastion"
}

resource "alicloud_security_group_rule" "mgmt_ssh_from_bastion" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.fw.id
  cidr_ip           = "10.10.30.0/24"
  description       = "Palo Alto Mgmt SSH from CyberArk Bastion"
}

resource "alicloud_security_group_rule" "mgmt_deny_all" {
  type              = "ingress"
  ip_protocol       = "all"
  port_range        = "-1/-1"
  security_group_id = alicloud_security_group.fw.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "drop"
  priority          = 100
  description       = "Deny all other management access"
}

# Palo Alto Instances
resource "alicloud_instance" "palo_alto" {
  count                 = 2
  instance_name         = "${var.environment}-palo-alto-${count.index}"
  instance_type         = var.firewall_instance_type
  image_id              = var.image_id
  vswitch_id            = alicloud_vswitch.untrusted.id
  security_groups       = [alicloud_security_group.fw.id]
  system_disk_category  = "cloud_essd"
  system_disk_encrypted = true
  tags                  = merge(var.tags, { Role = "Firewall", Vendor = "PaloAlto", Mock = "true" })
}

# Data source to get ENI ID after instance creation
data "alicloud_network_interfaces" "palo_alto_eni" {

  depends_on  = [alicloud_instance.palo_alto]
  instance_id = alicloud_instance.palo_alto[0].id
}

# Route Table for Trusted Subnet - force traffic through Palo Alto
resource "alicloud_route_table" "trusted_rt" {
  vpc_id           = alicloud_vpc.hub.id
  route_table_name = "${var.environment}-trusted-rt"
}

resource "alicloud_route_table_attachment" "trusted" {
  vswitch_id     = alicloud_vswitch.trusted.id
  route_table_id = alicloud_route_table.trusted_rt.id
}

# Route to Palo Alto for all outbound traffic
resource "alicloud_route_entry" "to_firewall" {
  route_table_id        = alicloud_route_table.trusted_rt.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NetworkInterface"
  nexthop_id            = data.alicloud_network_interfaces.palo_alto_eni.ids[0]
}

# ============================================
# IPv4 GATEWAY (For Inbound Traffic)
# ============================================
resource "alicloud_vpc_ipv4_gateway" "default" {
  ipv4_gateway_name = "${var.environment}-ipv4-gateway"
  vpc_id            = alicloud_vpc.hub.id
  enabled           = true
}

# ============================================
# GATEWAY ROUTE TABLE (For Inbound Traffic)
# ============================================
resource "alicloud_route_table" "inbound" {
  vpc_id           = alicloud_vpc.hub.id
  route_table_name = "${var.environment}-inbound-gateway-rt"
  description      = "Gateway route table for inbound traffic via Palo Alto"
  associate_type = "Gateway"  # To make it works as Gateway route table
}

# ============================================
# GATEWAY ROUTE ENTRIES (Redirect Inbound Traffic to Palo Alto)
# ============================================
# need to config Palo Alto DNAT instead for it to work
# resource "alicloud_route_entry" "inbound_to_palo_alto" {
#   for_each = toset(var.inbound_redirect_cidrs)
  
#   route_table_id        = alicloud_route_table.inbound.id
#   destination_cidrblock = each.value
#   nexthop_type          = "NetworkInterface"
#   nexthop_id            = data.alicloud_network_interfaces.palo_alto.ids[0]
# }


data "alicloud_cen_instances" "existing" {
  ids = [var.cen_id]
}

resource "alicloud_cen_transit_router_vpc_attachment" "hub" {
  cen_id            = var.cen_id
  transit_router_id = var.transit_router_id
  vpc_id            = alicloud_vpc.hub.id
  
  lifecycle {
    prevent_destroy = false  # true to prevent from setting each time
  }
  zone_mappings {
    zone_id    = data.alicloud_zones.available.zones[0].id
    vswitch_id = alicloud_vswitch.trusted.id
  }
}

# CEN Bandwidth Package (temp disable KMS for budget reason)
# resource "alicloud_cen_bandwidth_package" "cross_border" {
#   geographic_region_a_id     = "China"
#   geographic_region_b_id     = "Asia-Pacific"
#   bandwidth                  = var.backbone_bandwidth_mbps
#   cen_bandwidth_package_name = "${var.environment}-hk-sg-bwp"
# }

# resource "alicloud_cen_bandwidth_package_attachment" "attach" {
#   instance_id          = var.cen_id
#   bandwidth_package_id = alicloud_cen_bandwidth_package.cross_border.id
# }

# ============================================
# ATTACH DATAWORKS VPC TO CEN
# ============================================

resource "alicloud_cen_transit_router_vpc_attachment" "dataworks" {
  count = var.dataworks_vpc_id != "" ? 1 : 0
  
  cen_id            = var.cen_id
  transit_router_id = var.transit_router_id
  vpc_id            = var.dataworks_vpc_id
  
  lifecycle {
    prevent_destroy = false  # true to prevent from setting each time
  }
  zone_mappings {
    zone_id    = data.alicloud_zones.available.zones[0].id
    vswitch_id = var.dataworks_vswitch_id
  }
}

# ============================================
# GWLB Config (uncomment for prod)
# ============================================
# GWLB SERVER GROUP
# ============================================

# resource "alicloud_gwlb_server_group" "palo_alto" {
#   server_group_name = "${var.environment}-palo-alto-sg"
#   vpc_id            = alicloud_vpc.hub.id
#   scheduler         = "5TCH"  # Consistent Hash
#   protocol          = "GENEVE"  # GWLB uses GENEVE
  
#   servers {
#     server_id   = alicloud_instance.palo_alto[0].id
#     server_type = "Ecs"
#   }
  
#   servers {
#     server_id   = alicloud_instance.palo_alto[1].id
#     server_type = "Ecs"
#   }
  
#   health_check_config {
#     health_check_enabled      = true
#     health_check_protocol     = "HTTP"
#     health_check_connect_port = 80
#     health_check_path         = "/health-check"
#     health_check_interval     = 10
#     healthy_threshold         = 2
#     unhealthy_threshold       = 2
#   }
# }

# ============================================
# GWLB LOAD BALANCER
# ============================================

# resource "alicloud_gwlb_load_balancer" "unified ingress" {
#   load_balancer_name = "gwlb"
#   # need to provide EIP for it to be internet-facing
#   vpc_id             = var.hub_vpc_cidr
  
#   zone_mappings {
#     vswitch_id = alicloud_vswitch.untrusted.id
#     zone_id    = data.alicloud_zones.available.zones[0].id
#   }
# }

# ============================================
# GWLB LISTENER (監聽器)
# ============================================

# resource "alicloud_gwlb_listener" "default" {
#   load_balancer_id = alicloud_gwlb_load_balancer.default.id
#   server_group_id  = alicloud_gwlb_server_group.palo_alto.id
#   listener_description = "${var.environment}-gwlb-listener"
# }