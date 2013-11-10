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
   if (params['id'] != nil)
	id = params['id'].to_i;
   else
   	id = rand(size);
   end

   question = QUESTIONS[id];
   question[:answers] = question[:answers].shuffle();
   str = "<form method=\"post\" action=\"/form_check\"> \n #{question[:question]} <br/>\n";
   question[:answers].each do |answer|
	   str << "<input type=\"checkbox\" name=\"answers[]\" value=\"#{answer[:answer]}\" > #{answer[:answer]} </input><br/>\n";
   end
   str << "<input type=\"hidden\" name=\"id\" value=#{id} />\n";
   str << "<input type=\"submit\" value=\"Check\" /></form>\n";
   <<-HTML
#{str}
   HTML

end

post '/form_check' do
#	data = JSON.parse(request.body.read)
#	<<-HTML 
##{params}
#	HTML
#=begin
	id = params['id'].to_i;
	seed = params['seed'].to_i;
	question = QUESTIONS[id];
	correct_answers = question[:answers].select do |answer|
		answer[:correct]
	end
	correct_answers = correct_answers.map { |a| a[:answer]}
	if (params['answers'] == nil)
		correct = false;
	else
		correct = correct_answers.sort == params['answers'].sort
	end
	str = "";
	if (correct)
		str << "Congratulation, right answer <br/>\n";
	else
		str << "Wrong answer.<br/>\n";
		str << "<form method=\"get\" action=\"/form_question\">\n";
		str << "<input type=\"hidden\" name=\"id\" value=#{id} />\n";
		str << "<input type=\"submit\" value=\"Retry question\" />\n";
		str << "</form>\n";
	end
	str << "<form method=\"get\" action=\"/form_question\">\n"
	str << "<input type=\"submit\" value=\"Next question\" />\n";
	str << "</form>\n";
	<<-HTML
#{str}
	HTML
#=end
end

post '/answer' do
	data = JSON.parse(request.body.read)
	question = QUESTIONS[data['id']]
	correct_answers = question[:answers].select do |answer|
		answer[:correct]
	end
	correct_answers = correct_answers.map { |a| a[:answer]}
	correct = correct_answers.sort == data['answers'].sort

	json(:correct => correct)
end



