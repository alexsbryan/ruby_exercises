DICTIONARY = File.read("dictionary.txt").split("\n")

def adjacent_words (word, dictionary)

  word_chars = word.split("")
  found_words = []
  dictionary.each do |dict_word|
    off_chars = 0
    next if dict_word.length != word_chars.length
    word_chars.each_with_index do |char, index|

      off_chars += 1 if char != dict_word[index]

    end
    found_words << dict_word if off_chars == 1
  end
  found_words
end

def explore_words(source, dictionary)
  words_to_expand = [source]
  candidate_words = dictionary.select {|word| word.length == source.length}
  all_reachable_words = [source]

  while true

    more_words = adjacent_words(words_to_expand.pop,candidate_words)
    candidate_words = candidate_words-more_words
    words_to_expand.concat(more_words)
    all_reachable_words.concat(more_words)

    break if words_to_expand.empty?

  end

  all_reachable_words

end

def find_chain(source, target, dictionary)
  words_to_expand = [source]
  candidate_words = dictionary.select {|word| word.length == source.length}
  parents = {}

  while true
    parent_word = words_to_expand.pop

    break if parent_word == target

    more_words = adjacent_words(parent_word,candidate_words)
    candidate_words = candidate_words-more_words
    words_to_expand.concat(more_words)
    more_words.each { |child_word| parents[child_word] = parent_word}

  end

  parents[source] = nil
  build_path_from_breadcrumbs(parents, target)

end

def build_path_from_breadcrumbs(parents, target)
  path_array = [target]
  while true

    parent = parents[target]
    path_array << parent
    break if parents[parent].nil?

    target = parent
  end

  path_array

end
a = find_chain("duck", "ruby", DICTIONARY)
p a