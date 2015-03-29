# Creation

`creation` allows to create customized Rails applications for rapid prototyping,
with the exact integrations that we need. `creation` is an opinionated software,
and curretly, provides the following customizations:

- activates `rspec` for testing
- activates `pry-rails` for easy debugging
- adds home page using `high_voltage`
- adds twitter bootstrap for frontend framework via `bootstrap-generators`
- sets up and activates `activeadmin` for admin backend
- sets up, activates `pundit` for authorization, and adds certain policies
- sets up and activates `sidekiq` for background processing of queues

## Installation

Install it yourself as:

    $ gem install creation

## Usage

`creation` is based upon the default `rails` command, and adds the above
mentioned integrations/features on top of it. You can see a list of all such
features by running: `creation help`.

Note that, each of the above integrations/features have a corresponding command
to disable that particular feature. `--skip-bundle` should not be used with this
gem, however, the option still exists and works as expected, but several
customizations done by `creation` gem require gems to be bundled, and hence,
some of these customizations will be skipped.

### ActiveAdmin Integration

To create a new Rails application, along with `activeadmin`, `pundit`, frontend
with twitter bootstrap based layout, `sidekiq` and `rspec`, you can simply, run:

    creation new test_app

To create a new Rails application that uses root namespace for `activeadmin`
(i.e. `http://localhost:3000` will be the activeadmin instance), you can run:

    creation new test_app --admin-namespace=

To mount `actievadmin` to somewhere else (say: `/backend`), you can run:

    creation new test_app --admin-namespace=backend

This integration uses `user` model as default user for `activeadmin`. You can
change that to say `member` model, by running:

    creation new test_app --admin-user=member

### Other integrations

    # do not install sidekiq
    creation new test_app --skip-sidekiq

    # do not install rspec
    creation new test_app --skip-rspec

    # do not install pundit
    creation new test_app --skip-pundit

    # do not install active_admin
    creation new test_app --skip-active-admin

    # do not use twitter bootstrap
    creation new test_app --skip-bootstrap

    # do not create a home page
    creation new test_app --skip-home-page


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/console` for an interactive prompt that will allow you to experiment. Run
`bundle exec creation` to use the code located in this directory, ignoring other
installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release` to create a git tag for the version, push git commits
and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/creation/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
