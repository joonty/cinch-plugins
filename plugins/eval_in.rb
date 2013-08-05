# encoding: utf-8

require 'cinch'
require 'httparty'
require 'nokogiri'

class Cinch::Plugins::EvalIn
  include Cinch::Plugin

  set :prefix, /^>>/

  match(/(\S*)? (.*)/)
  def execute(m, lang, code)
    lang = lang.length > 0 ? lang.to_sym : :ruby
    res = API.new.evaluate(lang, code)
    m.reply "#{res.url} >> #{res.output}"
  rescue => e
    m.reply "eval error >> #{e.message}"
  end

  class NokogiriParser < HTTParty::Parser
    SupportedFormats.merge!('text/html' => :html)

    def html
      Nokogiri::HTML(body)
    end
  end

  class Result
    attr_reader :output, :url

    def initialize(response)
      @output = response.css('.highlighttable').
        first.
        next_element.
        next_element.
        text.chomp("\n")
      @url = response.request.last_uri
    end

    def to_s
      output
    end
  end

  class UnknownLangError < StandardError; end

  class API

    include HTTParty
    base_uri 'https://eval.in'
    parser NokogiriParser

    OPTIONS = {
      :body => {
        :lang => 'ruby/mri-2.0.0',
        :execute => "on",
        :input => "",
        :utf8 => "λ"
      },
      :headers => {
        'User-Agent' => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.52 Safari/537.36"
      }
    }

    LANGS = {
      ruby: "ruby/mri-2.0.0",
      ruby19: "ruby/mri-1.9.3",
      javascript: "javascript/node-0.8.8",
      php: "php/php-5.4.6",
      perl: "perl/perl-5.16.1",
      python: "python/cpython-2.7.3",
      python3: "python/cpython-3.2.3",
    }

    def evaluate(lang, code)
      LANGS.has_key?(lang) or \
        raise UnknownLangError, "Unknown language #{lang}"

      options = OPTIONS.dup
      options[:body][:lang] = LANGS.fetch lang
      options[:body][:code] = code
      Result.new self.class.post('/', options)
    end
  end
end
