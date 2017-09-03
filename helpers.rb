# Utility function remove 30% of the words from a line and replace it with _.
def remove_words(line)
  line.split(' ').map do |word|
    rand <= 0.3 ? '_' * word.size : word
  end.join(' ')
end
