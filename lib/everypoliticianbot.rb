require 'everypoliticianbot/version'
require 'git'
require 'octokit'
require 'tmpdir'

module Everypoliticianbot
  def self.github
    @github ||= Octokit::Client.new(
      access_token: github_access_token
    )
  end

  def self.github_access_token
    @github_access_token ||= ENV.fetch('GITHUB_ACCESS_TOKEN')
  rescue KeyError
    abort 'Please set GITHUB_ACCESS_TOKEN in the environment before running'
  end

  # Mixin to provide a GitHub client and helpers.
  module Github
    def github
      Everypoliticianbot.github
    end

    def with_git_repo(repo_name, options)
      repo = github.repository(repo_name)
      branch = options.fetch(:branch, 'master')
      message = options.fetch(:message)
      with_tmp_dir do
        git = clone(clone_url(repo.clone_url), depth: options[:clone_depth])
        if git.branches["origin/#{branch}"]
          git.checkout(branch)
        else
          git.checkout(branch, new_branch: true)
        end
        yield
        git.add
        return unless git.status.changed.any? || git.status.added.any?
        git.commit(message)
        git.push('origin', branch)
      end
    end

    private

    def clone(url, options = {})
      @git ||= Git.clone(url, '.', options).tap do |g|
        g.config('user.name', github.login)
        g.config('user.email', github.emails.first[:email])
      end
    end

    def clone_url(uri)
      URI.parse(uri).tap do |repo_clone_url|
        repo_clone_url.user = github.login
        repo_clone_url.password = github.access_token
      end
    end

    def with_tmp_dir(&block)
      Dir.mktmpdir { |tmp_dir| Dir.chdir(tmp_dir, &block) }
    end
  end
end
