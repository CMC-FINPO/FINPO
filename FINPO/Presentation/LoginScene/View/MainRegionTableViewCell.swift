//
//  MainRegionTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/07.
//

import UIKit
import SnapKit


class MainRegionTableViewCell: UITableViewCell {

    public var mainRegionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.G02
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        return label
    }()
    
    public var notReadyRegionLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textAlignment = .center
        label.textColor = UIColor.W01
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.backgroundColor = UIColor.G05
        label.text = "준비중"
        label.isHidden = true
        label.topInset = 5
        label.leftInset = 3
        label.rightInset = 3
        label.bottomInset = 5
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.G09
        contentView.addSubview(mainRegionLabel)
        contentView.addSubview(notReadyRegionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //property layout here
        mainRegionLabel.snp.makeConstraints {
            $0.center.equalTo(contentView.snp.center)
        }
        
    }
    
    func setRegionLayout() {
        mainRegionLabel.snp.remakeConstraints {
            $0.center.equalTo(contentView.snp.center)
        }
        mainRegionLabel.layoutIfNeeded()
    }
    
    func setLayout() {
        mainRegionLabel.textColor = UIColor.G05
        mainRegionLabel.textAlignment = .left
        mainRegionLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).offset(15)
            $0.centerY.equalTo(contentView.snp.centerY)
        }
        mainRegionLabel.layoutIfNeeded()
        
        notReadyRegionLabel.isHidden = false
        notReadyRegionLabel.snp.makeConstraints {
            $0.trailing.equalTo(contentView.snp.trailing).inset(10)
            $0.centerY.equalTo(contentView.snp.centerY)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        mainRegionLabel.textColor = selected ? UIColor.W01 : UIColor.G02
        contentView.backgroundColor = selected ? UIColor.P01 : UIColor.G09
    }
}
