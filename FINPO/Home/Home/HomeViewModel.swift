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
    static var participatedId = Int()
    static var serviceString: [String] = [String]()
    
    ///load more 중복 방지
    var loadMore = false
    
    let myPageViewModel = MyPageViewModel()
    
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
        case deleteAll
    }
    
    ///나의 관심 카테고리인지 확인하는 액션
    enum isMyInterestCategory {
        case right(ChildDetail)
        case notYet(ChildDetail)
        case clear(Bool)
    }
    var checkNotInterestCategoryId = Set<[Int]>()
    
    ///나의 이용목적인지 확인하는 액션
    enum isMyForWhat {
        case right(UserPurpose)
        case nope(UserPurpose)
        case clear(Bool)
    }
    var checkIsMyForWhat = Set<[Int]>()
    
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
        
        ///유저 정보 가져오기
        let getUserInfo = PublishRelay<Void>()
        
        //맨처음 나의 정책 로드
        let myPolicyTrigger = PublishRelay<isMyPolicy>()
        
        //Sort
        let textFieldObserver = PublishRelay<String>()
        let loadMoreObserver = PublishRelay<Bool>()
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
        let filterResetTriggerObserver = PublishRelay<Void>()
        
        //category
        let categoryObserver = PublishRelay<Void>() ///child 형식
        let lowCategoryObserver = PublishRelay<Void>()
        let selectedCategoryObserver = PublishRelay<[Int]>()
        let interestCategoryObserver = PublishRelay<Void>()
        
        //confirm button
        let confirmButtonValid = PublishRelay<Bool>()
        
        //policy detail info
        let serviceInfoObserver = PublishRelay<Int>()
        let mypolicyAddObserver = PublishRelay<Int>()
        let presentMemoAlertObserver = PublishRelay<Void>()
        let participatedId = PublishRelay<Int>()
        let memoTextObserver = PublishRelay<String>()
        let memoCheckObserver = PublishRelay<Void>()
        var bookmarkObserver = PublishRelay<Int>()
        let bookmarkDeleteObserver = PublishRelay<Int>()
        
        ///이용 목적 전체 트리거
        let forWhatObserver = PublishRelay<Void>()
        ///내 이용 목적 트리거
        let myForWhatObserver = PublishRelay<Void>()
        ///리셋 트리거
        let resetTrigger = PublishRelay<Void>()
        
        ///서버 등록
        let interestEditCompleteObserver = PublishRelay<[Int]>()
        let forWhatEditCompleteObserver = PublishRelay<[Int]>()
    }
    
    struct OUTPUT {
        ///유저 정보 전달
        var sendUserInfo = PublishRelay<User>()
        
        var textFieldResult = PublishRelay<Contents>()
        var policyResult = PublishRelay<Action>()
        
        //filter
        var isFirstLoadOutput = PublishRelay<MyRegionList>()
        var regionButtonTapped = PublishRelay<RegionActionType>()
        var subRegionTagOutput = PublishRelay<DataDetail>().asObservable()
        var createFilterdRegionOutput = PublishRelay<DataDetail>()
        
        //confirm button
        var confirmButtonValidOutput = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
        
        //policy detail info
        var serviceInfoOutput = PublishRelay<DetailInfoModel>()
        var mypolicyAddOutput = PublishRelay<Bool>()
        var goToMemoAlert = PublishRelay<Bool>()
        var checkedMemoOutput = PublishRelay<Bool>()
        var checkedBookmarkOutput = PublishRelay<Bool>()
        var checkedBookmarkDeleteOutput = PublishRelay<Bool>()
        
        
        ///category - childs 형식
        var getJobData = PublishRelay<CategoryModel>()
        ///관심 카테고리
        var getInterestCategory = PublishRelay<MyInterestCategoryModel>()
        ///하위 전체 카테고리
        var getLowCategory = PublishRelay<LowCategoryModel>()
        ///전체 카테고리 + 관심 카테고리(일자리)
        var interestCategoryOutput = PublishRelay<isMyInterestCategory>()
        
        ///전체 카테고리 + 관심 카테고리(생활안정)
        var interestLivingOutput = PublishRelay<isMyInterestCategory>()
        ///전체 카테고리 + 관심 카테고리(교육문화)
        var interestEducationCategoryOutput = PublishRelay<isMyInterestCategory>()
        ///전체 카테고리 + 관심 카테고리(참여공간)
        var participationCategoryOutput = PublishRelay<isMyInterestCategory>()
        
        ///이용목적 전체 조회
        var getAllForWhat = PublishRelay<UserPurposeAPIResponse>()
        ///내 이용목적 조회
        var getMyAllForWhat = PublishRelay<MyPurposeAPIResponse>()
        ///이용목적 리턴
        var returnForWhat = PublishRelay<isMyForWhat>()
        
    }
    
    init() {
        ///유저 정보 가져오기
        input.getUserInfo
            .flatMap { self.myPageViewModel.getProfileInfo() }
            .subscribe(onNext: { value in
                self.output.sendUserInfo.accept(value)
                self.input.selectedCategoryObserver.accept(value.category)
                self.input.filteredRegionObserver.accept(value.region)
            }).disposed(by: disposeBag)
        
//        self.myPageViewModel.getProfileInfo()
//            .subscribe(onNext: { value in
//                self.output.sendUserInfo.accept(value)
//            }).disposed(by: disposeBag)
        
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
        
        input.filterResetTriggerObserver
            .subscribe(onNext: { _ in
                self.input.tagLoadActionObserver.accept(.deleteAll)
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
                ///참여 공간 라벨 레이아웃 조정용
                for i in 0..<(data.data[3].childs.count) {
                    FilterViewController.participationTagStr.append(data.data[3].childs[i].name)
                }
                ///생활 안정 라벨 레이아웃 조정용
                for i in 0..<(data.data[1].childs.count) {
                    FilterViewController.livingTagStr.append(data.data[1].childs[i].name)
                }
            }).disposed(by: disposeBag)
        
        input.lowCategoryObserver
            .flatMap { CallCategoryAPI.callChildCategory() }
            .subscribe(onNext: { categories in
                self.output.getLowCategory.accept(categories)
            }).disposed(by: disposeBag)
        
        input.interestCategoryObserver
            .flatMap { CallCategoryAPI.callInterestCategory() }
            .subscribe(onNext: { interestCategories in
                self.output.getInterestCategory.accept(interestCategories)
            }).disposed(by: disposeBag)
        
        input.serviceInfoObserver
            .flatMap { id in
                SearchDetailPolicyAPI.searchDetailPolicy(id: id)}
            .subscribe(onNext: { info in
                guard let str = info.data.support else { return }
                HomeViewModel.serviceString.removeAll()
//                HomeViewModel.serviceString = str.components(separatedBy: ["n", "ㅇ", "\n"])
                HomeViewModel.serviceString.append(info.data.support ?? "")
                self.output.serviceInfoOutput.accept(info)
            }).disposed(by: disposeBag)
        
        ///참여 정책 추가
        input.mypolicyAddObserver
            .flatMap { id in
                AddParticipatedAPI.addParticipationToAPI(id: id, with: nil) }
            .subscribe(onNext: { valid in
                self.output.mypolicyAddOutput.accept(valid)
                self.input.participatedId.accept(HomeViewModel.participatedId)
            }).disposed(by: disposeBag)
                    
        ///메모 알럿 present
        input.presentMemoAlertObserver
            .subscribe(onNext: { _ in
                self.output.goToMemoAlert.accept(true)
            }).disposed(by: disposeBag)
        
        ///메모 서버 저장
        _ = Observable.combineLatest(
            self.input.participatedId,
            self.input.memoTextObserver)
            .map { a, b in
                AddParticipatedAPI.addMemoToAPI(id: a, with: b)
            }
            .flatMap { $0 }
            .subscribe(onNext: { valid in
                print("메모 삽입완료:\(valid)")
                self.output.checkedMemoOutput.accept(valid)
            }).disposed(by: disposeBag)
        
        ///북마크
        input.bookmarkObserver
            .flatMap { BookMarkAPI.addBookmark(polidyId: $0) } //북마크 추가 API
            .subscribe(onNext: { valid in
                self.output.checkedBookmarkOutput.accept(valid)
            }).disposed(by: disposeBag)
        
        ///북마크 삭제
        input.bookmarkDeleteObserver
            .flatMap { BookMarkAPI.deleteBookmark(polidyId: $0) }
            .subscribe(onNext: { valid in
                self.output.checkedBookmarkDeleteOutput.accept(valid)
            }).disposed(by: disposeBag)
        
        ///전체 이용목적 트리거
        input.forWhatObserver
            .flatMap { ForWhatAPI.getAllForWhat() }
            .subscribe(onNext: { allForWhat in
                self.output.getAllForWhat.accept(allForWhat)
            }).disposed(by: disposeBag)
        
        ///내 이용목적 트리거
        input.myForWhatObserver
            .flatMap { ForWhatAPI.getMyAllForWhat() }
            .subscribe(onNext: { myAllForWhat in
                self.output.getMyAllForWhat.accept(myAllForWhat)
            }).disposed(by: disposeBag)
        
        ///관심 일자리, 문화, 참여공간 서버 등록
        input.interestEditCompleteObserver
            .flatMap { CallCategoryAPI.saveCategory(at: $0) }
            .subscribe(onNext: { valid in
                print("관심 일자리, 문화, 참여공간 서버 등록: \(valid)")
            }).disposed(by: disposeBag)
        
        ///이용목적 서버 등록
        input.forWhatEditCompleteObserver
            .flatMap { ForWhatAPI.saveForWhat(forWhatIds: $0) }
            .subscribe(onNext: { valid in
                print("이용목적 서버 등록: \(valid)")
            }).disposed(by: disposeBag)
        
        ///
        ///OUTPUT
        ///
        
        ///맨 처음 로드 시 나의 정책(관심+기본지역), 카테고리에 해당하는 정책 조회
        
        //정렬했을 때 -> Page 0 불러오기
        _ = Observable.combineLatest(
            input.myPolicyTrigger.asObservable(), //나의 정책인지 아닌지
            input.sortActionObserver.asObservable(), //최신/인기순 정렬
            input.textFieldObserver.asObservable(), //정책 검색시
            input.selectedCategoryObserver.asObservable(), //필터링 시 카테고리
            input.filteredRegionObserver.asObservable() //필터링 시 지역
        )
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
        
//        스크롤 내렸을 때 loadMore 하기
        _ = Observable.combineLatest(
            input.myPolicyTrigger.asObservable(),
            input.loadMoreObserver.asObservable(),
//            input.currentPage.asObservable(),
            input.sortActionObserver.asObservable(),
            input.selectedCategoryObserver.asObservable(),
            input.filteredRegionObserver.asObservable()
        )
        .debug()
//        .take(while: { _, can, _, _, _, _ in
//            can == true //여기서 disposed 됨(loadmore -> sort 변경 시)
//        })
        .flatMap({ (myPolicy, isReload, action, categories, filteredRegions) -> Observable<SearchPolicyResponse> in
            print("추가 데이터 불러오기")
            if isReload {
                switch myPolicy {
                case .mypolicy:
                    switch action {
                    case .latest:
                        self.loadMore = true
                        return MyPolicySearchAPI.searchMyPolicy(at: self.currentPage)
                    case .popular:
                        self.loadMore = true
                        return MyPolicySearchAPI.searchMyPolicyAsPopular(at: self.currentPage)
                    }
                case .notMyPolicy:
                    switch action {
                    case .latest:
                        self.loadMore = true
                        return SearchPolicyAPI.searchPolicyAPI(title: self.currentText, at: self.currentPage, to: categories, in: filteredRegions)
                    case .popular:
                        self.loadMore = true
                        return SearchPolicyAPI.searchPolicyAsPopular(title: self.currentText, at: self.currentPage, to: categories, in: filteredRegions)
                    }
                }
            }
            else {
                //dummy data
                self.loadMore = false
                return MyPolicySearchAPI.searchMyPolicy(at: self.currentPage)
            }
            
        })
        .subscribe(onNext: { addedData in
            if(self.loadMore) {
                self.output.policyResult.accept(Action.loadMore(Contents(content: addedData.data!.content)))
                for i in 0..<(addedData.data?.content.count ?? 0) {
                    HomeViewModel.detailId.append(addedData.data?.content[i].id ?? 1000)
                }
                print("추가 로드 되었을 때 상세정보 아이디: \(HomeViewModel.detailId)")
            }
        }).disposed(by: disposeBag)
        
        output.confirmButtonValidOutput = input.confirmButtonValid.asDriver(onErrorJustReturn: false)
                
        ///전체 카테고리 + 관심 카테고리
        _ = Observable.zip(
            self.output.getLowCategory,
            self.output.getInterestCategory, resultSelector: { (all, interest) in
                for i in 0..<(interest.data.count) {
                    if(interest.data[i].subscribe) {
                        //여기서 구독된 거 체크
                        self.checkNotInterestCategoryId.insert([interest.data[i].category.id])
//                        print("구독된거 데이터: \(self.checkNotInterestCategoryId)")
                    }
                }
                for i in 0..<(all.data.count) {
                    if(self.checkNotInterestCategoryId.contains([all.data[i].id])) {
                        ///일자리 분기
                        if(all.data[i].parent.id == 1) {
                            self.output.interestCategoryOutput.accept(.right(ChildDetail(id: all.data[i].id, name: all.data[i].name)))
                            InterestCategoryViewController.confirmJobLabelSize.append(all.data[i].name)
                        }
                        ///생활안정 분기
                        if(all.data[i].parent.id == 2) {
                            self.output.interestLivingOutput.accept(.right(ChildDetail(id: all.data[i].id, name: all.data[i].name)))
                            InterestCategoryViewController.confirmLivingLabelSize.append(all.data[i].name)
                        }
                        
                        ///교육문화 분기
                        else if(all.data[i].parent.id == 3) {
                            self.output.interestEducationCategoryOutput.accept(.right(ChildDetail(id: all.data[i].id, name: all.data[i].name)))
                            InterestCategoryViewController.confirmEduLabelSize.append(all.data[i].name)
                        }
                        ///참여공간 분기
                        else if(all.data[i].parent.id == 4) {
                            self.output.participationCategoryOutput.accept(.right(ChildDetail(id: all.data[i].id, name: all.data[i].name)))
                            InterestCategoryViewController.confirmParticiLabelSize.append(all.data[i].name)
                        }
                            
                        continue
                    }
                    else {
                        ///일자리 분기
                        if(all.data[i].parent.id == 1) {
                            self.output.interestCategoryOutput.accept(.notYet(ChildDetail(id: all.data[i].id, name: all.data[i].name)))
                            InterestCategoryViewController.confirmJobLabelSize.append(all.data[i].name)
                        }
                        ///생활안정 분기
                        if(all.data[i].parent.id == 2) {
                            self.output.interestLivingOutput.accept(.notYet(ChildDetail(id: all.data[i].id, name: all.data[i].name)))
                            InterestCategoryViewController.confirmLivingLabelSize.append(all.data[i].name)
                        }
                        
                        ///교육문화 분기
                        else if(all.data[i].parent.id == 3) {
                            self.output.interestEducationCategoryOutput.accept(.notYet(ChildDetail(id: all.data[i].id, name: all.data[i].name)))
                            InterestCategoryViewController.confirmEduLabelSize.append(all.data[i].name)
                        }
                        ///참여공간 분기
                        else if(all.data[i].parent.id == 4) {
                            self.output.participationCategoryOutput.accept(.notYet(ChildDetail(id: all.data[i].id, name: all.data[i].name)))
                            InterestCategoryViewController.confirmParticiLabelSize.append(all.data[i].name)
                        }
                    }
                }                
            })
        .subscribe(onNext: { _ in
            print("방출")
        }).disposed(by: disposeBag)
        
        ///리셋버튼 클릭 시 전체 카테고리 가져오기
        _ = Observable.zip(self.input.resetTrigger, self.output.getLowCategory, resultSelector: { _, all in
            for i in 0..<(all.data.count) {
                if(all.data[i].parent.id == 1) {
                    self.output.interestCategoryOutput.accept(.clear(true))
                } else if(all.data[i].parent.id == 2) {
                    self.output.interestLivingOutput.accept(.clear(true))
                }
                else if(all.data[i].parent.id == 3) {
                    self.output.interestEducationCategoryOutput.accept(.clear(true))
                } else if(all.data[i].parent.id == 4) {
                    self.output.participationCategoryOutput.accept(.clear(true))
                }
            }
        })
        .subscribe(onNext: {
            print("리셋 방출")
        }).disposed(by: disposeBag)
    
        ///전체 이용목적 + 관심 이용목적
        _ = Observable.zip(
            self.output.getAllForWhat, self.output.getMyAllForWhat, resultSelector: { all, my in
                //내 이용목적과 전체 이용목적을 비교해서 중복된다면 저장
                all.data.forEach { data in
                    my.data.forEach { num in
                        if(data.id == num) {
                            self.checkIsMyForWhat.insert([num])
//                            print("체크 마이 이용목적: \(self.checkIsMyForWhat)")
                        }
                    }
                }
                
                for i in 0..<(all.data.count) {
                    if(self.checkIsMyForWhat.contains([all.data[i].id])) {
                        InterestCategoryViewController.confirmIsForWhatLabelSize.append(all.data[i].name)
                        self.output.returnForWhat.accept(.right(all.data[i]))
                    } else {
                        InterestCategoryViewController.confirmIsForWhatLabelSize.append(all.data[i].name)
                        self.output.returnForWhat.accept(.nope(all.data[i]))
                    }
                }
            })
        .subscribe(onNext: {
            print("이용목적 방출")
        }).disposed(by: disposeBag)
        
        ///전체 이용목적 초기화
        _ = Observable.zip(self.input.resetTrigger, self.output.getAllForWhat, resultSelector: { _, all in
            for _ in 0..<(all.data.count) {
                self.output.returnForWhat.accept(.clear(true))
            }
        })
        .subscribe(onNext: {
            print("이용목적 클리어 방출")
        }).disposed(by: disposeBag)
        
        
        
        
    }

}
