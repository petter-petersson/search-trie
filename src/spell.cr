struct Spell
  LETTERS = "abcdefghijklmnopqrstuvxyzåäö"

  def self.expand(word)
    deletions(word) + transpositions(word) + alterations(word) + insertions(word)
  end

  def self.expand2(word)
    res = [] of String
    first_level = expand(word)
    first_level.each do |i|
      expand(i).each { |j| res << j }
    end
    res
  end

  private def self.deletions(word)
    n = word.chars.size
    (0...n).map { |i| (word[0...i] + word[i + 1..-1]) }.to_set
  end

  def self.transpositions(word)
    n = word.chars.size
    (0...n - 1).map { |i| (word[0...i] + word[i + 1, 1] + word[i, 1] + word[i + 2..-1]) }.to_set
  end

  def self.alterations(word)
    n = word.chars.size
    res = Set(String).new
    n.times do |i|
      LETTERS.chars.each { |l| res << (word[0...i] + l + word[i + 1..-1]) }
    end
    res
  end

  def self.insertions(word)
    n = word.chars.size
    res = Set(String).new
    (n + 1).times do |i|
      LETTERS.chars.each { |l| res << (word[0...i] + l + word[i..-1]) }
    end
    res
  end
end
