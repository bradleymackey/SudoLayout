//
//  SudoLayout.swift
//
//  Created by Bradley Mackey on 30/09/2019.
//  MIT Licenced
//

/*
 * Abstract: AutoLayout helpers when programmatically defining views
 */

import UIKit

// MARK: - Helper Structs

/// # EdgeConstraints
/// when a view is edge using a helper method,
/// the binding constraints are returned in this
/// object such that they can be later manipulated
/// (for example, with animations)
public struct EdgeConstraints {
    
    let top: NSLayoutConstraint
    let bottom: NSLayoutConstraint
    let leading: NSLayoutConstraint
    let trailing: NSLayoutConstraint
    
    init(
        _ top: NSLayoutConstraint,
        _ bottom: NSLayoutConstraint,
        _ leading: NSLayoutConstraint,
        _ trailing: NSLayoutConstraint
    ) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
    }
    
    var allConstraints: [NSLayoutConstraint] {
        return [top, bottom, leading, trailing]
    }
    
}

/// # Edges
/// a position on a view, used to restrict particular masks
public struct Edges: OptionSet {
    let rawValue: Int

    static let leading    = Edges(rawValue: 1 << 0)
    static let trailing   = Edges(rawValue: 1 << 1)
    static let top        = Edges(rawValue: 1 << 2)
    static let bottom     = Edges(rawValue: 1 << 3)

    static let sides: Edges = [.leading, .trailing]
    static let tops: Edges  = [.top, .bottom]
    static let all: Edges   = [.top, .bottom, .leading, .trailing]
}

// MARK: - Autolayout Exts.

public extension UIView {
    
    /// enforces that the view hugs and does not compress
    /// in relation to the given axis
    func concrete(for axis: NSLayoutConstraint.Axis) {
        setContentHuggingPriority(.init(1000), for: axis)
        setContentCompressionResistancePriority(.init(1000), for: axis)
    }
    
    /// enforces that the view streches to fill space whenever possible
    /// in relation to the given axis
    func flexible(for axis: NSLayoutConstraint.Axis) {
        setContentHuggingPriority(.init(1), for: axis)
        setContentCompressionResistancePriority(.init(1), for: axis)
    }
    
