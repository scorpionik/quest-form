require 'sinatra'
require 'sinatra/json'
require 'json'
require 'erb'

DATA_FILE = File.expand_path('../ruby.txt', __FILE__)

def parse_data(data)
  data.split(/^=$/).map do |question_data|
    parse_question(question_data)
  end
end

def parse_question(question_data)
  question_text, *answers_data = question_data.split(/^$/).map(&:strip).reject(&:empty?)

  { :question => question_text,
    :answers  => parse_answers(answers_data)    }
end

def parse_answers(answers_data)
  answers_data.map do |answer_data|
    { :answer => answer_data.sub(/^\* */,''),
      :correct => answer_data.start_with?('*') }
  end
end

QUESTIONS = parse_data(File.read(DATA_FILE));
   
=begin
get '/' do
  <<-HTML
    <form method="post" action="/register">
      <input type="radio" name="regRadio" value="1" />
      <input type="radio" name="regRadio" value="2" />
      <input type="radio" name="regRadio" value="3" />
      <input type="radio" name="regRadio" value="4" />
      <input type="submit" value="Register"/>
    </form>
  HTML
end

post '/register' do
  "You selected #{params[:regRadio]}"
end
=end

get '/question' do
   size = QUESTIONS.size;
   id = rand(size);
   question = QUESTIONS[id];
   response = {}
   response[:id] = id
   response[:question] = question[:question]
   response[:answers] = question[:answers].map do |answer|
	   answer[:answer]
   end

   json(response)

end

get '/form_question' do
   size = QUESTIONS.size;
   id = rand(size);
   question = QUESTIONS[id];
   str = "<form method> \n #{question[:question]} <br/>\n";
   question[:answers].each do |answer|
	   str << "<input type=\"radio\" name=\"answers\" value=\"#{answer[:answer]}\" > #{answer[:answer]} </input><br/>\n";
   end
   str << "</form>\n";
   <<-HTML
#{str}
   HTML

end

post '/answer' do
	data = JSON.parse(request.body.read)
	question = QUESTIONS[data['id']]
	correct_answers = question[:answers].select do |answer|
		answer[:correct]
	end
	correct_answers = correct_answers.map { |a| a[:answer]}
	correct = correct_answers == data['answers']

	json(:correct => correct)
end



