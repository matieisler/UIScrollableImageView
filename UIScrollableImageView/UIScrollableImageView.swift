//
//  UIScrollableImageView.swift
//  UIScrollableImageView
//
//  Created by Matias Eisler on 9/17/17.
//  Copyright © 2017 Matias Eisler. All rights reserved.
//

import UIKit

class UIScrollableImageView: UIImageView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    private var zoom = false
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var view: UIView!
    private var closeButton: UIButton!
    var minimumZoomScale: CGFloat = 1.0
    var maximumZoomScale: CGFloat = 3.0
    var closeButtonImage: UIImage!
    
    override init(image: UIImage?) {
        super.init(image: image)
        setTapListener()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTapListener()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setTapListener()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTapListener()
    }
    
    private func setTapListener() {
        self.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(displayScrollableImage))
        self.addGestureRecognizer(recognizer)
        closeButtonImage = UIImage(named: "X")
    }
    
    private func createFullscreenView() {
        view = UIView(frame: self.frame)
        view.contentMode = UIViewContentMode.scaleAspectFit
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        view.alpha = 0.0
        view.isUserInteractionEnabled = true
    }
    
    @objc private func displayScrollableImage() {
        
        let window = UIApplication.shared.windows.first!
        
        createFullscreenView()
        
        self.closeButton = createCloseButton()
        self.view.addSubview(closeButton)
        
        if self.image == nil {
            return
        }
        
        let imageWidth = self.image!.size.width
        let imageHeight = self.image!.size.height
        let heightWidthRatio = imageHeight / imageWidth
        
        let scrollViewWidth = window.frame.size.width
        let scrollViewHeight = min(scrollViewWidth * heightWidthRatio, scrollViewWidth * 1.4)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: (window.frame.height - scrollViewHeight) / 2, width: scrollViewWidth, height: scrollViewHeight))
        scrollView.delegate = self
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.contentSize = self.image!.size
        scrollView.contentMode = .center
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(updateZoom))
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)
        
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        imageView.image = self.image
        imageView.contentMode = .scaleAspectFit
        
        scrollView.addSubview(imageView)
        
        view.addSubview(scrollView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideFullscreen))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        UIApplication.shared.keyWindow?.addSubview(view)

        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            
            self.view.frame = window.frame
            self.view.alpha = 1
            self.view.layoutSubviews()
            
            //self.closeLabel.alpha = 1
            self.closeButton.alpha = 0.7
        }, completion: { _ in
        })
    }
    
    @objc private func hideFullscreen() {
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            
            self.view.frame = self.frame
            self.view.alpha = 0
            
        }, completion: { finished in
            
            self.view.removeFromSuperview()
            self.view = nil
            self.scrollView = nil
            self.imageView = nil
            self.closeButton = nil
            
        })
    }
    
    @objc private func updateZoom() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            
            if self.zoom {
                self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                self.zoom = false
            } else {
                self.scrollView.zoomScale = self.scrollView.maximumZoomScale
                self.zoom = true
            }
            
        }, completion: nil)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    private func createCloseButton() -> UIButton {
        let buttonSide = self.view.frame.width * 0.1
        let button = UIButton(frame: CGRect(x: UIApplication.shared.windows.first!.frame.width - (3/2) * buttonSide, y: buttonSide, width: buttonSide, height: buttonSide))
        button.setBackgroundImage(closeButtonImage, for: .normal)
        button.imageView?.contentMode = .scaleToFill
        button.alpha = 0.0
        button.addTarget(self, action: #selector(hideFullscreen), for: .touchUpInside)
        return button
    }
    
    func setCloseButtonImage(image: UIImage) {
        self.closeButtonImage = image
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !scrollView.bounds.contains(touch.location(in: scrollView))
    }
    
}
