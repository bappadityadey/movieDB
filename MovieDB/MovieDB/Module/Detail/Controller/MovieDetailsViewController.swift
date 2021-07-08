//
//  MovieDetailsViewController.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import UIKit
import Combine

class MovieDetailsViewController: UIViewController {

    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var poster: UIImageView!
    @IBOutlet private var header: UILabel!
    @IBOutlet private var subtitle: UILabel!
    @IBOutlet private var rating: UILabel!
    @IBOutlet private var overview: UILabel!

    var viewModel: MovieDetailsViewModelType?
    private var cancellables: [AnyCancellable] = []
    private let appear = PassthroughSubject<Void, Never>()
    private var isFavourited = false
    private var btnFavourite: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vm = viewModel {
            bind(to: vm)
        }
        isFavourited = viewModel?.isMovieExistsInFavourites() == true

        btnFavourite = UIBarButtonItem()
        btnFavourite?.target = self
        btnFavourite?.action = #selector(favouriteMovieAction)
        updateRighBarButton(isFavourite: isFavourited)
    }
    
    func updateRighBarButton(isFavourite : Bool){
        if isFavourite {
            btnFavourite?.image = UIImage(systemName: "star.fill")
        } else{
            btnFavourite?.image = UIImage(systemName: "star")
        }
        self.navigationItem.rightBarButtonItem = btnFavourite
    }
    
    @objc func favouriteMovieAction(){
        self.isFavourited = !self.isFavourited
        if viewModel?.isMovieExistsInFavourites() == true {
            viewModel?.removeFromFavourite()
        } else {
            viewModel?.addToFavourite()
        }
        updateRighBarButton(isFavourite: isFavourited)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear.send(())
    }

    private func bind(to viewModel: MovieDetailsViewModelType) {
        let input = MovieDetailsViewModelInput(appear: appear.eraseToAnyPublisher())
        var output: MovieDetailsViewModelOutput?
        if AppDelegate.appDelegateInstance?.isReachable == false {
            output = viewModel.offlineMovieDetails(input: input)
        } else {
            output = viewModel.transform(input: input)
        }
        output?.sink(receiveValue: {[unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
    }

    private func render(_ state: MovieDetailsState) {
        switch state {
        case .loading:
            self.contentView.isHidden = true
            self.loadingIndicator.isHidden = false
        case .failure:
            self.contentView.isHidden = true
            self.loadingIndicator.isHidden = true
        case .success(let movieDetails):
            self.contentView.isHidden = false
            self.loadingIndicator.isHidden = true
            show(movieDetails)
        }
    }

    private func show(_ movieDetails: MovieViewModel) {
        DispatchQueue.main.async {
            self.title = movieDetails.title
            self.header.text = movieDetails.title
            self.subtitle.text = movieDetails.subtitle
            self.rating.text = movieDetails.rating
            self.overview.text = movieDetails.overview
            movieDetails.poster
                .assign(to: \UIImageView.image, on: self.poster)
                .store(in: &self.cancellables)
        }
    }
}
