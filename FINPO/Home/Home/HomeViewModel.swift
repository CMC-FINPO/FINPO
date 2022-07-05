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
    
    //나의 정책인지 확인하는 액션
    enum isMyPolicy {
        case mypolicy
        case notMyPolicy
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
        //맨처음 나의 정책 로드
        let myPolicyTrigger = PublishRelay<isMyPolicy>()
        
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
        let mypolicyAddObserver = PublishRelay<Int>()
        let presentMemoAlertObserver = PublishRelay<Void>()
        let memoTextObserver = PublishRelay<String>()
        let memoCheckObserver = PublishRelay<Void>()
        var bookmarkObserver = PublishRelay<Int>()
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
        var mypolicyAddOutput = PublishRelay<Bool>()
        var goToMemoAlert = PublishRelay<Bool>()
        var checkedMemoOutput = PublishRelay<Bool>()
        var checkedBookmarkOutput = PublishRelay<Bool>()
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
        
        ///참여 정책 추가
        input.mypolicyAddObserver
            .flatMap { id in
                AddParticipatedAPI.addParticipationToAPI(id: id, with: nil) }
            .subscribe(onNext: { valid in
                self.output.mypolicyAddOutput.accept(valid)
            }).disposed(by: disposeBag)
                    
        ///메모 알럿 present
        input.presentMemoAlertObserver
            .subscribe(onNext: { _ in
                self.output.goToMemoAlert.accept(true)
            }).disposed(by: disposeBag)
        
        _ = Observable.combineLatest(self.input.mypolicyAddObserver, self.input.memoTextObserver)
            .map { a, b in
                AddParticipatedAPI.addParticipationToAPI(id: a, with: b)
            }
            .flatMap { $0 }
            .subscribe(onNext: { valid in
                print("메모 삽입완료")
                self.output.checkedMemoOutput.accept(valid)
            }).disposed(by: disposeBag)
        
        //북마크
        input.bookmarkObserver
            .flatMap { BookMarkAPI.addBookmark(polidyId: $0) } //북마크 추가 API
            .subscribe(onNext: { valid in
                self.output.checkedBookmarkOutput.accept(valid)
            }).disposed(by: disposeBag)
        
        ///OUTPUT
        //맨 처음 로드 시 나의 정책(관심+기본지역), 카테고리에 해당하는 정책 조회
                
        //정렬했을 때 -> Page 0 불러오기
        _ = Observable.combineLatest(
            input.myPolicyTrigger.asObservable(), //나의 정책인지 아닌지
            input.sortActionObserver.asObservable(), //최신/인기순 정렬
            input.textFieldObserver.asObservable(), //정책 검색시
            input.selectedCategoryObserver.asObservable(), //필터링 시 카테고리
            input.filteredRegionObserver.asObservable() //필터링 시 지역
        )
//        .take(1)
        .flatMap({ (myPolicy, action, text, categories, filteredRegions) -> Observable<SearchPolicyResponse> in
            switch myPolicy {
            case .mypolicy:
                switch action {
                case .latest:
                    //여기서 최초 최신순 나의 정책 리턴
                    return MyPolicySearchAPI.searchMyPolicy()
                case .popular:
                    //여기서 인기순 나의 정책 리턴
                    return MyPolicySearchAPI.searchMyPolicyAsPopular()
                }
            case .notMyPolicy:
                switch action {
                case .latest:
                    self.currentText = text
                    return SearchPolicyAPI.searchPolicyAPI(title: text, to: categories, in: filteredRegions)
                case .popular:
                    self.currentText = text
                    return SearchPolicyAPI.searchPolicyAsPopular(title: text, to: categories, in: filteredRegions)
                }
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
            input.myPolicyTrigger.asObservable(),
            input.loadMoreObserver.asObservable(),
            input.currentPage.asObservable(),
//            input.textFieldObserver.asObservable(),
            input.sortActionObserver.asObservable(),
            input.selectedCategoryObserver.asObservable(),
            input.filteredRegionObserver.asObservable()
        )
        .flatMap({ (myPolicy, _, page, action, categories, filteredRegions) -> Observable<SearchPolicyResponse> in
            switch myPolicy {
            case .mypolicy:
                switch action {
                case .latest:
                    return MyPolicySearchAPI.searchMyPolicy(at: page)
                case .popular:
                    return MyPolicySearchAPI.searchMyPolicyAsPopular(at: page)
                }
            case .notMyPolicy:
                switch action {
                case .latest:
                    return SearchPolicyAPI.searchPolicyAPI(title: self.currentText, at: page, to: categories, in: filteredRegions)
                case .popular:
                    return SearchPolicyAPI.searchPolicyAsPopular(title: self.currentText, at: page, to: categories, in: filteredRegions)
                }
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
