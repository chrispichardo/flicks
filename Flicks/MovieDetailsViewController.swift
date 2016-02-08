//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by christian pichardo on 2/7/16.
//  Copyright © 2016 christian pichardo. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movieID : Int = 0
    var movie : NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMovie()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*Function to Load the movies*/
    func loadMovie(){
        let api_key = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(self.movieID)?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                if let _ = errorOrNil {
                    self.networkErrorView.hidden = false;
                }
                else {
                    if let data = dataOrNil {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                            
                            //hide the network error view
                            self.networkErrorView.hidden = true
                            
                            // Hide HUD once the network request comes back 
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            self.movie = responseDictionary
                            //title
                            let releaseDate = self.movie!["release_date"] as? String
                            let year = releaseDate!.componentsSeparatedByString("-")[0]
                            let title = self.movie!["title"] as? String
                            self.titleLabel.text = "\(title!) (\(year))"
                            //overview
                            self.overviewLabel.text = self.movie!["overview"] as? String
                            self.overviewLabel.sizeToFit()
                            //poster
                            if let posterPath = self.movie!["poster_path"] as? String {
                                let baseURL = "https://image.tmdb.org/t/p/w342"
                                let imageURL = NSURL(string: baseURL+posterPath)
                                self.posterImageView.setImageWithURL(imageURL!)
                            }else{
                                self.posterImageView.image = nil
                            }
                            //genres
                            if let genres = self.movie!["genres"] as? [NSDictionary]{
                                var genresArray = [String]()
                                for genre in genres{
                                    genresArray.append(genre["name"] as! String);
                                    
                                }
                                
                                self.genresLabel.text = genresArray.joinWithSeparator(", ")
                            }
                            //duration
                            let runtime = self.movie!["runtime"] as? Int
                            let hours = runtime! / 60
                            let minutes = runtime! % 60
                            self.durationLabel.text = "\(hours) hr \(minutes) mins"
                            
                            //ratings
                            let voteAverage = self.movie!["vote_average"] as? Float
                            let voteCount = self.movie!["vote_count"] as? Int
                            self.ratingsLabel.text = "\(voteAverage!) (\(voteCount!))"
                            
                            //Popularity
                            let popularity = self.movie!["popularity"] as? Float
                            self.popularityLabel.text = "\(String(format: "%.2f", popularity!))%"

                        }
                    }
                }
        });
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
