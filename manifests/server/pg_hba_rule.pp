# This resource manages an individual rule that applies to the file defined in
# $target. See README.md for more details.
define edbas::server::pg_hba_rule(
  $type = 'local',
  $database = 'all',
  $user = 'all',
  $auth_method = 'trust',
  $address     = undef,
  $description = 'default HBA rule',
  $auth_option = undef,
  $order       = '150',

  # Needed for testing primarily, support for multiple files is not really
  # working.
  $target             = $edbas::server::pg_hba_conf_path,
  $edbas_version = $edbas::server::_version
) {

  #Allow users to manage pg_hba.conf even if they are not managing the whole edbas instance
  if !defined( 'edbas::server' ) {
    $manage_pg_hba_conf = true
  }
  else {
    $manage_pg_hba_conf = $edbas::server::manage_pg_hba_conf
  }

  if $manage_pg_hba_conf == false {
      fail('edbas::server::manage_pg_hba_conf has been disabled, so this resource is now unused and redundant, either enable that option or remove this resource from your manifests')
  } else {
    validate_re($type, '^(local|host|hostssl|hostnossl)$',
    "The type you specified [${type}] must be one of: local, host, hostssl, hostnosssl")

    if($type =~ /^host/ and $address == undef) {
      fail('You must specify an address property when type is host based')
    }

    $allowed_auth_methods = $edbas_version ? {
      '9.5' => ['trust', 'reject', 'md5', 'password', 'gss', 'sspi', 'ident', 'peer', 'ldap', 'radius', 'cert', 'pam'],
      '9.4' => ['trust', 'reject', 'md5', 'password', 'gss', 'sspi', 'ident', 'peer', 'ldap', 'radius', 'cert', 'pam'],
      '9.3' => ['trust', 'reject', 'md5', 'password', 'gss', 'sspi', 'krb5', 'ident', 'peer', 'ldap', 'radius', 'cert', 'pam'],
      default => ['trust', 'reject', 'md5', 'password', 'gss', 'sspi', 'krb5', 'ident', 'peer', 'ldap', 'radius', 'cert', 'pam', 'crypt']
    }
    notice("Vibhor Debug => variable allowed_auth_methods is ${allowed_auth_methods}")

    $auth_method_regex = join(['^(', join($allowed_auth_methods, '|'), ')$'],'')
    validate_re($auth_method, $auth_method_regex,
    join(["The auth_method you specified [${auth_method}] must be one of: ", join($allowed_auth_methods, ', ')],''))

    # Create a rule fragment
    $fragname = "pg_hba_rule_${name}"
    concat::fragment { $fragname:
      target  => $target,
      content => template('edbas/pg_hba_rule.conf'),
      order   => $order,
    }
  }
}