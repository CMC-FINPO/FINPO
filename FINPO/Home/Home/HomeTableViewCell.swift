//
//  HomeTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/22.
//

import Foundation
import UIKit

class HomeTableViewCell: UITableViewCell {
    public var regionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(hexString: "5B43EF")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        return label
    }()
    
    public var policyNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(hexString: "000000")
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        return label
    }()
    
    public var organizationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(hexString: "616161")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        return label
    }()
    
    public var bookMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "scrap_inactive"), for: .normal)
        button.setImage(UIImage(named: "scrap_active"), for: .selected)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        contentView.addSubview(regionLabel)
        contentView.addSubview(policyNameLabel)
        contentView.addSubview(organizationLabel)
        contentView.addSubview(bookMarkButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        regionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(17)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(70)
        }
        
        policyNameLabel.snp.makeConstraints {
            $0.top.equalTo(regionLabel.snp.bottom).offset(7)
            $0.leading.equalTo(regionLabel.snp.leading)
            $0.trailing.equalToSuperview()
        }
        
        organizationLabel.snp.makeConstraints {
            $0.top.equalTo(policyNameLabel.snp.bottom).offset(6)
            $0.leading.equalTo(policyNameLabel.snp.leading)
            $0.trailing.equalToSuperview()
        }
        
        bookMarkButton.snp.makeConstraints {
            $0.top.equalTo(regionLabel.snp.top)
            $0.leading.equalTo(regionLabel.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().inset(14)
            $0.height.equalTo(25)
            $0.height.equalTo(26)
        }
    }
}
