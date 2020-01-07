#!/usr/bin/env ruby

require 'byebug'
require 'concurrent-ruby'
require 'engtagger'
require 'optparse'
require 'pry'
require 'smarter_csv'
require 'tty-prompt'

require_relative('anki_web_client')
require_relative('anki_writer')
require_relative('helpers')
require_relative('kindle_note_reader')
require_relative('anki_connect')

options = {}

OptionParser.new do |parser|
  parser.on(
    '-dir',
    '--directory PATH',
    'Input a folder - all HTML files will turn into decks'
  ) { |v| options[:dir] = File.expand_path(v) }
end.parse!

prompt = TTY::Prompt.new

OPTION_1 = 'Create Cloze cards from highlights in a folder'
action = prompt.select('What do you want to do?', [
  'Create Cloze cards from highlights in a folder',
])

if action == OPTION_1
  Dir[options[:dir]].each do |path|
    puts "Processing #{path}..."
    reader = KindleNoteReader.new(path)
    cards = []
    reader.notes.each do |note|
      cards << {
        'front' => cloze_text(note),
      }
    end
    deck_name, _ = File.basename(path).split('.')
    next unless prompt.yes?("This will create #{cards.size} cards in '#{deck_name}'. Continue?")
    connect = AnkiConnect.new
    connect.create_deck(deck_name)
    connect.deck_name = deck_name
    connect.create_cards(cards)
  end
end

puts 'Done.'
