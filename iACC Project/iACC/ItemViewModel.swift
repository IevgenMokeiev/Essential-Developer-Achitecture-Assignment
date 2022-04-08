//	
// Copyright © Eugene Mokeiev. All rights reserved.
//

import Foundation

struct ItemViewModel: Equatable {
  let name: String
  let detail: String
  let selection: () -> Void

  static func == (lhs: ItemViewModel, rhs: ItemViewModel) -> Bool {
    return lhs.name == rhs.name
  }
}

extension ItemViewModel {

  init(friend: Friend, selection: @escaping () -> Void) {
    self.init(
      name: friend.name,
      detail: friend.phone,
      selection: selection
    )
  }

  init(card: Card, selection: @escaping () -> Void) {
    self.init(
      name: card.number,
      detail: card.holder,
      selection: selection
    )
  }

  init(
    transfer: Transfer,
    longDateStyle: Bool,
    selection: @escaping () -> Void
  ) {
    let numberFormatter = Formatters.number
    numberFormatter.numberStyle = .currency
    numberFormatter.currencyCode = transfer.currencyCode

    let amount = numberFormatter.string(from: transfer.amount as NSNumber)!

    let dateFormatter = Formatters.date

    var detail: String = ""

    if longDateStyle {
      dateFormatter.dateStyle = .long
      dateFormatter.timeStyle = .short
      detail = "Sent to: \(transfer.recipient) on \(dateFormatter.string(from: transfer.date))"
    } else {
      dateFormatter.dateStyle = .short
      dateFormatter.timeStyle = .short
      detail = "Received from: \(transfer.sender) on \(dateFormatter.string(from: transfer.date))"
    }

    let name = "\(amount) • \(transfer.description)"

    self.init(
      name: name,
      detail: detail,
      selection: selection
    )
  }
}


