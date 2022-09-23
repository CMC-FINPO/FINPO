//
//  CommunityCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/24.
//

import Foundation
import UIKit
import SnapKit

///커뮤니티 상세 게시글 사진용
class CommunityCollectionViewCell: UICollectionViewCell {
    
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private var checkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Interest_check")
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.width.equalTo(90)
            $0.height.equalTo(90)
            $0.center.equalToSuperview()
        }
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}
