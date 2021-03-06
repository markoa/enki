#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/config/environment.rb'
require 'rexml/document'

system('rake db:drop')
system('rake db:migrate')

doc = REXML::Document.new(File.read('wordpress.xml'))
doc.elements.each('rss/channel/item') do |item|
  next if item.elements['wp:status'].text != 'publish'

  title = item.elements['title'].text
  date = Time.parse(item.elements['pubDate'].text)
  body = item.elements['content:encoded'].text
  type = item.elements['wp:post_type'].text

  next if not title
  next if not body

  if type == 'post'
    p = Post.new
    p.title = title
    p.published_at = date
    p.created_at = date
    p.updated_at = date
    p.edited_at = date
    p.body = body
    p.generate_slug
    p.save!

    item.elements.each('wp:comment') do |comment|
      next if comment.elements['wp:comment_type'].text == 'pingback'

      author = comment.elements['wp:comment_author'].text

      author_email = comment.elements['wp:comment_author_email'].text
      author_email ||= ""

      author_url = comment.elements['wp:comment_author_url'].text
      author_url ||= ""

      date = Time.parse(comment.elements['wp:comment_date_gmt'].text)
      content = comment.elements['wp:comment_content'].text

      c = Comment.new :author => author, :author_url => author_url, :author_email => author_email,
                      :body => content, :created_at => date, :updated_at => date
      p.comments << c
      p.save!
    end
  else
    p = Page.new
    p.title = title
    p.created_at = date
    p.updated_at = date
    p.body = body
    p.generate_slug
    p.save!
  end
end
