//
//  AddPurposeCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/25.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class AddPurposeCollectionViewCell: UICollectionViewCell {
    
    var bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var statusButton: UIButton = {
        let button = UIButton()
        button.isUserInteractionEnabled = false
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        button.setTitleColor(UIColor(hexString: "000000"), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 3
    }
    
    func setup() {
        contentView.backgroundColor = UIColor(hexString: "F0F0F0")
        contentView.addSubview(statusButton)
        statusButton.snp.makeConstraints {
            $0.center.equalTo(contentView.snp.center)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = UIColor(hexString: "5B43EF")
                statusButton.setBackgroundColor(UIColor(hexString: "5B43EF"), for: .normal)
                statusButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
            } else {
                contentView.backgroundColor = UIColor(hexString: "F0F0F0")
                statusButton.setBackgroundColor(UIColor(hexString: "F0F0F0"), for: .normal)
                statusButton.setTitleColor(UIColor(hexString: "000000"), for: .normal)
            }
        }
    }
    
    override func prepareForReuse() {
        self.prepareForReuse()
        
        bag = DisposeBag()
    }
    
}
