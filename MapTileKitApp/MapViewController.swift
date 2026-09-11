//
//  MapViewController.swift
//  MapTileKitApp
//
//  Builds its view in code rather than loading a XIB, and is the app's only
//  screen.
//

import UIKit
import MapKit
import MapTileKit

final class MapViewController: UIViewController, MKMapViewDelegate {

    private var mapView: MKMapView!
    private var tileOverlay: TileOverlay?
    private var hasSetInitialRegion = false

    override func loadView() {
        mapView = MKMapView(frame: UIScreen.main.bounds)
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        guard let mbtilesURL = Bundle.main.url(forResource: "countries", withExtension: "mbtiles") else {
            NSLog("countries.mbtiles not found in the app bundle")
            return
        }

        let tileOverlay = TileOverlay(mbtilesURL: mbtilesURL)
        self.tileOverlay?.fillsMissingTilesWithBackground = false
        self.tileOverlay = tileOverlay
        mapView.addOverlay(tileOverlay)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // MapKit runs its own "fly in" intro camera animation the first
        // time a map view actually appears on screen, which overrides any
        // visibleMapRect set earlier in viewDidLoad (before the view was on
        // screen) - setting it here, after that intro has a view to act on,
        // is what actually sticks.
        guard !hasSetInitialRegion, let tileOverlay else { return }
        hasSetInitialRegion = true

        var visibleRect = mapView.mapRectThatFits(tileOverlay.boundingMapRect)
        visibleRect.size.width /= 2
        visibleRect.size.height /= 2
        visibleRect.origin.x += visibleRect.size.width / 2
        visibleRect.origin.y += visibleRect.size.height / 2
        mapView.setVisibleMapRect(visibleRect, animated: false)
    }

    // MARK: - MapKit delegate

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? TileOverlay else { return MKOverlayRenderer(overlay: overlay) }
        return MKTileOverlayRenderer(overlay: tileOverlay)
    }
}
