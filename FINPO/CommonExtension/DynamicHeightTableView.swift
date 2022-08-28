//
//  DynamicHeightTableView.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/26.
//

import Foundation
import UIKit

final class DynamicHeightTableView: UITableView {
  override var intrinsicContentSize: CGSize {
    let height = self.contentSize.height + self.contentInset.top + self.contentInset.bottom
    return CGSize(width: self.contentSize.width, height: height)
  }
  override func layoutSubviews() {
    self.invalidateIntrinsicContentSize()
    super.layoutSubviews()
  }
}
