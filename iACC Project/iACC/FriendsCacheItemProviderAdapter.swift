//
// Copyright © EugeneMokeiev. All rights reserved.
//

struct FriendsCacheItemProviderAdapter: ItemProvider {
  let cache: FriendsCache
  let selection: (ItemViewModel) -> Void

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  ) {
    cache.loadFriends { result in
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
