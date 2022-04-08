//
// Copyright © EugeneMokeiev. All rights reserved.
//

struct TransfersAPIItemProviderAdapter: ItemProvider {
  let api: TransfersAPI
  let fromSentTransfersScreen: Bool
  let selection: (Transfer) -> Void

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
          .map { transfer in
          ItemViewModel(
            transfer: transfer,
            longDateStyle: fromSentTransfersScreen) {
              selection(transfer)
            }
        }
        completion(.success(items))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
