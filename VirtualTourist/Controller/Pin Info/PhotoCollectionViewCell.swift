//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/5/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var imageData: Data!
    
    var collectionCell: Photo! {
        didSet {
            configureCell()
        }
    }
    
    // Configures the cell
    func configureCell() {
        photoImage.image = UIImage(data: collectionCell.imageData!)
    }
}
