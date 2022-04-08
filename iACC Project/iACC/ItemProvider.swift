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
}
