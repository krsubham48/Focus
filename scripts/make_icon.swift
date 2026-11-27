#!/usr/bin/env swift
// Draws the app icon: a white three-quarter ring on teal. Usage: swift scripts/make_icon.swift
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024
// No alpha channel: the App Store rejects icons with one.
let context = CGContext(
    data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
context.setFillColor(CGColor(srgbRed: 0x0F / 255, green: 0x7C / 255, blue: 0x74 / 255, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: size, height: size))
context.setStrokeColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
context.setLineWidth(90)
context.setLineCap(.round)
// From the top, clockwise, three quarters of the way round.
context.addArc(center: CGPoint(x: 512, y: 512), radius: 300, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
context.strokePath()

let output = URL(fileURLWithPath: "Focus/Assets.xcassets/AppIcon.appiconset/icon-1024.png")
let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, context.makeImage()!, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("could not write the icon") }
print("wrote \(output.path)")
