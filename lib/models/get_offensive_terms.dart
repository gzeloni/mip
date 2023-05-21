import 'dart:collection';

class TrieNode {
  final Map<String, TrieNode> children = HashMap();
  bool isEndOfWord = false;
}

class Trie {
  final TrieNode _root = TrieNode();

  /// Inserts a word into the trie.
  void insert(String word) {
    TrieNode? node = _root;
    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      if (!node!.children.containsKey(char)) {
        node.children[char] = TrieNode();
      }
      node = node.children[char];
    }
    node!.isEndOfWord = true;
  }

  /// Searches for a word in the trie.
  bool search(String word) {
    TrieNode node = _root;
    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      if (!node.children.containsKey(char)) {
        return false;
      }
      node = node.children[char]!;
    }
    return node.isEndOfWord;
  }
}

/// Verifies if any word in the given list is offensive using the trie.
List<String> verifyOffensiveWords(List<String> words, Trie trie) {
  final List<String> offensiveWords = [];

  for (final word in words) {
    if (trie.search(word)) {
      offensiveWords.add(word);
    }
  }

  return offensiveWords;
}
