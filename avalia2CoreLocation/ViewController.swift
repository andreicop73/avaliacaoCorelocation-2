//
//  ViewController.swift
//  avalia2CoreLocation
//
//  Created by mac ssd on 16/09/17.
//  Copyright © 2017 andruino. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var latitude: UILabel!
    
    
    @IBOutlet weak var longitude: UILabel!
    
    @IBOutlet weak var mapa: MKMapView!
    
    
    var gerenciadorLocalizacao = CLLocationManager()
    var minhaPosicao = CLLocationCoordinate2D()
    
    var destino: MKMapItem = MKMapItem()
    
    @IBAction func iniciarGps(_ sender: Any) {
        gerenciadorLocalizacao.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
     //   gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.startUpdatingLocation()
    
        
        mapa.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let localizacaoUsuario = locations.last!
        
        let latitudeL = localizacaoUsuario.coordinate.latitude
        let longitudeL = localizacaoUsuario.coordinate.longitude
        
        latitude.text = String(describing: latitudeL)
        
        longitude.text = String(describing: longitudeL)
        
        
        let deltaLat: CLLocationDegrees = 0.08
        let deltalong: CLLocationDegrees = 0.08
        
        let localizacao: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudeL, longitudeL)
        let areaExibida: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: deltaLat, longitudeDelta: deltalong)
        let regiao: MKCoordinateRegion = MKCoordinateRegion(center: localizacao, span: areaExibida)
        mapa.setRegion(regiao, animated: true)
    
    }
    
    
    @IBAction func marcarPino(_ sender: UILongPressGestureRecognizer) {
        
        let localizacao = sender.location(in: self.mapa)
        
        let locCoord = self.mapa.convert(localizacao, toCoordinateFrom: self.mapa)
        let anotacao = MKPointAnnotation()
        anotacao.coordinate = locCoord
        anotacao.title = "Minha Localizacão"
        
        let placeMark = MKPlacemark(coordinate: locCoord, addressDictionary: nil)
        
        destino = MKMapItem(placemark: placeMark)
        
        mapa.removeAnnotations(mapa.annotations)
        mapa.addAnnotation(anotacao)
        
    }
    
    
    
    @IBAction func irPara(_ sender: Any) {
        
        let request = MKDirectionsRequest()
        request.source = (MKMapItem.forCurrentLocation())
        
        
        request.destination = (destino)
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        //
        
        let direcao = MKDirections(request: request)
        
        direcao.calculate { (respnse: MKDirectionsResponse!, Erro) in
           
            if Erro != nil {
                
                print("Erro\(String(describing: Erro))")
                
            }else{
                
                let overlays = self.mapa.overlays
                self.mapa.removeOverlays(overlays)
                
                for route in respnse.routes {
                    self.mapa.add(route.polyline, level: MKOverlayLevel.aboveRoads )
                    
                    for next in route.steps {
                        print(next.instructions)
                    }
                    
                }
            }
            
        }
    }
    

    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse{
            let alertaController = UIAlertController(title: "Permissão de Localização", message: "Necessário Permissão para acesso à sua localização! Por favor habilite.", preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir Configurações", style: .default, handler: { (alertaConfiguracoes) in
                
                if let configuracoes = NSURL(string:  UIApplicationOpenSettingsURLString) {
                    
                    UIApplication.shared.open(configuracoes as URL)
                }
            })
            
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            
            alertaController.addAction(acaoConfiguracoes)
            alertaController.addAction(acaoCancelar)
            
            present(alertaController, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let linha = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        linha.strokeColor = UIColor.purple
        linha.lineWidth = 4.0
        return linha
    }
}

