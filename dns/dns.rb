#coding: utf-8
require 'fiber'

module Tacape
  module Tools
    class Dns < Thor
      include Tacape::Tools::Helpers::JsonConfig
      include Tacape::Tools::Helpers::OsSupport
      namespace 'dns'

      C_MARK='✓'
      X_MARK='✘'
      
      def initialize(*args)
        super
        @os_support=[Tacape::Os::Fedora,Tacape::Os::Osx]
        check_os_support
        @config_file="#{@current_os.config_folder}/dns.json"
        @config_template={
          'default_names_file'=>"#{ENV['HOME']}/names.txt",
          'default_output_file'=>"#{ENV['HOME']}/output.txt",
          'default_suffixes'=>['.com','.io']
        }
      end

      desc 'check_names NAMES_FILE OUTPUT_FILE',I18n.t('tools.dns.check_names.desc')
      def check_names(names_file=nil,output_file=nil)
        load_config

        names_file=@config['default_names_file'] if names_file==nil
        output_file=@config['default_output_file'] if output_file==nil
        suffixes=@config['default_suffixes']

        names = get_names(names_file)

        puts names.inspect
        `rm #{output_file}`
        output = File.new(output_file,'w')

        search_names(output)

        output.close
      end

      private
      def get_names(names_file)
        file = File.read(names_file)
        names = file.split("\n")
        clear_names = []
        names.each do |n|
          clear_names.push(n.gsub("\r",'').gsub(' ',''))
        end
        return clear_names
      end

      private
      def search_names(output)
        names.each do |n|
          if n!=nil && n!=''
            #puts n.inspect
            all_available=true
            print_string = "#{n.upcase} \t -> "
            suffixes.each do |s|
              result = `nslookup #{n.downcase}#{s}`.split("\n").last
              if result.include? 'NXDOMAIN'
                print_string+="[#{s}:#{C_MARK}] "
              else
                print_string+="[#{s}:#{X_MARK}] "
                all_available=false
              end
            end
            if all_available
              overall=C_MARK
            else
              overall=X_MARK
            end
            output_string = "#{overall} : #{print_string}"
            puts output_string
            output.puts output_string 
          else
            puts "Ignoring blank line..."
          end
        end
      end

    end
  end

  #Redefining the Cli to use this Tool
  class Cli < Thor
    desc 'dns','Tacape Tool for DNS things'
    subcommand 'dns', Tools::Dns
  end
end