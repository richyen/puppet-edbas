# hash a string "PASSWORD()" function would do it
require 'digest/md5'

module Puppet::Parser::Functions
  newfunction(:edbas_password, :type => :rvalue, :doc => <<-EOS
    Returns the edbas password hash from the clear text username / password.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "edbas_password(): Wrong number of arguments " +
      "given (#{args.size} for 2)") if args.size != 2

    username = args[0]
    password = args[1]

    'md5' + Digest::MD5.hexdigest(password + username)
  end
end
