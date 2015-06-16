require 'highline'


class String
  def blank?
    (self.nil? or self.strip=='')
  end
end

class SiteBuilder

  def setup

    # absolute path for all installed sites
    @scripts_path = File.expand_path(File.dirname(__FILE__))
    @sites_path = @scripts_path.split('/')[0..-2].concat(['sites']).join('/')


    if File.directory?(@sites_path)

      @site_names_already_taken = Dir.entries(@sites_path).select do |entry| 
        File.directory?("#{@sites_path}/#{entry}") and not ['.', '..'].include?(entry)
      end

      @site_paths_already_taken = @site_names_already_taken.map{|site_name| "#{@sites_path}/#{site_name}"}
      @site_names_already_taken = @site_names_already_taken.map{|site_name| site_name}

    else
      
      # creates site's folder if it is not there
      Dir.mkdir(@sites_path)
      @site_paths_already_taken = []
      @site_names_already_taken = []

    end

    @console = HighLine.new

    true

  end

  def print_log title, text

    puts "\n=== #{title}"
    puts ""

    if text
      puts text
      puts "\n\n"
    end

  end


  def print_error text
    puts "\n  !!! #{text}\n\n"
  end


  def create_site_folders

    text = "  names already taken\n"
    if @site_names_already_taken.size > 0
      
      @site_names_already_taken.sort.each_with_index do |name, index|
        text += "    #{index+1}. #{name}\n"
      end

    else

      text += "    . zero names taken"

    end

    self.print_log('CHOOSE YOUR SITE NAME', text)

    name = @console.ask("  name: ")

    if @site_names_already_taken.include?(name)
      self.print_error "Name already taken. Nothing was done."
    else

      @site_name = name
      @site_path = "#{@sites_path}/#{name}"
      @javascripts_path = "#{@site_path}/javascripts"
      @images_path = "#{@site_path}/images"
      @styles_path = "#{@site_path}/styles"

      # builds site's folder tree
      Dir.mkdir(@site_path)
      Dir.mkdir(@javascripts_path)
      Dir.mkdir(@images_path)
      Dir.mkdir(@styles_path)

      # creates necessary files
      self.create_site_html
      


    end

  end

  def create_site_html
    site_html = File.new("#{@site_path}/#{@site_name}.html", "w")
    site_html.puts File.open("#{@scripts_path}/templates/site.html", "r").read
    site_html.close
  end

end

site_builder = SiteBuilder.new
site_builder.setup
site_builder.create_site_folders

