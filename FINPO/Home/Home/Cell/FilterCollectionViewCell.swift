//
//  FilterTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/30.
//

import Foundation
import UIKit
import SnapKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    var data: MyInterestSectionType?
    
    lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(tagLabel)
        contentView.backgroundColor = UIColor(hexString: "F0F0F0")
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 3
        tagLabel.snp.makeConstraints {
            $0.center.equalTo(contentView.snp.center)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
 
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func configureCell(data: MyInterestSectionType) {
        self.data = data
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = UIColor(hexString: "5B43EF")
                tagLabel.textColor = UIColor(hexString: "FFFFFF")
            } else {
                contentView.backgroundColor = UIColor(hexString: "F0F0F0")
                tagLabel.textColor = UIColor(hexString: "000000")
            }
        }
    }
}
