//	
// Copyright © Eugene Mokeiev. All rights reserved.
//

struct CardAPIItemProviderAdapter: ItemProvider {
  let api: CardAPI
  let selection: () -> Void

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  ) {
    api.loadCards { result in
      switch result {
      case .success(let cards):
        let items = cards.map { ItemViewModel(card: $0, selection: selection) }
        completion(.success(items))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
