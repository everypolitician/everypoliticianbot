**:warning: Deprecated: Please use [with_git_repo](https://github.com/everypolitician/with_git_repo) instead**

# Everypoliticianbot

Contains shared ruby code that's used in various places in the [EveryPolitician project](http://everypolitician.org).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'everypoliticianbot', github: 'everypolitician/everypoliticianbot'
```

And then execute:

    $ bundle

## Usage

To use the GitHub client first set the `GITHUB_ACCESS_TOKEN` environment variable, then you can access an [Octokit](http://octokit.github.io/octokit.rb/) instance:

```ruby
Everypoliticianbot.github
```

To manipulate a git repository:

```ruby
class MyClass
  include Everypoliticianbot::Github

  def perform
    options = { branch: 'new-things', message: 'Added new things' }
    with_git_repo('everypolitician/viewer-sinatra', options) do
      File.write('new.txt', "This is a new file\n"
    end
  end
end
```

The above code will clone the [everypolitician/viewer-sinatra](https://github.com/everypolitician/viewer-sinatra) repository, checkout the given branch, in this case `new-things`, then it will run the block with the current working directory set to the repository. When the block has finished it will then commit the changes, if there are any, using the provided message and push the result back to GitHub.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/everypoliticianbot.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

