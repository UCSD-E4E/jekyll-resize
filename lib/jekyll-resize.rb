require "digest"
require "mini_magick"

module Jekyll
  module Resize
    CACHE_DIR = "cache/resize/"
    HASH_LENGTH = 32

    # Generate output image filename.
    def _dest_filename(src_path, dest_dir, resize_option, imageFormat)
      base_name = File.basename(src_path, File.extname(src_path))
      options_slug = resize_option.gsub(/[^\da-z]+/i, "")
      ext = imageFormat && !imageFormat.empty? ? ".#{imageFormat}" : File.extname(src_path)

      "#{base_name}_#{options_slug}#{ext}"
    end

    # Build the path strings.
    def _paths(repo_base, img_path, resize_option, imageFormat)
      src_path = File.join(repo_base, img_path)
      raise "Image at #{src_path} is not readable" unless File.readable?(src_path)

      dest_dir = File.join(repo_base, CACHE_DIR)

      dest_filename = _dest_filename(src_path, dest_dir, resize_option, imageFormat)

      dest_path = File.join(dest_dir, dest_filename)
      dest_path_rel = File.join(CACHE_DIR, dest_filename)

      return src_path, dest_path, dest_dir, dest_filename, dest_path_rel
    end

    # Determine whether the image needs to be written.
    def _must_create?(src_path, dest_path)
      !File.exist?(dest_path) || File.mtime(dest_path) <= File.mtime(src_path)
    end

    # Read, process, and write out as new image.
    def _process_img(src_path, dest_path, resize_option, imageFormat = nil, imageQuality = nil, crop_option = nil)
      image = MiniMagick::Image.open(src_path)

      puts "TEST"
      puts crop_option
      if crop_option.is_a?(String) && !crop_option.empty?
        image.crop crop_option
      end
      
      image.auto_orient
      image.resize resize_option
      image.strip
      


      if imageFormat.is_a?(String) && !imageFormat.empty?
        image.format(imageFormat)
      end
  
      if imageQuality.is_a?(Integer) && imageQuality.between?(1, 100)
        image.quality(imageQuality.to_s)
      end

      image.write dest_path
    end

    # Liquid tag entry-point.
    #
    # param source: e.g. "my-image.jpg"
    # param options: e.g. "800x800>"
    #
    # return dest_path_rel: Relative path for output file.
    def resize(source, options)
      raise "`source` must be a string - got: #{source.class}" unless source.is_a? String
      raise "`source` may not be empty" unless source.length > 0
      raise "`options` must be a string - got: #{options.class}" unless options.is_a? String
      raise "`options` may not be empty" unless options.length > 0

      site = @context.registers[:site]

      
      # Split the options string into individual components
      options_array = options.split(',')
      resize_option = options_array[0] # Always present
      imageFormat = options_array[1] # Optional
      imageQuality = options_array[2] ? options_array[2].to_i : nil # Optional
      crop_option = options_array[3] # Optional
     

      src_path, dest_path, dest_dir, dest_filename, dest_path_rel = _paths(site.source, source, resize_option, imageFormat)

      FileUtils.mkdir_p(dest_dir)

      if _must_create?(src_path, dest_path)
        puts options_array[3]
        puts options_array
        puts "Resizing '#{source}' to '#{dest_path_rel}' - using resize option: '#{resize_option}'#{", format: #{imageFormat}" if imageFormat}#{", quality: #{imageQuality}" if imageQuality}#{", crop: #{crop_option}" if crop_option}"

        _process_img(src_path, dest_path, resize_option, imageFormat, imageQuality, crop_option)

        site.static_files << Jekyll::StaticFile.new(site, site.source, CACHE_DIR, dest_filename)
      end

      File.join(site.baseurl, dest_path_rel)
    end
  end
end

Liquid::Template.register_filter(Jekyll::Resize)
