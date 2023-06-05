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


// /// Realiza a busca em largura na Trie.
// bool bfsSearch(Trie trie, List<String> words, String word) {
//   TrieNode? node = trie._root;
//   Queue<TrieNode> queue = Queue<TrieNode>();
//   queue.add(node);

//   for (int i = 0; i < word.length; i++) {
//     final char = word[i];

//     while (queue.isNotEmpty) {
//       TrieNode current = queue.removeFirst();

//       if (current.children.containsKey(char)) {
//         node = current.children[char];
//         break;
//       }

//       for (var child in current.children.values) {
//         queue.add(child);
//       }
//     }
//   }

//   return node!.isEndOfWord;
// }

// /// Realiza a busca em profundidade na Trie.
// bool dfsSearch(TrieNode node, List<String> words, String word, int index) {
//   if (index == word.length) {
//     return node.isEndOfWord;
//   }

//   final char = word[index];

//   if (!node.children.containsKey(char)) {
//     return false;
//   }

//   TrieNode? nextNode = node.children[char];
//   return dfsSearch(nextNode!, words, word, index + 1);
// }
