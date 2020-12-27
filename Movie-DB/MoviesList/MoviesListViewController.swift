//
//  MoviesListViewController.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class MoviesListViewController: UIViewController {
    
    @IBOutlet weak var offlineView: UILabel!
    @IBOutlet weak var offlineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    var noDataLabel: UILabel? = nil

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "popularity", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
    
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        // Setting fetchedResultsControllerDelegate to update the tableview on database change
        fetchedResultsController.delegate = self
            
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }()
    
    private var viewModel: MoviesViewModel = MoviesViewModel()

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadMoviesIfNeeded()
    }
    
    func setupUI() {
        tableView.backgroundColor = UIColor.systemGray6
        tableView.separatorStyle = .none
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController

        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        // Auto layout
        let horizontalConstraint = activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let verticalConstraint = activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
        
        hideOfflineView()
    }
    
    @objc func refresh() {
        viewModel.getMovies()
    }
    
}

private extension MoviesListViewController {
    
    func setUpObservers() {
        
        viewModel
            .isRefreshing
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
        viewModel
            .isLoading
            .bind(to: self.activityIndicatorView.rx.isAnimating)
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
            .error
            .subscribe( onNext: { element in
                print(element as Any)
            })
            .disposed(by: self.disposeBag)
        
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

        self.tableView.isHidden = true
        
        let noDataLabel = UILabel()
        noDataLabel.text = "Unable to retrive movie list"
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
        self.tableView.isHidden = false

        noDataLabel?.removeFromSuperview()
        noDataLabel = nil
    }
}

extension MoviesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }

        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieCell else { fatalError("provide a valid identifier")}

        let movie = fetchedResultsController.object(at: indexPath)
        cell.set(movie: movie)

        return cell
    }

}

extension MoviesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MovieCell, let movieId = cell.movie?.id else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "MovieDetailsViewController") as? MovieDetailsViewController else { return }
        
        controller.viewModel = MovieDetailsViewModel(movieId: movieId)
        
        self.navigationController?.pushViewController(controller, animated: true);
    }

}

extension MoviesListViewController:  NSFetchedResultsControllerDelegate {    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
