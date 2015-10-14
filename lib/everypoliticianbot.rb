require 'everypoliticianbot/version'

module Everypoliticianbot
  # Mixin to provide a GitHub client and helpers.
  module Github
    class SystemCallFail < StandardError; end

    def github
      @github ||= Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    end

    def with_git_repo(repo_name, options)
      repo = github.repository(repo_name)
      branch = options.fetch(:branch, 'master')
      with_tmp_dir do |dir|
        system("git clone --quiet #{clone_url(repo.clone_url)} #{dir}")
        system("git checkout -B #{branch}")
        yield
        git_commit_and_push(options.merge(branch: branch))
      end
    end

    def clone_url(uri)
      repo_clone_url = URI.parse(uri)
      repo_clone_url.user = github.login
      repo_clone_url.password = github.access_token
      repo_clone_url
    end

    def with_tmp_dir(&block)
      Dir.mktmpdir do |tmp_dir|
        Dir.chdir(tmp_dir, &block)
      end
    end

    def git_config
      @git_config ||= "-c user.name='#{github.login}' " \
        "-c user.email='#{github.emails.first[:email]}'"
    end

    def git_commit_and_push(options)
      branch_name = options.fetch(:branch)
      message = options.fetch(:message)
      system('git add .')
      system(%(git #{git_config} commit --quiet --message="#{message}" || true))
      system("git push --quiet origin #{branch_name}")
    end

    def system(*args)
      fail SystemCallFail, "#{args} #{$CHILD_STATUS}" unless Kernel.system(*args)
    end
  end
end
