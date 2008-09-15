require 'rubygems'
require 'cgi'
require 'base64'
require 'net/https'
require 'digest/sha2'
require 'openssl'
require 'hmac'
require 'hmac-sha2'

# Goto https://msm.live.com/app/default.aspx to configure your application
#  
# For testin purposes in my example me.diary.com is a virtual host in the /etc/hosts file pointing at 127.0.0.1
# 
# The APP_DETAILS hash has most of all the information I have registered my application with
# 
# Example rails controller code:
# 
# require 'live_contacts'
# 
# protect_from_forgery :except => :windows_live_authentication
# 
# APP_DETAILS = { 
#   :application_name => 'RLiveContacts',
#   :app_id => '0016BFFD80013411',
#   :secret => 'b623d64e8f1d18bfe8b281d385ad461c1e8bbebb',
#   :security_algorithm => 'wsignin1.0',
#   :return_url => 'http://me.diary.com:3000/home/windows_live_authentication',
#   :privacy_policy_url => "http://me.diary.com:3000/privacy",
#   :application_verifier_required => false
# }
# 
# def windows_live_authentication
#   lc = LiveContacts.new(APP_DETAILS)
#   if request.post?
#     lc.process_consent_params(params)
#     xml = lc.retrieve_address_book_xml
#     render :xml => xml and return
#   else
#     redirect_to lc.generate_delegation_url and return
#   end
# end
class LiveContacts
  
  VERSION = '0.0.4'
  
  # Live application attibutes
  attr_accessor :application_name, :app_id,:secret, :security_algorithm, :return_url, :privacy_policy_url, :application_verifier_required, :timestamp
  
  # delegated authentication attributes
  attr_reader :consent_token, :parsed_token, :eact, :cryptkey, :decrypted_token, :parsed_decrypted_token, :lid, :int_lid, :delt
  
  # Step 1 - Initialize the object with the corrent details
  def initialize(app_details)
    self.application_name = app_details[:application_name]
    self.app_id = app_details[:app_id]
    self.secret = app_details[:secret]
    self.security_algorithm = app_details[:security_algorithm]
    self.return_url = app_details[:return_url]
    self.privacy_policy_url = app_details[:privacy_policy_url]
    self.application_verifier_required = app_details[:application_verifier_required]
    
    # mainly used for testing purposes to check the signature generated
    self.timestamp = app_details[:timestamp]
  end
  
  # Step 2 - Get authentication consent from Live.com
  def generate_delegation_url
    url = "https://consent.live.com/Delegation.aspx?RU=#{self.return_url}&ps=Contacts.View&pl=#{self.privacy_policy_url}"
    url += "&app=#{generate_app_verifier}" if self.application_verifier_required
    url
  end
  
  # Step 3 - Process what was returned from Step 2, so we are ready to talk to the API
  def process_consent_params(params)
    return false unless params['ResponseCode'] == 'RequestApproved'
    return false unless params['ConsentToken']
    @consent_successful = false
    @consent_successful = true if process_consent_token(params['ConsentToken'])
    @consent_successful
  end

  # Step 4 - Actually request some information from the API, at the moment, simply just getting all contacts from the address book
  # TODO timeout, error responses
  def retrieve_address_book_xml
    return unless @consent_successful
    url = URI.parse("https://livecontacts.services.live.com" + "/users/@C@" + self.int_lid.to_s + "/REST/LiveContacts/Contacts")

    req = Net::HTTP::Get.new(url.path)
    req.add_field('Authorization', "DelegatedToken dt=\"" + self.delt + "\"")
    req.set_content_type('application/xml', :charset => 'utf-8')

    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true

    res = con.start { |http| http.request(req) }
    res.body
  end

  private
  
  def process_consent_token(token)
    begin
      @parsed_token = parse(CGI.unescape(token))
      @eact = self.parsed_token['eact']
      @cryptkey = Digest::SHA256.digest('ENCRYPTION' + self.secret)[0..15]
      @decrypted_token = decode_token(self.eact, self.cryptkey)
      @parsed_decrypted_token = parse(self.decrypted_token)
      @lid = self.parsed_decrypted_token['lid']
      @int_lid = self.lid.hex
      @delt = self.parsed_decrypted_token['delt']
      return true
    rescue Exception => e
      return false
    end
  end

  # FIXME copied from Microsoft demo code, I'm sure this can be done in 2 lines of code, tests first though
  def parse(input)
    if (input.nil? or input.empty?)
      return false
    end

    pairs = {}
    if (input.class == String)
      input = input.split('&')
      input.each{|pair|
        k, v = pair.split('=')
        pairs[k] = v
      }
    else
      input.each{|k, v|
        v = v[0] if (v.class == Array)
        pairs[k.to_s] = v.to_s
      }
    end
    return pairs
  end
  
  # FIXME copied from Microsoft demo
  def decode_token(token, cryptkey)
    if (cryptkey.nil? or cryptkey.empty?)
      return false
    end
    token = Base64.decode64(CGI.unescape(token))
    if (token.nil? or (token.size <= 16) or !(token.size % 16).zero?)
      return false
    end
    iv = token[0..15]
    crypted = token[16..-1]
    begin
      aes128cbc = OpenSSL::Cipher::AES128.new("CBC")
      aes128cbc.decrypt
      aes128cbc.iv = iv
      aes128cbc.key = cryptkey
      decrypted = aes128cbc.update(crypted) + aes128cbc.final
    rescue Exception => e
      return false
    end
    decrypted
  end
  
  # FIXME copied from Microsoft demo
  def generate_app_verifier(ip = nil)
    token = "appid=#{self.app_id}&ts=#{self.timestamp.to_i.to_s || Time.now.to_i.to_s}"
    token += "&ip=#{ip}" if ip
    token += "&sig=#{CGI.escape(Base64.encode64((signToken(token))))}"
    CGI.escape token
  end
  
  # FIXME copied from Microsoft demo
  def signToken(token)
    begin
      # TODO using the openssl libraries, they may not be up-to-date, e.g. Mac OSX Leopard doesn't have SHA256 in openssl
      # digest = OpenSSL::Digest::SHA256.new
      # return OpenSSL::HMAC.digest(digest, Digest::SHA256.digest('SIGNATURE' + SECRET)[0..15], token)
      
      # using thw hmac from the ruby-openid libraries
      return HMAC::SHA256.digest(Digest::SHA256.digest('SIGNATURE' + self.secret)[0..15], token)
    rescue Exception => e
      return false
    end
  end

end