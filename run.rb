require 'smarter_csv'
require 'tty-prompt'
require 'optparse'
require 'byebug'

require_relative('anki_web_client.rb')
require_relative('helpers')

# Usage:
# bundle exec ruby csv_to_anki.rb --username XXXXX --password XXXXX --input-file sample_input.csv
# username: Password to ankiweb.net
# password: Password to ankiweb.net

options = {}

OptionParser.new do |parser|
  parser.on('-u', '--username USERNAME', 'Username to AnkiWeb.net') do |v|
    options[:username] = v
  end
  parser.on('-p', '--password USERNAME', 'Password to AnkiWeb.net') do |v|
    options[:password] = v
  end
  parser.on('-in', '--input-file FILEPATH', 'Input file to turn into a Deck') do |v|
    options[:input_file] = v
  end
end.parse!

unless File.exist?(options[:input_file])
  puts 'Input file is missing. Use -in FILEPATH'
end

client = AnkiWebClient.new(options[:username], options[:password])
client.add_card('test', 'test card', 'hello world')

csv = CSV.read(options[:input_file])

book_title = csv[1][0]
annotation_row_start_index = csv.find_index do |row|
  row[0] =~ /Highlight/ # first column is Highlight
end

cards_added = 0
csv.drop(annotation_row_start_index).each do |highlight_row|
  highlight_text = highlight_row[3]
  highlight_preview_text =
    if highlight_text.size > 80
      highlight_text[0..77] + '...'
    else
      highlight_text[0..80]
    end
  client.add_card(book_title, remove_words(highlight_text), highlight_text)
  cards_added += 1
  puts "Adding [#{book_title}] ... \"#{highlight_preview_text}\""
end

puts "Added #{cards_added} card(s)."
