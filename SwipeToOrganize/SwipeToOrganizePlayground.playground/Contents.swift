//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 750, height: 1334))
        
        let imageView = UIImageView()
        
        let image = #imageLiteral(resourceName: "example.gif")
        imageView.image = image
        
        let imageViewSize = CGSize(width: image.size.width, height: image.size.height)
        let imageViewPoint = CGPoint(x: (view.frame.size.width - image.size.width) / 2, y: (view.frame.size.height - image.size.height) / 2)
        imageView.frame = CGRect(origin: imageViewPoint, size: imageViewSize)
        
        self.view = view
        self.view.addSubview(imageView)
        
    }
    
    
}

// Present the view controller in the Live View window

PlaygroundPage.current.liveView = MyViewController()
