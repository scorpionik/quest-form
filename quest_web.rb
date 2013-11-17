require "sinatra"
require "sinatra/json"
require "json"

def parse_data(data)
  data.split(/^=$/).map do |question_data|
    parse_question(question_data)
  end
end

def parse_question(question_data)
  question_text, *answers_data = question_data.split(/^$/).map(&:strip).reject(&:empty?)
  {:question => question_text.gsub(/[\r\n]/,'<br/>'),
  :answers  => parse_answers(answers_data)    }
end

def parse_answers(answers_data)
  answers_data.map do |answer_data|
    {:answer => answer_data.sub(/^\* */,"").gsub(/[\r\n]/,'<br/>'),
    :correct => answer_data.start_with?("*") }
  end
end

DATA_FILE = File.expand_path("../ruby.txt", __FILE__)
QUESTIONS = parse_data(File.read(DATA_FILE))

get "/form_question" do
  if (params["id"] != nil)
	  id = params["id"].to_i
  else
    id = rand(QUESTIONS.size)
  end
  question = QUESTIONS[id]
  question[:answers] = question[:answers].shuffle()
  response = {}
  response[:answers] = question[:answers].map do |answer|
    answer[:answer]
  end
  @id = id
  @html_question = question[:question]
  @html_answers = response[:answers]
  @answers = []
  i = 0
  @html_answers.each do |answer|
   	@answers[i]="#{answer}"
   	i += 1
  end

  file =  @env["PATH_INFO"]
  file = "/index" if file == "/"
  file += ".erb"
  @template = ERB.new(File.read(File.expand_path(File.join("..", "views", file), __FILE__)))
  @template.result(binding)
end

post "/form_check" do
	@id = params["id"].to_i
	seed = params["seed"].to_i
	question = QUESTIONS[@id]
	correct_answers = question[:answers].select do |answer|
	  answer[:correct]
	end
	correct_answers = correct_answers.map { |a| a[:answer]}
	if (params["answers"] == nil)
	  @correct = false
	else
	  @correct = correct_answers.sort == params["answers"].sort
	end
	file =  @env["PATH_INFO"]
  file = "/index" if file == "/"
  file += ".erb"
  @template = ERB.new(File.read(File.expand_path(File.join("..", "views", file), __FILE__)))
  @template.result(binding)
end


get "/question" do
  size = QUESTIONS.size
  id = rand(size)
  question = QUESTIONS[id]
  response = {}
  response[:id] = id
  response[:question] = question[:question]
  response[:answers] = question[:answers].map do |answer|
    answer[:answer]
  end
  json(response)
end

post "/answer" do
	data = JSON.parse(request.body.read)
	question = QUESTIONS[data["id"]]
	correct_answers = question[:answers].select do |answer|
	  answer[:correct]
	end
	correct_answers = correct_answers.map { |a| a[:answer]}
	correct = correct_answers.sort == data["answers"].sort
	json(:correct => correct)
end

