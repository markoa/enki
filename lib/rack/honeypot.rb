# Idea taken from http://mad.ly/2009/05/01/honeypot-filter-as-a-rack-middleware
#
# When a spammer wants to attack your site, they'll likely send an automated
# bot that will blindly fill out any forms it encounters. The idea of
# a "honeypot" is that you place a hidden field in a form. That's the honeypot.
# If this field is filled in, then it's almost certain to be a spammer
# (since a normal user wouldn't have even seen the field), and the contents
# of the form can safely be discarded.
 
# Normally, you would implement a "honeypot" in a Rails app with some
# combination of a special field in a particular form, and then some logic
# in the corresponding controller that would check for content in the
# "honeypot" field. This is somewhat of an inefficient approach, because
# it requires special code (not DRY), and bots are still going through an
# entire request/response cycle with all of the normal action/controller
# overhead.
 
# Using a Rack middleware strategy, you have a very low impact solution,
# both in terms of code needed, and in terms of impact on your servers.
# All you need to do is to enable the middleware and place a honeypot field
# in whatever forms you want to protect. Then, the middleware will return
# a blank 200 OK response for any form posts that include a value for
# the honeypot field.

module Rack
  class Honeypot

    def initialize(app, field_name)
      @app = app
      @field_name = field_name
    end

    def call(env)
      form_hash = env["rack.request.form_hash"]

      if form_hash && form_hash[@field_name] =~ /\S/
        [200, {'Content-Type' => 'text/html', "Content-Length" => "0"}, []]
      else
        @app.call(env)
      end
    end

  end
end
