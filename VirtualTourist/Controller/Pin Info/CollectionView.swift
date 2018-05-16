//
//  CollectionView.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/13/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit

extension PinInfoVC: UICollectionViewDelegate {
    
    //When photo is selected, photo is faded
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        selectedPhotos[indexPath] = cell.collectionCell
        cell.photoImage.alpha = 0.3
        
        print(selectedPhotos)
    }
    
    //When photo is deselected, photo reverts back to original state
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        selectedPhotos[indexPath] = nil
        cell.photoImage.alpha = 1
        
        print(selectedPhotos)
    }
    
}

extension PinInfoVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return annotationPhotoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.collectionCell = annotationPhotoArray[indexPath.row]
        cell.imageData = annotationPhotoArray[indexPath.row].imageData
        cell.photoImage.alpha = selectedPhotos[indexPath] != nil ? 0.3 : 1
        
        if cell.imageData == placeHolderData {
            
            cell.loadingActivityIndicator.startAnimating()
            cell.loadingActivityIndicator.isHidden = false
            
        } else {
            
            cell.loadingActivityIndicator.stopAnimating()
            cell.loadingActivityIndicator.isHidden = true
            
        }
        return cell
    }
}
