require 'everypoliticianbot/version'
require 'git'

module Everypoliticianbot
  # Mixin to provide a GitHub client and helpers.
  module Github
    def github
      @github ||= Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    end

    def with_git_repo(repo_name, options)
      repo = github.repository(repo_name)
      branch = options.fetch(:branch, 'master')
      message = options.fetch(:message)
      with_tmp_dir do
        git = clone(clone_url(repo.clone_url))
        git.branch(branch).checkout
        yield
        return unless git.status.changed.any? || git.status.untracked.any?
        git.add
        git.commit(message)
        git.push
      end
    end

    def clone(url)
      @git ||= Git.clone(url, '.').tap do |g|
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
