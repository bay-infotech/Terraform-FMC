terraform {
  required_providers {
    fmc = {
      source = "CiscoDevNet/fmc"
      # version = "0.2.0"
    }
  }
}

provider "fmc" {
  fmc_username = var.fmc_username
  fmc_password = var.fmc_password
  fmc_host = var.fmc_host
  fmc_insecure_skip_verify = var.fmc_insecure_skip_verify
}

data "fmc_ips_policies" "ips_policy" {
    name = "Connectivity Over Security"
}

data "fmc_syslog_alerts" "syslog_alert" {
    name = "Testing Syslog"
}

data "fmc_access_policies" "access_policy" {
    name = "FTD"
}

resource "fmc_access_policies" "access_policy" {
    name = "Terraform Access Policy"
    default_action = "block" # Cannot have block with base IPS policy
    # default_action = "permit"
    # default_action_base_intrusion_policy_id = data.fmc_ips_policies.ips_policy.id
    default_action_send_events_to_fmc = true
    default_action_log_begin = true
    default_action_syslog_config_id = data.fmc_syslog_alerts.syslog_alert.id
}

output "existing_fmc_access_policy" {
    value = data.fmc_access_policies.access_policy
}

output "new_fmc_access_policy" {
    value = fmc_access_policies.access_policy
}

resource "fmc_access_policies" "access_policy" {
    name = "Terraform Access Policy"
    default_action = "block" 
}

resource "fmc_access_policies_category" "access_policy_test_category" {
    name             = "CategoryTest"
    access_policy_id = fmc_access_policies.access_policy.id
}

resource "fmc_access_rules" "access_rule_1" {
    acp = fmc_access_policies.access_policy.id
    category = fmc_access_policies_category.access_policy_test_category.name
    name = "Test rule 1"
    enabled = true
    action = "allow"
}

data "fmc_security_zones" "inside" {
    name = "inside"
}

data "fmc_security_zones" "outside" {
    name = "outside"
}

data "fmc_network_objects" "source" {
    name = "VLAN825-Public"
}

data "fmc_network_objects" "dest" {
    name = "VLAN825-Private"
}

data "fmc_port_objects" "http" {
    name = "HTTPS"
}

data "fmc_ips_policies" "ips_policy" {
    name = "Connectivity Over Security"
}

data "fmc_syslog_alerts" "syslog_alert" {
    name = "Testing Syslog"
}

resource "fmc_url_objects" "dest_url" {
    name = "Guacamole"
    url = "http://guacamole.adyah.cisco"
    description = "Testing ACR"
}

resource "fmc_access_policies" "access_policy" {
    name = "Terraform Access Policy"
    # default_action = "block" # Cannot have block with base IPS policy
    default_action = "permit"
    default_action_base_intrusion_policy_id = data.fmc_ips_policies.ips_policy.id
    default_action_send_events_to_fmc = "true"
    default_action_log_end = "true"
    default_action_syslog_config_id = data.fmc_syslog_alerts.syslog_alert.id
}

resource "fmc_access_rules" "access_rule_1" {
    acp = fmc_access_policies.access_policy.id
    section = "mandatory"
    name = "Test rule 1"
    action = "allow"
    enabled = true
    enable_syslog = true
    syslog_severity = "alert"
    send_events_to_fmc = true
    log_files = false
    log_end = true
    source_zones {
        source_zone {
            id = data.fmc_security_zones.inside.id
            type =  data.fmc_security_zones.inside.type
        }
        source_zone {
            id = data.fmc_security_zones.outside.id
            type =  data.fmc_security_zones.outside.type
        }
    }
    destination_zones {
        destination_zone {
            id = data.fmc_security_zones.outside.id
            type =  data.fmc_security_zones.outside.type
        }
    }
    source_networks {
        source_network {
            id = data.fmc_network_objects.source.id
            type =  data.fmc_network_objects.source.type
        }
    }
    destination_networks {
        destination_network {
            id = data.fmc_network_objects.dest.id
            type =  data.fmc_network_objects.dest.type
        }
    }
    destination_ports {
        destination_port {
            id = data.fmc_port_objects.http.id
            type =  data.fmc_port_objects.http.type
        }
    }
    urls {
        url {
            id = fmc_url_objects.dest_url.id
            type = "Url"
        }
    }
    ips_policy = data.fmc_ips_policies.ips_policy.id
    syslog_config = data.fmc_syslog_alerts.syslog_alert.id
    new_comments = [ "New", "comment" ]
}