    /// a stretchy spacer view, allows other views
    /// to wrap their content inside of a stack view easily
    static var spacer: UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.flexible(for: .horizontal)
        view.flexible(for: .vertical)
        return view
    }
    
    /// a fixed spacer of a specific height
    static func spacer(height: CGFloat) -> UIView {
        let view = UIView()
        view.height(equalTo: height)
        return view
    }
    
    /// a fixed spacer of a specific width
    static func spacer(width: CGFloat) -> UIView {
        let view = UIView()
        view.width(equalTo: width)
        return view
    }
    
    /// constrain this view to have a height equal to the supplied view, with the given multiplier
    @discardableResult
    func height(
        equalTo view: UIView, multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        let constraint = heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplier)
        constraint.isActive = true
        return constraint
    }
    
    /// wrapper for autolayout constraint
    @discardableResult
    func height(
        equalTo constant: CGFloat
    ) -> NSLayoutConstraint {
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func height(
        lessThan constant: CGFloat
    ) -> NSLayoutConstraint {
        let constraint = heightAnchor.constraint(lessThanOrEqualToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    /// constrain this view to have an equal width to the the supplied view, with the given multiplier
    @discardableResult
    func width(
        equalTo view: UIView, multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        let constraint = widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier)
        constraint.isActive = true
        return constraint
    }
    
    /// constrain this view to have an equal width to the the supplied view, with the given multiplier
    @discardableResult
    func constrainAsSquare() -> NSLayoutConstraint {
        let constraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1)
        constraint.isActive = true
        return constraint
    }
    
    /// wrapper for autolayout constraint
    @discardableResult
    func width(equalTo constant: CGFloat) -> NSLayoutConstraint {
        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    /// make this view have an equal width and height to the supplied view
    @discardableResult
    func size(equalTo view: UIView) -> (height: NSLayoutConstraint, width: NSLayoutConstraint) {
        let h = height(equalTo: view)
        let w = width(equalTo: view)
        return (h, w)
    }
    
    /// Adds a view as a subview and constrains it to the edges
    /// of its new containing view.
    ///
    /// - Parameter view: view to add as subview and constrain
    @discardableResult
    func addEdgeConstrainedSubview(view: UIView) -> EdgeConstraints {
        addSubview(view)
        return edgeConstrain(subview: view)
    }
    
    /// constrains the given subview to be in the center of this view
    func centerConstrain(subview: UIView, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        let x = subview.centerXAnchor.constraint(equalTo: centerXAnchor, constant: xOffset)
        let y = subview.centerYAnchor.constraint(equalTo: centerYAnchor, constant: yOffset)
        NSLayoutConstraint.activate([x, y])
    }
    
    /// Constrains a given subview to all 4 sides
    /// of its containing view.
    ///
    /// - parameter subview: view to constrain to its container
    /// - parameter inset: how inset this should be (default 0)
    /// - parameter priority: standard auto-layout priority
    /// - returns: the edge constraints that were supplied, so these can be manipulated later on if required
    @discardableResult
    func edgeConstrain(
        subview: UIView, inset: UIEdgeInsets = .zero, priority: UILayoutPriority = .required
    ) -> EdgeConstraints {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let top = subview.topAnchor.constraint(equalTo: topAnchor, constant: inset.top)
        let bottom = subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.bottom)
        let leading = subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left)
        let trailing = subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset.right)
        let edgeConstraints = EdgeConstraints(top, bottom, leading, trailing)
        edgeConstraints.allConstraints.forEach { cons in
            cons.priority = priority
        }
        NSLayoutConstraint.activate(edgeConstraints.allConstraints)
        return edgeConstraints
    }
    
    /// Constrains a given subview to all 4 sides
    /// of its containing view's safe area.
    ///
    /// - parameter subview: view to constrain to its container
    /// - parameter inset: how inset this should be (default 0)
    /// - parameter priority: standard auto-layout priority
    /// - returns: the edge constraints that were supplied, so these can be manipulated later on if required
    @discardableResult
    func edgeConstrainToSafeArea(subview: UIView, inset: UIEdgeInsets = .zero) -> EdgeConstraints {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let top = subview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: inset.top)
        let bottom = subview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -inset.bottom)
        let leading = subview.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: inset.left)
        let trailing = subview.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -inset.right)
        NSLayoutConstraint.activate([ top, bottom, leading, trailing ])
        return EdgeConstraints(top, bottom, leading, trailing)
    }
    
    /// constrain only a subset of views to the safe area, the rest to the edge of the display
    @discardableResult
    func edgeConstrainSubsetOfEdgesToSafeArea(
        subview: UIView, edges: Edges, inset: UIEdgeInsets = .zero
    ) -> EdgeConstraints {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let topBolt: NSLayoutYAxisAnchor = edges.contains(.top) ? safeAreaLayoutGuide.topAnchor : topAnchor
        let top = subview.topAnchor.constraint(equalTo: topBolt, constant: inset.top)
        let bottomBolt: NSLayoutYAxisAnchor = edges.contains(.bottom) ? safeAreaLayoutGuide.bottomAnchor : bottomAnchor
        let bottom = subview.bottomAnchor.constraint(equalTo: bottomBolt, constant: -inset.bottom)
        let leadingBolt: NSLayoutXAxisAnchor = edges.contains(.leading) ? safeAreaLayoutGuide.leadingAnchor : leadingAnchor
        let leading = subview.leadingAnchor.constraint(equalTo: leadingBolt, constant: inset.left)
        let trailingBolt: NSLayoutXAxisAnchor = edges.contains(.trailing) ? safeAreaLayoutGuide.trailingAnchor : trailingAnchor
        let trailing = subview.trailingAnchor.constraint(equalTo: trailingBolt, constant: -inset.right)
        NSLayoutConstraint.activate([ top, bottom, leading, trailing ])
        return EdgeConstraints(top, bottom, leading, trailing)
    }

    @discardableResult
    func edgeConstrainAsSquare(subview: UIView, inset: UIEdgeInsets = .zero) -> EdgeConstraints {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        setContentHuggingPriority(.init(1), for: .vertical)
        setContentHuggingPriority(.init(1), for: .horizontal)
        
        let edgeConstraints = edgeConstrain(subview: subview, inset: inset, priority: .defaultLow)
       
        // also constrain to be a square in the middle
        let height = subview.heightAnchor.constraint(equalTo: subview.widthAnchor, multiplier: 1)
        height.priority = .required
        height.isActive = true
        let centerx = centerXAnchor.constraint(equalTo: subview.centerXAnchor)
        centerx.priority = .required
        centerx.isActive = true
        let centery = centerYAnchor.constraint(equalTo: subview.centerYAnchor)
        centery.priority = .required
        centery.isActive = true
        
        return edgeConstraints
    }
    
}
