//
//  ChannelFlowLayout.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/22/20.
//

import UIKit

class ChannelFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        layoutAttributes?.forEach { attribute in
            if attribute.representedElementKind == UICollectionView.elementKindSectionHeader {
                guard let collectionView = collectionView else { return }
                let contentOffsetY = collectionView.contentOffset.y
                
                if contentOffsetY < 0 {
                    let width = collectionView.frame.width
                    let height = max(10, attribute.frame.height - contentOffsetY)
                    attribute.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
                }
                else if contentOffsetY < 150 {
                    let width = collectionView.frame.width
                    let height = max(attribute.frame.height - contentOffsetY, 50)
                    attribute.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
                }
            }
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
