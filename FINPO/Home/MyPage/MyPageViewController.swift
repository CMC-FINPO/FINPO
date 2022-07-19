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
    let disposeBag = DisposeBag()

    let writeMySelfVC = WriteMySelfViewController()
    let commentMySelfVC = CommentMySelfViewController()
    let likeMySelfVC = LikeMySelfViewController()
    
    //관심사 라벨 길이 측정용
    static var interestThingsString = [String]()
    
    //커뮤니티
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
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private var editImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        imageView.image = UIImage(named: "pen")
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
        button.setImage(UIImage(named: "selectarea"), for: .normal)
        return button
    }()
    
    private var interestAreaLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "지역 선택"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    ///관심사 설정
    private var participationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "interesting"), for: .normal)
        return button
    }()
    
    private var participationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "관심사 설정"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    ///참여 목록
    private var interestListButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 61, height: 61))
        button.setImage(UIImage(named: "participation"), for: .normal)
        return button
    }()
    
    private var interestListLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "참여 목록"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var separatorLineView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        return separator
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
    
    private var interestThingsCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.minimumLineSpacing = 3
        flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = false
        cv.isUserInteractionEnabled = false
        return cv
    }()
    
    @objc fileprivate func moveToAlarmPage() {
        let vc = AlarmViewController()
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        navigationItem.title = ""
        let alarmButton = UIBarButtonItem(
            image: UIImage(named: "alarm")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(moveToAlarmPage)
        )
        
        let settingBarButtn = UIBarButtonItem(image: UIImage(named: "setting_3x")?.withRenderingMode(.alwaysOriginal)
                                              , style: .plain,
                                              target: self,
                                              action: #selector(goToSettingVC))
        self.navigationItem.rightBarButtonItems = [settingBarButtn, alarmButton]
        
        profileImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapChangeProfilePic))
        profileImageView.addGestureRecognizer(gesture)
        
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "000000")], for: .normal)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "000000"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .normal)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "5B43EF"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .selected)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "5B43EF"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .highlighted)
        
        self.segmentedControl.addTarget(self, action: #selector(self.changeValue(control:)), for: .valueChanged)
        self.segmentedControl.selectedSegmentIndex = 0
        
        //segmentedControl 값이 변경될 때, pageVC에도 적용시켜주기 위해 selector 추가
        self.changeValue(control: self.segmentedControl)
        
        //컬렉션뷰
        interestThingsCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "interestThingsCollectionView")
        interestThingsCollectionView.delegate = self
    }
    
    @objc private func goToSettingVC() {
        let vc = MyPageSettingViewController()
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
//        self.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func setLayout() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            $0.leading.equalToSuperview().inset(21)
            $0.height.equalTo(72)
            $0.width.equalTo(72)
        }
        
        editImageView.layer.cornerRadius = editImageView.frame.height/2
        editImageView.clipsToBounds = true
        
        view.addSubview(editImageView)
        editImageView.snp.makeConstraints {
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(2)
            $0.bottom.equalTo(profileImageView.snp.bottom).inset(3)
            $0.height.width.equalTo(25)
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
        
        view.addSubview(interestThingsCollectionView)
        interestThingsCollectionView.snp.makeConstraints {
            $0.leading.equalTo(interestingAreaLabel.snp.trailing).offset(10)
            $0.top.equalTo(interestingAreaLabel.snp.top)
            $0.height.equalTo(23)
            $0.trailing.equalToSuperview().inset(50)
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
        
        view.addSubview(separatorLineView)
        separatorLineView.snp.makeConstraints {
            $0.top.equalTo(interestListLabel.snp.bottom).offset(23)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
//        view.addSubview(segmentedControl)
//        segmentedControl.snp.makeConstraints {
//            $0.top.equalTo(interestListLabel.snp.bottom).offset(23)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(50)
//        }
//        
//        view.addSubview(pageViewController.view)
//        pageViewController.view.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview().inset(1)
//            $0.top.equalTo(segmentedControl.snp.bottom).offset(1)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//        }
        
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.input.loadUserDataObserver.accept(())
                //관심사 조회(부모카테고리)
                self.viewModel.input.loadUserInterestedThingsObserver.accept(())
            }).disposed(by: disposeBag)
                
        interestAreaButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let vc = EditRegionViewController()
                vc.modalPresentationStyle = .fullScreen
                vc.setViewModel(viewModel: self?.viewModel ?? MyPageViewModel())
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
     
        ///관심사 설정
        participationButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let vc = InterestCategoryViewController()
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        ///참여 목록
        interestListButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let vc = ParticipationViewController()
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.getUserData
            .asSignal()
            .emit(onNext: { [weak self] userInfo in
                guard let self = self else { return }
                print("유저정보 넘어옴!")
                print("유저 프로필 이미지 url: \(userInfo.profileImg)")
                self.nameLabel.text = "\(userInfo.nickname)님"
                guard let profileImg = userInfo.profileImg else {
                    self.profileImageView.image = UIImage(named: "profile")
                    return
                }
                print("마이페이지에서 가져온 프로필 이미지\(profileImg)")
                self.profileImageView.kf.setImage(with: profileImg)

            }).disposed(by: disposeBag)

        viewModel.output.updateProfileImage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] profileImgStr in
                guard let self = self else { return }
                let profileURL = URL(string: profileImgStr)
                self.profileImageView.kf.setImage(with: profileURL)
            }).disposed(by: disposeBag)
        
        viewModel.output.sendUserInterestedThings
            .scan(into: [myInterestCategory](), accumulator: { mycategory, models in
                mycategory.removeAll()
                for i in 0..<(models.data.count) {
                    mycategory.append(models.data[i])
                }
            })
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: self.interestThingsCollectionView.rx.items(cellIdentifier: "interestThingsCollectionView", cellType: FilterCollectionViewCell.self)) {
                (index: Int, element: myInterestCategory, cell) in
                cell.contentView.backgroundColor = UIColor(hexString: "F0F0F0")
                cell.tagLabel.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
                cell.tagLabel.textColor = UIColor(hexString: "5B43EF")
                cell.tagLabel.text = element.name
            }.disposed(by: disposeBag)
            
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
        viewModel.input.selectedProfileImageObserver.accept(selectedImage)
            
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

extension MyPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let name = MyPageViewController.interestThingsString[indexPath.row]
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.firstLineHeadIndent = 10 //indent for the first line
//        paragraphStyle.headIndent = 10
//        paragraphStyle.tailIndent = 10
        
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
//            ,NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        let nameSize = (name as NSString).size(withAttributes: attributes as [NSAttributedString.Key: Any])
        return CGSize(width: nameSize.width, height: 21)
    }
}
