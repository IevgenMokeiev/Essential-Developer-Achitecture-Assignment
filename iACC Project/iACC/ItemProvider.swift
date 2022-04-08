//	
// Copyright © Eugene Mokeiev. All rights reserved.
//

protocol ItemProvider {

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  )
}

extension ItemProvider {

  func fallback(_ otherProvider: ItemProvider) -> ItemProvider {
    return CompositionItemProvider(
      api: self,
      fallbackAPI: otherProvider
    )
  }

  func retry() -> ItemProvider {
    return fallback(self)
  }

  func retry(_ count: Int) -> ItemProvider {
    var provider: ItemProvider = self
    for _ in 1...count {
      provider = provider.fallback(self)
    }
    return provider
  }
}
