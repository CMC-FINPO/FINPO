//
//  AlarmTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/11.
//

import Foundation
import UIKit
import RxSwift

class AlarmTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    public var fullStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillProportionally
        view.spacing = 10
        view.axis = .horizontal
        view.backgroundColor = UIColor(hexString: "F9F9F9")
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    public var alarmImageView: UIImageView = {
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: 25, height: 25))
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "alarm_active")?.withAlignmentRectInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.1)
        imageView.layer.cornerRadius = imageView.frame.width/2
        return imageView
    }()
    
    public var alarmButton: UIButton = {
        let button = UIButton(frame: .init(x: 0, y: 0, width: 25, height: 25))
        button.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.1)
        button.layer.cornerRadius = button.frame.width/2
        return button
    }()
    
    public var infoStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = .white
        return view
    }()
    
    public var alarmInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.textAlignment = .left
        return label
    }()
    
    public var alarmDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(hexString: "F9F9F9")
        
        contentView.addSubview(alarmButton)
        alarmButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(3)
            $0.top.equalToSuperview().inset(18.5)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(25)
        }
        
        contentView.addSubview(fullStackView)
        fullStackView.snp.makeConstraints {
            $0.leading.equalTo(alarmButton.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        
        fullStackView.addArrangedSubview(infoStackView)
        infoStackView.addArrangedSubview(alarmInfoLabel)
        infoStackView.addArrangedSubview(alarmDateLabel)
    }
    
    func remakeImage() {
        alarmButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(3)
            $0.top.equalToSuperview().inset(18.5)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(25)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}

