# GitEraser

Welcome to GitEraser 🧹🧹! 

By this Gem, you'll Preview and Cleanup your branches that had been merged to master branch.

## TODOs

- [ ] Allow to skip different branches not just master.
- [ ] Allow deleting immediately flag --force.

## Installation

Execute this command:

    $ gem install git_eraser

## Usage

* Navigate to directory where you need to delete branches. (*NOTE:* MUST HAVE .git folder)
* Write this command to preview local branches: (Change --local to --origin to preview origin branches)


    $ git_eraser preview --local
    
* Write this command to delete local branches:  (Change --local to --origin to delete origin branches) (*NOTE:* This command will delete all branches except master just for now)


    $ git_eraser erase --local
    
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KarimEbrahemAbdelaziz/git_eraser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GitEraser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/KarimEbrahemAbdelaziz/git_eraser/blob/master/CODE_OF_CONDUCT.md).
