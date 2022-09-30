//
//  CommunityWritingViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/28.
//

import Foundation
import RxRelay
import RxSwift
import Alamofire

class CommunityWritingViewModel {
    let disposeBag = DisposeBag()
    
    let input = INPUT()
    var output = OUTPUT()
    
    struct INPUT {
        let selectedBoardImages = PublishRelay<[UIImage]>()
        let imgUrlStorage = BehaviorRelay<[String]>(value: [""])
        let textStorage = PublishSubject<String>()
        let sendButtonTapped = PublishRelay<Void>()
        let isAnony = PublishSubject<Bool>()
    }
    
    struct OUTPUT {
        var loadImages = PublishRelay<BoardImageResponseModel>()
    }
    
    init() {
        input.selectedBoardImages
            .map { images in
                ApiManager.postImage(with: images, from: BaseURL.url.appending("upload/post"), to: BoardImageResponseModel.self, encoding: URLEncoding.default)
            }
            .flatMap { $0 }
            .map { $0 }
            .subscribe(onNext: { [weak self] imgUrls in
                self?.output.loadImages.accept(imgUrls)
                self?.input.imgUrlStorage.accept(imgUrls.data.imgUrls)
            }).disposed(by: disposeBag)
        
        _ = input.sendButtonTapped
            .withLatestFrom(Observable.combineLatest(
                input.imgUrlStorage.asObservable(),
                input.textStorage.asObservable(),
                input.isAnony.asObservable()))
        {($0, $1.0, $1.1, $1.2)}
            .map { (a,b,c,d) -> Parameters in
                return self.toDic(imgUrls: b, text: c, isAnony: d)
            }
            .map { $0 }
            .flatMap { para -> Observable in
                return ApiManager.postData(with: para, from: BaseURL.url.appending("post"), to: CommunityDetailBoardResponseModel.self, encoding: JSONEncoding.default)
            }
            .asObservable()
            .subscribe(onNext: { a in
                
            }, onError: { error in
                print("게시글 업로드 실패: \(error)")
            }
            ).disposed(by: disposeBag)
    }
    
    func toDic(imgUrls: [String], text: String, isAnony: Bool = false) -> Parameters {
        var dics = [[String:Any]]()
        if imgUrls[0] == "" {
            let paramters: Parameters = [
                "content": text,
                "anonymity": isAnony
            ]
            return paramters
        } else {
            for i in 0..<imgUrls.count {
                let param: Parameters = [
                    "img":imgUrls[i],
                    "order": i
                ]
                dics.append(param)
            }
        }
        let parameters: Parameters = [
            "imgs": dics,
            "anonymity": isAnony,
            "content": text
        ]
        return parameters
    }
}
