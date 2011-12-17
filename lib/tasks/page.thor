class Page < Thor
  include ::Thor::Shell
  include ::Thor::Actions

  PAGE_DIR = "source/"

  desc "new page-slug [--title STRING]", "Add a new page with the slug"
  method_options title: :string
  def new(slug)
    now = Time.now
    creation_time = now.strftime("%Y-%m-%d %H:%M")
    page_dir = [PAGE_DIR]
    if slug.downcase =~ /(^.+\/)?(.+)/
      filename, dot, extension = $2.rpartition('.').reject(&:empty?)
      title = options[:title] || filename.split('-').map(&:capitalize).join(' ')
      page_dir.concat($1.downcase.sub(/^\//, '').split('/')) unless $1.nil?  # Add path to page_dir Array
      if extension.nil?
        page_dir << filename
        filename = "index"
      end
      extension ||= "markdown"
      page_dir = page_dir.join('/')
      filename = filename.downcase

      file = "#{page_dir}/#{filename}.#{extension}"
      create_file(file) do
        <<MD
---
date: #{creation_time}
updated_at: <#{creation_time}>
title: #{title}
layout: page
comments: true
sharing: false
footer: true
---
MD
      end
    else
      error "Syntax error: #{slug} contains unsupported characters"
    end
  end
end
