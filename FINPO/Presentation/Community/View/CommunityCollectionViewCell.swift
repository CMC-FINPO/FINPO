//
//  CommunityCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

///커뮤니티 상세 게시글 사진용
class CommunityCollectionViewCell: UICollectionViewCell {
    
    var disposeBag = DisposeBag()
    var delegate: UIViewController?
    var viewModel: CommunityWritingViewModel?
    var editViewModel: BoardEditViewModelType?
    
    var detailsTap : Observable<Void> {
        return self.checkImageBtn.rx.tap.asObservable()
    }
    
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    public var checkImageBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "delete_gray"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.width.equalTo(90)
            $0.height.equalTo(90)
            $0.center.equalToSuperview()
        }
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        
        imageView.addSubview(checkImageBtn)
        checkImageBtn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.trailing.equalToSuperview().inset(7)
            $0.height.width.equalTo(25)
        }
    }
    
    func removeImage(imgUrl: String) {
        self.detailsTap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let ac = UIAlertController(title: "이 이미지를 삭제하시겠습니까?", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { action in
                    self.removeFromSuperview()
                    let urls = self.viewModel?.input.imgUrlStorage.value.filter{ $0 != imgUrl }
                    if let urls = urls {
                        self.viewModel?.input.imgUrlStorage.accept(urls)
                        let refreshedBoardImg = BoardImageResponseModel(data: BoardImageDataDetail(imgUrls: urls))
                        self.viewModel?.output.loadImages.accept(refreshedBoardImg)
                    }
                }))
                ac.addAction(UIAlertAction(title: "취소", style: .cancel))
                self.delegate?.present(ac, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    func editRemoveImage(imgUrl: String) {
        self.detailsTap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let ac = UIAlertController(title: "이 이미지를 삭제하시겠습니까?", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { action in
                    self.removeFromSuperview()
                    let urls = self.editViewModel?.editedImg.value.filter { $0 != imgUrl }
                    if let urls = urls {
                        self.editViewModel?.editedImg.accept(urls)
                    }
                    var data = [BoardImgDetail]()
                    if let urls = urls {
                        for i in 0..<urls.count {
                            data.append(BoardImgDetail(img: urls[i], order: i))
                        }
                    }
                    self.editViewModel?.originData.accept(CommunityDetailBoardResponseModel(data: BoardDataDetail(status: false, id: -1, content: "", anonymity: false, likes: 0, hits: 0, countOfComment: 0, user: nil, isMine: false, isLiked: false, isBookmarked: false, isModified: false, createdAt: "", modifiedAt: "", imgs: data)))
                           
                }))
                ac.addAction(UIAlertAction(title: "취소", style: .cancel))
                self.delegate?.present(ac, animated: true)
            }).disposed(by: disposeBag)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
        
}
