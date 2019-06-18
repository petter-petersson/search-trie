class Trie
  class Node
    property parent : Node?
    property value : Char?
    property children : Set(Node)

    def_equals_and_hash @value

    def initialize(parent : Node?, value : Char?)
      @parent = parent
      @value = value
      @children = Set(Node).new
    end

    # unused
    def is_root?
      parent.nil? && value.nil?
    end

    def is_end?
      !parent.nil? && value.nil?
    end

    def add(ord : Array(Char))
      if ord.size > 0
        c = ord.delete_at(0)
        n = Node.new(parent: self, value: c)
        n1 = @children.find { |i| i == n }
        if n1.nil?
          @children.add(n)
          n.add(ord)
        else
          n1.add(ord)
        end
      else
        @children.add(Node.new(parent: self, value: nil))
      end
    end

    def to_s
      res = [] of Char?
      node = self
      while(node != nil)
        n = node.not_nil!
        res << n.value unless n.value.nil?
        node = n.parent
      end
      res.reverse.join
    end
  end

  property root : Node
  property fwd_max_nomatch_count : Int8
  property rwd_max_nomatch_count : Int8
  property min_relevance : Float32 # TODO: rename since it is relevance where we're *not* done

  def initialize(fwd_max_nomatch_count : Int8 = 1,
                 rwd_max_nomatch_count : Int8 = 1,
                 min_relevance : Float32 = 0.2)
    @root = Node.new(parent: nil, value: nil)
    @fwd_max_nomatch_count = fwd_max_nomatch_count
    @rwd_max_nomatch_count = rwd_max_nomatch_count
    @min_relevance = min_relevance # relevance val when done scanning input word n.b
  end

  def add(word : String)
    root.add(word.chars)
  end

  def all
    res = [] of String
    root.children.each do |child|
      collect(child, res)
    end
    res
  end

  def count
    all.size
  end

  def beginning_with(word : String)
    res = [] of String
    root.children.each do |child|
      recursive_strict(child, word.chars, 0, res)
    end
    res
  end

  def find(word : String)

    res = {} of String => Float64

    root.children.each do |child|
      recursive_lenient(child,
                        word.chars,
                        0,
                        0,
                        0,
                        0,
                        res)
    end
    res.to_a.sort_by do |value, relevance|
      relevance
    end.reverse
  end

  private def collect(node : Node, 
                      result : Enumerable(String))

    node.children.each do |child|
      collect(child, result)
    end
    if node.is_end?
      result << node.to_s
    end
  end

  private def recursive_strict(node : Node,
                               word : Array(Char),
                               position : Int,
                               result : Array(String))

    if word.size > 0 && position < word.size &&
        if node.value != word[position]
          return
    end
    end
    node.children.each do |child|
      recursive_strict(child, word, position + 1, result)
    end
    if node.is_end?
      result << node.to_s
    end
  end

  private def recursive_lenient(node : Node,
                                word : Array(Char),
                                position : Int,
                                match_count : Int,
                                fwd_count : Int,
                                rwd_count : Int,
                                result : Hash(String, Float))

    if node.is_end?
      s = node.to_s

      if match_count > 0

        relevance = match_count.to_f/s.size.to_f
        # puts "#{s} - match count: #{match_count}, " +
        #      "relevance: #{relevance}"

        # TODO: (de)increase relevance if word[0] == (!=)  s.first ?
        # TODO: 

        if s.size < word.size
          #TEST (lower short word ranking)
          #increase this penalty
          relevance = relevance * (s.size.to_f/word.size.to_f)
        end

        if result.has_key?(s)
          if result[s] < relevance
            result[s] = relevance
          end
        else
          result[s] = relevance
        end
      end
      return
    end

    if position >= word.size
      # just collect the rest without any adjustments etc

      if match_count > 0
        # on very large sets we need to limit response size
        s = node.to_s #collect what we got so far
        relevance = match_count.to_f/s.size.to_f

        if relevance > min_relevance
          node.children.each do |child|
            recursive_lenient(child,
                              word,
                              position,
                              match_count,
                              0,
                              0,
                              result)
          end
        end
      end
      return
    end

    if node.value == word[position]
      node.children.each do |child|
        recursive_lenient(child,
                          word,
                          position + 1,
                          match_count + 1,
                          0,
                          0,
                          result)
      end
    else
      if fwd_count < fwd_max_nomatch_count && node.value != nil
        node.children.each do |child|
          recursive_lenient(child,
                            word,
                            position,
                            match_count,
                            fwd_count + 1,
                            rwd_count,
                            result)
        end
      end

      if rwd_count < rwd_max_nomatch_count && node.value != nil
        recursive_lenient(node,
                          word,
                          position + 1,
                          match_count,
                          fwd_count,
                          rwd_count + 1,
                          result)
      end
    end
  end
end
