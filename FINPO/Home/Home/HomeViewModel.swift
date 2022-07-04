//
//  HomeViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/22.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class HomeViewModel {
    
    static var detailId = [Int]()
    static var serviceString: [String] = [String]()
    
    enum Action {
        case load([Contents])
        case loadMore(Contents)
    }
    
    enum SortAction {
        case latest
        case popular
    }
    
    enum TagLoadAction {
        case isFirstLoad([DataDetail])
        case delete(at: Int)
        case add(DataDetail)
    }
    
    let disposeBag = DisposeBag()
    
    var input = INPUT()
    var output = OUTPUT()
    var user = User.instance
    
    var dataSource = [Contents]()
    var currentPage = 0
    var currentText = ""
    
    static var mainRegion: [MainRegion] = [MainRegion]()
    static var subRegion: [SubRegion] = [SubRegion]()
    
    struct INPUT {
        //Sort
        let textFieldObserver = PublishRelay<String>()
        let loadMoreObserver = PublishRelay<Void>()
        let currentPage = PublishRelay<Int>()
        let sortActionObserver = PublishRelay<SortAction>()
                
        //Filter
        let isFirstLoadObserver = PublishRelay<Void>()
        let tagLoadActionObserver = PublishRelay<TagLoadAction>()
        var deleteTagObserver = PublishRelay<Int>()
        let addTagObserver = PublishRelay<Int>()
        let regionDataSetObserver = PublishRelay<Void>()
        let addMainRegionIndexObserver = PublishRelay<Int>()
        let filteredRegionObserver = PublishRelay<[Int]>()
        
        //category
        let categoryObserver = PublishRelay<Void>()
        let selectedCategoryObserver = PublishRelay<[Int]>()
        
        //confirm button
        let confirmButtonValid = PublishRelay<Bool>()
        
        //policy detail info
        let serviceInfoObserver = PublishRelay<Int>()
    }
    
    struct OUTPUT {
        var textFieldResult = PublishRelay<Contents>()
        var policyResult = PublishRelay<Action>()
        
        //filter
        var isFirstLoadOutput = PublishRelay<MyRegionList>()
        var regionButtonTapped = PublishRelay<RegionActionType>()
        var subRegionTagOutput = PublishRelay<DataDetail>().asObservable()
        var createFilterdRegionOutput = PublishRelay<DataDetail>()
        
        //category
        var getJobData = PublishRelay<CategoryModel>()
        
        //confirm button
        var confirmButtonValidOutput = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
        
        //policy detail info
        var serviceInfoOutput = PublishRelay<DetailInfoModel>()
    }
    
    init() {
        ///INPUT
        input.loadMoreObserver
            .debug()
            .subscribe(onNext: { _ in
                print("테이블 load more Oberver 이벤트 방출......")
                self.currentPage += 1
                self.input.currentPage.accept(self.currentPage)
            }).disposed(by: disposeBag)
        
        input.isFirstLoadObserver
            .flatMap { CallMyRegionAPI.callMyRegion() }
            .subscribe(onNext: { list in
                if(FilterViewController.isFirstLoad == true) {
                    for i in 0..<list.data.count {
                        FilterRegionViewController.filteredDataList.append(list.data[i])
                        print("필터된 리스트: \(FilterRegionViewController.filteredDataList)")
                    }
                }
                self.input.tagLoadActionObserver.accept(.isFirstLoad(FilterRegionViewController.filteredDataList))
            }).disposed(by: disposeBag)
        
        input.deleteTagObserver
            .subscribe(onNext: { index in
                self.input.tagLoadActionObserver.accept(.delete(at: index))
                FilterRegionViewController.filteredDataList.remove(at: index)
            }).disposed(by: disposeBag)
        
        output.subRegionTagOutput =  input.addTagObserver.withLatestFrom(input.addMainRegionIndexObserver) { subIndex, mainIndex in
            let dataDetail = DataDetail(
                region: RegionDetail(
                    id: HomeViewModel.subRegion[subIndex].id,
                    name: HomeViewModel.subRegion[subIndex].name,
                    parent: RegionParentDetail(
                        id: HomeViewModel.mainRegion[mainIndex].id,
                        name: HomeViewModel.mainRegion[mainIndex].name)),
                isDefault: false)
            return dataDetail
        }
            
        output.subRegionTagOutput
            .subscribe(onNext: { data in
                print("생성될것: \(data.region.name)")
                self.input.tagLoadActionObserver.accept(.add(data))
                FilterRegionViewController.filteredDataList.append(data)
            }).disposed(by: disposeBag)
        
        input.categoryObserver
            .flatMap { CallCategoryAPI.callCategory() }
            .subscribe(onNext: { data in
                self.output.getJobData.accept(data)
            }).disposed(by: disposeBag)
        
        input.serviceInfoObserver
            .flatMap { id in
                SearchDetailPolicyAPI.searchDetailPolicy(id: id)}
            .subscribe(onNext: { info in
                guard let str = info.data.support else { return }
                HomeViewModel.serviceString.removeAll()
                HomeViewModel.serviceString = str.components(separatedBy: ["n", "ㅇ", "\n"])
                self.output.serviceInfoOutput.accept(info)
            }).disposed(by: disposeBag)

        
        ///OUTPUT
                
        //정렬했을 때 -> Page 0 불러오기
        _ = Observable.combineLatest(
            input.sortActionObserver.asObservable(),
            input.textFieldObserver.asObservable(),
            input.selectedCategoryObserver.asObservable(),
            input.filteredRegionObserver.asObservable()
        )
//        .take(1)
        .flatMap({ (action, text, categories, filteredRegions) -> Observable<SearchPolicyResponse> in
            switch action {
            case .latest:
                self.currentText = text
                return SearchPolicyAPI.searchPolicyAPI(title: text, to: categories, in: filteredRegions)
            case .popular:
                self.currentText = text
                return SearchPolicyAPI.searchPolicyAsPopular(title: text)
            }
        })
        .subscribe(onNext: { policyData in
            HomeViewModel.detailId.removeAll()
            for i in 0..<(policyData.data?.content.count ?? 0) {
                HomeViewModel.detailId.append(policyData.data?.content[i].id ?? 1000)
            }
            self.output.policyResult.accept(Action.load([Contents(content: policyData.data!.content)]))
            print("상세정보 아이디: \(HomeViewModel.detailId)")
        }).disposed(by: disposeBag)
        
        //스크롤 내렸을 때 loadMore 하기
        _ = Observable.combineLatest(
            input.loadMoreObserver.asObservable(),
            input.currentPage.asObservable(),
//            input.textFieldObserver.asObservable(),
            input.sortActionObserver.asObservable(),
            input.selectedCategoryObserver.asObservable(),
            input.filteredRegionObserver.asObservable()
        )
        .flatMap({ (_, page, action, categories, filteredRegions) -> Observable<SearchPolicyResponse> in
            switch action {
            case .latest:
                return SearchPolicyAPI.searchPolicyAPI(title: self.currentText, at: page, to: categories, in: filteredRegions)
            case .popular:
                return SearchPolicyAPI.searchPolicyAsPopular(title: self.currentText, at: page)
            }
        })
        .subscribe(onNext: { addedData in
            self.output.policyResult.accept(Action.loadMore(Contents(content: addedData.data!.content)))
            for i in 0..<(addedData.data?.content.count ?? 0) {
                HomeViewModel.detailId.append(addedData.data?.content[i].id ?? 1000)
            }
            print("추가 로드 되었을 때 상세정보 아이디: \(HomeViewModel.detailId)")
        }).disposed(by: disposeBag)
        
        output.confirmButtonValidOutput = input.confirmButtonValid.asDriver(onErrorJustReturn: false)
        
    }

}
