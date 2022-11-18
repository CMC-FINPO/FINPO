//
//  BookmarkCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/10.
//

import Foundation
import SnapKit
import UIKit

class BookmarkCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(imageView)
//        imageView.snp.makeConstraints {
//            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(-15)
//            $0.centerX.equalTo(contentView.snp.centerX)
//            $0.width.equalTo(95)
//            $0.height.equalTo(85)
//        }
        
        stackView.addArrangedSubview(titleLabel)
//        titleLabel.snp.makeConstraints {
//            $0.top.equalTo(imageView.snp.bottom).offset(10)
//            $0.centerX.equalTo(imageView.snp.centerX)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "test"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    public var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .center
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }

}
