import UIKit

public class Bakery: NSObject {

  static let bakery = Bakery()
  static var bakes: [[Bake]] = [[]]
  static var delays: [NSTimeInterval] = []
  var closures: [(() -> Void)?] = []
  var final: (() -> Void)?

  /**
   Then gets called when the animation block above has ended.
   */
  public func then(closure: () -> Void) -> Bakery {
    closures.append(closure)
    return Bakery.bakery
  }

  /**
   Finally is the last method that gets called when the chain of animations is done.
   */
  public func finally(closure: () -> Void) {
    final = closure
  }

  // MARK: - Animate

  static func animate() {
    guard let delay = Bakery.delays.first else { return }

    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue()) {
      guard let bake = Bakery.bakes.first else { return }

      for (_, bake) in bake.enumerate() {
        guard let presentedLayer = bake.view.layer.presentationLayer() as? CALayer else { return }

        for (index, animation) in bake.animations.enumerate() {
          let property = bake.properties[index]

          if bake.kind == .Bezier {
            animation.values?.insert(Animation.propertyValue(property, layer: presentedLayer), atIndex: 0)
          } else if let value = bake.finalValues.first {
            animation.values = Baker.calculateSpring(property, finalValue: value, layer: presentedLayer, type: .Spring)
            animation.duration = Baker.springTiming
          }

          bake.finalValues.removeFirst()
          bake.view.layer.addAnimation(animation, forKey: "animation-\(index)")
        }
      }
    }
  }

  // MARK: - Finish animation

  public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
    guard var group = Bakery.bakes.first, let animation = anim as? CAKeyframeAnimation else { return }

    var index = 0
    var animationIndex = 0
    for (position, bake) in group.enumerate() {
      for (animationPosition, _) in bake.animations.enumerate()
        where bake.view.layer.animationForKey("animation-\(animationPosition)") == animation {

        index = position
        animationIndex = animationPosition
      }
    }

    let bake = group[index]

    guard let layer = bake.view.layer.presentationLayer() as? CALayer else { return }

    bake.view.layer.position = layer.position
    bake.view.layer.transform = layer.transform
    bake.view.layer.cornerRadius = layer.cornerRadius
    bake.view.layer.removeAnimationForKey("animation-\(animationIndex)")
    bake.animations.removeAtIndex(animationIndex)
    bake.properties.removeAtIndex(animationIndex)

    if bake.animations.isEmpty {
      group.removeAtIndex(index)

      Bakery.bakes[0] = group
    }

    if group.isEmpty {
      Bakery.bakes.removeFirst()
      Bakery.delays.removeFirst()
      Bakery.animate()

      if let firstClosure = closures.first, closure = firstClosure {
        closure()
        closures.removeFirst()
      } else if !closures.isEmpty {
        closures.removeFirst()
      }
    }

    if let final = final where Bakery.bakes.isEmpty {
      final()
    }
  }
}
