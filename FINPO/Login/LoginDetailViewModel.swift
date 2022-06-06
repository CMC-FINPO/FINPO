//
//  LoginDetailViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/04.
//

import Foundation
import RxSwift
import RxCocoa

class LoginDetailViewModel {
    
    let disposeBag = DisposeBag()
    var dataSource = [[Terms]]()
    
    //OUTPUT
    let updateTermsContents = PublishRelay<Void>() //for tableview reload
    let satisfyTermsPermission = PublishRelay<Bool>()
    let acceptAllTerms = PublishRelay<Bool>()
    
    func viewWillAppear() {
        dataSource = Terms.loadSampleData()
    }
    
    func accpetAllTerms(_ isCheckedBtnAllAccept: Bool?) {
        guard let isCheckedBtnAllAccept = isCheckedBtnAllAccept else { return }
        for section in 0 ..< dataSource.count {
            for row in 0 ..< dataSource[section].count {
                dataSource[section][row].isAccept = isCheckedBtnAllAccept
            }
        }
        
        updateTermsContents.accept(())
        satisfyTermsPermission.accept(isCheckedBtnAllAccept)
    }
    
    func didSelectTermsCell(indexPath: IndexPath) {
        // main cell tap -> synchronize sub cell
        if indexPath.row == 0 {
            dataSource[indexPath.section][0].isAccept.toggle()
            
            for row in 1 ..< dataSource[indexPath.section].count {
                dataSource[indexPath.section][row].isAccept = dataSource[indexPath.section][0].isAccept
            }
        }
        // sub cell tap -> sub cell에 따라 main cell update
        else {
            dataSource[indexPath.section][indexPath.row].isAccept.toggle()
            
            for row in 1 ..< dataSource[indexPath.section].count {
                if !dataSource[indexPath.section][row].isAccept {
                    dataSource[indexPath.section][0].isAccept = false
                    break //sub cell이 하나라도 false면 main은 비활성화
                }
                dataSource[indexPath.section][0].isAccept = true
            }
        }
        updateTermsContents.accept(())
        checkSatisfyTerms()
        checkAcceptAllTerms()
    }
    
    private func checkSatisfyTerms() {
        for termsList in dataSource {
            for terms in termsList where terms.isMandatory && !terms.isAccept {
                satisfyTermsPermission.accept(false)
                return
            }
        }
        satisfyTermsPermission.accept(true)
    }
    
    private func checkAcceptAllTerms() {
        for termsList in dataSource {
            for terms in termsList where !terms.isAccept {
                acceptAllTerms.accept(false)
                return
            }
        }
        acceptAllTerms.accept(true)
    }
    
}
