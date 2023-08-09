extension Filter<T> on Stream<List<T>> {
  //We took the stream and made it to the stream with list of specific objects .
  Stream<List<T>> filter(bool Function(T) where) => map(
        (items) => items.where(where).toList(),
      );
}
