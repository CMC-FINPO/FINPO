//
//  ServiceTypeCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/03.
//

import Foundation
import UIKit
import SnapKit

class ServiceTypeCollectionViewCell: UICollectionViewCell {
    
    var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "check")
        return imageView
    }()
    
    var tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 14)
        label.textColor = UIColor(hexString: "000000")
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(checkImageView)
        contentView.addSubview(tagLabel)
        contentView.layer.masksToBounds = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        tagLabel.preferredMaxLayoutWidth = tagLabel.frame.size.width
        super.layoutSubviews()
    }
    
    func configureLabels() {
        checkImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).offset(16)
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.width.height.equalTo(25)
        }
        tagLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).priority(999)
            $0.leading.equalTo(checkImageView.snp.trailing).offset(12)
            $0.bottom.equalTo(contentView.snp.bottom)
//            $0.centerY.equalTo(contentView.snp.centerY)
            $0.trailing.equalTo(contentView.snp.trailing).inset(17)
            $0.height.greaterThanOrEqualTo(24)
        }
    }
    
    func sizeFittingWith(cellHeight: CGFloat, text: String) -> CGSize {
        tagLabel.text = text
        
        // ✅ systemLayoutSizeFitting 메서드 파라미터에 필요한 targetSize(선호하는 사이즈)를 만들어보자.
        // ✅ 너비의 경우 intrincsicContentSize 에 딱 맞도록 최소 크기를 위해서 layoutFittingCompressedSize 를 사용해서 설정.
        // ✅ 높이의 경우 파라미터로 받아온 고정 값 설정.
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: cellHeight)
        
        // ✅ targetSize 를 만들어주었으니 선호하는 사이즈를 명시할 수 있겠죠!
        // ✅ horizontal constraints(너비)는 contentView 에 따라서 늘어나야하기 때문에 우선순위가 낮고 최대한 targetSize 와 가까운 값을 얻는 fittingSizeLevel 로 설정.
        // ✅ vertical constraints(높이)는 targetSize 에 맞춰야하니 우선순위가 가장 높은 required 로 설정.
        return self.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
}

