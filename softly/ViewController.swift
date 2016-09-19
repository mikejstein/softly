//
//  ViewController.swift
//  softly
//
//  Created by Michael Stein on 6/6/16.
//  Copyright © 2016 Mike Stein Online. All rights reserved.
//

import UIKit


enum NeighborState {
    case top
    case bottom
    case both
}

class ViewController: UIViewController {
    var swiped = false
    var lastPoint = CGPoint.zero
    
    var changeSet = Set<UnsafeMutablePointer<UInt32>>()
    
    let mainImageView:UIImageView = UIImageView()
    let tempImageView:UIImageView = UIImageView()
    
    /*
     Let's think this one through.
     I need to animate over time a change in pixels.
     I can create an array of XXX, which lists all the pixels who have neighbors that need to change
     On each hit, i change the neighbors, and check on those neighbors.
     
    */
    
    override func viewDidLoad() {
        mainImageView.frame = self.view.frame
        tempImageView.frame = self.view.frame
        
        self.view.addSubview(mainImageView)
        self.view.addSubview(tempImageView)
    }
    
    /*
 When I put my finger on the screen, get the last point I touched
 */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first as UITouch? {
            lastPoint = touch.locationInView(self.view)
        }
    }
    
    /*
 Draw a line between two points.
 Interestingly, it's drawing the line on to main image, not temp image.
 Why?
 */
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextSetLineCap(context,  .Round)
        CGContextSetLineWidth(context, 2.0)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetBlendMode(context, .Normal)
        
        CGContextStrokePath(context)
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        //tempImageView.image = pixelBleed(tempImageView.image!)
        addPointToChange(tempImageView.image!, point: toPoint)
        print(changeSet.count)
    }
    
    func addPointToChange(image:UIImage, point:CGPoint) {
        UIGraphicsBeginImageContext(image.size) //se
        let context = UIGraphicsGetCurrentContext()
        image.drawAtPoint(CGPointZero)
        
        let pixelsWide = CGImageGetWidth(image.CGImage)
        let pixelsHigh = CGImageGetHeight(image.CGImage)
        
        
        
        let pixelBuffer = UnsafeMutablePointer<UInt32>(CGBitmapContextGetData(context)) // a pointer to the start of the memory location of the bitmap
        var currentPixel = pixelBuffer // the pointer to the currently selectd pixels location
        
        
        /*
         What's the logic we need?
         Every time we loop through the buffer, we want to look for a pixel of a certain color, and change the color until we be dead.
         */
        for _ in 0 ..< Int(pixelsHigh) {
            for _ in 0 ..< Int(pixelsWide) {
                let pixel = currentPixel.memory //converting the pointer to the actual memory.
                if red(pixel) >= 100 {
                    changeSet.insert(currentPixel)
                }
                currentPixel += 1 //advance the pointer to the next byte in memory
                
            }
        }
        UIGraphicsEndImageContext()
    }
    
    func pixelBleed(image:UIImage) -> UIImage {
        UIGraphicsBeginImageContext(image.size) //se
        let context = UIGraphicsGetCurrentContext()
        image.drawAtPoint(CGPointZero)
        
        let pixelsWide = CGImageGetWidth(image.CGImage)
        let pixelsHigh = CGImageGetHeight(image.CGImage)
        
        for pixel in changeSet {
            let abovePixel = pixel - 1
            let alpha = UInt8(Int((Double(30 - Int(i)) / 30.0) * 255))
            backPixel.memory = rgba(red:90, green: 0, blue: 0, alpha: alpha)
            backPixel -= Int(pixelsWide) + 1
        }
    }
    
    /*
    func pixelBleed(image:UIImage) -> UIImage{
        UIGraphicsBeginImageContext(image.size) //se
        let context = UIGraphicsGetCurrentContext()
        image.drawAtPoint(CGPointZero)
        
        let pixelsWide = CGImageGetWidth(image.CGImage)
        let pixelsHigh = CGImageGetHeight(image.CGImage)
        
        

        let pixelBuffer = UnsafeMutablePointer<UInt32>(CGBitmapContextGetData(context)) // a pointer to the start of the memory location of the bitmap
        var currentPixel = pixelBuffer // the pointer to the currently selectd pixels location
        
        
        /*
         What's the logic we need?
         Every time we loop through the buffer, we want to look for a pixel of a certain color, and change the color until we be dead.
        */
        for _ in 0 ..< Int(pixelsHigh) {
            for _ in 0 ..< Int(pixelsWide) {
                let pixel = currentPixel.memory //converting the pointer to the actual memory.
                if red(pixel) >= 100 {
                    var backPixel = currentPixel - 1
                    //we want draw bleed up a bit, so how do I do it?
                    for i in 0...30 {
                        let alpha = UInt8(Int((Double(30 - Int(i)) / 30.0) * 255))
                        backPixel.memory = rgba(red:90, green: 0, blue: 0, alpha: alpha)
                        backPixel -= Int(pixelsWide) + 1
                    }
                    backPixel = currentPixel - 1
                    for i in 0...30 {
                        let alpha = UInt8(Int((Double(30 - Int(i)) / 30.0) * 255))
                        backPixel.memory = rgba(red:90, green: 0, blue: 0, alpha: alpha)
                        backPixel += Int(pixelsWide) + 1
                    }
                }
                currentPixel += 1 //advance the pointer to the next byte in memory
                
            }
        }
        
        let retImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return retImg
    }
 */
    
    /*
 When I move my finger, set swipe to true.
 Get the current point I'm on, and draw a point from last point to current point.
 Then set last point to current point
 */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first as UITouch? {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
            if traitCollection.forceTouchCapability == UIForceTouchCapability.Available {
                if (touch.force > 3.0) {
                    mainImageView.image = nil
                    tempImageView.image = nil
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .Normal, alpha: 1.0)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    func alpha(color: UInt32) -> UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    func red(color: UInt32) -> UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    func green(color: UInt32) -> UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    func blue(color: UInt32) -> UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    func rgba(red red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> UInt32 {
        return (UInt32(alpha) << 24) | (UInt32(red) << 16) | (UInt32(green) << 8) | (UInt32(blue) << 0)
    }
    
}

