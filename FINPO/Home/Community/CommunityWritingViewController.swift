//
//  CommunityWritingViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/27.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PhotosUI
import Kingfisher
/*
 커뮤니티 게시글 작성 View
 */

class CommunityWritingViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private var addWritingBoardButton = UIBarButtonItem()
    
    let viewModel = CommunityWritingViewModel()
    
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
        textView.textColor = .secondaryLabel
        textView.returnKeyType = .done
        textView.delegate = self
        return textView
    }()
    
    private var barButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
    
    private lazy var imageCollectionView: UICollectionView = {
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
        view.backgroundColor = .white
        barButton.setTitle("작성하기", for: .normal)
        barButton.setTitleColor(UIColor.P01, for: .normal)
        barButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        addWritingBoardButton.customView = barButton
        self.navigationItem.rightBarButtonItem = addWritingBoardButton
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
            .drive(onNext: { [weak self] _ in
                //이미지를 넣지 않았을 때
                self?.viewModel.input.imgUrlStorage.accept([""])
                self?.viewModel.input.isAnony.onNext(false)
            }).disposed(by: disposeBag)
        
        boardTextView.rx.text
            .bind { [weak self] text in
                if let text = text {
                    self?.viewModel.input.textStorage.onNext(text)
                }
            }.disposed(by: disposeBag)
        
        barButton.rx.tap
            .take(1)
            .bind { [weak self] _ in
                self?.viewModel.input.sendButtonTapped.accept(())
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        //TODO: 선택된 이미지 확대
//        imageCollectionView.rx.itemSelected
//            .bind { [weak self] indexPath in
//            }.disposed(by: disposeBag)
    }
    
    private func setOutputBind() {
        viewModel.output.loadImages
            .scan(into: [String]()) { imgurl, model in
                imgurl.removeAll()
                for i in 0..<model.data.imgUrls.count {
                    imgurl.append(model.data.imgUrls[i])
                }
            }
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: imageCollectionView.rx.items(cellIdentifier: "CommunityCollectionViewCell", cellType: CommunityCollectionViewCell.self)) { [weak self]
                (index: Int, imgUrl: String, cell) in
                guard let self = self else { return }
                cell.imageView.kf.setImage(with: URL(string: imgUrl))
                cell.delegate = self
                cell.viewModel = self.viewModel
                cell.removeImage(imgUrl: imgUrl)
            }.disposed(by: disposeBag)
        
        viewModel.output.activated?
            .map { !$0 }
            .bind { [weak self] finished in
                if finished {
                    self?.indicator.stopAnimating()
                } else {
                    self?.indicator.startAnimating()
                }
            }.disposed(by: disposeBag)
    }
    
    @objc private func didTapSelectBoardImage() {
        self.presentPhotoActionSheet()
    }
    
//    @objc func deletePreview(sender: UIButton){
//       //cell 삭제 //delete cell at index of collectionview
//        print("tapped")
//        self.imageCollectionView.deleteItems(at: [IndexPath.init(row: sender.tag, section: 0)])
//       }
}

extension CommunityWritingViewController: UITextViewDelegate {
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

extension CommunityWritingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension CommunityWritingViewController: PHPickerViewControllerDelegate {
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
                viewModel.input.selectedBoardImages.accept(images)
                break
            }
        }
        
    }

}

extension CommunityWritingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}
enum PhotosError: Error {
    case getImageError
}
