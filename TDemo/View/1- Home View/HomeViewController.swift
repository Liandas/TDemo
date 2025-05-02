//
//  HomeViewController.swift
//  TDemo
//
//  Created by Arda Doğantemur on 30.04.2025.
//

import Foundation
import UIKit

class HomeViewController:UIViewController, UICollectionViewDataSource , UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout
{

    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    var viewModel: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.log("Home")
        
        viewModel.onProductsUpdated = { [weak self] products, source in
            Logger.shared.log(self?.viewModel.products)
            self?.productsCollectionView.reloadData()
        }
        
        viewModel.onError = { error, source in
            switch error {
            default:
                TopBannerAlert(message: error.userMessage).show(in: self.view)
            }
        }
        
        viewModel.getProducts()
    }
    
    // MARK: - Collection View Delegate Datasource
    // ===============================================================================
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
        let product = viewModel.products[indexPath.row]
        cell.productNameLabel.text = product.name
        cell.productPriceLabel.text = "\(product.price ?? 0)"
        cell.productCellImage.setImage(for: product, useThumbnail: true, placeholder: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 200)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if FeatureGatekeeper.shared.isProductDetailEnabled
        {
            let product = viewModel.products[indexPath.row]
            
            let repository = ProductRepositoryImp(network: NetworkImp(urlSession: .shared), persistence: PersistenceCoreDataImp.shared)
            let detailViewModel = DetailViewModel(repository: repository, product: product)
            let viewController = DetailViewController.instantiate(with: detailViewModel)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension HomeViewController {
    static func instantiate(with viewModel: HomeViewModel) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.viewModel = viewModel
        return vc
    }
}
