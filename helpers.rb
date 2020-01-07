MIN_WORDS_TO_HIDE = 1
MAX_WORDS_TO_HIDE = 5
POS_PUNCTUATION = %w[PP PPC PPD PPL PPR PPS LRB RRB]

# Utility function remove 30% of the words from a line and replace it with _.
def remove_words(line)
  line.split(' ').map do |word|
    rand <= 0.3 ? '_' * word.size : word
  end.join(' ')
end

# Turns text into the Anki format for a Cloze front-card.
def cloze_text(text)
  tagger = EngTagger.new
  note_with_tags = tagger.get_readable(text).split(' ')
  # Find the word_pairs in the note that we'll hide.
  candidate_words_to_hide_with_tag = Set.new
  note_with_tags.each do |word_tag_pair|
    _, tag = word_tag_pair.split('/')
    # Hide numbers and proper nouns.
    if tag == 'CD' || tag == 'NNP'
      candidate_words_to_hide_with_tag.add(word_tag_pair)
    end
  end
  # Shuffle the set so that we don't hide the first N words, but randomly dispersed words.
  candidate_words_to_hide_with_tag =
    Set.new(candidate_words_to_hide_with_tag).to_a.sample(MIN_WORDS_TO_HIDE + MAX_WORDS_TO_HIDE)
  # Build the content and hide candidates.
  card_content = ''
  hide_count = 0
  # This is non-sense that I hope we can remove one day.
  # Cloze must have at least 1 deletion so if there are no candidates above we hide the first word.
  note_with_tags.each_with_index do |word_tag_pair, index|
    word, tag = word_tag_pair.split('/')
    is_first_index = index.zero?
    can_add_space = !is_first_index && !POS_PUNCTUATION.include?(tag) # Not punctuation
    if (candidate_words_to_hide_with_tag.member?(word_tag_pair) && hide_count < MAX_WORDS_TO_HIDE) ||
       (candidate_words_to_hide_with_tag.empty? && hide_count == 0)
      hide_count += 1
      word = "{{c1::#{word}}}"
    end
    card_content << ' ' if can_add_space
    card_content << word
  end
  card_content
end
