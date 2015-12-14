//
//  bookingViewController.swift
//  Courter
//
//  Created by Xinyu Chen on 11/29/15.
//  Copyright © 2015 Xinyu Chen. All rights reserved.
//

import UIKit
import MapKit

class bookingViewController: UIViewController, UITableViewDataSource, MKMapViewDelegate {
    
    var hours0:NSString?
    var hoursArray0:NSArray?
    var hours1:NSString?
    var hoursArray1:NSArray?
    var isSerf = true
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSerf{
            return hoursArray0!.count/4}
        else { return hoursArray1!.count/4}
        //return 5
    }
    
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "   Time             Court 1           Court 2          Court 3"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:bookingTableViewCell = tableView.dequeueReusableCellWithIdentifier("cCell") as! bookingTableViewCell
        cell.time.numberOfLines = 2
        cell.time.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.court1.numberOfLines = 2
        cell.court1.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.court2.numberOfLines = 2
        cell.court2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.court3.numberOfLines = 2
        cell.court3.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        
        
        if isSerf{
            cell.time.text = hoursArray0![4*indexPath.row] as! String
            cell.court1.text = hoursArray0![4*indexPath.row+1] as! String
            cell.court2.text = hoursArray0![4*indexPath.row+2] as! String
            cell.court3.text = hoursArray0![4*indexPath.row+3] as! String
            if(cell.court1.text == "Available"){
                cell.court1.textColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
            }else{
                cell.court1.textColor = UIColor.blackColor()
            }
            if(cell.court2.text == "Available"){
                cell.court2.textColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
            }else{
                cell.court2.textColor = UIColor.blackColor()
            }
            if(cell.court3.text == "Available"){
                cell.court3.textColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
            }else{
                cell.court3.textColor = UIColor.blackColor()
            }
        }
        else{
            cell.time.text = hoursArray1![4*indexPath.row] as! String
            cell.court1.text = hoursArray1![4*indexPath.row+1] as! String
            cell.court2.text = hoursArray1![4*indexPath.row+2] as! String
            cell.court3.text = hoursArray1![4*indexPath.row+3] as! String
            if(cell.court1.text == "Available"){
                cell.court1.textColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
            }else{
                cell.court1.textColor = UIColor.blackColor()
            }
            if(cell.court2.text == "Available"){
                cell.court2.textColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
            }else{
                cell.court2.textColor = UIColor.blackColor()
            }
            if(cell.court3.text == "Available"){
                cell.court3.textColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
            }else{
                cell.court3.textColor = UIColor.blackColor()
            }
        }
        
        return cell
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!{
        if annotation is MKPointAnnotation {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
            annotationView.canShowCallout = true
            
            return annotationView
            
        }
        
        
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if ((view.annotation?.title)! == "SERF"){
            isSerf = true
        }
        if ((view.annotation?.title)! == "Natatorium"){
            isSerf = false
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
        
        var nib = UINib(nibName: "bookingUITableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cCell")
        
        hours0 = try? NSString(string: "6am\n7am,Available,Ting\n2222,Ting\n2222,7am\n8am,Ting\n2222,John\n3333,Cherng\n1111,8am\n9am,Braun\n5555,Available,Cherng\n1111,9am\n10am,Cherng\n1111,Braun\n5555,Available,10am\n11am,Cherng\n1111,Braun\n5555,Cherng\n1111,11am\n12pm,Available,Available,Cherng\n1111,12pm\n1pm,Available,Available,Cherng\n1111,1pm\n2pm,Available,Available,Cherng\n1111,2pm\n3pm,John\n3333,Available,Cherng\n1111,3pm\n4pm,John\n3333,Available,Cherng\n1111,4pm\n5pm,John\n3333,Available,Cherng\n1111,5pm\n6pm,John\n3333,Ting\n2222,Cherng\n1111,6pm\n7pm,John\n3333,Ting\n2222,Cherng\n1111,7pm\n8pm,Ting\n2222,Ting\n2222,Cherng\n1111,8pm\n9pm,Ting\n2222,Ting\n2222,Cherng\n1111,9pm\n10pm,Ting\n2222,Braun\n5555,John\n3333,10pm\n11pm,Ting\n2222,Braun\n5555,John\n3333,11pm\n12am,Ting\n2222,Braun\n5555,John\n3333")
        hoursArray0 = hours0?.componentsSeparatedByString(",")
        
        hours1 = try? NSString(string: "6am\n7am,Available,Available,Ting\n2222,7am\n8am,Ting\n2222,John\n3333,Chen\n1111,8am\n9am,Bob\n5555,Available,Chen\n1111,9am\n10am,Available,Bob\n5555,Available,10am\n11am,Chen\n1111,Bob\n5555,Chen\n1111,11am\n12pm,Available,Available,Chen\n1111,12pm\n1pm,Available,Available,Chen\n1111,1pm\n2pm,Available,Available,Chen\n1111,2pm\n3pm,John\n3333,Available,Chen\n1111,3pm\n4pm,John\n3333,Available,Chen\n1111,4pm\n5pm,John\n3333,Available,Chen\n1111,5pm\n6pm,John\n3333,Ting\n2222,Chen\n1111,6pm\n7pm,John\n3333,Ting\n2222,Chen\n1111,7pm\n8pm,Ting\n2222,Ting\n2222,Chen\n1111,8pm\n9pm,Ting\n2222,Ting\n2222,Chen\n1111,9pm\n10pm,Ting\n2222,Bob\n5555,John\n3333,10pm\n11pm,Ting\n2222,Bob\n5555,John\n3333,11pm\n12am,Ting\n2222,Bob\n5555,John\n3333")
        hoursArray1 = hours1?.componentsSeparatedByString(",")

        
        let initialLocation = CLLocation(latitude: 43.071746, longitude: -89.409921)
        centerMapOnLocation(initialLocation)
        
        let serf = MKPointAnnotation()
        serf.title = "SERF"
        serf.coordinate = CLLocationCoordinate2D(latitude: 43.070613, longitude: -89.398167)
        mapView.addAnnotation(serf)
        
        let nat = MKPointAnnotation()
        nat.title = "Natatorium"
        nat.coordinate = CLLocationCoordinate2D(latitude: 43.077642, longitude: -89.419796)
        mapView.addAnnotation(nat)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
