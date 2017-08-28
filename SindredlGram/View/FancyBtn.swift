//
//  FancyBtn.swift
//  SindredlGram
//
//  Created by Sindre Dahl Løken on 28.08.2017.
//  Copyright © 2017 Sindre Dahl Løken. All rights reserved.
//

import UIKit

class FancyBtn: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 2.0
    }
    
    

}
