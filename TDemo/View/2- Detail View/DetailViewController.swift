//
//  DetailViewController.swift
//  TDemo
//
//  Created by Arda Doğantemur on 30.04.2025.
//

import Foundation
import UIKit

class DetailViewController:UIViewController
{
    var viewModel: DetailViewModel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onProductUpdated = { [weak self] product, source in
            Logger.shared.log(self?.viewModel.product)
            self?.loadProduct()
        }
        
        viewModel.onError = { error, source in
            switch error {
            default:
                TopBannerAlert(message: error.userMessage).show(in: self.view)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        viewModel.getProduct()
    }
    
    func loadProduct()
    {
        productImage.setImage(for: viewModel.product,useThumbnail: false, placeholder: nil)
        productTitle.text = viewModel.product.name
        productDescription.text = viewModel.product.detail

    }
}

extension DetailViewController
{
    static func instantiate(with viewModel: DetailViewModel) -> DetailViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.viewModel = viewModel
        return vc
    }
}
