//
//  ServiceTypeCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/03.
//

import Foundation
import UIKit
import SnapKit

class PolicyTypeCollectionViewCell: UICollectionViewCell {
    let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "5B43EF")
        label.backgroundColor = UIColor(hexString: "F0F0F0")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(tagLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tagLabel.snp.makeConstraints {
            $0.edges.equalTo(contentView.snp.edges)
        }
    }
}
