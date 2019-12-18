#!/usr/bin/env ruby

require_relative './lambda.rb'
puts ENV.inspect

json = File.read('./request_body.json')

lambda_handler(event:nil, context:nil)
