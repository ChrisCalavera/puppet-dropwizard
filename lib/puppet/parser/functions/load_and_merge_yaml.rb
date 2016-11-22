module Puppet::Parser::Functions
  newfunction(:load_and_merge_yaml, :type => :rvalue) do |args|

    raise(Puppet::ParseError, "load_and_merge_yaml(): Wrong number of arguments " +
      "given (#{args.size}/1)") if args.size > 2 and args.size < 1

    require 'yaml'

    yaml_files = args[0]
    # Check that the first parameter is an array
    unless yaml_files.is_a?(Array)
      raise(Puppet::ParseError, 'load_and_merge_yaml(): Requires an array to work with')
    end

    result = Hash.new
    yaml_files.each do |yaml_file|
      if File.exists?(yaml_file)
        begin
          loaded_hash = YAML::load_file(yaml_file)

          # If the value was empty string, skip it.
          next if loaded_hash.is_a? String and loaded_hash.empty? # empty string is synonym for puppet's undef

          # If the value was not a hash, skip it.
          unless loaded_hash.is_a?(Hash)
            raise Puppet::ParseError, "load_and_merge_yaml(): unexpected argument type #{loaded_hash.class}, only expects hash arguments"
          end

          result = result.merge(loaded_hash)
        end
      else
        warning("Can't load '#{yaml_file}' File does not exist!")
      end
    end
    return(result)
  end
end