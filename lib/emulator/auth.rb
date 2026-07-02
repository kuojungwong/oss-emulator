require 'base64'
require 'openssl'
require 'cgi'
require 'emulator/config'

module OssEmulator
  module Auth

    def self.verify(request)
      return true unless Config.enable_auth

      auth_header = request['Authorization']
      return false unless auth_header

      unless auth_header =~ /^OSS\s+(.+):(.+)$/
        return false
      end

      access_key = $1
      signature = $2

      return false if access_key != Config.access_key

      string_to_sign = build_string_to_sign(request)
      expected_signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', Config.secret_key, string_to_sign))

      signature == expected_signature
    end

    def self.build_string_to_sign(request)
      http_method = request.request_method
      content_md5 = request['Content-MD5'] || ''
      content_type = request['Content-Type'] || ''
      date = get_date(request)

      canonicalized_headers = build_canonicalized_headers(request)
      canonicalized_resource = build_canonicalized_resource(request)

      "#{http_method}\n#{content_md5}\n#{content_type}\n#{date}\n#{canonicalized_headers}#{canonicalized_resource}"
    end

    def self.get_date(request)
      if request['x-oss-date'] && !request['x-oss-date'].empty?
        request['x-oss-date'].first
      elsif request['Date'] && !request['Date'].empty?
        request['Date'].first
      else
        ''
      end
    end

    def self.build_canonicalized_headers(request)
      oss_headers = {}
      request.each do |key, value|
        if key.downcase.start_with?('x-oss-')
          oss_headers[key.downcase] = value.first.strip
        end
      end

      result = ''
      oss_headers.keys.sort.each do |key|
        result += "#{key}:#{oss_headers[key]}\n"
      end
      result
    end

    def self.build_canonicalized_resource(request)
      resource = ''
      host = request['Host']

      if host && !host.empty?
        host_parts = host.first.split(':')
        host_name = host_parts[0]
        bucket_name = nil

        unless Config.hostnames.include?(host_name)
          bucket_name = host_name.split('.')[0]
        end

        if bucket_name
          resource += "/#{bucket_name}"
        end
      end

      resource += request.path
      query_string = request.request_uri.query
      if query_string
        params = CGI::parse(query_string)
        sorted_params = params.keys.sort
        if sorted_params.any?
          resource += '?' + sorted_params.map { |k| "#{k}=#{params[k].first}" }.join('&')
        end
      end

      resource
    end

    def self.extract_access_key(request)
      auth_header = request['Authorization']
      return nil unless auth_header

      if auth_header =~ /^OSS\s+(.+):/
        return $1
      end
      nil
    end

  end # Auth
end # OssEmulator