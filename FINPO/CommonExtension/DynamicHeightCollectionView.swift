//
//  DynamicHeightCollectionView.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/23.
//

import Foundation
import UIKit

///댓글, 대댓글용 컬렉션뷰
class DynamicHeightCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

