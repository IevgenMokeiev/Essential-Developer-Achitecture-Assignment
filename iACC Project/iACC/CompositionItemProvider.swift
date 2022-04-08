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
        fallbackAPI.loadItems { result in
          switch result {
          case .success(let items):
            completion(.success(items))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
    }
  }
}
