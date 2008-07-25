require 'live_contacts'
require 'time'

class LiveContactsTest < Test::Unit::TestCase
  
  LIVE_APP_DETAILS = { 
    :application_name => 'RLiveContacts',
    :app_id => '0016BFFD80013411',
    :secret => 'b623d64e8f1d18bfe8b281d385ad461c1e8bbebb',
    :security_algorithm => 'wsignin1.0',
    :return_url => 'http://me.diary.com:3000',
    :privacy_policy_url => "http://me.diary.com:3000/privacy",
    :application_verifier_required => true
  }
  
  def test_initialize  
    lc = LiveContacts.new(LIVE_APP_DETAILS)
    
    LIVE_APP_DETAILS.keys.each do |k|
      assert_equal lc.send(k), LIVE_APP_DETAILS[k]
    end
  end
  
  def test_generate_delegation_url
    lc = LiveContacts.new(LIVE_APP_DETAILS.merge(:timestamp => Time.parse('Thu Jul 24 12:07:34 +0100 2008')))
    assert_equal 'https://consent.live.com/Delegation.aspx?RU=http://me.diary.com:3000&ps=Contacts.View&pl=http://me.diary.com:3000/privacy&app=appid%3D0016BFFD80013411%26ts%3D1216897654%26sig%3DNJ3VHx6F9YMBZbCODuNcimejCqurCBXpEbWAclN4EZU%253D%250A', lc.generate_delegation_url
  end
  
  def test_generate_delegation_url_without_app_verification
    lc = LiveContacts.new(LIVE_APP_DETAILS.merge(:timestamp => Time.parse('Thu Jul 24 12:07:34 +0100 2008'), :application_verifier_required => false))
    assert_equal 'https://consent.live.com/Delegation.aspx?RU=http://me.diary.com:3000&ps=Contacts.View&pl=http://me.diary.com:3000/privacy', lc.generate_delegation_url
  end
  
  def test_process_consent_params
    lc = LiveContacts.new(LIVE_APP_DETAILS.merge(:timestamp => Time.parse('Thu Jul 24 12:07:34 +0100 2008')))
    assert lc.process_consent_params({"action"=>"delauth", "ResponseCode"=>"RequestApproved", "ConsentToken"=>"eact%3DwWAWABR%252Fr8S0kHilwbO3zEw8yn%252FJxvLnBeuneexie1Qm%252FdyzS438Jfnqk97wcNh4cDKf83L6KwzjVpHSnZOzlyJ0Rw8KG7sl%252F5nxTLRe7j5nKpn%252Bg%252FmRltAF9z%252BciCckPnDllO0%252FJ4%252BMvkb2YmGzo3SntFhMtyGc9WPTFtLKk%252F1INVSG6ssB%252FO4nC4riEKwqm662cfu4WOA0CPzVveh5VY7YknWM9zsJmSIfJ%252B0hxibpLzG7nLQHNF77xAscujc0OgPJVgYWEirCIqA2QUSkCDOmK%252B%252FkhUGr%252BIGlVxg1%252FunpGGrecDLyVtnlCm8tanRF8kZ3t47Hcg5SYkQbsPyv3S8prjMWDelUSus63yaTVsx10UrwhGM%252FfErSccsJUpYMVi1%252F%252FkhJNdlMCzHe2eJGNDyQhgZKZTXUW036fU5ZaY9CT8ARjSGlzc2uGf2FqQl2fr0g8%252FS6P%252BSz9G%252FP6fbsDM1HqcnyOcciR6R6sKEZ0dyBa4Md1HQPinJuO7sJhWxKV%252FpIRsvNX8u02ixcj63MmsQlb%252FOYRCOlz0D7Q%252BZzdUeP%252FUxh3z5XgBNJvQRpEyIWPTdXMbtuY0aGjNGVTujSqgtqnk2%252FqeHFbyk5iBHXrB1zMTFgM1lt9Yn5pppUDDTDZIeirWErgV2BMzxbIiAjjJYp0Fp6oHnepNro658vScgAlM8%252FuQzB31bbubvUWEZwZQAy7WmvZoxT33z8D8oiis8RPrCe0vIdYop1FNlKC163fRl3WtnGIJgaQZTGlONaCOtK5WAPm8Gy82P387FkdtD5FNJFgu0Ow4AMmvR8s4usOe7lFzLYzCUj0pYrIDFzY6UYJbEiJPohXwyzveu9y2HUxbsApkG36cmaa5Bzuxg5ECQE%252FsKFeIRwW23XI%252FrWL6XcRuuwL2pf4K%252F4eBolJQBIwgzPO4DPL7pf6FNjfKop2yWp9V5QJBY6K8ueqSCluwAFUNSHvoGaODdWINqTFB6haD0Gqmb9br0Po8%252BeExEYohF57X3Kv%252BXStGy5Of0jiCxcQfo0VZTooK17njLCtqFo%252B9I%252Fx53qis3AwaSpGXeiALHnyPK6oe2rtU77dQ8nT%252B45CgpKmOKdV%252Fk0gbzfQu3XTt%252F7Y%252BcvAIHy3NIqxZsE7fiyKRbHb0U9dXXhHh89dQds5Yd1lU%252BoNq0Dh8g7ZMO3hE%252FV%252FuZ8Jsz%252FQUYwWsMFamClI7zcfhh6qucxmV%252B%252BQxDnO2huiJVMRSXxsZXPYw%253D%253D", "appctx"=>""})
  end
  
  def test_location_id
    lc = LiveContacts.new(LIVE_APP_DETAILS.merge(:timestamp => Time.parse('Thu Jul 24 12:07:34 +0100 2008')))
    lc.process_consent_params({"action"=>"delauth", "ResponseCode"=>"RequestApproved", "ConsentToken"=>"eact%3DwWAWABR%252Fr8S0kHilwbO3zEw8yn%252FJxvLnBeuneexie1Qm%252FdyzS438Jfnqk97wcNh4cDKf83L6KwzjVpHSnZOzlyJ0Rw8KG7sl%252F5nxTLRe7j5nKpn%252Bg%252FmRltAF9z%252BciCckPnDllO0%252FJ4%252BMvkb2YmGzo3SntFhMtyGc9WPTFtLKk%252F1INVSG6ssB%252FO4nC4riEKwqm662cfu4WOA0CPzVveh5VY7YknWM9zsJmSIfJ%252B0hxibpLzG7nLQHNF77xAscujc0OgPJVgYWEirCIqA2QUSkCDOmK%252B%252FkhUGr%252BIGlVxg1%252FunpGGrecDLyVtnlCm8tanRF8kZ3t47Hcg5SYkQbsPyv3S8prjMWDelUSus63yaTVsx10UrwhGM%252FfErSccsJUpYMVi1%252F%252FkhJNdlMCzHe2eJGNDyQhgZKZTXUW036fU5ZaY9CT8ARjSGlzc2uGf2FqQl2fr0g8%252FS6P%252BSz9G%252FP6fbsDM1HqcnyOcciR6R6sKEZ0dyBa4Md1HQPinJuO7sJhWxKV%252FpIRsvNX8u02ixcj63MmsQlb%252FOYRCOlz0D7Q%252BZzdUeP%252FUxh3z5XgBNJvQRpEyIWPTdXMbtuY0aGjNGVTujSqgtqnk2%252FqeHFbyk5iBHXrB1zMTFgM1lt9Yn5pppUDDTDZIeirWErgV2BMzxbIiAjjJYp0Fp6oHnepNro658vScgAlM8%252FuQzB31bbubvUWEZwZQAy7WmvZoxT33z8D8oiis8RPrCe0vIdYop1FNlKC163fRl3WtnGIJgaQZTGlONaCOtK5WAPm8Gy82P387FkdtD5FNJFgu0Ow4AMmvR8s4usOe7lFzLYzCUj0pYrIDFzY6UYJbEiJPohXwyzveu9y2HUxbsApkG36cmaa5Bzuxg5ECQE%252FsKFeIRwW23XI%252FrWL6XcRuuwL2pf4K%252F4eBolJQBIwgzPO4DPL7pf6FNjfKop2yWp9V5QJBY6K8ueqSCluwAFUNSHvoGaODdWINqTFB6haD0Gqmb9br0Po8%252BeExEYohF57X3Kv%252BXStGy5Of0jiCxcQfo0VZTooK17njLCtqFo%252B9I%252Fx53qis3AwaSpGXeiALHnyPK6oe2rtU77dQ8nT%252B45CgpKmOKdV%252Fk0gbzfQu3XTt%252F7Y%252BcvAIHy3NIqxZsE7fiyKRbHb0U9dXXhHh89dQds5Yd1lU%252BoNq0Dh8g7ZMO3hE%252FV%252FuZ8Jsz%252FQUYwWsMFamClI7zcfhh6qucxmV%252B%252BQxDnO2huiJVMRSXxsZXPYw%253D%253D", "appctx"=>""})
    assert_equal 7682662888421099853, lc.int_lid
  end
  
  def test_delegation_token
    lc = LiveContacts.new(LIVE_APP_DETAILS.merge(:timestamp => Time.parse('Thu Jul 24 12:07:34 +0100 2008')))
    lc.process_consent_params({"action"=>"delauth", "ResponseCode"=>"RequestApproved", "ConsentToken"=>"eact%3DwWAWABR%252Fr8S0kHilwbO3zEw8yn%252FJxvLnBeuneexie1Qm%252FdyzS438Jfnqk97wcNh4cDKf83L6KwzjVpHSnZOzlyJ0Rw8KG7sl%252F5nxTLRe7j5nKpn%252Bg%252FmRltAF9z%252BciCckPnDllO0%252FJ4%252BMvkb2YmGzo3SntFhMtyGc9WPTFtLKk%252F1INVSG6ssB%252FO4nC4riEKwqm662cfu4WOA0CPzVveh5VY7YknWM9zsJmSIfJ%252B0hxibpLzG7nLQHNF77xAscujc0OgPJVgYWEirCIqA2QUSkCDOmK%252B%252FkhUGr%252BIGlVxg1%252FunpGGrecDLyVtnlCm8tanRF8kZ3t47Hcg5SYkQbsPyv3S8prjMWDelUSus63yaTVsx10UrwhGM%252FfErSccsJUpYMVi1%252F%252FkhJNdlMCzHe2eJGNDyQhgZKZTXUW036fU5ZaY9CT8ARjSGlzc2uGf2FqQl2fr0g8%252FS6P%252BSz9G%252FP6fbsDM1HqcnyOcciR6R6sKEZ0dyBa4Md1HQPinJuO7sJhWxKV%252FpIRsvNX8u02ixcj63MmsQlb%252FOYRCOlz0D7Q%252BZzdUeP%252FUxh3z5XgBNJvQRpEyIWPTdXMbtuY0aGjNGVTujSqgtqnk2%252FqeHFbyk5iBHXrB1zMTFgM1lt9Yn5pppUDDTDZIeirWErgV2BMzxbIiAjjJYp0Fp6oHnepNro658vScgAlM8%252FuQzB31bbubvUWEZwZQAy7WmvZoxT33z8D8oiis8RPrCe0vIdYop1FNlKC163fRl3WtnGIJgaQZTGlONaCOtK5WAPm8Gy82P387FkdtD5FNJFgu0Ow4AMmvR8s4usOe7lFzLYzCUj0pYrIDFzY6UYJbEiJPohXwyzveu9y2HUxbsApkG36cmaa5Bzuxg5ECQE%252FsKFeIRwW23XI%252FrWL6XcRuuwL2pf4K%252F4eBolJQBIwgzPO4DPL7pf6FNjfKop2yWp9V5QJBY6K8ueqSCluwAFUNSHvoGaODdWINqTFB6haD0Gqmb9br0Po8%252BeExEYohF57X3Kv%252BXStGy5Of0jiCxcQfo0VZTooK17njLCtqFo%252B9I%252Fx53qis3AwaSpGXeiALHnyPK6oe2rtU77dQ8nT%252B45CgpKmOKdV%252Fk0gbzfQu3XTt%252F7Y%252BcvAIHy3NIqxZsE7fiyKRbHb0U9dXXhHh89dQds5Yd1lU%252BoNq0Dh8g7ZMO3hE%252FV%252FuZ8Jsz%252FQUYwWsMFamClI7zcfhh6qucxmV%252B%252BQxDnO2huiJVMRSXxsZXPYw%253D%253D", "appctx"=>""})
    assert_equal 'EwCoARAnAAAUaiat%2Fx8TEXYT53ezUhJ8EEISAEWAANKjIpGuJPNQTsQn42llKNW4vXUOBv0v1FDcbBb2%2FsITUZBfSg7Cp1LoNDNn0paH4WAQrwHHMm5oPIOryQ3T9sGpZR3k%2BxewhYMzJja3XsMLNraZqufqrvhi6yjDHYyqtUK%2F0K5ZkDYBgdQNIqZrUIdbdqOkQ4VavTPg4sGikrq0A2YAAAihe2Xb8%2FZYXvgA0VMMFi3QfWAjj0jToUCYuyMteWu2l5jmkOaI5kxp%2FTV2YcrBIkKitlv8N1MBSZQZ67vWmNYNHIiwCN8PXnq5bfjK5RlIklFyDW0gA319xuxtU3A434A%2BuMwVtsMP9RGvfgyJ9eb1CiJmmo7ebl2%2FlHnAMQ7Mp02I7iHaNWeZVcCI9zZERKeb1yrDZAU3N4ykkKWMxdy1Z0Kp7%2FyZRJAD28P%2FuWEaEJl4TTy4b%2F0RMJ75VzuKKkf7u5bdmpV6t9IJgnz%2FtKhCXMQvdZGZVk4OT6QcGwP3Tm%2Fn9emRNpQki6EJhZ4Uwdx3OZ%2BLILfBT%2BDyta6DaudAFGQAAA%3D%3D', lc.delt
  end
  
end