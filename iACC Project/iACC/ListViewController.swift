//
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
  var items = [ItemViewModel]()

  var retryCount = 0
  var maxRetryCount = 0
  var shouldRetry = false

  var longDateStyle = false

  var fromReceivedTransfersScreen = false
  var fromSentTransfersScreen = false
  var fromCardsScreen = false
  var fromFriendsScreen = false

  var itemProvider: ItemProvider?

  override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

    if fromFriendsScreen {
      shouldRetry = true
      maxRetryCount = 2

      title = "Friends"

      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))

    } else if fromCardsScreen {
      shouldRetry = false

      title = "Cards"

      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCard))

    } else if fromSentTransfersScreen {
      shouldRetry = true
      maxRetryCount = 1
      longDateStyle = true

      navigationItem.title = "Sent"
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendMoney))

    } else if fromReceivedTransfersScreen {
      shouldRetry = true
      maxRetryCount = 1
      longDateStyle = false

      navigationItem.title = "Received"
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Request", style: .done, target: self, action: #selector(requestMoney))
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if tableView.numberOfRows(inSection: 0) == 0 {
      refresh()
    }
  }

  @objc private func refresh() {
    refreshControl?.beginRefreshing()

    itemProvider?.loadItems(completion: { [weak self] result in
      DispatchQueue.mainAsyncIfNeeded {
        self?.handleAPIResult(result)
      }
    })
  }

  private func handleAPIResult(
    _ result: Result<[ItemViewModel], Error>
  ) {
    switch result {
    case let .success(items):
      if fromFriendsScreen && User.shared?.isPremium == true {
        (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).cache.save(items as! [Friend])
      }
      self.retryCount = 0
      self.items = items
      self.refreshControl?.endRefreshing()
      self.tableView.reloadData()
    case let .failure(error):
      if shouldRetry && retryCount < maxRetryCount {
        retryCount += 1
        refresh()
        return
      }

      retryCount = 0


      let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default))
      self.presenterVC.present(alert, animated: true)
      self.refreshControl?.endRefreshing()
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  override func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    items.count
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let item = items[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ItemCell")

    cell.configure(item: item)

    return cell
  }

  override func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    let item = items[indexPath.row]
    item.selection(item)
  }

  @objc func addCard() {
    show(AddCardViewController(), sender: self)
  }

  @objc func addFriend() {
    show(AddFriendViewController(), sender: self)
  }

  @objc func sendMoney() {
    show(SendMoneyViewController(), sender: self)
  }

  @objc func requestMoney() {
    show(RequestMoneyViewController(), sender: self)
  }
}

extension UITableViewCell {

  func configure(item: ItemViewModel) {
    textLabel?.text = item.name
    detailTextLabel?.text = item.detail
  }
}