resource "fmc_access_rules" "access_rule_2" {
    acp = fmc_access_policies.access_policy.id
    section = "mandatory"
    insert_before = 1 # Wont work as assumed since terraform does not 
    name = "Test rule 2"
    action = "allow"
    enabled = true
    enable_syslog = true
    syslog_severity = "alert"
    send_events_to_fmc = true
    log_files = false
    log_end = true
    source_zones {
        source_zone {
            id = data.fmc_security_zones.inside.id
            type =  data.fmc_security_zones.inside.type
        }
        # source_zone {
        #     id = data.fmc_security_zones.outside.id
        #     type =  data.fmc_security_zones.outside.type
        # }
    }
    destination_zones {
        destination_zone {
            id = data.fmc_security_zones.outside.id
            type =  data.fmc_security_zones.outside.type
        }
    }
    source_networks {
        source_network {
            id = data.fmc_network_objects.source.id
            type =  data.fmc_network_objects.source.type
        }
    }
    destination_networks {
        destination_network {
            id = data.fmc_network_objects.dest.id
            type =  data.fmc_network_objects.dest.type
        }
    }
    destination_ports {
        destination_port {
            id = data.fmc_port_objects.http.id
            type =  data.fmc_port_objects.http.type
        }
    }
    urls {
        url {
            id = fmc_url_objects.dest_url.id
            type = "Url"
        }
    }
    ips_policy = data.fmc_ips_policies.ips_policy.id
    syslog_config = data.fmc_syslog_alerts.syslog_alert.id
    new_comments = [ "New comment" ]
    depends_on = [
        fmc_access_rules.access_rule_1
    ]
}

resource "fmc_access_rules" "access_rule_3" {
    acp = fmc_access_policies.access_policy.id
    section = "mandatory"
    insert_before = 2 # Wont work as assumed since terraform does not 
    name = "Test rule 3"
    action = "allow"
    enabled = true
    enable_syslog = true
    syslog_severity = "alert"
    send_events_to_fmc = true
    log_files = false
    log_end = true
    source_zones {
        source_zone {
            id = data.fmc_security_zones.inside.id
            type =  data.fmc_security_zones.inside.type
        }
        # source_zone {
        #     id = data.fmc_security_zones.outside.id
        #     type =  data.fmc_security_zones.outside.type
        # }
    }
    destination_zones {
        destination_zone {
            id = data.fmc_security_zones.outside.id
            type =  data.fmc_security_zones.outside.type
        }
    }
    source_networks {
        source_network {
            id = data.fmc_network_objects.source.id
            type =  data.fmc_network_objects.source.type
        }
    }
    destination_networks {
        destination_network {
            id = data.fmc_network_objects.dest.id
            type =  data.fmc_network_objects.dest.type
        }
    }
    destination_ports {
        destination_port {
            id = data.fmc_port_objects.http.id
            type =  data.fmc_port_objects.http.type
        }
    }
    urls {
        url {
            id = fmc_url_objects.dest_url.id
            type = "Url"
        }
    }
    ips_policy = data.fmc_ips_policies.ips_policy.id
    syslog_config = data.fmc_syslog_alerts.syslog_alert.id
    new_comments = [ "New comment" ]
    depends_on = [
        fmc_access_rules.access_rule_2
    ]
}

output "new_fmc_access_policy" {
    value = fmc_access_policies.access_policy
}

output "new_fmc_access_rule_1" {
    value = fmc_access_rules.access_rule_1
}

output "new_fmc_access_rule_3" {
    value = fmc_access_rules.access_rule_3
}

data "fmc_devices" "device" {
    name = "ftd.adyah.cisco"
}

output "existing_device" {
    value = data.fmc_devices.device
}

resource "fmc_dynamic_object" "test" {
  name        = "DynamicObject"
  object_type = "IP"
  description = "testing terraform"
}

resource "fmc_dynamic_object" "test" {
  name        = "DynamicObject"
  object_type = "IP"
  description = "testing terraform"
}

