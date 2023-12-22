//
//  OnboardingCollectionViewCell.swift
//  Onboarding
//
//  Created by Maheen on 06/06/2022.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: OnboardingCollectionViewCell.self)

    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var slideTitleLbl: UILabel!
    @IBOutlet weak var slideDescriptionLbl: UILabel!
    @IBOutlet weak var imgCornerDecoration: UIImageView!
    
    func setup(_ slide: OnboardingSlide) {
        slideImageView.image = slide.image
        slideTitleLbl.text = slide.title
        slideDescriptionLbl.text = slide.description
    }
}
