//
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

  var items = [ItemViewModel]()
  var itemProvider: ItemProvider?

  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
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
      self.items = items
      self.refreshControl?.endRefreshing()
      self.tableView.reloadData()
    case let .failure(error):
      let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default))
      showDetailViewController(alert, sender: self)
      refreshControl?.endRefreshing()
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
    item.selection()
  }
}

extension UITableViewCell {

  func configure(item: ItemViewModel) {
    textLabel?.text = item.name
    detailTextLabel?.text = item.detail
  }
}
