//	
// Copyright © EugeneMokeiev. All rights reserved.
//

struct FriendsAPIItemProviderAdapter: ItemProvider {
  let api: FriendsAPI
  let selection: (ItemViewModel) -> Void

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  ) {
    api.loadFriends { result in
      switch result {
      case .success(let friends):
        let items = friends.map { ItemViewModel(friend: $0, selection: selection) }
        completion(.success(items))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
