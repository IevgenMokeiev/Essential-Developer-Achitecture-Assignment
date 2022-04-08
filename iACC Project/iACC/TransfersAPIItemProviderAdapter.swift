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
        let items = transfers
          .filter { fromSentTransfersScreen ? $0.isSender : !$0.isSender }
          .map { transfer in
            ItemViewModel(
              transfer: transfer,
              longDateStyle: fromSentTransfersScreen
            ) {
              selection(transfer)
            }
          }
        completion(.success(items))
      case .failure(let error):
        print("OH SHIT ERROR\(error)")
        completion(.failure(error))
      }
    }
  }
}
