//
//  ViewController.swift
//  MaterialDesignWidgetsDemo
//
//  Created by Ho, Tsung Wei on 5/17/19.
//  Copyright © 2019 Michael Ho. All rights reserved.
//

import UIKit
import MaterialDesignWidgets

class ViewController: UIViewController {
    
    private var stackView: UIStackView!
    private var topSegmentControl: UISegmentedControl!
    private let widgets: [WidgetType] = [
        .textField,
        .segmentedControlOutline,
        .segmentedControlLineText,
        .segmentedControlFill,
        .segmentedControlLineIcon
    ]
    
    private let buttons: [WidgetType] = [
        .button,
        .loadingButton,
        .verticalButton,
        .shadowButton,
        .loadingIndicator
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        topSegmentControl = UISegmentedControl(items: ["All Widgets", "Buttons"])
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.systemBackground
            topSegmentControl.selectedSegmentTintColor = UIColor.systemFill
        }
        topSegmentControl.tintColor = .black
        
        topSegmentControl.addTarget(self, action: #selector(topSegmentDidChange(_:)), for: .valueChanged)
        stackView = UIStackView(axis: .vertical, distribution: .fill, spacing: self.view.frame.height * 0.01)
        self.view.addSubViews([topSegmentControl, stackView])
        
        topSegmentControl.selectedSegmentIndex = 0
        topSegmentDidChange(topSegmentControl)
    }
    /**
     Reload demo app UI.
    
    - Parameter widgetTypes: The widget type to display.
    */
    private func reloadStackView(_ widgetTypes: [WidgetType]) {
        // Remove old widgets
        self.stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        // Add all widgets
        for type in widgetTypes {
            let label = UILabel()
            label.text = type.rawValue
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            // Set label color for dark mode
            label.textColor = .black
            if #available(iOS 13.0, *) {
                label.textColor = .label
            }
            stackView.addArrangedSubview(label)
            if let last = stackView.arrangedSubviews.last {
                last.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.06).isActive = true
            }
            
            if type == .loadingButton, let stack = type.widget as? UIStackView {
                for subView in stack.arrangedSubviews {
                    if let loadingBtn = subView as? MaterialButton {
                        loadingBtn.addTarget(self, action: #selector(tapLoadingButton(sender:)), for: .touchUpInside)
                    }
                }
                stackView.addArrangedSubview(stack)
            } else if let segCtrl = type.widget as? MaterialSegmentedControl {
                switch type {
                case .segmentedControlFill, .segmentedControlOutline:
                    setSampleSegments(segmentedControl: segCtrl, radius: 18.0)
                case .segmentedControlLineText:
                    setSampleSegments(segmentedControl: segCtrl, radius: 0.0)
                case .segmentedControlLineIcon:
                    let icons = [#imageLiteral(resourceName: "ic_home_fill").colored(.darkGray)!, #imageLiteral(resourceName: "ic_home_fill").colored(.gray)!, #imageLiteral(resourceName: "ic_home_fill").colored(.lightGray)!]
                    for i in 0..<3 {
                        segCtrl.appendIconSegment(icon: icons[i], preserveIconColor: true, rippleColor: .clear, cornerRadius: 0.0)
                    }
                default:
                    continue
                }
                stackView.addArrangedSubview(segCtrl)
            } else {
                stackView.addArrangedSubview(type.widget)
            }
            
            if let last = stackView.arrangedSubviews.last {
                last.heightAnchor.constraint(equalTo: self.view.heightAnchor,
                                             multiplier: type == .verticalButton || type == .segmentedControlLineIcon ? 0.1 : 0.06).isActive = true
            }
        }
        self.view.layoutIfNeeded()
    }
    /**
     Create sample segments for the segmented control.
     
     - Parameter segmentedControl: The segmented control to put these segments into.
     - Parameter cornerRadius:     The corner radius to be set to segments and selectors.
     */
    private func setSampleSegments(segmentedControl: MaterialSegmentedControl, radius: CGFloat) {
        for i in 0..<3 {
            segmentedControl.appendSegment(text: "Segment \(i)", textColor: .gray, bgColor: .clear, cornerRadius: radius)
        }
    }
    
