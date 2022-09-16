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
        return imageView
    }()
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "test"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor.B01
        return label
    }()
    
    private var checkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Interest_check")
        imageView.isHidden = true
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 3
    }
    
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
        
        addSubview(checkImage)
        checkImage.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(10)
            $0.leading.equalTo(contentView.snp.leading).offset(10)
            $0.height.width.equalTo(25)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.layer.borderColor = UIColor.P01.cgColor
                contentView.backgroundColor = UIColor.P01.withAlphaComponent(0.1)
                titleLabel.textColor = UIColor.P01
                checkImage.isHidden = false
            } else {
                contentView.layer.borderColor = UIColor.B01.cgColor
                contentView.backgroundColor = .clear
                titleLabel.textColor = UIColor.B01
                self.viewModel?.user.category.removeAll { $0 == id }
                self.viewModel?.input.interestButtonTapped.accept(())
                checkImage.isHidden = true
            }
        }
    }
    
}
