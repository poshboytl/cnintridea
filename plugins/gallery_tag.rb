require File.expand_path("../image_tag", __FILE__)

module Jekyll

  class GalleryTag < ImageTag
    @img = nil

    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      img = @img.dup
      page = context.environments.first['page']
                                   # remove leading slash
      gallery = page['gallery'] || page['id'][1..-1].gsub('/', '-')
      img['src'] = '/gallery/' + gallery + img['src']
      if img
        "<img #{img.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")}>"
      else
        "Error processing input, expected syntax: {% img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end
end

Liquid::Template.register_tag('gimg', Jekyll::GalleryTag)
