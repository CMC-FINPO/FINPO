//
//  SettingTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/19.
//

import Foundation
import UIKit
import RxSwift

class SettingTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    public var settingNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(hexString: "000000")
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        return label
    }()
    
    public var controlSwitch: UISwitch = {
        let st = UISwitch()
        st.isHidden = true
        st.thumbTintColor = UIColor(hexString: "5B43EF")
        st.onTintColor = UIColor(hexString: "F0F0F0")
        st.layer.masksToBounds = true
        st.layer.cornerRadius = 15
        st.layer.borderWidth = 1
        st.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
        return st
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        
        contentView.addSubview(settingNameLabel)
        contentView.addSubview(controlSwitch)

        settingNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(21)
            $0.centerY.equalToSuperview()
        }
        
        controlSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(21)
            $0.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
}
