import 'dart:collection';

extension ListExtensions<E> on List<E> {
  List<E> removeAll(Iterable<E> allToRemove) {
    // ignore: unnecessary_null_comparison
    if (allToRemove == null) {
      return this;
    } else {
      for (var element in allToRemove) {
        remove(element);
      }
      return this;
    }
  }

  List<E> distinctBy(dynamic Function(E) keySelector) {
    HashSet<dynamic> set = HashSet();
    List<E> list = [];

    forEach((e) {
      final key = keySelector(e);
      if (set.add(key)) {
        list.add(e);
      }
    });

    return list;
  }

  List<E> getDupes({dynamic Function(E)? distinctBy}) {
    List<E> dupes = List.from(this);

    if (distinctBy == null) {
      dupes.removeAll(toSet().toList());
    } else {
      dupes.removeAll(this.distinctBy(distinctBy).toSet().toList());
    }

    return dupes;
  }
}