resource "fmc_dynamic_object_mapping" "test" {
  dynamic_object_id =  fmc_dynamic_object.test.id
  mappings = ["1.1.1.1", "8.8.8.8", "4.4.4.4"]
}


data "fmc_devices" "ftd" {
    name = "ftd.adyah.cisco"
}

resource "fmc_ftd_deploy" "ftd" {
    device = data.fmc_devices.ftd.id
    ignore_warning = false
    force_deploy = false
}
data "fmc_security_zones" "inside" {
    name = "inside"
}

data "fmc_security_zones" "outside" {
    name = "outside"
}

data "fmc_host_objects" "CUCMPub" {
  name = "CUCM-Pub"
}

data "fmc_network_objects" "private" {
    name = "VLAN825-Private"
}

data "fmc_network_objects" "public" {
    name = "VLAN825-Public"
}

resource "fmc_ftd_nat_policies" "nat_policy" {
    name = "Terraform NAT Policy"
    description = "New NAT policy!"
}

resource "fmc_ftd_manualnat_rules" "new_rule" {
    nat_policy = fmc_ftd_nat_policies.nat_policy.id
    description = "Testing Manual NAT priv-pub"
    nat_type = "static"
    source_interface {
        id = data.fmc_security_zones.inside.id
        type = data.fmc_security_zones.inside.type
    }
    destination_interface {
        id = data.fmc_security_zones.outside.id
        type = data.fmc_security_zones.outside.type
    }
    original_source {
        id = data.fmc_network_objects.public.id
        type = data.fmc_network_objects.public.type
    }
    translated_destination {
        id = data.fmc_network_objects.public.id
        type = data.fmc_network_objects.public.type
    }
    interface_in_original_destination = true
    interface_in_translated_source = true
    ipv6 = true
}

resource "fmc_ftd_manualnat_rules" "new_rule_after" {
    nat_policy = fmc_ftd_nat_policies.nat_policy.id
    description = "Testing Manual NAT priv-pub"
    nat_type = "static"
    section = "after_auto"
    source_interface {
        id = data.fmc_security_zones.inside.id
        type = data.fmc_security_zones.inside.type
    }
    destination_interface {
        id = data.fmc_security_zones.outside.id
        type = data.fmc_security_zones.outside.type
    }
    original_source {
        id = data.fmc_network_objects.public.id
        type = data.fmc_network_objects.public.type
    }
    translated_destination {
        id = data.fmc_network_objects.public.id
        type = data.fmc_network_objects.public.type
    }
    interface_in_original_destination = true
    interface_in_translated_source = true
    ipv6 = true
}

resource "fmc_ftd_manualnat_rules" "new_rule_before_1" {
    nat_policy = fmc_ftd_nat_policies.nat_policy.id
    description = "Testing Manual NAT before priv-pub"
    nat_type = "static"
    section = "before_auto"
    target_index = 1
    source_interface {
        id = data.fmc_security_zones.inside.id
        type = data.fmc_security_zones.inside.type
    }
    destination_interface {
        id = data.fmc_security_zones.outside.id
        type = data.fmc_security_zones.outside.type
    }
    original_source {
        id = data.fmc_network_objects.public.id
        type = data.fmc_network_objects.public.type
    }
    translated_destination {
        id = data.fmc_host_objects.CUCMPub.id
        type = data.fmc_host_objects.CUCMPub.type
    }
    interface_in_original_destination = true
    interface_in_translated_source = true
    ipv6 = true
}

output "new_ftd_nat_policy" {
    value = fmc_ftd_nat_policies.nat_policy
}

output "new_ftd_manualnat_rule" {
    value = fmc_ftd_manualnat_rules.new_rule
}

output "new_ftd_manualnat_rule_after" {
    value = fmc_ftd_manualnat_rules.new_rule_after
}

output "new_ftd_manualnat_rule_before_1" {
    value = fmc_ftd_manualnat_rules.new_rule_before_1
}

resource "fmc_ftd_nat_policies" "nat_policy" {
    name = "Terraform NAT Policy"
    description = "New NAT policy!"
}

output "new_ftd_nat_policy" {
    value = fmc_ftd_nat_policies.nat_policy
}

