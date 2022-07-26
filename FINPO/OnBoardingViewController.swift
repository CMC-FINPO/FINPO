//
//  OnBoardingViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/22.
//

import Foundation
import UIKit

class OnBoardingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setAttribute()
    }
    
    let imageNames = ["onboarding1", "onboarding2", "onboarding3", "onboarding4"]
    
    let titles = ["전국 청년정책을 한 곳에", "관심분야\n청년정책만 모아서", "참여하거나 관심있는\n청년정책 스크랩", "후기나 관련 정보\n인사이트 공유"]
    let descriptions = ["시군구별 청년정책 검색 가능", "세부 카테고리 별로 필터링", "마이페이지로 편리하게 저장 및 관리", "청년만을 위한 커뮤니티 공간 제공"]
    
    private var pageControl: UIPageControl = {
        let pg = UIPageControl()
        pg.currentPage = 0
        return pg
    }()
    
    private var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = false
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.isScrollEnabled = true
        sv.isPagingEnabled = true
        sv.bounces = false
        // 경계지점에서 bounce될건지 체크 (첫 or 마지막 페이지에서 바운스 스크롤 효과 여부)
        return sv
    }()
    
    private var imageView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
        label.textColor = UIColor.black
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        label.textColor = UIColor.black
        return label
    }()
    
    private var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor(hexString: "999999"), for: .normal)
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        button.backgroundColor = .clear
        button.isEnabled = true
        button.layer.masksToBounds = true
        return button
    }()
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("시작하기", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.backgroundColor = UIColor(hexString: "F0F0F0")
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate func setAttribute() {
        confirmButton.addTarget(self, action: #selector(confirmButtonDidTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(confirmButtonDidTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(confirmButton)
        view.addSubview(skipButton)
        
        skipButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(25)
        }
        
        pageControl.numberOfPages = imageNames.count
        pageControl.pageIndicatorTintColor = UIColor(hexString: "D9D9D9")
        pageControl.currentPageIndicatorTintColor = UIColor(hexString: "5B43EF")
        
        scrollView.frame = UIScreen.main.bounds
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(imageNames.count), height: UIScreen.main.bounds.height)
        scrollView.delegate = self // scroll범위에 따라 pageControl의 값을 바꾸어주기 위한 delegate
        
    
        for (index, imageName) in imageNames.enumerated() {
            let image = UIImage(named: imageName)
            self.imageView = UIImageView(image: image)
            self.imageView.frame.size = CGSize(width: 350, height: 350)
            let startPositionX = (UIScreen.main.bounds.width - self.imageView.frame.width) / 2
            self.imageView.frame.origin.x = (UIScreen.main.bounds.width) * CGFloat(index) + startPositionX
            self.imageView.frame.origin.y = 80

            scrollView.addSubview(self.imageView)
        }
        
        for (index, title) in titles.enumerated() {
            let titlelabel = UILabel()
            titlelabel.numberOfLines = 0
            titlelabel.textAlignment = .center
            titlelabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
            titlelabel.textColor = UIColor.black
            titlelabel.text = title
            titlelabel.sizeToFit()
            self.titleLabel = titlelabel
            self.titleLabel.frame.size = CGSize(width: 350, height: 100)
            let startPositionX = (UIScreen.main.bounds.width - self.titleLabel.frame.width) / 2
            self.titleLabel.frame.origin.x = UIScreen.main.bounds.width * CGFloat(index) + startPositionX
            self.titleLabel.frame.origin.y = self.imageView.frame.height + 60
            scrollView.addSubview(self.titleLabel)
        }
        
        for (index, title) in descriptions.enumerated() {
            let titlelabel = UILabel()
            titlelabel.numberOfLines = 0
            titlelabel.textAlignment = .center
            titlelabel.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
            titlelabel.textColor = UIColor.black
            titlelabel.text = title
            titlelabel.sizeToFit()
            self.descriptionLabel = titlelabel
            self.descriptionLabel.frame.size = CGSize(width: 350, height: 30)
            let startPositionX = (UIScreen.main.bounds.width - self.descriptionLabel.frame.width) / 2
            self.descriptionLabel.frame.origin.x = UIScreen.main.bounds.width * CGFloat(index) + startPositionX
            self.descriptionLabel.frame.origin.y = self.imageView.frame.height + self.titleLabel.frame.height + 50
            scrollView.addSubview(self.descriptionLabel)
        }
        
        
        pageControl.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(100)
            $0.centerX.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(pageControl.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(50)
        }
    }

    @objc private func confirmButtonDidTapped() {
        let vc = LoginViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
        self.present(navVC, animated: true)
    }
    
}

extension OnBoardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
        if(pageControl.currentPage == 3) {
            DispatchQueue.main.async {
                self.confirmButton.isEnabled = true
                self.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                self.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
            }
        } else {
            DispatchQueue.main.async {
                self.confirmButton.isEnabled = false
                self.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                self.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .normal)
            }
        }
    }
}
