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
            .subscribe(onNext: { imgUrls in
                self.output.loadImages.accept(imgUrls)
            }).disposed(by: disposeBag)
       
    }
}
