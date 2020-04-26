//
//  FlickrAlbumCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Makaveli Ohaya on 4/20/20.
//  Copyright © 2020 Ohaya. All rights reserved.
//

import UIKit
protocol DeleteCell {
    func delete(index: IndexPath)
}

class FlickrAlbumCollectionViewCell: UICollectionViewCell {
     @IBOutlet weak var image: UIImageView!
        
        @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }
        
        //Containing the actual image
        func cellWithImage(imageFetched: UIImage) {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            image.contentMode = .scaleToFill
            image.image = imageFetched
        }
        
        //Sets cell with placeholder while images load
        func cellWithPlaceHolder() {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            image.contentMode = .scaleToFill
            image.image = UIImage(named: "placeholder")

        }
        
        var index: IndexPath?
        var delegate: DeleteCell?
        
        @IBAction func buttonTapped(_ sender: Any) {
            delegate!.delete(index: index!)
        }
        
    }

    

