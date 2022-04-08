//	
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

  convenience init() {
    self.init(nibName: nil, bundle: nil)
    self.setupViewController()
  }

  private func setupViewController() {
    viewControllers = [
      makeNav(for: makeFriendsList(), title: "Friends", icon: "person.2.fill"),
      makeTransfersList(),
      makeNav(for: makeCardsList(), title: "Cards", icon: "creditcard.fill")
    ]
  }

  private func makeNav(for vc: UIViewController, title: String, icon: String) -> UIViewController {
    vc.navigationItem.largeTitleDisplayMode = .always

    let nav = UINavigationController(rootViewController: vc)
    nav.tabBarItem.image = UIImage(
      systemName: icon,
      withConfiguration: UIImage.SymbolConfiguration(scale: .large)
    )
    nav.tabBarItem.title = title
    nav.navigationBar.prefersLargeTitles = true
    return nav
  }

  private func makeTransfersList() -> UIViewController {
    let sent = makeSentTransfersList()
    sent.navigationItem.title = "Sent"
    sent.navigationItem.largeTitleDisplayMode = .always

    let received = makeReceivedTransfersList()
    received.navigationItem.title = "Received"
    received.navigationItem.largeTitleDisplayMode = .always

    let vc = SegmentNavigationViewController(first: sent, second: received)
    vc.tabBarItem.image = UIImage(
      systemName: "arrow.left.arrow.right",
      withConfiguration: UIImage.SymbolConfiguration(scale: .large)
    )
    vc.title = "Transfers"
    vc.navigationBar.prefersLargeTitles = true
    return vc
  }

  private func makeFriendsList() -> ListViewController {

    let vc = ListViewController()
    var adapter: ItemProvider = FriendsAPIItemProviderAdapter(
      api: FriendsAPI.shared
    ) { [weak self] item in
      let destination = FriendDetailsViewController()
      vc.show(destination, sender: self)
    }

    if User.shared?.isPremium == true {
      let cacheAdapter = FriendsCacheItemProviderAdapter(
        cache: FriendsCache()
      ) { [weak self] item in
        let destination = FriendDetailsViewController()
        vc.show(destination, sender: self)
      }
      adapter = adapter.fallback(cacheAdapter)
    }

    vc.itemProvider = adapter
    vc.fromFriendsScreen = true
    return vc
  }

  private func makeSentTransfersList() -> ListViewController {
    let vc = ListViewController()
    let adapter = TransfersAPIItemProviderAdapter(
      api: TransfersAPI.shared,
      fromSentTransfersScreen: true
    ) { [weak self] item in
      let destination = TransferDetailsViewController()
      destination.item = item
      vc.show(destination, sender: self)
    }
    vc.itemProvider = adapter
    vc.fromSentTransfersScreen = true
    return vc
  }

  private func makeReceivedTransfersList() -> ListViewController {
    let vc = ListViewController()
    let adapter = TransfersAPIItemProviderAdapter(
      api: TransfersAPI.shared,
      fromSentTransfersScreen: false
    ) { [weak self] item in
      let destination = TransferDetailsViewController()
      destination.item = item
      vc.show(destination, sender: self)
    }
    vc.itemProvider = adapter
    vc.fromReceivedTransfersScreen = true
    return vc
  }

  private func makeCardsList() -> ListViewController {
    let vc = ListViewController()
    let adapter = CardAPIItemProviderAdapter(
      api: CardAPI.shared
    ) { [weak self] item in
      let destination = CardDetailsViewController()
      destination.item = item
      vc.show(destination, sender: self)
    }
    vc.itemProvider = adapter
    vc.fromCardsScreen = true
    return vc
  }
}
