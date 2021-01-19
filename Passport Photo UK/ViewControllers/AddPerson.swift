//
//  AddPerson.swift
//  Quick & Easy Photo ID
//
//  Created by Ronak Gondaliya on 09/12/19.
//  Copyright © 2019 Nirav Gondaliya. All rights reserved.
//

import Foundation
import RealmSwift

class AddContact: Object {
    @objc dynamic var FullName = ""
    @objc dynamic var imageData = Data()
}

