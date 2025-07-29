//
//  StarsRateView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 29.07.2025.
//
    
import UIKit

class StarsRateView: UIControl {
    
    // MARK: - Objects
    
    private struct Constants {
        static let starSize = CGSize(width: 34.0, height: 34.0)
        static let spacing: CGFloat = 2.0
        static let contentInsets  = UIEdgeInsets(top: 8.0, left: 30.0, bottom: 12.0, right: 30.0)
    }
    
    // MARK: - Properties. Private
    
    private let starsCount: Int
    private var starsViews: [StarView] = []
    
    // MARK: - Properties. Public
    
    var starsSelected: Int {
        didSet {
            self.starsSelected = min(max(0, self.starsSelected), self.starsCount)
            if oldValue != starsSelected {
                self.updateStarViewsState()
                self.sendActions(for: .valueChanged)
                UserDefaults.standard.set(starsSelected, forKey: GlobalConstants.userDefaultsAppRatingKey)
            }
        }
    }
    
    // MARK: — Initializer
    
    init(starsCount: Int = 5) {
        let saved = UserDefaults.standard.integer(forKey: GlobalConstants.userDefaultsAppRatingKey)
        self.starsCount = starsCount
        
        let initial = min(max(0, saved), starsCount)
        self.starsSelected = initial
        
        super.init(frame: .zero)
        
        self.loadLayout()
        self.updateStarViewsState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !self.starsViews.isEmpty else {
            return
        }
        var x = Constants.contentInsets.left
        let y = Constants.contentInsets.top
        for star in self.starsViews {
            star.frame = CGRect(origin: .init(x: x, y: y), size: Constants.starSize)
            x += Constants.starSize.width + Constants.spacing
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let totalWidth = CGFloat(starsCount) * Constants.starSize.width
        + CGFloat(starsCount - 1) * Constants.spacing
        + Constants.contentInsets.left + Constants.contentInsets.right
        
        let totalHeight = Constants.starSize.height + Constants.contentInsets.top + Constants.contentInsets.bottom
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touchPoint = touches.first?.location(in: self) else { return }
        
        let totalWidth = bounds.width
            - Constants.contentInsets.left
            - Constants.contentInsets.right
        
        let rawX = touchPoint.x - Constants.contentInsets.left
        let clampedX = min(max(0.0, rawX), totalWidth)
        let fraction = clampedX / totalWidth
        let selected = Int(floor(fraction * CGFloat(starsCount))) + 1
        self.starsSelected = selected
    }
    
    // MARK: — Methods. Private
    
    private func loadLayout() {
        self.starsViews = (0..<self.starsCount).map { _ in
            StarView(fillColor: UIColor(hex: GlobalConstants.fillStarImageColor), emptyColor: UIColor(hex: GlobalConstants.emptyStarImageColor))
        }
        self.starsViews.forEach(self.addSubview)
    }
    
    private func updateStarViewsState() {
        for (index, star) in self.starsViews.enumerated() {
            star.setSelected(index < self.starsSelected)
        }
    }
    
}
