//
//  ParticipationTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/07.
//

import Foundation
import UIKit

class ParticipationTableViewCell: UITableViewCell {
    public var regionLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textAlignment = .left
        label.textColor = UIColor(hexString: "5B43EF")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
//        label.rightInset = 2
//        label.leftInset = 2
//        label.topInset = 2
//        label.bottomInset = 2
        label.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.1)
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
    
    public var memoStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = UIColor(hexString: "F9F9F9")
        view.spacing = 5
        view.alignment = .leading
        return view
    }()
    
    public var memoTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "494949")
        return label
    }()
    
    public var memoEditButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hexString: "5B43EF"), for: .normal)
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        button.setImage(UIImage(named: "memo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setTitle("메모 작성", for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        contentView.addSubview(regionLabel)
        contentView.addSubview(policyNameLabel)
        contentView.addSubview(organizationLabel)
        contentView.addSubview(bookMarkButton)
        contentView.addSubview(memoStackView)
        memoStackView.addArrangedSubview(memoTextLabel)
        memoStackView.addArrangedSubview(memoEditButton)
        
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
            $0.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(25)
            $0.width.equalTo(26)
        }
        
        memoStackView.snp.makeConstraints {
            $0.top.equalTo(organizationLabel.snp.bottom).offset(5)
            $0.leading.equalTo(organizationLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(10)
        }

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

        
    }
}
