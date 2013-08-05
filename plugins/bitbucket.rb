#!/usr/bin/env ruby
require 'bitbucket_rest_api'
require 'bitbucket-api-extension'

class Cinch::Plugins::Bitbucket
  include Cinch::Plugin

  match(/(prs|pull)/)

  def execute(m)
    m.reply("Getting pull requests, give me a moment...")
    prs = each_open_pull_request do |repo, pull|
      m.reply("PR for #{repo.name} by #{pull.author}: #{pull.title} (#{pull.request_page_url}")
    end
    m.reply("Pull request summary: #{prs.length} open")
  end

private
  def bitbucket
    @bitbucket ||= BitBucket.new({
      login: config[:username],
      password: config[:password]
    })
  end

  def invalidate_cache!
    @bitbucket = nil
    @repos = nil
  end

  def repos
    @repos ||= bitbucket.repos.all.select { |r| !r.is_fork }
  rescue
    invalidate_cache!
    retry
  end

  def each_open_pull_request
    repos.each_with_object([]) do |repo, prs|
      # initialize
      account = BitbucketApiExtension::Account.new(user_id: config[:username],
                                                   user_password: config[:password])
      project = BitbucketApiExtension::Project.new(name: repo.slug,
                                                   organization_name: config[:username])
      api = BitbucketApiExtension::Api.new(project, account)

      # fetch pull request list
      pulls = api.pull_requests
      if pulls.any?
        unless pulls.one? && pulls.first.id == nil
          prs.concat pulls
          pulls.each do |pull|
            yield repo, pull
          end
        end
      end
    end
  end
end

