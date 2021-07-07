//
//  HelpMenuViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/18/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `HelpMenuViewControllerDelegate` protocol defines methods that allow you to handle table item selection actions.

 - note: Component API only.
 */

public protocol HelpMenuViewControllerDelegate: AnyObject {
    func help(_ menuViewController: HelpMenuViewController, didSelect item: HelpMenuViewController.MenuItem)
}

/**
 The `HelpMenuViewController` provides explanations on how to take better pictures, how to
 use the _Open with_ feature and which formats are supported by the Gini Capture SDK.
 */

public final class HelpMenuViewController: UITableViewController {
    public weak var delegate: HelpMenuViewControllerDelegate?
    let giniConfiguration: GiniConfiguration
    let tableRowHeight: CGFloat = 64
    var helpMenuCellIdentifier = "helpMenuCellIdentifier"

    public enum ItemPresentationMode {
        case noResultsTips
        case helpItem
    }

    /**
     The `MenuItem` class represents a menu item with its detail view
     
     - Parameters:
        - title: A title for the help menu item. We recommend to define it as a localized string if you support multiple languages
        - viewController: A custom view controller which represents a detail view for help menu item
        - presentationMode: An optional parameter, will be set as `.helpItem` as a default, responsible for navigation bank from the detailed view of the  help menu item
     
     */
    @objc public class MenuItem: NSObject {
        public var title: String
        public var viewController: UIViewController
        public var presentationMode: ItemPresentationMode?
        
        public init (title: String, viewController: UIViewController, presentationMode: ItemPresentationMode? = .helpItem) {
            self.title = title
            self.viewController = viewController
            self.presentationMode = presentationMode
        }
    }
    
    lazy var menuItems: [MenuItem] = []

    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }

    fileprivate func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: helpMenuCellIdentifier)
        tableView.rowHeight = tableRowHeight
        
        tableView.backgroundColor = UIColor.from(giniColor: giniConfiguration.helpScreenBackgroundColor)
        
        // In iOS it is .automatic by default, having an initial animation when the view is loaded.
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    fileprivate func configureMainView() {
        title = .localized(resource: HelpStrings.menuTitle)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureMenuItems()
        configureMainView()
        configureTableView()
    }

    func configureMenuItems() {
        let title: String = .localized(resource: ImageAnalysisNoResultsStrings.titleText)
        let topViewText: String = .localized(resource: ImageAnalysisNoResultsStrings.warningHelpMenuText)
        let viewController = ImageAnalysisNoResultsViewController(title: title,
                                                                  subHeaderText: nil,
                                                                  topViewText: topViewText,
                                                                  topViewIcon: nil)
        let noResultsItemTitle: String = .localized(resource: HelpStrings.menuFirstItemText)
        let noResultsItem = MenuItem(title: noResultsItemTitle, viewController: viewController, presentationMode: ItemPresentationMode.noResultsTips)
        menuItems.append(noResultsItem)

        if giniConfiguration.shouldShowSupportedFormatsScreen {
            let supportedFormatsItem = MenuItem(title: .localized(resource: HelpStrings.menuThirdItemText), viewController: SupportedFormatsViewController())
            menuItems.append(supportedFormatsItem)
        }

        if giniConfiguration.openWithEnabled {
            let openWithItem = MenuItem(title: .localized(resource: HelpStrings.menuSecondItemText), viewController: OpenWithTutorialViewController())
            menuItems.append(openWithItem)
        }
        
        if giniConfiguration.hasCustomMenuItems {
            menuItems.append(contentsOf: giniConfiguration.customMenuItems)
        }
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HelpMenuViewController {
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: helpMenuCellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.from(giniColor: giniConfiguration.helpScreenCellsBackgroundColor)
        cell.textLabel?.text = menuItems[indexPath.row].title
        cell.textLabel?.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menuItems[indexPath.row]

        guard delegate == nil else {
            delegate?.help(self, didSelect: item)
            return
        }
    }
}
