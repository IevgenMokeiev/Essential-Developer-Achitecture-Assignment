///
// Copyright © Eugene Mokeiev. All rights reserved.
//

struct CompositionItemProvider: ItemProvider {
  let api: ItemProvider
  let fallbackAPI: ItemProvider

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  ) {
    api.loadItems { result in
      switch result {
      case let .success(items):
        completion(.success(items))
      case .failure:
        fallbackAPI.loadItems { items in
          switch result {
          case let .success(items):
            completion(.success(items))
          case let .failure(error):
            completion(.failure(error))
          }
        }
      }
    }
  }
}
