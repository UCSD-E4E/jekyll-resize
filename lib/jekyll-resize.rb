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
      if src_path.include?(CACHE_DIR)
        src_path = File.join(repo_base, CACHE_DIR + src_path.split("/")[-1])
      end  
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

    # automatically crops an image
    def _crop_img(image, crop_option, gravity_option = nil) 
      puts crop_option, gravity_option
      if crop_option.is_a?(String) && !crop_option.empty?
        if !crop_option.include?("+")
          raise "For crop, use the format {geomerty}+{x_point}+{y_point} location in image!!!"
        end 
        if gravity_option.is_a?(String) && !gravity_option.empty?
          image.combine_options do |c|
            c.gravity gravity_option
            c.crop crop_option
          end
        else
          image.crop crop_option
        end
      end
      image
    end

    # automatically resizes an image
    def _resize_img(image, resize_option)
      if resize_option.is_a?(String) && !resize_option.empty?
        image.resize resize_option
      end
      image
    end

    # automatically resizes an image
    def _format_img(image, imageFormat)
      if imageFormat.is_a?(String) && !imageFormat.empty?
        image.format(imageFormat)
      end
      image
    end

     # automatically sets image quality of an image
     def _quality_img(image, imageQuality)
      imageQuality = imageQuality.to_i
      if imageQuality.is_a?(Integer) && imageQuality.between?(1, 100)
        image.quality(imageQuality.to_s)
      end
      image
    end

    # Read, process, and write out as new image.
    def _process_img(src_path, dest_path, resize_option = nil, imageFormat = nil, imageQuality = nil, crop_option = nil)
      image = MiniMagick::Image.open(src_path)
      image.auto_orient

      image = _crop_img(image, crop_option)
      image = _resize_img(image, resize_option)
      image = _format_img(image, imageFormat)
      image = _quality_img(image, imageQuality)
      
      image.strip
      image.write dest_path
    end

    def _raise_bad_inputs(source, options)
      raise "`source` must be a string - got: #{source.class}" unless source.is_a? String
      raise "`source` may not be empty" unless source.length > 0
      raise "`options` must be a string - got: #{options.class}" unless options.is_a? String
      raise "`options` may not be empty" unless options.length > 0
    end
    # Liquid tag entry-point.
    #
    # param source: e.g. "my-image.jpg"
    # param options: e.g. "800x800>"
    #
    # return dest_path_rel: Relative path for output file.
    def resize(source, options)
      _raise_bad_inputs(source, options)
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
        puts "Resizing '#{source}' to '#{dest_path_rel}' - using resize option: '#{resize_option}'#{", format: #{imageFormat}" if imageFormat}#{", quality: #{imageQuality}" if imageQuality}#{", crop: #{crop_option}" if crop_option}"

        _process_img(src_path, dest_path, resize_option, imageFormat, imageQuality, crop_option)

        site.static_files << Jekyll::StaticFile.new(site, site.source, CACHE_DIR, dest_filename)
      end

      File.join(site.baseurl, dest_path_rel)
    end

    # Liquid tag entry-point.
    #
    # param source: e.g. "my-image.jpg"
    # param options: e.g. "webp, jpg, etc"
    #
    # return dest_path_rel: Relative path for output file.
    def format(source, options)
      _raise_bad_inputs(source, options)
      site = @context.registers[:site]
      puts source, options.include?("resize"), options

      src_path, dest_path, dest_dir, dest_filename, dest_path_rel = _paths(site.source, source, "", options)
      FileUtils.mkdir_p(dest_dir)

      if _must_create?(src_path, dest_path)
        puts "Reformating '#{source}' to '#{dest_path_rel}' - using resize option: #{", format: #{options}"}"

        image = MiniMagick::Image.open(src_path)
        image.auto_orient

        image = _format_img(image, options)
        
        image.strip
        image.write dest_path
        

        site.static_files << Jekyll::StaticFile.new(site, site.source, CACHE_DIR, dest_filename)
      end

      File.join(site.baseurl, dest_path_rel)
    end


    # Liquid tag entry-point.
    #
    # param source: e.g. "my-image.jpg"
    # param options: e.g. "300x300"
    #
    # return dest_path_rel: Relative path for output file.
    def crop(source, options)
      _raise_bad_inputs(source, options)
      site = @context.registers[:site]

      options_array = options.split(',')
      crop_option = options_array[0] # Always present
      gravity_option = options_array[1] # Optional

      src_path, dest_path, dest_dir, dest_filename, dest_path_rel = _paths(site.source, source, "cropped", nil)
      FileUtils.mkdir_p(dest_dir)

      if _must_create?(src_path, dest_path)
        puts "Reformating '#{source}' to '#{dest_path_rel}' - using #{"crop: #{crop_option}"}"
        puts src_path, dest_path
        image = MiniMagick::Image.open(src_path)
        image.auto_orient

        puts image
        image = _crop_img(image, crop_option, gravity_option)
        puts image
        #image.strip
        puts dest_path
        image.write dest_path
        

        site.static_files << Jekyll::StaticFile.new(site, site.source, CACHE_DIR, dest_filename)
      end

      File.join(site.baseurl, dest_path_rel)
    end

    # Liquid tag entry-point.
    #
    # param source: e.g. "my-image.jpg"
    # param options: e.g. "webp, jpg, etc"
    #
    # return dest_path_rel: Relative path for output file.
    def quality(source, options)
      _raise_bad_inputs(source, options)
      site = @context.registers[:site]

      src_path, dest_path, dest_dir, dest_filename, dest_path_rel = _paths(site.source, source, options, nil)
      FileUtils.mkdir_p(dest_dir)

      if _must_create?(src_path, dest_path)
        puts "Reformating '#{source}' to '#{dest_path_rel}' - using resize option: #{", quality: #{options}"}"

        image = MiniMagick::Image.open(src_path)
        image.auto_orient

        image = _quality_img(image, options)
        
        image.strip
        image.write dest_path
        

        site.static_files << Jekyll::StaticFile.new(site, site.source, CACHE_DIR, dest_filename)
      end

      File.join(site.baseurl, dest_path_rel)
    end
  end
end

Liquid::Template.register_filter(Jekyll::Resize)
