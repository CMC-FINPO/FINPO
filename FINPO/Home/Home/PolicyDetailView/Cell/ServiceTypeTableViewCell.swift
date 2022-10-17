//
//  ServiceTypeTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/20.
//

import Foundation
import UIKit
import RxSwift

class ServiceTypeTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    public var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "check")
        return imageView
    }()
    
    private var tagView: UIView = {
        let tagView = UIView()
        tagView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner]
        tagView.layer.masksToBounds = true
        tagView.translatesAutoresizingMaskIntoConstraints = false
        return tagView
    }()
    
    public var tagLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 14)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    public var memoStackView: UIStackView = {
        let view = UIStackView()
//        view.axis = .vertical
        view.axis = .horizontal
        view.backgroundColor = .clear
        view.spacing = 5
        view.alignment = .leading
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.3)
        contentView.addSubview(checkImageView)
        checkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(2)
            $0.width.height.equalTo(25)
        }
        
        contentView.addSubview(memoStackView)
        memoStackView.addArrangedSubview(tagLabel)
        memoStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.leading.equalToSuperview().inset(30)
            $0.width.lessThanOrEqualTo(UIScreen.main.bounds.width-100)
            $0.bottom.equalToSuperview()
//            $0.height.greaterThanOrEqualTo(100)
        }
        
  
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
