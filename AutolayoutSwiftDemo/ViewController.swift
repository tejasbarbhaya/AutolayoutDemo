//
//  ViewController.swift
//  AutolayoutSwiftDemo
//
//  Created by Tejash on 04/07/19.
//  Copyright © 2019 Topnotch. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tblView: UITableView!
    let imageCache = NSCache<NSString, UIImage>()
    
    
    
    
    var objLeagueModel : LeagueModel?
    
    //MARK: Class Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        
        // make Network call to get data
        //self.makeNetworkCall()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.objLeagueModel?.arrayLeagues.count {
            return count;
        }else {
            return 0;
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeagueCellId", for: indexPath) as! LeagueCell
        
        let leagueObj = self.objLeagueModel?.arrayLeagues[indexPath.row]
        
        cell.tag = indexPath.row
        
        if cell.tag == indexPath.row {
            cell.leagueModel = leagueObj
            cell.indePath = indexPath
        }
        
        
        
        
        //cell.imgLogo.image = UIImage.init(named: "iconPlaceholder")
        
        if let cachedImage = self.imageCache.object(forKey: (leagueObj?.logo)! as NSString) {
            if cell.tag == indexPath.row {
                cell.imgLogo.image = cachedImage
            }
        }
        else {
            Alamofire.request((leagueObj?.logo)!).responseImage { response in
                if let image = response.result.value {
                    if cell.tag == indexPath.row {
                        cell.imgLogo.image = image
                        self.imageCache.setObject(image, forKey: (leagueObj?.logo)! as NSString)
                    }
                }
//                else {
//                    cell.imgLogo.image = UIImage.init(named: "iconPlaceholder")
//                }
            }
        }
        
        
        
        return cell;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Network call
    
    func makeNetworkCall() {
        
        NetworkController.api.showProgressView(forView: self.view)
        NetworkController.api.getLeagues(url:"leagues", complition: { response, error in
            if error != nil {
                print(error?.description)
                DispatchQueue.main.async {
                    NetworkController.api.hideProgressView()
                    self.tblView.isHidden = true
                }
            }else {
                self.objLeagueModel = response as? LeagueModel
                
                DispatchQueue.main.async {
                    self.tblView.isHidden = false
                    NetworkController.api.hideProgressView()
                    self.tblView.reloadData()
                }
            }
        })
    }
}

// MARK: ScanListCell Class Defination

class LeagueCell : UITableViewCell {
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblEnddate: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblLeagueName: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    
    var imageCache = NSCache<NSString,UIImage>()
    var indePath : IndexPath!
    
    var leagueModel : League! {
        didSet {
            self.lblLeagueName.text = leagueModel.name + " tag : \(self.tag)"
        }
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
}

