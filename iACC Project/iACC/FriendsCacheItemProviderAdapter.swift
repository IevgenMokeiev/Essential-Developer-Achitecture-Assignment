//
// Copyright © EugeneMokeiev. All rights reserved.
//

struct FriendsCacheItemProviderAdapter: ItemProvider {
  let cache: FriendsCache
  let selection: (Friend) -> Void

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  ) {
    cache.loadFriends { result in
      switch result {
      case .success(let friends):
        let items = friends.map { friend in
          ItemViewModel(friend: friend) {
            selection(friend)
          }
        }
        completion(.success(items))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
