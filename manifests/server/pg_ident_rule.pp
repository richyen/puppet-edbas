# This resource manages an individual rule that applies to the file defined in
# $target. See README.md for more details.
define edbas::server::pg_ident_rule(
  $map_name,
  $system_username,
  $database_username,
  $description = 'none',
  $order       = '150',

  # Needed for testing primarily, support for multiple files is not really
  # working.
  $target      = $edbas::server::pg_ident_conf_path
) {

  if $edbas::server::manage_pg_ident_conf == false {
      fail('edbas::server::manage_pg_ident_conf has been disabled, so this resource is now unused and redundant, either enable that option or remove this resource from your manifests')
  } else {

    # Create a rule fragment
    $fragname = "pg_ident_rule_${name}"
    concat::fragment { $fragname:
      target  => $target,
      content => template('edbas/pg_ident_rule.conf'),
      order   => $order,
    }
  }
}