    @objc func topSegmentDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            reloadStackView(widgets)
        case 1:
            reloadStackView(buttons)
        default:
            break
        }
    }
    
    @objc func tapLoadingButton(sender: MaterialButton) {
        sender.isLoading = !sender.isLoading
        sender.isLoading ? sender.showLoader(userInteraction: true) : sender.hideLoader()
    }
    // AutoLayout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = self.view.frame.height
        let width = self.view.frame.width
        self.topSegmentControl.setConstraintsToView(top: self.view, tConst: 0.08*height, left: self.view, lConst: 0.05*width, right: self.view, rConst: -0.05*width)
        self.stackView.setConstraintsToView(left: self.view, lConst: 0.05*width, right: self.view, rConst: -0.05*width)
        self.topSegmentControl.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView!, attribute: .top, relatedBy: .equal, toItem: topSegmentControl, attribute: .bottom, multiplier: 1.0, constant: 0.03*height))
        self.view.layoutIfNeeded()
    }
}

enum WidgetType: String {
    case button = "Material Design Button"
    case loadingButton = "Loading Button"
    case shadowButton = "Shadow Button"
    case verticalButton = "Vertical Aligned Button"
    case textField = "Material Design TextField"
    case loadingIndicator = "Loading Indicator"
    case segmentedControlOutline = "Segmented Control - Outline"
    case segmentedControlLineText = "Segmented Control - Line Text"
    case segmentedControlFill = "Segmented Control - Fill"
    case segmentedControlLineIcon = "Segmented Control - Line Icon"
    
