//	
// Copyright © Eugene Mokeiev. All rights reserved.
//

protocol ItemProvider {

  func loadItems(completion: @escaping (Result<[ItemViewModel], Error>) -> Void)
}
