require 'json'
require 'net/https'

def lambda_handler(event:, context:)
	responses = []
  # Your env has to have the page id for which statuspage you're updating
	uri_base = "/v1/pages/#{ENV['STATUSPAGE_PAGE_ID']}/components"

  # and you also need your statuspage.io oauth key. See https://doers.statuspage.io/api/basics/
	auth = "OAuth #{ENV['STATUSPAGE_API_KEY']}"

  # Let's set up Net::HTTP
	http = Net::HTTP.new("api.statuspage.io", 443)
	http.use_ssl = true

  # Still defualts to SSL v3 /sigh
	http.ssl_version = :TLSv1_2_client
	http.verify_mode = OpenSSL::SSL::VERIFY_PEER

	body = JSON.parse(event['body'])

  # We're going to expect an application/JSON that resembles:
=begin
  {
    "component_ids": "comma,separated,list,of,ids",
    "component_status": "enum status from statuspage.io docs"
  }
=end

	status = body['component_status']
	component_ids = body['component_ids'].split(',')
	component_ids.each do |id|
			puts "Setting component #{id} to #{status}"
			component_uri = "#{uri_base}/#{id}.json"
      content = { "component[status]" => status }
			http_request = Net::HTTP::Patch.new component_uri

      # Remember our authorization header?
			http_request['Authorization'] = auth

      # Net::HTTP has a nice API for automatically setting form data, which it turns out
      # is what statuspage.io expects in their request
      http_request.set_form_data content
      response = http.request(http_request)

      unless response.code == 200
        # Error logging for lambda
        STDERR.puts response.code
        STDERR.puts response.message
        STDERR.puts response.body
      end
			responses << response
	end
	{
			statusCode: 200,
			body: JSON.generate(responses.inspect)
	}
end
