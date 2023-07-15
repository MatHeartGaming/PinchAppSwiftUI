//
//  PageModel.swift
//  PinchApp
//
//  Created by Matteo Buompastore on 15/07/23.
//

import Foundation

struct Page : Identifiable {
    let id : Int
    let imageName : String
}

extension Page {
    
    var thumbnailName : String {
        return "thumb-" + imageName
    }
    
}
