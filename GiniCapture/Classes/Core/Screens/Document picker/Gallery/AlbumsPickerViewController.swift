//
//  AlbumsPickerViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation
import PhotosUI

protocol AlbumsPickerViewControllerDelegate: AnyObject {
    func albumsPicker(_ viewController: AlbumsPickerViewController,
                      didSelectAlbum album: Album)
}

final class AlbumsPickerViewController: UIViewController, PHPhotoLibraryChangeObserver {
    
    weak var delegate: AlbumsPickerViewControllerDelegate?
    fileprivate let galleryManager: GalleryManagerProtocol
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate let library = PHPhotoLibrary.shared()
    fileprivate let headerHeight: CGFloat = 50.0
    fileprivate let footerHeight: CGFloat = 50.0
    fileprivate let headerIdentifier = "AlbumsHeaderView"

    // MARK: - Views

    lazy var albumsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = Colors.Gini.dynamicPearl
        } else {
            tableView.backgroundColor = Colors.Gini.pearl
        }
        tableView.register(AlbumsPickerTableViewCell.self,
                           forCellReuseIdentifier: AlbumsPickerTableViewCell.identifier)
        return tableView
    }()

    // MARK: - Initializers

    init(galleryManager: GalleryManagerProtocol,
         giniConfiguration: GiniConfiguration = GiniConfiguration.shared) {
        self.galleryManager = galleryManager
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func loadView() {
        super.loadView()
        title = .localized(resource: GalleryStrings.albumsTitle)
        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(albumsTableView)
        Constraints.pin(view: albumsTableView, toSuperView: view)
    }
    
    func reloadAlbums() {
        albumsTableView.reloadData()
    }
    
   func showLimitedLibraryPicker() {
        if #available(iOS 14.0, *) {
            library.presentLimitedLibraryPicker(from: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        library.register(self)
        let nib = UINib(nibName: headerIdentifier, bundle: Bundle(for: GiniCapture.self))
        albumsTableView.register(nib, forHeaderFooterViewReuseIdentifier: headerIdentifier)
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.galleryManager.reloadAlbums()
            self.reloadAlbums()
        }
    }
    
    deinit {
        library.unregisterChangeObserver(self)
    }

}

// MARK: UITableViewDataSource

extension AlbumsPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleryManager.albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            AlbumsPickerTableViewCell.identifier) as? AlbumsPickerTableViewCell
        let album = galleryManager.albums[indexPath.row]
        cell?.setUp(with: album,
                    giniConfiguration: giniConfiguration,
                    galleryManager: galleryManager)
        return cell!
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if #available(iOS 14.0, *) {
            if galleryManager.isGalleryAccessLimited && section == 0 {
                let headerView = self.albumsTableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! AlbumsHeaderView
                headerView.didTapSelectButton = {
                    self.showLimitedLibraryPicker()
                }
                return headerView
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 14.0, *) {
            return galleryManager.isGalleryAccessLimited && section == 0 ? headerHeight : 0.0
        } else {
            return 0.0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if #available(iOS 14.0, *) {
            return galleryManager.isGalleryAccessLimited && section == 0 ? footerHeight : 0.0
        } else {
            return 0.0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if #available(iOS 14.0, *) {
            if galleryManager.isGalleryAccessLimited && section == 0 {
                let label = UILabel()
                let footerWidth = albumsTableView.frame.size.width - 20.0
                label.frame =  CGRect(x: 10, y: 0, width: footerWidth, height: footerHeight)
                label.numberOfLines = 0
                label.text = NSLocalizedStringPreferredFormat("ginicapture.albums.footer",
                                                              comment: "Albums footer message")
                label.font = giniConfiguration.customFont.with(weight: .regular, size: 12, style: .footnote)
                label.textColor = UIColor.label
                label.textAlignment = NSTextAlignment.center
                label.lineBreakMode = NSLineBreakMode.byWordWrapping
                label.backgroundColor = UIColor.clear
                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: albumsTableView.frame.size.width, height: footerHeight))
                footerView.addSubview(label)
                return footerView
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

// MARK: UITableViewDelegate

extension AlbumsPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.albumsPicker(self, didSelectAlbum: galleryManager.albums[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AlbumsPickerTableViewCell.height
    }
}

class AlbumsHeaderView: UITableViewHeaderFooterView {
    var didTapSelectButton: (() -> Void) = {}
    @IBOutlet weak var selectPhotosButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }

    fileprivate func configureView() {
        let configuration = GiniConfiguration.shared
        let buttonTitle = NSLocalizedStringPreferredFormat("ginicapture.albums.selectMorePhotosButton",
                                                           comment: "Title for select more photos button")
        selectPhotosButton.setTitle(buttonTitle, for: .normal)
        selectPhotosButton.setTitleColor(configuration.navigationBarTintColor, for: .normal)
        selectPhotosButton.sizeToFit()
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func selectMorePhotosTapped(_ sender: Any) {
        didTapSelectButton()
    }
}
