//
//  MovieDetailsViewController.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import UIKit
import CoreData
import Kingfisher
import RxSwift
import RxCocoa

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var offlineView: UILabel!
    @IBOutlet weak var offlineViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewValueLabel: UILabel!

    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    var noDataLabel: UILabel? = nil

    var viewModel: MovieDetailsViewModel!

    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setUpObservers()
    }
    
    func setupUI() {
        title = "Movie Details"

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        // Auto layout
        let horizontalConstraint = activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let verticalConstraint = activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
        
        hideOfflineView()
    }
}

extension MovieDetailsViewController {
    func setUpObservers() {
        
        viewModel
            .isLoading
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        viewModel
            .showDetailsView
            .bind(to: self.scrollView.rx.isHidden)
            .disposed(by: self.disposeBag)

        viewModel
            .showOfflineView
            .subscribe(onNext: { [weak self] element in
                if element {
                    self?.showOfflineView()
                } else {
                    self?.hideOfflineView()
                }
            })
            .disposed(by: self.disposeBag)
        
        viewModel
            .showNoDataLabel
            .subscribe( onNext: { [weak self] element in
                if element {
                    self?.showNoDataLabel()
                } else {
                    self?.removeNoDataLabel()
                }
            })
            .disposed(by: self.disposeBag)
        
        viewModel
            .movieDetails
            .subscribe( onNext: { [weak self] element in
                guard let movieDetails = element else { return }
                self?.configureView(details: movieDetails)
            })
            .disposed(by: self.disposeBag)
        
        viewModel
            .error
            .subscribe( onNext: { element in
                print(element as Any)
            })
        .disposed(by: self.disposeBag)
        
    }
    
    func configureView(details: MovieDetails) {
        let url = URL(string: "\(Constants.Image.baseUrl)\(details.posterPath ?? "")")
        let processor = DownsamplingImageProcessor(size: movieImageView.bounds.size)
        movieImageView.kf.indicatorType = .activity
        movieImageView.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        titleLabel.text = details.title
        overviewValueLabel.text = details.overview
    }
    
    func showOfflineView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.offlineViewTopConstraint.constant = 0
        }
    }
    
    func hideOfflineView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let height = self?.offlineView.frame.size.height else { return }
            self?.offlineViewTopConstraint.constant = -height
        }
    }
    
    func showNoDataLabel() {
        self.removeNoDataLabel()

        let noDataLabel = UILabel()
        noDataLabel.text = "Unable to retrive movie details"
        noDataLabel.textAlignment = .center
        
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        // Auto layout
        let leadingConstraint = noDataLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8)
        let trailingConstraint = self.view.trailingAnchor.constraint(equalTo: noDataLabel.trailingAnchor, constant: 8)

        let noDataLabelVerticalConstraint = noDataLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, noDataLabelVerticalConstraint])
        
        self.noDataLabel = noDataLabel
    }
    
    func removeNoDataLabel() {
        noDataLabel?.removeFromSuperview()
        noDataLabel = nil
    }
}
