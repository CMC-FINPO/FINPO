//
//  BoardEditViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/06.
//

import Foundation
import UIKit
import PhotosUI
import RxSwift
import Kingfisher
import RxCocoa

class BoardEditViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel  : BoardEditViewModelType
    let pageId     : Int
    
    init(viewModel: BoardEditViewModelType = BoardEditViewModel(), pageId: Int) {
        self.viewModel = viewModel
        self.pageId = pageId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = BoardEditViewModel()
        pageId = -1
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private lazy var boardTextView: UITextView = {
        let textView = UITextView()
        textView.text = "글자 수는 최대 1000자입니다."
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
//        textView.textColor = .secondaryLabel
        textView.returnKeyType = .done
        textView.delegate = self
        return textView
    }()
    
    private var barButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
    
    public lazy var imageCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.minimumInteritemSpacing = 15
        flow.minimumLineSpacing = 15
        let cv = UICollectionView(frame: .init(), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(CommunityCollectionViewCell.self, forCellWithReuseIdentifier: "CommunityCollectionViewCell")
        cv.delegate = self
        return cv
    }()
    
    private var bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var albumButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.setImage(UIImage(named: "AlbumImg"), for: .normal)
        button.addTarget(self, action: #selector(didTapSelectBoardImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.medium
       return indicator
    }()
    
    private func setAttribute() {
        view.backgroundColor = UIColor.G09
        barButton.setTitle("수정하기", for: .normal)
        barButton.setTitleColor(UIColor.P01, for: .normal)
        barButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
    }
    
    private func setLayout() {
        view.addSubview(boardTextView)
        boardTextView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(200)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        bottomView.addSubview(albumButton)
        albumButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(45)
            $0.width.height.equalTo(25)
        }
        
        view.addSubview(imageCollectionView)
        imageCollectionView.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(105)
        }
        
        view.addSubview(indicator)
    }
    
    private func setInputBind() {
        rx.viewWillAppear.asDriver { _ in return .never()}
            .debug()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.getOriginData.onNext(self.pageId)
            }).disposed(by: disposeBag)
        
        boardTextView.rx.text
            .bind { [weak self] text in
                if let text = text {
                    self?.viewModel.textObserver.onNext(text)
                }
            }.disposed(by: disposeBag)
        
        barButton.rx.tap
            .bind { [weak self] _ in self?.viewModel.uploadObserver.onNext(())}.disposed(by: disposeBag)
    }
    
    private func setOutputBind() {
        viewModel.originData
            .scan(into: [BoardImgDetail]()) { [weak self] data, from in
                data.removeAll()
                var ImgStr = [String]()
                if let img = from.data.imgs {
                    for i in 0..<img.count {
                        data.append(img[i])
                        ImgStr.append(img[i].img)
                    }
                }
                self?.viewModel.editedImg.accept(ImgStr)
            }
            .debug()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: imageCollectionView.rx.items(cellIdentifier: "CommunityCollectionViewCell", cellType: CommunityCollectionViewCell.self)) { [weak self]
                (index: Int, element: BoardImgDetail, cell: CommunityCollectionViewCell) in
                guard let self = self else { return }
                cell.imageView.kf.setImage(with: URL(string: "\(element.img)")!)
                cell.delegate = self
                cell.editViewModel = self.viewModel
                cell.editRemoveImage(imgUrl: element.img)
            }.disposed(by: disposeBag)
        
        viewModel.getOriginText
            .map { $0 }
            .bind { [weak self] text in self?.boardTextView.text = text }
            .disposed(by: disposeBag)
            
        viewModel.uploadResult
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] finished in
                if finished {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showAlert("게시글 수정 실패!", "에러가 발생했습니다. 잠시 후 다시 시도해주세요")
                    self?.navigationController?.popViewController(animated: true)
                }
            }.disposed(by: disposeBag)
        
        viewModel.activated
            .map { !$0 }
            .bind { [weak self] finished in
                finished ? (self?.indicator.stopAnimating()) : (self?.indicator.startAnimating())
            }.disposed(by: disposeBag)
        
    }
    
    @objc private func didTapSelectBoardImage() {
        self.presentPhotoActionSheet()
    }
}

extension BoardEditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .secondaryLabel else { return }
        textView.text = nil
        textView.textColor = .label
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension BoardEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "게시글 이미지 추가", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "사진 촬영", style: .default, handler: { [weak self] _ in
            //MARK: 카메라 켜기
            self?.showImageAction(.camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "앨범에서 선택", style: .default, handler: { [weak self] _ in
            //MARK: 앨범 이동
            self?.loadPHPicker()
        }))
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                self.present(actionSheet, animated: true, completion: nil)
            }
        } else {
            self.present(actionSheet, animated: true)
        }
    }
    
    func showImageAction(_ action: UIImagePickerController.SourceType) {
        let vc = UIImagePickerController()
        vc.sourceType = action
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func loadPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .any(of: [.images])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension BoardEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        var images: [UIImage] = [UIImage]()
        var cnt = 0
        let queue = DispatchQueue(label: "custom")
        queue.sync {
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) {
                    object, error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        if let image = object as? UIImage {
                            images.append(image)
                            cnt += 1
                            print("이미지 추가됨")
                        }
                    }
                }
            }
        }
        while true {
            if cnt == results.count {
//                viewModel.input.selectedBoardImages.accept(images)
                viewModel.selectedImg.onNext(images)
                break
            }
        }
        
    }

}

extension BoardEditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}
