import 'dart:collection';

class TrieNode {
  final Map<String, TrieNode> children = HashMap();
  bool isEndOfWord = false;
}

class Trie {
  final TrieNode _root = TrieNode();

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

List<String> verifyOffensiveWords(List<String> words, Trie trie) {
  final List<String> offensiveWords = [];

  for (final palavra in words) {
    if (trie.search(palavra)) {
      offensiveWords.add(palavra);
    }
  }

  return offensiveWords;
}
