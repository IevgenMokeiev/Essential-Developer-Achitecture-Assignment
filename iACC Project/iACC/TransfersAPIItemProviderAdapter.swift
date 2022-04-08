//
// Copyright © EugeneMokeiev. All rights reserved.
//

struct TransfersAPIItemProviderAdapter: ItemProvider {
  let api: TransfersAPI
  let fromSentTransfersScreen: Bool
  let selection: (ItemViewModel) -> Void

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  ) {
    api.loadTransfers { result in
      switch result {
      case .success(let transfers):
        var filteredItems = transfers
        if fromSentTransfersScreen {
          filteredItems = transfers.filter(\.isSender)
        } else {
          filteredItems = transfers.filter { !$0.isSender }
        }

        let items = filteredItems
          .map {
          ItemViewModel(
            transfer: $0,
            longDateStyle: fromSentTransfersScreen,
            selection: selection
          )
        }
        completion(.success(items))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
