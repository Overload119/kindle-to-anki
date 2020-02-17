#!/usr/bin/env ruby

require 'byebug'
require 'concurrent-ruby'
require 'engtagger'
require 'optparse'
require 'pry'
require 'smarter_csv'
require 'tty-prompt'

require_relative('anki_writer')
require_relative('helpers')

options = {}

OptionParser.new do |parser|
  parser.on(
    '-dir',
    '--directory PATH',
    'Input a folder - all HTML files will turn into decks'
  ) { |v| options[:dir] = File.expand_path(v) }
  parser.on(
    '-i',
    '--input-file PATH',
    'Input a file. The file will be turned into a Deck'
  ) { |v| options[:'input-file'] = File.expand_path(v) }
end.parse!

prompt = TTY::Prompt.new

OPTIONS = [
  'Create Cloze cards from highlights in a folder',
  'Create Cloze cards from highlights in a file'
]
action = prompt.select('What do you want to do?', OPTIONS)

case action
when OPTIONS[0]
  Dir[options[:dir]].each do |path|
    deck_name, _ = File.basename(path).split('.')
    writer = AnkiWriter.new(deck_name)
    writer.input_file = path
    writer.generate_cards(:cloze)
    next unless prompt.yes?("This will create #{writer.cards.size} cards in '#{deck_name}'. Continue?")
    writer.write_to_anki
  end
when OPTIONS[1]
  path = prompt.ask('Which file?', default: options[:'input-file'])
  deck_name, _ = File.basename(path).split('.')
  writer = AnkiWriter.new(deck_name)
  writer.input_file = path
  writer.generate_cards(:cloze)
  exit() unless prompt.yes?("This will create #{writer.cards.size} cards in '#{deck_name}'. Continue?")
  writer.write_to_anki
end

puts 'Done.'
