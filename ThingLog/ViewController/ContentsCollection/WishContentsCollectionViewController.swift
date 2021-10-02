//
//  WishViewController.swift
//  ThingLog
//
//  Created by hyunsu on 2021/09/21.
//

import UIKit

class WishContentsCollectionViewController: BaseContentsCollectionViewController {
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        originScrollContentsHeight = collectionView.contentSize.height
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        8
    }
}