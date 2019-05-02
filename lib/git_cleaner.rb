require "git_cleaner/version"
require "thor"
require "highline"
require "rainbow"
require "httpclient"
require "git"

module GitCleaner
  class Error < StandardError; end

  class Cleaner < Thor

    desc 'cleanup', 'Clean git branches that had been merged into master'
    option :local
    option :origin
    def cleanup
      cleanup_local if options[:local]
      cleanup_origin if options[:origin]
      Helper.new.print_no_flag_error_message if options.empty?
    end

    desc 'preview', 'Preview git branches that had been merged into master'
    option :local
    option :origin
    def preview
      preview_local if options[:local]
      preview_origin if options[:origin]
      Helper.new.print_no_flag_error_message if options.empty?
    end

    no_commands do
      def preview_local
        Git.configure do |config|
          # If you want to use a custom git binary
          config.binary_path = "/usr/bin/git"
        end
        current_directory = Dir.pwd

        Helper.new.print_preview_message('local')
        begin
          g = Git.open("#{current_directory}")

          g.branches.local.each_with_index do |local_branch, index|
            puts "    🧹 #{index + 1}. #{local_branch}"
          end

          puts "\n\n"
        rescue
          Helper.new.print_no_git_error_message
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

        Helper.new.print_preview_message('origin')
        begin
          g = Git.open("#{current_directory}")

          g.branches.remote.each_with_index do |origin_branch, index|
            puts "    🧹 #{index + 1}. #{origin_branch}"
          end

          puts "\n\n"
        rescue
          Helper.new.print_no_git_error_message
        end
      end
    end

    no_commands do
      def cleanup_local
        current_directory = Dir.pwd

        Helper.new.print_cleanup_message
        begin
          g = Git.open("#{current_directory}")

          g.branches.local.each_with_index do |local_branch, index|
            puts "    🧹 #{index + 1}. #{local_branch}"
          end

          puts "\n\n"

          inputStream = HighLine.new
          should_delete_branches = inputStream.agree("Delete these branches? (y/n) ")
          if should_delete_branches == true
            puts "\n\n"
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
          Helper.new.print_no_git_error_message
        end
      end
    end

    no_commands do
      def cleanup_origin
        current_directory = Dir.pwd

        Helper.new.print_cleanup_message
        begin
          g = Git.open("#{current_directory}")

          g.branches.remote.each_with_index do |origin_branch, index|
            puts "    🧹 #{index + 1}. #{origin_branch}"
          end

          puts "\n\n"

          inputStream = HighLine.new
          should_delete_branches = inputStream.agree("Delete these branches? (y/n) ")

          if should_delete_branches == true
            puts "\n\n"
            g.checkout('master')
            g.pull('origin', 'master')
            array_of_remote_deleted_branches = []
            g.branches.remote.each_with_index do |origin_branch, index|
              begin
                branch_string = origin_branch.to_s
                branch_string['remotes/origin/'] = ''
                g.checkout(branch_string)
                if g.branch('master').contains?(branch_string) && branch_string != 'master'
                  system "git push -u origin --delete #{branch_string} -q"
                  puts "    #{index + 1}. '#{origin_branch}' Removed ✅"
                  array_of_remote_deleted_branches.append(branch_string)
                elsif branch_string == 'master'
                  puts "    #{index + 1}. '#{origin_branch}' Can't remove 'master' branch ❌"
                else
                  puts "    #{index + 1}. '#{origin_branch}' Not merged into 'master' ❌"
                end
              rescue
                puts "    #{index + 1}. Can't remove '#{origin_branch}' ❌"
              end
            end
            g.checkout('master')
            delete_local_after_origin(array_of_remote_deleted_branches)
          end
          puts "\n\n"
        rescue
          Helper.new.print_no_git_error_message
        end
      end
    end

    no_commands do
      def delete_local_after_origin(branches)
        current_directory = Dir.pwd
        begin
          g = Git.open("#{current_directory}")
          g.branches.local.each do |local_branch|
            puts "Local: #{local_branch}"
            branches.each do |value|
              puts "coming: #{value}"
              if local_branch.to_s == value
                local_branch.delete
              end
            end
          end
        rescue
        end
      end
    end

  end

  class Helper
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
