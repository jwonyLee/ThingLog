//
//  PhotosViewController.swift
//  ThingLog
//
//  Created by 이지원 on 2021/10/27.
//

import Photos
import UIKit

import RxCocoa
import RxSwift

/// 사진 목록을 보여주기 위한 뷰 컨트롤러
final class PhotosViewController: BaseViewController {
    // MARK: - View Properties
    private let collectionView: UICollectionView = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 2) / 3,
                                     height: (UIScreen.main.bounds.width - 2) / 3)
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let titleButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("사진첩 선택", for: .normal)
        button.setTitleColor(SwiftGenColors.black.color, for: .normal)
        button.titleLabel?.font = UIFont.Pretendard.button
        button.setImage(SwiftGenAssets.arrowDropDown.image, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()

    private let successButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(SwiftGenColors.black.color, for: .normal)
        button.setTitleColor(SwiftGenColors.gray4.color, for: .disabled)
        button.titleLabel?.font = UIFont.Pretendard.body1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()

    // MARK: - Properties
    let selectedMaxCount: Int = 10
    var coordinator: WriteCoordinator?
    var selectedIndexPath: [IndexPath] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateSelectedOrder()
                self?.updateSuccessButton()
            }
        }
    }
    var selectedImages: [UIImage] = []

    lazy var assets: PHFetchResult<PHAsset> = fetchAssets(assetCollection: nil) {
        didSet {
            collectionView.reloadData()
        }
    }

    private(set) var thumbnailSize: CGSize = CGSize()
    private(set) var albumsViewController: AlbumsViewController = AlbumsViewController()

    private var isShowAlbumsViewController: Bool = false {
        didSet {
            isShowAlbumsViewController ? titleButton.setImage(SwiftGenAssets.arrowDropUp.image, for: .normal) : titleButton.setImage(SwiftGenAssets.arrowDropDown.image, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = SwiftGenColors.white.color
        selectedIndexPath = []
        isShowAlbumsViewController = false

        PHPhotoLibrary.shared().register(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let scale: CGFloat = UIScreen.main.scale
        let cellSize: CGSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        albumsViewController.willMove(toParent: nil)
        albumsViewController.view.removeFromSuperview()
        albumsViewController.removeFromParent()

        NotificationCenter.default.removeObserver(self, name: .selectAlbum, object: nil)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func setupNavigationBar() {
        setupBaseNavigationBar()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: SwiftGenAssets.closeBig.image.withRenderingMode(.alwaysOriginal),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapBackButton))

        navigationItem.titleView = titleButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: successButton)
    }

    override func setupView() {
        setupCollectionView()
        setupAlbumsViewController()
    }

    override func setupBinding() {
        bindNavigationButton()
        bindNotification()
    }
}

// MARK: - setup
extension PhotosViewController {
    private func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        collectionView.register(ContentsCollectionViewCell.self, forCellWithReuseIdentifier: ContentsCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupAlbumsViewController() {
        addChild(albumsViewController)
        view.addSubview(albumsViewController.view)

        NSLayoutConstraint.activate([
            albumsViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            albumsViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            albumsViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            albumsViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        albumsViewController.didMove(toParent: self)
        albumsViewController.view.isHidden = true
    }

    private func bindNavigationButton() {
        successButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                NotificationCenter.default.post(name: .passSelectImages,
                                                object: nil,
                                                userInfo: [Notification.Name.passSelectImages: self.selectedImages])
                self.coordinator?.back()
            }.disposed(by: disposeBag)

        titleButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.isShowAlbumsViewController ? self.dismissAlbumsViewController() : self.showAlbumsViewController()
                self.isShowAlbumsViewController.toggle()
            }.disposed(by: disposeBag)
    }

    private func bindNotification() {
        NotificationCenter.default.rx.notification(.selectAlbum, object: nil)
            .map { notification -> PHAssetCollection? in
                notification.userInfo?[Notification.Name.selectAlbum] as? PHAssetCollection
            }
            .bind { [weak self] assetCollection in
                guard let self = self else { return }
                self.resetSelectedIndexPath()
                self.selectedImages = []

                self.assets = self.fetchAssets(assetCollection: assetCollection)
                self.titleButton.sendActions(for: .touchUpInside)
            }.disposed(by: disposeBag)
    }

    @objc
    private func didTapBackButton() {
        coordinator?.back()
    }
}

extension PhotosViewController {
    /// `selectedIndexPath`을 초기화한다.
    func resetSelectedIndexPath() {
        selectedIndexPath.forEach { indexPath in
            guard let cell: ContentsCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ContentsCollectionViewCell else {
                return
            }

            cell.updateCheckButton(string: "", backgroundColor: .clear)
            cell.layoutIfNeeded()
        }

        selectedIndexPath = []
    }

