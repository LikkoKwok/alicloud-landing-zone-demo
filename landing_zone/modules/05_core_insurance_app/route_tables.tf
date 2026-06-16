# ============================================
# ROUTE TABLES: FORCE TRAFFIC THROUGH PALO ALTO
# Requirement: All outbound traffic must pass through
# Palo Alto firewall first (north-south protection)
# ============================================

# Create a custom route table for each environment's web subnet
resource "alicloud_route_table" "env_web" {
  for_each         = local.environments
  vpc_id           = alicloud_vpc.core_insurance.id  # Changed from webapp
  route_table_name = "${var.environment}-${each.key}-web-rt"
  description      = "Route table forcing ${each.key} web traffic through Palo Alto"
}

# Default enforce each web subnet in every environment route traffic to 0.0.0.0/0 pointing to the Palo Alto's Trust ENI
resource "alicloud_route_entry" "force_to_palo_alto" {
  for_each               = local.environments
  route_table_id         = alicloud_route_table.env_web[each.key].id
  destination_cidrblock  = "0.0.0.0/0"
  nexthop_type           = "NetworkInterface"
  nexthop_id             = var.palo_alto_trust_eni_id
  description            = "Force all outbound traffic through Palo Alto firewall"
}

# Attach route table to each web subnet
resource "alicloud_route_table_attachment" "attach_web_subnet" {
  for_each       = local.environments
  vswitch_id     = alicloud_vswitch.web[each.key].id
  route_table_id = alicloud_route_table.env_web[each.key].id
}
