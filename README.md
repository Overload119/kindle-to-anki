# Kindle to Anki

Purpose: I want a way to convert Exported Kindle Notes into Anki cards so I can review it on the Anki mobile app.

- Parse exported Book Notes (currently only HTML is supported).
- Connect to AnkiWeb to create Cloze type cards by automatically remove words in the card.

## Usage

- `git clone`
- `bundle`
- Rename `config.sample.json -> config.json` and fill it out with your details.
- `bundle exec ./run.rb --input-file './debt.highlights.example.html' --deck Test`
