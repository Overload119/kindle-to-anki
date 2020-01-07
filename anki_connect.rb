# Handles communication with the AnkiConnect addon.
class AnkiConnect
  VERSION = 6
  attr_writer :deck_name

  # @param [Array<Hash>] the cards (each card has a front key and back key)
  def create_deck(deck_name)
    resp = HTTP.get('http://localhost:8765', json: {
      action: 'createDeck',
      version: 6,
      params: {
        deck: deck_name,
      },
    })
    catch_error(resp)
  end

  # Only supports Cloze cards for now.
  # Create several cards using the multi-API.
  def create_cards(cards)
    resp = HTTP.post('http://localhost:8765', json: {
      action: 'addNotes',
      version: 6,
      params: {
        notes: cards.map { |card| new_cloze_note(card) },
      },
    })
    catch_error(resp)
  end

  def new_cloze_note(card)
    {
      deckName: @deck_name,
      modelName: 'Cloze',
      tags: [],
      fields: {
        'Text': card['front'],
      },
    }
  end

  private

  def catch_error(resp)
    resp_json = JSON.parse(resp.body.to_s)
    puts "Error occurred: #{resp_json['error']}" unless resp_json['error'].nil?
  end
end
