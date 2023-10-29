import 'dart:collection';

class TrieNode {
  final Map<String, TrieNode> children = HashMap();
  bool isEndOfWord = false;
}

class Trie {
  final TrieNode _root = TrieNode();

  /// Inserts a word into the trie.
  void insert(String word) {
    TrieNode node = _root;
    for (final char in word.codeUnits) {
      final charString = String.fromCharCode(char);
      if (!node.children.containsKey(charString)) {
        node.children[charString] = TrieNode();
      }
      node = node.children[charString]!;
    }
    node.isEndOfWord = true;
  }

  /// Searches for a word in the trie.
  bool search(String word) {
    TrieNode node = _root;
    for (final char in word.codeUnits) {
      final charString = String.fromCharCode(char);
      if (!node.children.containsKey(charString)) {
        return false;
      }
      node = node.children[charString]!;
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
