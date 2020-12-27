//
//  MovieCell.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import UIKit
import Kingfisher

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var parentContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    weak var movie: Movie?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        self.containerView.layer.cornerRadius = 15
        self.containerView.layer.masksToBounds = true
        
        self.parentContainerView.backgroundColor = .clear
        self.parentContainerView.layer.shadowColor = UIColor.black.cgColor
        self.parentContainerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.parentContainerView.layer.shadowOpacity = 0.2
        self.parentContainerView.layer.shadowRadius = 4 
    }
    
    override func prepareForReuse() {
        movieImageView.image = nil
        titleLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(movie: Movie) {
        self.movie = movie

        // TODO: Should have the image loader code into a seperate UIImageView Extension
        let url = URL(string: "\(Constants.Image.baseUrl)\(movie.posterPath ?? "")")
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
        
        titleLabel.text = movie.title
    }

}
