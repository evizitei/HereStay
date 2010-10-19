require 'rubygems'
require 'yajl'
module Facebook
  class ParamsParser
    def initialize(app, *args, &condition)
      @app = app
      @args = args
      @condition = condition
    end

    def call(env)
      request = Rack::Request.new(env)
      
      signed_request = request.params["signed_request"]
      if signed_request
        signature, signed_params = signed_request.split('.')

        # Verify signature
        if signed_request_is_valid?("8878da4199b3af4cacbf188b15c21517", signature, signed_params)
          # Parse JSON
          signed_params = Yajl::Parser.new.parse(base64_url_decode(signed_params))

          # Add JSON parameters to Rails params
          signed_params.each do |k,v|
            request.params[k] = v
          end
        else
          request.params["invalid_signature"] = "true"
        end
      end
      @app.call(env)
    end

    private
    def signed_request_is_valid?(secret, signature, params)
      signature = base64_url_decode(signature)
      expected_signature = OpenSSL::HMAC.digest('SHA256', secret, params.tr("-_", "+/"))
      return signature == expected_signature
    end

    # Stolen from mini_fb.
    # Ruby's implementation of base64 decoding reads the string in multiples of 6 and ignores any extra bytes.
    # Since facebook does not take this into account, this function fills any string with white spaces up to
    # the point where it becomes divisible by 6, then it replaces '-' with '+' and '_' with '/' (URL-safe decoding),
    # and decodes the result.
    def base64_url_decode(str)
      str = str + "=" * (6 - str.size % 6) unless str.size % 6 == 0
      return Base64.decode64(str.tr("-_", "+/"))
    end
  end
end