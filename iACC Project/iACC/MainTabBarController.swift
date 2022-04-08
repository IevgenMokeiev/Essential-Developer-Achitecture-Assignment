//	
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

  let cache: FriendsCache

  init(cache: FriendsCache) {
    self.cache = cache
    super.init(nibName: nil, bundle: nil)
    self.setupViewController()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

    let cacheAdapter = FriendsCacheItemProviderAdapter(
      cache: cache
    ) { [weak self] friend in
      let destination = FriendDetailsViewController()
      destination.friend = friend
      vc.show(destination, sender: self)
    }
    let apiAdapter: ItemProvider = FriendsAPIItemProviderAdapter(
      api: FriendsAPI.shared,
      isPremium: User.shared?.isPremium == true,
      cache: cache
    ) { [weak self] friend in
      let destination = FriendDetailsViewController()
      destination.friend = friend
      vc.show(destination, sender: self)
    }.retry(2)

    var adapter = apiAdapter
    if User.shared?.isPremium == true {
      adapter = apiAdapter.fallback(cacheAdapter)
    }

    vc.itemProvider = adapter
    vc.title = "Friends"

    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
    return vc
  }

  private func makeSentTransfersList() -> ListViewController {
    let vc = ListViewController()
    let adapter = TransfersAPIItemProviderAdapter(
      api: TransfersAPI.shared,
      fromSentTransfersScreen: true
    ) { [weak self] transfer in
      let destination = TransferDetailsViewController()
      destination.transfer = transfer
      vc.show(destination, sender: self)
    }.retry(1)
    vc.itemProvider = adapter
    vc.navigationItem.title = "Sent"
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendMoney))
    return vc
  }

  private func makeReceivedTransfersList() -> ListViewController {
    let vc = ListViewController()
    let adapter = TransfersAPIItemProviderAdapter(
      api: TransfersAPI.shared,
      fromSentTransfersScreen: false
    ) { [weak self] transfer in
      let destination = TransferDetailsViewController()
      destination.transfer = transfer
      vc.show(destination, sender: self)
    }.retry(1)
    vc.itemProvider = adapter
    vc.navigationItem.title = "Received"
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Request", style: .done, target: self, action: #selector(requestMoney))
    return vc
  }

  private func makeCardsList() -> ListViewController {
    let vc = ListViewController()
    let adapter = CardAPIItemProviderAdapter(
      api: CardAPI.shared
    ) { [weak self] card in
      let destination = CardDetailsViewController()
      destination.card = card
      vc.show(destination, sender: self)
    }
    vc.itemProvider = adapter
    vc.title = "Cards"
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCard))
    return vc
  }

  // MARK: - Actions

  @objc func addCard() {
    selectedViewController?.show(AddCardViewController(), sender: self)
  }

  @objc func addFriend() {
    selectedViewController?.show(AddFriendViewController(), sender: self)
  }

  @objc func sendMoney() {
    selectedViewController?.show(SendMoneyViewController(), sender: self)
  }

  @objc func requestMoney() {
    selectedViewController?.show(RequestMoneyViewController(), sender: self)
  }
}
