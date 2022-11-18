//
//  ServiceTypeCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/03.
//

import Foundation
import UIKit
import SnapKit

class ServiceTypeCollectionViewCell: UICollectionViewCell {
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(memoStackView)
        memoStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.leading.equalToSuperview().inset(10)
            $0.width.lessThanOrEqualTo(UIScreen.main.bounds.width-100)
            $0.bottom.equalToSuperview()
//            $0.bottom.greaterThanOrEqualToSuperview()
        }
        
        memoStackView.addArrangedSubview(checkImageView)
        
//        memoStackView.addArrangedSubview(tagLabel)
        tagView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints {
            $0.size.equalToSuperview()
        }
        memoStackView.addArrangedSubview(tagView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func configureLabels() {
        
    }
    
    func sizeFittingWith(cellHeight: CGFloat, text: String) -> CGSize {
        tagLabel.text = text
        
        // ✅ systemLayoutSizeFitting 메서드 파라미터에 필요한 targetSize(선호하는 사이즈)를 만들어보자.
        // ✅ 너비의 경우 intrincsicContentSize 에 딱 맞도록 최소 크기를 위해서 layoutFittingCompressedSize 를 사용해서 설정.
        // ✅ 높이의 경우 파라미터로 받아온 고정 값 설정.
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: cellHeight)
        
        // ✅ targetSize 를 만들어주었으니 선호하는 사이즈를 명시할 수 있겠죠!
        // ✅ horizontal constraints(너비)는 contentView 에 따라서 늘어나야하기 때문에 우선순위가 낮고 최대한 targetSize 와 가까운 값을 얻는 fittingSizeLevel 로 설정.
        // ✅ vertical constraints(높이)는 targetSize 에 맞춰야하니 우선순위가 가장 높은 required 로 설정.
        return self.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
}

