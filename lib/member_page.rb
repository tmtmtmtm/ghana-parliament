# frozen_string_literal: true

require 'scraped'

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :id do
    url[/(\d+)$/, 1]
  end

  field :name do
    box.at_css('h4').text.sub('HON.', '').tidy
  end

  field :image do
    box.at_css('img @src').text
  end

  field :constituency do
    box.css('center').text[/MP for (.*)/, 1].tidy.chomp('.')
  end

  field :party do
    record_for('Party').split('(').first.tidy
  end

  field :religion do
    record_for('Religion')
  end

  field :birth_date do
    datefrom(record_for('Date of Birth'))
  end

  field :email do
    record_for('Email')
  end

  private

  def box
    noko.css('#content')
  end

  def record_for(text)
    node = box.xpath('//b[contains(text(),"%s")]/following::td' % text).first or return
    node.text.tidy
  end

  def datefrom(str)
    return if str.empty?
    date = Date.parse(str)
    return if date.year < 1900 # some records broken upstream
    date
  end
end
