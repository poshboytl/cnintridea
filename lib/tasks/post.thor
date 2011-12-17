class Post < Thor
  include ::Thor::Shell
  include ::Thor::Actions

  POST_DIR = "source/_posts/"
  STASH_DIR = "source/_stash/"
  GALLERY_DIR = "source/gallery/"

  source_root '.'
  
  desc "new post-slug [--title STRING] [--author STRING]", "Add a new post with the slug"
  method_options title: :string, author: :string
  def new(slug)
    now = Time.now
    creation_date = now.strftime("%Y-%m-%d")
    creation_time = now.strftime("%Y-%m-%d %H:%M")
    file_name = "#{POST_DIR}#{creation_date}-#{slug}.markdown"
    title = options[:title] || slug.split('-').map(&:capitalize).join(' ')
    create_file(file_name) do
      <<MD
---
date: #{creation_time}
updated_at: <#{creation_time}>
title: #{title}
author: #{options[:author]}
layout: post
gallery: #{creation_date}-#{slug}
comment: true
categories:
---
MD
    end
    empty_directory "#{GALLERY_DIR}#{creation_date}-#{slug}"
  end

  desc "list [keyword]", "list posts"
  def list(keyword = nil)
    find_posts(keyword).each { |p| puts File.basename(p) }
  end
  
  desc "delete keyword", "Delete selected post which slug matches the keyword"
  def delete(keyword = nil)
    select_post(keyword) do |post|
      if post
        if yes?("Really delete #{File.basename(post)} (yes/no)?")
          remove_file post
        end
      end
    end
  end

  desc "isolate keyword", "Move all other posts than the selected one"
  def isolate(keyword = nil)
    select_post(keyword) do |selected|
      empty_directory STASH_DIR
      # FileUtils.mkdir(stash_dir) unless File.exist?(stash_dir)
      Dir.glob("#{POST_DIR}*.*") do |post|
        destination = STASH_DIR + File.basename(post)
        if post != selected
          copy_file post, destination
          remove_file post
        end
      end
    end
  end

  desc "integrate", "Move all posts back into posts directory"
  def integrate
    Dir.glob("#{STASH_DIR}*.*") do |post|
      destination = POST_DIR + File.basename(post)
      copy_file post, destination
      remove_file post
    end
  end

  no_tasks do
    def find_posts(keyword)
      if keyword.nil? || keyword.empty?
        glob = '*'
      else
        glob = "*#{keyword}*"
      end
      Dir[POST_DIR + glob].find_all { |f| File.file?(f) }
    end

    def select_post(keyword)
      posts = find_posts(keyword)
      if posts.empty?
        yield nil
        return
      end

      post = posts.first
      if posts.length > 1
        table = posts.each_with_index.map{ |p,i| [i+1,File.basename(p)] }

        print_table table
        puts

        answer = ask("Which one? [q to quit]", :yellow)
        if answer.downcase == 'q'
          post = nil
        else
          post = posts[answer.to_i-1] rescue nil
        end
      end

      yield post
    end
  end
end
