//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/4/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
