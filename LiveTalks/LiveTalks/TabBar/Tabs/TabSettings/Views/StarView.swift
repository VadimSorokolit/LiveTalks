//
//  StarView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 29.07.2025.
//
    
import UIKit

class StarView: UIView {
    
    // MARK: - Properties. Private
    
    private let imageView = UIImageView()
    private let templateImage: UIImage
    private let fillColor: UIColor
    private let emptyColor: UIColor
    
    // MARK: - Initializer
    
    init(fillColor: UIColor, emptyColor: UIColor) {
        guard let base = UIImage(named: GlobalConstants.ratingStarImageName) else {
            fatalError("Missing star image")
        }
        
        self.templateImage = base.withRenderingMode(.alwaysTemplate)
        self.fillColor = fillColor
        self.emptyColor = emptyColor
        
        super.init(frame: .zero)
        
        self.addSubview(self.imageView)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = self.templateImage
        self.setSelected(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = bounds
    }
    
    // MARK: - Methods. Public
    
    func setSelected(_ selected: Bool) {
        self.imageView.tintColor = selected ? self.fillColor : self.emptyColor
    }
    
}
