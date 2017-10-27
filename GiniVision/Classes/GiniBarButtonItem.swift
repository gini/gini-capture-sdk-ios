//
//  GiniBarButtonItem.swift
//  GiniVision
//
//  Created by Peter Pult on 13/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

internal class GiniBarButtonItem: UIBarButtonItem {
    
    init(image: UIImage?, title: String?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector) {
        super.init()
        self.style = style
        self.target = target
        self.action = action
        
        // Prioritize image over title
        if let _ = image {
            self.image = image
        } else {
            self.title = title
        }
        
        // Set accessibility label on all elements
        self.accessibilityLabel = title
        
        var attributes = titleTextAttributes(for: .normal) ?? [String : AnyObject]()
        attributes[NSFontAttributeName] = GiniConfiguration.sharedConfiguration.customFont == nil ?
            GiniConfiguration.sharedConfiguration.navigationBarItemFont :
            GiniConfiguration.sharedConfiguration.font.regular.withSize(16)
        setTitleTextAttributes(attributes, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
