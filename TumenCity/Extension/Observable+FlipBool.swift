//
//  Observable+FlipBool.swift
//  TumenCity
//
//  Created by Павел Кай on 21.06.2023.
//

import RxSwift

extension ObservableType where Element == Bool {
    func flip() -> Observable<Bool> {
        return map { !$0 }
    }
}
