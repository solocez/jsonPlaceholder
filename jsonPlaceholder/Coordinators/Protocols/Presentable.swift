//
//  Presentable.swift
//  EmployerApp
//
//  Created by Leo Marcotte on 12/03/2018.
//  Copyright © 2018 Leo Marcotte. All rights reserved.
//

import UIKit

public protocol Presentable {
    func toPresent() -> UIViewController?
}

extension UIViewController: Presentable {
    public func toPresent() -> UIViewController? {
        self
    }
}
