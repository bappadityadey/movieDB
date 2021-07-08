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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vm = viewModel {
            bind(to: vm)
        }
        
        let favButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(favouriteMovieAction))
        self.navigationItem.rightBarButtonItem = favButton
    }
    
    @objc func favouriteMovieAction(){
         print("clicked")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear.send(())
    }

    private func bind(to viewModel: MovieDetailsViewModelType) {
        let input = MovieDetailsViewModelInput(appear: appear.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)

        output.sink(receiveValue: {[unowned self] state in
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
        title = movieDetails.title
        header.text = movieDetails.title
        subtitle.text = movieDetails.subtitle
        rating.text = movieDetails.rating
        overview.text = movieDetails.overview
        movieDetails.poster
            .assign(to: \UIImageView.image, on: self.poster)
            .store(in: &cancellables)
    }
}
