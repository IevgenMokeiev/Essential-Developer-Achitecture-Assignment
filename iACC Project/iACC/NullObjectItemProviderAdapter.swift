//
// Copyright © EugeneMokeiev. All rights reserved.
//

struct NullObjectItemProviderAdapter: ItemProvider {

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  ) {
  }
}
