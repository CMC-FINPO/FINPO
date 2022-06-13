//
//  MyPageViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/13.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher
import Photos

class MyPageViewController: UIViewController {
    
    let viewModel = MyPageViewModel()
//    let segmentedControl = UnderlineSegmentedControl()
    let writeMySelfVC = WriteMySelfViewController()
    let commentMySelfVC = CommentMySelfViewController()
    let likeMySelfVC = LikeMySelfViewController()
    
    var dataViewControllers: [UIViewController] {
        [self.writeMySelfVC, self.commentMySelfVC, self.likeMySelfVC]
    }
    
    var currentPage: Int = 0 {
        didSet {
            ///from segmentedControl -> pageViewController update
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            self.pageViewController.setViewControllers(
                [dataViewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
        }
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
        imageView.image = UIImage(named: "profile")
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        label.textColor = .black
        return label
    }()
    
    private var interestingAreaLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "C4C4C5")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.text = "관심사"
        return label
    }()
    
    private var interestAreaButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "illust"), for: .normal)
        return button
    }()
    
    private var interestAreaLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "관심 지역 선택"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var participationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "illust"), for: .normal)
        return button
    }()
    
    private var participationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "참여 목록"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var interestListButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 61, height: 61))
        button.setImage(UIImage(named: "illust"), for: .normal)
        return button
    }()
    
    private var interestListLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "관심 목록"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UnderlineSegmentedControl(items: ["내가 쓴 글", "댓글 단 글", "좋아요 한 글"])

        return segmentedControl
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.setViewControllers([self.dataViewControllers[0]], direction: .forward, animated: true)
        vc.delegate = self
        vc.dataSource = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting"), style: .plain, target: nil, action: nil)
        profileImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapChangeProfilePic))
        profileImageView.addGestureRecognizer(gesture)
        
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "000000")], for: .normal)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "5B43EF"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .selected)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "5B43EF"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .highlighted)
        
        self.segmentedControl.addTarget(self, action: #selector(self.changeValue(control:)), for: .valueChanged)
        self.segmentedControl.selectedSegmentIndex = 0
        
        //segmentedControl 값이 변경될 때, pageVC에도 적용시켜주기 위해 selector 추가
        self.changeValue(control: self.segmentedControl)
    }
    
    fileprivate func setLayout() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1
        
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            $0.leading.equalToSuperview().inset(21)
            $0.height.equalTo(72)
            $0.width.equalTo(72)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalToSuperview().inset(110)
        }
        
        view.addSubview(interestingAreaLabel)
        interestingAreaLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(17)
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        view.addSubview(interestAreaButton)
        interestAreaButton.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(37)
            $0.leading.equalToSuperview().inset(51)
            $0.height.width.equalTo(61)
        }
        
        view.addSubview(interestAreaLabel)
        interestAreaLabel.snp.makeConstraints {
            $0.top.equalTo(interestAreaButton.snp.bottom).offset(9)
            $0.centerX.equalTo(interestAreaButton.snp.centerX)
        }
        
        view.addSubview(participationButton)
        participationButton.snp.makeConstraints {
            $0.top.equalTo(interestAreaButton.snp.top)
//            $0.leading.equalTo(interestAreaButton.snp.trailing).offset(40)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(interestAreaButton)
        }
        
        view.addSubview(participationLabel)
        participationLabel.snp.makeConstraints {
            $0.top.equalTo(participationButton.snp.bottom).offset(9)
            $0.centerX.equalTo(participationButton.snp.centerX)
        }
        
        view.addSubview(interestListButton)
        interestListButton.snp.makeConstraints {
            $0.top.equalTo(participationButton.snp.top)
            $0.leading.equalTo(participationButton.snp.trailing).offset(40)
            $0.height.width.equalTo(interestAreaButton)
        }
        
        view.addSubview(interestListLabel)
        interestListLabel.snp.makeConstraints {
            $0.top.equalTo(interestListButton.snp.bottom).offset(9)
            $0.centerX.equalTo(interestListButton.snp.centerX)
        }
        
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(interestListLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(1)
            $0.top.equalTo(segmentedControl.snp.bottom).offset(1)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.input.loadUserDataObserver.accept(())
            }).disposed(by: disposeBag)
                
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.getUserData
            .asSignal()
            .emit(onNext: { [weak self] userInfo in
                guard let self = self else { return }
                print("유저정보 넘어옴!")
                self.profileImageView.kf.setImage(with: userInfo.profileImg)
                self.nameLabel.text = "\(userInfo.nickname)님"
            }).disposed(by: disposeBag)
        
        viewModel.output.updateProfileImage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] profileImgStr in
                guard let self = self else { return }
                let profileURL = URL(string: profileImgStr)
                self.profileImageView.kf.setImage(with: profileURL)
            }).disposed(by: disposeBag)
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    @objc private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
    }
    
}

extension MyPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "프로필 사진 변경",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "사진 촬영",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "앨범에서 선택",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        //to viewmodel image
        viewModel.input.selectedProfileImageObserver
            .accept(selectedImage)
            
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension MyPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.dataViewControllers.firstIndex(of: viewController),
              index - 1 >= 0 else { return nil }
        return self.dataViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.dataViewControllers.firstIndex(of: viewController),
              index + 1 < self.dataViewControllers.count else { return nil }
        return self.dataViewControllers[index + 1]
    }
}
/*
 pageViewController에서 값이 변경될 때 segmentedControl에도 적용하기 위해, delegate 처리
 위 dataSource에서 처리하면 캐싱이 되어 index값이 모두 불리지 않으므로, delegate에서 따로 처리가 필요
 */
extension MyPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?[0],
              let index = self.dataViewControllers.firstIndex(of: viewController) else { return }
        self.currentPage = index
        self.segmentedControl.selectedSegmentIndex = index
    }
}