data "fmc_host_objects" "existing_host_1" {
  name = "CUCM-Pub"
}
resource "fmc_host_objects" "test_host_2" {
  name        = "terraform_test_host_2"
  value       = "1.1.1.2"
  description = "testing terraform change"
}

output "test_host_1" {
  value = fmc_host_objects.test_host_2
}

output "test_exiting_host" {
  value = data.fmc_host_objects.existing_host_1
}

resource "fmc_icmpv4_objects" "shbharti-icmpv4-5" {
  name        = "shbharti-icmpv4-5"
  icmp_type = "3"
  code  = 2
}

resource "fmc_icmpv4_objects" "shbharti-icmpv4-7" {
  name        = "shbharti-icmpv4-7"
  icmp_type = "3"
}

output "new_fmc_network_object_3" {
  value = fmc_icmpv4_objects.shbharti-icmpv4-5.id
}

data "fmc_network_objects" "PrivateVLAN" {
  name = "VLAN825-Private"
}

resource "fmc_network_objects" "PrivateVLANDR" {
  name        = "DRsite-VLAN"
  value       = data.fmc_network_objects.PrivateVLAN.value
  description = "testing terraform"
}

resource "fmc_network_group_objects" "TestPrivateGroup" {
  name = "TestPrivateGroup"
  description = "Testing groups"
  objects {
      id = data.fmc_network_objects.PrivateVLAN.id
      type = data.fmc_network_objects.PrivateVLAN.type
  }
  objects {
      id = fmc_network_objects.PrivateVLANDR.id
      type = fmc_network_objects.PrivateVLANDR.type
  }
  literals {
      value = "10.10.10.10"
      type = "Host"
  }
}

output "existing_fmc_network_object" {
  value = data.fmc_network_objects.PrivateVLAN
}

output "new_fmc_network_object" {
  value = fmc_network_objects.PrivateVLANDR
}

output "new_fmc_network_group_object" {
  value = fmc_network_group_objects.TestPrivateGroup
}

resource "fmc_port_objects" "shbharti_port_1" {
  name        = "shbharti_test_port_object_1"
  port        = "3943"
  protocol    = "TCP"
  description = "testing terraform"
  overridable = false
}

resource "fmc_icmpv4_objects" "shbharti-icmpv4-1" {
  name        = "shbharti-icmpv4-1"
  icmp_type = "3"
  code  = 2
}

resource "fmc_port_group_objects" "TestPortGroup" {
  name = "TestPortGroup"
  description = "Testing groups"
  objects {
      id = fmc_port_objects.shbharti_port_1.id
      type = fmc_port_objects.shbharti_port_1.type
  }
  objects {
      id = fmc_icmpv4_objects.shbharti-icmpv4-1.id
      type = fmc_icmpv4_objects.shbharti-icmpv4-1.type
  }
}

output "new_fmc_port_group_object" {
  value = fmc_port_group_objects.TestPortGroup
}
data "fmc_port_objects" "existing" {
  name = "DNS_over_TCP"
  port = "53"
}

# resource "fmc_port_objects" "jay_test_port_object_1" {
#   name        = "jay_test_port_object_1"
#   port        = "3943"
#   protocol    = "TCP"
#   description = "testing terraform"
#   overridable = false
# }

resource "fmc_port_objects" "similar" {
  name = "${data.fmc_port_objects.existing.name}-Test"
  port = data.fmc_port_objects.existing.port
  protocol = data.fmc_port_objects.existing.protocol
}

output "existing_port" {
  value = data.fmc_port_objects.existing
}

output "similar_port" {
  value = fmc_port_objects.similar
}

data "fmc_port_objects" "existing" {
  name = "DNS_over_TCP"
  port = "53"
}

# resource "fmc_port_objects" "jay_test_port_object_1" {
#   name        = "jay_test_port_object_1"
#   port        = "3943"
#   protocol    = "TCP"
#   description = "testing terraform"
#   overridable = false
# }

resource "fmc_port_objects" "similar" {
  name = "${data.fmc_port_objects.existing.name}-Test"
  port = data.fmc_port_objects.existing.port
  protocol = data.fmc_port_objects.existing.protocol
}

output "existing_port" {
  value = data.fmc_port_objects.existing
}

output "similar_port" {
  value = fmc_port_objects.similar
}