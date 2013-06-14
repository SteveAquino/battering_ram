BatteringRam is a Ruby tool based on the Typhoeus and GentleBrute gems that allow you to send
many simultaneous login in attempts to a given url and guess potential user passwords.

First install Typhoeus and GentleBrute:

    gem install typhoeus
    gem install gentle_brute
    
Then make a ruby script similar to the following:

    require File.join(File.dirname(__FILE__), 'battering_ram', 'battering_ram.rb')

    potential_logins = %w(
      myGreatUserName
      user@email.com
      user@test.com
    )

    likely_passwords = %w(
      123qweasd
      password
      password123
    )

    success_match = /successfully logged in/i

    options = {
      likely_passwords: likely_passwords,
      url_options: {
        method: :post,
        followlocation: true
      }
    }

    b = BatteringRam.new("http://test.mysite.com/sign_in", potential_logins, success_match, options)
    b.run