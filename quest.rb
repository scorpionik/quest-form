#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'

BASE_URL = 'http://localhost:9292'
uri = URI.parse(BASE_URL)
HTTP = Net::HTTP.new(uri.host, uri.port)

def get(path)
  get_response(Net::HTTP::Get.new(path))
end

def post(path, data)
  request = Net::HTTP::Post.new(path)
  request.body = JSON.dump(data)
  request["Content-Type"] = "application/json"
  get_response(request)
end

def get_response(request)
  response = HTTP.request(request)
  if response.code == "200"
    return JSON.parse(response.body)
  else
    raise "Exit code #{response.code}"
  end
end

def run
  while true
    question = get('/question')
    ask_question(question)
  end
end

def ask_question(question)
  puts "#{question['question']}\n"
  answers_mapping = offer_answers(question)

  while true
    answer = gets
    exit if answer.nil? || ["q", "quit"].include?(answer.chomp)
    user_choices = answer.split(/[, ]/).map(&:strip)
    user_answers = user_choices.map { |choice| answers_mapping[choice] }
    result = post('/answer', {'id' => question['id'],
                              'answers' => user_answers })

    if result['correct']
      puts "Congratulation"
      puts "\n------------------------------------------------\n"
      break
    else
      puts "We are sorry, try again"
    end
  end
end

def offer_answers(question)
  answers = question['answers'].sort_by { rand }
  choices = ('a'..'z').first(answers.size)
  mapping = Hash[choices.zip(answers)]
  choices.each do |choice|
    answer = mapping[choice]
    puts "#{choice}) #{answer}"
    puts
  end
  return mapping
end

run
