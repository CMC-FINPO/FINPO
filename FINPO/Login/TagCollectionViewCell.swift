//
//  TagCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/16.
//

import Foundation
import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    let tagLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        $0.textColor = UIColor(hexString: "5B43EF")
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "delete_point")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(tagLabel)
        contentView.addSubview(imageView)
//        contentView.bounds = contentView.frame.insetBy(dx: -5, dy: -5)
    }
    
    func setLayout() {
        tagLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(tagLabel.snp.centerY)
            $0.width.height.equalTo(25)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        frame.size.width = ceil(size.width)
        
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}
