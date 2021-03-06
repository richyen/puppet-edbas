require 'puppet/provider/parsedfile'

Puppet::Type.type(:edbas_conf).provide(
  :parsed,
  :parent => Puppet::Provider::ParsedFile,
  :default_target => '/etc/edbas.conf',
  :filetype => :flat
) do
  desc "Set key/values in edbas.conf."

  text_line :comment, :match => /^\s*#/
  text_line :blank, :match => /^\s*$/

  record_line :parsed,
    :fields   => %w{name value comment},
    :optional => %w{comment},
    :match    => /^\s*([\w\.]+)\s*=?\s*(.*?)(?:\s*#\s*(.*))?\s*$/,
    :to_line  => proc { |h|

      # simple string and numeric values don't need to be enclosed in quotes
      if h[:value].is_a?(Numeric)
        val = h[:value].to_s
      else
        val = h[:value]
      end
      dontneedquote = val.match(/^(\d+.?\d+|\w+)$/)
      dontneedequal = h[:name].match(/^(include|include_if_exists)$/i)

      str =  h[:name].downcase # normalize case
      str += dontneedequal ? ' ' : ' = '
      str += "'" unless dontneedquote && !dontneedequal
      str += val
      str += "'" unless dontneedquote && !dontneedequal
      str += " # #{h[:comment]}" unless (h[:comment].nil? or h[:comment] == :absent)
      str
    },
    :post_parse => proc { |h|
      h[:name].downcase! # normalize case
      h[:value].gsub!(/(^'|'$)/, '') # strip out quotes
    }

end
