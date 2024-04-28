# Jekyll Resize 🖼 🤏 🔬
> Simple image resizing filter for Jekyll 3 and 4

[![GitHub tag](https://img.shields.io/github/tag/Sean1572/jekyll-resize)](https://github.com/Sean1572/jekyll-resize/tags/ "Go to GitHub tags")
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](#license "Go to License section")

[![Made with Ruby](https://img.shields.io/badge/Ruby->=2.6-blue.svg?logo=ruby)](https://ruby-lang.org "Go to Ruby homepage")
[![Jekyll](https://img.shields.io/badge/jekyll->=3.3,_4.x-blue.svg?logo=jekyll)](https://jekyllrb.com "Go to Jekyll homepage")


## Sample usage

Add the plugin gem to your Gemfile as below, then install it with Bundler.

```ruby
group :jekyll_plugins do
  gem "jekyll-resize", git: "https://github.com/Sean1572/jekyll-resize"
end
```

The `resize` filter will be available in Liquid (in your Markdown and HTML) so you can use it for a JPEG or PNG file.

Here we resize an image to max width and max height of 800 pixels and converting it to webp with an image quality of 80:

```liquid
{{ "my-image.png" | resize: "800x800>,webp,80" }}
```

Here we resize an image to max width and max height of 800 pixels with an image quality of 80:

```liquid
{{ "my-image.png" | resize: "800x800>,,80" }}
```

Here we resize an image to max width and max height of 800 pixels and converting it to webp:

```liquid
{{ "my-image.png" | resize: "800x800>,webp" }}
```

Here we resize an image to max width and max height of 800 pixels:

```liquid
{{ "my-image.png" | resize: "800x800>" }}
```

Here we crop the image to only show the frist 50% (see geomgery for imagemagick for all possible options):

```liquid
{{ "my-image.png" | resize: "800x800>,webp,80, 50%X100%" }}
```
**Note crop occurs before resizing**. The reason crop is the last parameter is to keep it compatible with previous fork

That takes care of:

- _generating_ the reduced image.
- providing a _link_ to the file.

See the docs linked below for a more detailed example using the filter with an HTML `img` tag.


## Documentation
> Why you should use this plugin and how to install and use it in a Jekyll project

<div align="center">

[![View - Documentation](https://img.shields.io/badge/View-Documentation-blue?style=for-the-badge)](/docs/ "Go to docs")

</div>


## Contributing

See [Contributing](/CONTRIBUTING.md) doc.


## License

Released under [MIT](/LICENSE) by [@Sean1572](https://github.com/Sean1572).

Original license - [MIT](/LICENSE-source).

See [Fork notes](/docs/fork-notes.md) for more details and a list of improvements this fork provides.
