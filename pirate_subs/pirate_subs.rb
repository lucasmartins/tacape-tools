#coding: utf-8
require 'fiber'
require 'open-uri'
require 'nokogiri'

module Tacape
  module Tools
    class PirateSubs < Thor
      include Tacape::Tools::Helpers::JsonConfig
      include Tacape::Tools::Helpers::OsSupport
      namespace 'pirate_subs'

      C_MARK='✓'
      X_MARK='✘'
      
      def initialize(*args)
        super
        @os_support=[Tacape::Os::Fedora,Tacape::Os::Osx]
        check_os_support
        @config_file="#{@current_os.config_folder}/pirate_subs.json"
        @config_template={
          'series'=>{
              'american dad' => {
                13 => [4,5,6]
              }
            },
          'default_download_folder'=>"#{ENV['HOME']}/Downloads",
          'trusted_sources'=>['ettv']
        }
      end

      desc 'download_new_episodes', 'You know what this does right?'
      def download_new_episodes
        @config['series'].each do |series_name, season_episodes_hash|
          season_episodes_hash.each do |season, episodes|
            puts "#{series_name}, #{season}, #{episodes.sort.last}"
            next_episode = episodes.sort.last
          end
        end
        last_downloaded_episode = @config['default_names_file'] 
      end

      desc 'search NAMES_FILE OUTPUT_FILE',I18n.t('tools.pirate_subs.check_names.desc')
      def check_names(names_file=nil,output_file=nil)
        load_config

        names_file=@config['default_names_file'] if names_file==nil
        output_file=@config['default_output_file'] if output_file==nil
        suffixes=@config['default_suffixes']

        names = get_names(names_file)

        puts names.inspect
        `rm #{output_file}`
        output = File.new(output_file,'w')

        search_names(names,suffixes,output)

        output.close
      end

      private

      def download_episode(name, season=1, episode=1)
        if season<10
          season = "0#{season}"
        end
        if episode<10
          episode = "0#{episode}"
        end
        name = "#{name} S#{season}E#{episode}"
        name = name.gsub(' ', '%20')
        page = Nokogiri::HTML(open("https://thepiratebay.org/search/#{name}/0/99/0"))
        first_result = page.css("#searchResult a[title='Download this torrent using magnet']").first
        magnet_link = first_result['href']
        IO.popen("aria2c #{magnet_link}") do |io|
          puts io.read
        end
      end

    end
  end

  #Redefining the Cli to use this Tool
  class Cli < Thor
    desc 'pirate_subs','Tacape Tool for using piratebay like a boss'
    subcommand 'pirate_subs', Tools::Dns
  end
end