    /// `selectedIndexPath`에 데이터가 변경될 때 기존에 있는 항목의 checkButton 문자열을 업데이트한다.
    func updateSelectedOrder() {
        selectedIndexPath.enumerated().forEach { index, indexPath in
            guard let cell: ContentsCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ContentsCollectionViewCell else {
                return
            }
            cell.updateCheckButton(string: "\(index + 1)", backgroundColor: .black)
            cell.layoutIfNeeded()
        }
    }

    /// 사용자의 앨범으로부터 이미지를 가져온다.
    /// - Parameter assetCollection: 특정 앨범을 가져오고 싶은 경우 사용한다.
    /// - Returns: 모든 이미지를 반환한다. (assetCollection이 있는 경우, 해당 앨범의 모든 이미지를 반환한다.)
    private func fetchAssets(assetCollection: PHAssetCollection?) -> PHFetchResult<PHAsset> {
        let allPhotosOptions: PHFetchOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        guard let assetCollection = assetCollection else {
            return PHAsset.fetchAssets(with: allPhotosOptions)
        }

        return PHAsset.fetchAssets(in: assetCollection, options: nil)
    }

    /// 네비게이션 우측 상단에 있는 확인 버튼에 선택한 개수를 변경한다. 선택한 항목이 없으면 "확인"으로 변경한다.
    private func updateSuccessButton() {
        guard !selectedIndexPath.isEmpty else {
            successButton.setAttributedTitle(nil, for: .normal)
            successButton.setTitle("확인", for: .normal)
            successButton.isEnabled = false
            return
        }

        let count: String = "\(selectedIndexPath.count)"
        let nsString: NSString = NSString(string: "\(count) 확인")
        let range: NSRange = nsString.range(of: "\(count)")
        let newContents: String = nsString.substring(from: range.location)

        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: newContents)
        attributedString.addAttribute(.font,
                                   value: UIFont.Pretendard.title2,
                                   range: (newContents as NSString).range(of: count))
        attributedString.addAttribute(.font,
                                   value: UIFont.Pretendard.body1,
                                   range: (newContents as NSString).range(of: "확인"))
        attributedString.addAttribute(.foregroundColor,
                                   value: SwiftGenColors.black.color,
                                   range: (newContents as NSString).range(of: count))
        attributedString.addAttribute(.foregroundColor,
                                   value: SwiftGenColors.black.color,
                                   range: (newContents as NSString).range(of: "확인"))
        successButton.setAttributedTitle(attributedString, for: .normal)
        successButton.sizeToFit()
        successButton.isEnabled = true
    }

    /// selectedMaxCount < selectedIndexPath.count 인 경우 사용자에게 Alert을 띄운다.
    func showMaxSelectedAlert() {
        let alert: AlertViewController = AlertViewController()
        alert.modalPresentationStyle = .overFullScreen

        alert.changeContentsText("이미지는 최대 10개까지 첨부할 수 있어요")
        alert.leftButton.setTitle("확인", for: .normal)

        alert.hideTitleLabel()
        alert.hideRightButton()
        alert.hideTextField()

        alert.leftButton.rx.tap.bind {
            alert.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)

        present(alert, animated: false, completion: nil)
    }
}

extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let change = changeInstance.changeDetails(for: assets) else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.assets = change.fetchResultAfterChanges
            self?.collectionView.reloadData()
        }
    }
}
