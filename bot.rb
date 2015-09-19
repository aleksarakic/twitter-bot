require 'jumpstart_auth'
require 'bitly'
Bitly.use_api_version_3

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing MicroBlogger"
		@client = JumpstartAuth.twitter
		@screen_names = @client.followers.collect {|follower| @client.user(follower).screen_name }
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			puts "Sorry, max 140 characters."
		end
	end

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""

		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]

			case command
				when 'q'    then puts "Goodbye!"
				when 't'    then tweet(parts[1..-1].join(" "))
				when 'dm'   then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'lt'   then last_tweets
				when 's'    then shorten(parts[-1])
				when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
				else 
					puts "Sorry, I dont know how to #{command}"
			end
		end
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message: #{message}"
		message = "d @#{target} #{message}"

		if @screen_names.include? target #paziti na mala i velika slova
			tweet(message)
		else
			puts "Sorry, you cant send DM to someone who doesn't follow you."
		end
	end

	def spam_my_followers(message)
		@screen_names.each do |follower| #loopuje preko imena
			dm(follower, message) #poziva dm metod 
		end
	end

	def last_tweets
		friends = @client.friends.sort_by {|friend| @client.user(friend).screen_name.downcase }
		friends.each do |friend|
      puts "----", "@#{@client.user(friend).screen_name} said this at #{@client.user(friend).status.created_at.strftime('%-m-%-d-%Y %l:%M %p')}", "---- \n"
      puts "\n#{@client.user(friend).status.text}", "\n"
    end
  end

  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts "Shortening this URL: #{original_url}"
    return bitly.shorten(original_url).short_url
  end
end

blogger = MicroBlogger.new
blogger.run
