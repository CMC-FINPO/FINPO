//
//  InterestCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/11.
//

import UIKit
import SnapKit

class InterestCollectionViewCell: UICollectionViewCell {
    
    var viewModel: LoginViewModel?
    var id = Int()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "test"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    func setup() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(15)
            $0.centerX.equalTo(contentView.snp.centerX)
            $0.width.equalTo(95)
            $0.height.equalTo(85)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.centerX.equalTo(imageView.snp.centerX)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                titleLabel.textColor = UIColor(hexString: "5B43EF")
            } else {
                imageView.layer.borderColor = UIColor(hexString: "000000").cgColor
                titleLabel.textColor = UIColor(hexString: "000000")
                                
                self.viewModel?.user.category.removeAll { $0 == id }
                self.viewModel?.input.interestButtonTapped.accept(())
            }
        }
    }
    
}
