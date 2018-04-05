//
//  ManagedObjects.swift
//  Everpobre
//
//  Created by Rafael Lujan on 13/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import Foundation

extension Note {
    //Si no coincide la key hacer este par
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        if key == "testTitle" {
            self.setValue(value, forKey: "title")
        }
    }
    public override func value(forUndefinedKey key: String) -> Any? {
        if key == "testTitle" {
            return "testTitle"
        } else {
            return super.value(forKey: key)
        }
    }
}
