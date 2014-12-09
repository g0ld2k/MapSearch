//
//  ViewController.swift
//  MapSearch
//
//  Created by Chris Golding on 12/5/14.
//  Copyright (c) 2014 vbgov. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, AGSQueryTaskDelegate, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate  {
    
    @IBOutlet weak var mapView: AGSMapView!
    
    let sketchLayer = AGSSketchGraphicsLayer()
    let graphicsLayer = AGSGraphicsLayer()
    var queryTask = AGSQueryTask()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        NSURLConnection.ags_trustedHosts().addObject("gismapstest.vbgov.com")

        mapView.touchDelegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "zoomDidChange:", name: "MapDidEndZooming", object: nil)
        
        
        loadTheMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadTheMap() {
            
        //Add a basemap tiled layer
        let url = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer")
        let basemap = AGSTiledMapServiceLayer(URL: url)
        
        let sketchPolygon = AGSMutablePolygon(spatialReference: self.mapView.spatialReference)
        sketchLayer.geometry = sketchPolygon
        
        mapView.addMapLayer(basemap, withName: "Basemap Tiled Layer")
        mapView.addMapLayer(graphicsLayer, withName: "Graphics Layer")
        mapView.addMapLayer(sketchLayer, withName: "Sketch Layer")
    
        self.mapView.touchDelegate = sketchLayer
        
        let envelope = AGSEnvelope(xmin: -8556639.905363766, ymin: 4400568.202483529, xmax: -8374566.763536232, ymax: 4452239.673463972, spatialReference: AGSSpatialReference.webMercatorSpatialReference())
        
        self.mapView.zoomToEnvelope(envelope, animated: false)
    }
    
    func mapViewDidLoad(mapView: AGSMapView!) {
        // register for "MapDidEndZooming" notifications
        
    }

    @IBAction func searchBtnPressed(sender: AnyObject) {
        graphicsLayer.removeAllGraphics()
        
        queryTask = AGSQueryTask(URL: NSURL(string: "https://gismapstest.vbgov.com/arcgis/rest/services/Basemaps/PropertyInformation_VBgov/MapServer/3"))
        let query = AGSQuery()
        query.returnGeometry = true
        query.outFields = ["MASTER_GPIN", "PROP_ADDRESS"]
        
        query.geometry = sketchLayer.geometry
        println(query.geometry.envelope.xmax)
        query.spatialRelationship = AGSSpatialRelationship.Contains
        
        queryTask.delegate = self
        
        queryTask.executeWithQuery(query)

    }
    
    @IBAction func clearGeometryButtonPressed(sender: AnyObject) {
//        sketchLayer.removeAllGraphics()
        let sketchPolygon = AGSMutablePolygon(spatialReference: self.mapView.spatialReference)
        sketchLayer.geometry = sketchPolygon
        
        graphicsLayer.removeAllGraphics()
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {

        println("Num of features: \(featureSet.features.count)")

        sketchLayer.removeAllGraphics()
        
        for f in featureSet.features as [AGSFeature] {
            var graphic = AGSGraphic(feature: f)
            var pt = f.geometry as AGSPoint
            let marker = AGSSimpleMarkerSymbol(color: UIColor.blueColor())
            
            graphic.symbol = marker
            graphicsLayer.addGraphic(graphic)
        }
        
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        println(error)
    }
    
    func zoomDidChange(notification: NSNotification) {
        println(mapView.contentScaleFactor);
    }
    
}

