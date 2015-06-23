//
//  GraphViewController.swift
//  Calculator
//
//  Created by Brian Jewkes on 6/23/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

@IBDesignable
class GraphViewController: UIViewController, GraphViewDataSource {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
        }
    }
}