    var widget: UIView {
        if #available(iOS 13.0, *) {
            switch self {
            case .button:
                let btnLeft = MaterialButton(text: "Button", cornerRadius: 15.0, buttonStyle: .fill)
                let btnRight = MaterialButton(text: "Button", cornerRadius: 15.0, buttonStyle: .outline)
                let stack = UIStackView(arrangedSubviews: [btnLeft, btnRight], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .loadingButton:
                let btnLeft = MaterialButton(text: self.rawValue, cornerRadius: 15.0, buttonStyle: .fill)
                let btnRight = MaterialButton(text: self.rawValue, cornerRadius: 15.0, buttonStyle: .outline)
                let stack = UIStackView(arrangedSubviews: [btnLeft, btnRight], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .shadowButton:
                // We don't recommend outline style shadow button since in such case the shadow will become the background color of the button.
                // Feel free to tune one by yourself if you still need a outline shadow button.
                return MaterialButton(text: self.rawValue, cornerRadius: 15.0, withShadow: true, buttonStyle: .fill)
            case .verticalButton:
                let btn1 = MaterialVerticalButton(icon: #imageLiteral(resourceName: "ic_home_fill"), text: "Fill", cornerRadius: 18.0, buttonStyle: .fill)
                let btn2 = MaterialVerticalButton(icon: #imageLiteral(resourceName: "ic_home_color"), text: "Color", useOriginalImg: true, cornerRadius: 18.0, buttonStyle: .fill)
                let btn3 = MaterialVerticalButton(icon: #imageLiteral(resourceName: "ic_home_outline"), text: "Outline", cornerRadius: 18.0, buttonStyle: .outline)
                let stack = UIStackView(arrangedSubviews: [btn1, btn2, btn3], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .textField:
                return MaterialTextField(placeholder: "Material Design TextField", bottomBorderEnabled: true)
            case .loadingIndicator:
                let indicatorBlack = MaterialLoadingIndicator(radius: 15.0, color: .label)
                let indicatorGray = MaterialLoadingIndicator(radius: 15.0, color: .systemFill)
                indicatorBlack.startAnimating()
                indicatorGray.startAnimating()
                let stack = UIStackView(arrangedSubviews: [indicatorBlack, indicatorGray], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .segmentedControlFill:
                var segCtrl: MaterialSegmentedControl!
                segCtrl = MaterialSegmentedControl(selectorStyle: .fill)
                segCtrl.setCornerBorder(cornerRadius: 18.0)
                return segCtrl
            case .segmentedControlOutline:
                return MaterialSegmentedControl(selectorStyle: .outline)
            case .segmentedControlLineText:
                return MaterialSegmentedControl(selectorStyle: .line)
            case .segmentedControlLineIcon:
                return MaterialSegmentedControl(selectorStyle: .line)
            }
        } else {
            switch self {
            case .button:
                let btnLeft = MaterialButton(text: "Button", textColor: .white, bgColor: .black, cornerRadius: 15.0)
                let btnRight = MaterialButton(text: "Button", textColor: .black, bgColor: .white)
                btnRight.setCornerBorder(color: .black, cornerRadius: 15.0)
                let stack = UIStackView(arrangedSubviews: [btnLeft, btnRight], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .loadingButton:
                let btnLeft = MaterialButton(text: self.rawValue, textColor: .white, bgColor: .black, cornerRadius: 15.0)
                let btnRight = MaterialButton(text: self.rawValue, textColor: .black, bgColor: .white, cornerRadius: 15.0)
                btnRight.setCornerBorder(color: .black, cornerRadius: 15.0)
                let stack = UIStackView(arrangedSubviews: [btnLeft, btnRight], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .shadowButton:
                let btnLeft = MaterialButton(text: self.rawValue,  textColor: .white, bgColor: .black, cornerRadius: 15.0, withShadow: true)
                let btnRight = MaterialButton(text: self.rawValue, textColor: .black, bgColor: .white, withShadow: true)
                btnRight.setCornerBorder(color: .black, cornerRadius: 15.0)
                let stack = UIStackView(arrangedSubviews: [btnLeft, btnRight], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .verticalButton:
                let btn1 = MaterialVerticalButton(icon: #imageLiteral(resourceName: "ic_home_fill"), text: "Fill", foregroundColor: .black, bgColor: .white, cornerRadius: 18.0)
                let btn2 = MaterialVerticalButton(icon: #imageLiteral(resourceName: "ic_home_color"), text: "Color", foregroundColor: .black, bgColor: .white, useOriginalImg: true, cornerRadius: 18.0)
                let btn3 = MaterialVerticalButton(icon: #imageLiteral(resourceName: "ic_home_outline"), text: "Outline", foregroundColor: .white, bgColor: .black, cornerRadius: 18.0)
                let stack = UIStackView(arrangedSubviews: [btn1, btn2, btn3], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .textField:
                return MaterialTextField(placeholder: "Material Design TextField", textColor: .black, bgColor: .white, borderColor: .lightGray)
            case .loadingIndicator:
                let indicatorBlack = MaterialLoadingIndicator(radius: 15.0, color: .black)
                let indicatorGray = MaterialLoadingIndicator(radius: 15.0, color: .gray)
                indicatorBlack.startAnimating()
                indicatorGray.startAnimating()
                let stack = UIStackView(arrangedSubviews: [indicatorBlack, indicatorGray], axis: .horizontal, distribution: .fillEqually, spacing: 10.0)
                return stack
            case .segmentedControlFill:
                var segCtrl: MaterialSegmentedControl!
                segCtrl = MaterialSegmentedControl(selectorStyle: .fill, fgColor: .black, selectedFgColor: .white, selectorColor: .black, bgColor: .lightGray)
                segCtrl.setCornerBorder(cornerRadius: 18.0)
                return segCtrl
            case .segmentedControlOutline:
                return MaterialSegmentedControl(selectorStyle: .outline, fgColor: .black, selectedFgColor: .black, selectorColor: .black, bgColor: .white)
            case .segmentedControlLineText:
                return MaterialSegmentedControl(selectorStyle: .line, fgColor: .black, selectedFgColor: .black, selectorColor: .black, bgColor: .white)
            case .segmentedControlLineIcon:
                return MaterialSegmentedControl(selectorStyle: .line, fgColor: .black, selectedFgColor: .black, selectorColor: .gray, bgColor: .white)
            }
        }
    }
}

