//
//  GalleryViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/09.
//

import Foundation
import UIKit

class GalleryViewController: UIViewController {
    var selectedIndex: Int = 0
    var imageArr: [BoardImgDetail] = []
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentMode = .scaleAspectFit
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.backgroundColor = .black
        sv.minimumZoomScale = 1
        sv.maximumZoomScale = 6
        sv.delegate = self
        return sv
    }()
    
    private let img: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let countlbl: UILabel = {
       let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let closeBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func closeBtnTapped(){
        self.dismissView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        setAttribute()
        setGesture()
        setLayout()
        loadImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = .black
        self.imageArr.removeAll()
        self.selectedIndex = 0        
    }
    
    private func setAttribute() {
        view.backgroundColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
    }
    
    private func setGesture() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapOnScrollView(recognizer:)))
        singleTapGesture.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapOnScrollView(recognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
        
        let rightSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeFrom(recognizer:)))
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeFrom(recognizer:)))
        rightSwipe.direction = .right
        leftSwipe.direction = .left
        
        scrollView.addGestureRecognizer(rightSwipe)
        scrollView.addGestureRecognizer(leftSwipe)
    }
    
    @objc func handleSingleTapOnScrollView(recognizer: UITapGestureRecognizer) {
        if closeBtn.isHidden {
            closeBtn.isHidden = false
            countlbl.isHidden = false
        } else {
            closeBtn.isHidden = true
            countlbl.isHidden = true
        }
    }
    
    //더블탭 - 확대 및 축소
    @objc func handleDoubleTapOnScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
            
            closeBtn.isHidden = true
            countlbl.isHidden = true
        } else {
            scrollView.setZoomScale(1, animated: true)
            closeBtn.isHidden = false
            countlbl.isHidden = false
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = img.frame.size.height / scale
        zoomRect.size.width = img.frame.size.width / scale
        let newCenter = img.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    @objc func handleSwipeFrom(recognizer: UISwipeGestureRecognizer) {
        let direction: UISwipeGestureRecognizer.Direction = recognizer.direction
        
        switch direction {
        case .right:
            self.selectedIndex -= 1
        case .left:
            self.selectedIndex += 1
        default:
            break
        }
        self.selectedIndex = (self.selectedIndex < 0) ? (self.imageArr.count - 1) : (self.selectedIndex % self.imageArr.count)
        
        loadImage()
    }
    
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer){
        print(recognizer)
        recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
        recognizer.scale = 1
        img.contentMode = .scaleAspectFit
    }
    
    func loadImage() {
        //캐시에서 가져오기
        let imgUrl = String(imageArr[selectedIndex].img)
        if let cachedImg = CacheManager.shared.object(forKey: NSString(string: imgUrl).lastPathComponent as NSString) {
            DispatchQueue.main.async {
                self.img.image = cachedImg
                self.countlbl.text = String(format: "%1d / %1d", self.selectedIndex + 1, self.imageArr.count)
            }
        }

    }
    
    private func setLayout() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        scrollView.addSubview(img)
//        img.frame = scrollView.bounds
        img.snp.makeConstraints {
            $0.centerY.equalTo(UIScreen.main.bounds.centerY)
            $0.width.equalTo(view.snp.width)
            $0.height.equalTo(350)
        }
        
        view.addSubview(countlbl)
        countlbl.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(40)
            $0.leading.trailing.equalToSuperview()
        }
        view.addSubview(closeBtn)
        closeBtn.frame = CGRect(x: 20, y: (self.navigationController?.navigationBar.frame.size.height)!, width: 25, height: 25)
    }
}

extension GalleryViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = img.image {
                let ratioW = img.frame.width / image.size.height
                let ratioH = img.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width*ratio
                let newHeight = image.size.height*ratio
                
                let left = 0.5 * (newWidth * scrollView.zoomScale > img.frame.width ? (newWidth - img.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > img.frame.height ? (newHeight - img.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }
}
