require "git_cleaner/version"
require "thor"
require "highline"
require "rainbow"
require "httpclient"
require "git"

module GitCleaner
  class Error < StandardError; end
  # Your code goes here...

  class Cleaner < Thor

    desc 'clean', 'Clean git branches'
    option :local
    option :origin
    def cleanup
      cleanup_local if options[:local]
      cleanup_origin if options[:origin]
      StaticMethods.new.print_no_flag_error_message if options.empty?
    end

    desc 'preview', 'Preview git branches that had been merged into master'
    option :local
    option :origin
    def preview
      preview_local if options[:local]
      preview_origin if options[:origin]
      StaticMethods.new.print_no_flag_error_message if options.empty?
    end

    no_commands do
      def preview_local
        Git.configure do |config|
          # If you want to use a custom git binary
          config.binary_path = "/usr/bin/git"
        end
        current_directory = Dir.pwd

        StaticMethods.new.print_preview_message('local')
        begin
          g = Git.open("#{current_directory}")

          g.branches.local.each_with_index do |local_branch, index|
            puts "    🧹 #{index + 1}. #{local_branch}"
          end

          puts "\n\n"
        rescue
          StaticMethods.new.print_no_git_error_message
        end
      end
    end

    no_commands do
      def preview_origin
        Git.configure do |config|
          # If you want to use a custom git binary
          config.binary_path = "/usr/bin/git"
        end
        current_directory = Dir.pwd

        StaticMethods.new.print_preview_message('origin')
        begin
          g = Git.open("#{current_directory}")

          g.branches.remote.each_with_index do |origin_branch, index|
            puts "    🧹 #{index + 1}. #{origin_branch}"
          end

          puts "\n\n"
        rescue
          StaticMethods.new.print_no_git_error_message
        end
      end
    end

    no_commands do
      def cleanup_local
        # Git.configure do |config|
        #   # If you want to use a custom git binary
        #   config.binary_path = "/usr/bin/git"
        # end
        # git_object = Git.init
        #
        # git_object.config('user.name', 'KarimEbrahemAbdelaziz')
        # git_object.config('user.email', 'karimabdelazizmansour@gmail.com')
        # g.config('user.name', g.config('user.name'))
        # g.config('user.email', g.config('user.email'))

        current_directory = Dir.pwd

        StaticMethods.new.print_cleanup_message
        begin
          g = Git.open("#{current_directory}")

          g.branches.local.each_with_index do |local_branch, index|
            puts "    🧹 #{index + 1}. #{local_branch}"
          end

          puts "\n\n"

          inputStream = HighLine.new
          should_delete_branches = inputStream.agree("Delete these branches? (y/n) ")
          puts "\n\n"
          if should_delete_branches == true
            g.checkout('master')
            g.branches.local.each_with_index do |local_branch, index|
              begin
                if g.branch('master').contains?(local_branch)
                  local_branch.delete
                  puts "    #{index + 1}. '#{local_branch}' Removed ✅"
                else
                  puts "    #{index + 1}. '#{local_branch}' Not merged into 'master' ❌"
                end
              rescue
                puts "    #{index + 1}. Can't remove '#{local_branch}' ❌"
              end
            end
          end
          puts "\n\n"
        rescue
          StaticMethods.new.print_no_git_error_message
        end
      end
    end

    no_commands do
      def cleanup_origin
        Git.configure do |config|
          # If you want to use a custom git binary
          config.binary_path = "/usr/bin/git"
        end
        current_directory = Dir.pwd

        StaticMethods.new.print_cleanup_message
        begin
          g = Git.open("#{current_directory}")

          g.branches.remote.each_with_index do |origin_branch, index|
            puts "    🧹 #{index + 1}. #{origin_branch}"
          end

          puts "\n\n"
        rescue
          StaticMethods.new.print_no_git_error_message
        end
      end
    end

  end

  class StaticMethods
    def print_cleanup_message
      text2 = "
   _____ _ _      _____ _
  / ____(_) |    / ____| |
 | |  __ _| |_  | |    | | ___  __ _ _ __   ___ _ __
 | | |_ | | __| | |    | |/ _ \\/ _` | '_ \\ / _ \\ '__|
 | |__| | | |_  | |____| |  __/ (_| | | | |  __/ |
  \\_____|_|\\__|  \\_____|_|\\___|\\__,_|_| |_|\\___|_|
"
      puts "#{text2} \n"
      puts "Welcome to the #{Rainbow("Git Cleaner").underline.bright.red} 🧹🧹 project!
Before we start cleaning your git branches, here is a preview of your branches: \n\n"
    end

    def print_preview_message(git_type)
      text2 = "
   _____ _ _      _____ _
  / ____(_) |    / ____| |
 | |  __ _| |_  | |    | | ___  __ _ _ __   ___ _ __
 | | |_ | | __| | |    | |/ _ \\/ _` | '_ \\ / _ \\ '__|
 | |__| | | |_  | |____| |  __/ (_| | | | |  __/ |
  \\_____|_|\\__|  \\_____|_|\\___|\\__,_|_| |_|\\___|_|
"
      puts "#{text2} \n"
      puts "Welcome to the #{Rainbow("Git Cleaner").underline.bright.red} 🧹🧹 project!
Here is a preview of your #{git_type} branches: \n\n"
    end

    def print_no_git_error_message
      text2 = "
   _____ _ _      _____ _
  / ____(_) |    / ____| |
 | |  __ _| |_  | |    | | ___  __ _ _ __   ___ _ __
 | | |_ | | __| | |    | |/ _ \\/ _` | '_ \\ / _ \\ '__|
 | |__| | | |_  | |____| |  __/ (_| | | | |  __/ |
  \\_____|_|\\__|  \\_____|_|\\___|\\__,_|_| |_|\\___|_|
"
      puts "#{text2} \n"
      puts "Welcome to the #{Rainbow("Git Cleaner").underline.bright.red} 🧹🧹 project! \n\n"
      puts "⚠️⚠️ There is no #{Rainbow("git").underline.bright.red} directory here 😡 \n\n"
    end

    def print_no_flag_error_message
      text2 = "
   _____ _ _      _____ _
  / ____(_) |    / ____| |
 | |  __ _| |_  | |    | | ___  __ _ _ __   ___ _ __
 | | |_ | | __| | |    | |/ _ \\/ _` | '_ \\ / _ \\ '__|
 | |__| | | |_  | |____| |  __/ (_| | | | |  __/ |
  \\_____|_|\\__|  \\_____|_|\\___|\\__,_|_| |_|\\___|_|
"
      puts "#{text2} \n"
      puts "Welcome to the #{Rainbow("Git Cleaner").underline.bright.red} 🧹🧹 project! \n\n"
      puts "⚠️⚠️ You didn't specify any flag, please use --local or --origin flag 😡 \n\n"
    end
  end


end
