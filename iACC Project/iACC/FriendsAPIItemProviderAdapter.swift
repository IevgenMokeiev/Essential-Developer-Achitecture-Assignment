//	
// Copyright © EugeneMokeiev. All rights reserved.
//

struct FriendsAPIItemProviderAdapter: ItemProvider {
  let api: FriendsAPI
  let isPremium: Bool
  let cache: FriendsCache
  let selection: (Friend) -> Void

  func loadItems(
    completion: @escaping (Result<[ItemViewModel], Error>) -> Void
  ) {
    api.loadFriends { result in
      switch result {
      case .success(let friends):
        if isPremium {
          cache.save(friends)
        }
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
