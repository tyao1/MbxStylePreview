import UIKit
import Mapbox

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var mapView: MGLMapView!
    var styles: [Style]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: mapContainerView.frame)
        mapContainerView.addSubview(mapView)
       
        let accessTokenButton = UIBarButtonItem(title: "token", style: .Plain, target: self, action: "didTapAccessTokenButton:")
        let stylesButton = UIBarButtonItem(title: "styles", style: .Plain, target: self, action: "didTapStylesTokenButton:")
        
        self.navigationItem.rightBarButtonItems = [accessTokenButton, stylesButton]
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
       
        NetworkUtility.owner = "boundsj"
        NetworkUtility.accessToken = "pk.eyJ1IjoiYm91bmRzaiIsImEiOiJlMDhiODlkODA4Yzk2MDRmMTA3MTFiNjE0MGQ5ZTllNyJ9.SQnoVXanXTQBiZ-prSX_gw"
        NetworkUtility.fetchStyles { (styles) in
            self.styles = styles
            self.pickerView.reloadAllComponents()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["mapView" : mapView]
        let formatString = "|[mapView]|"
        let contraints = NSLayoutConstraint.constraintsWithVisualFormat(formatString, options: .AlignAllTop, metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(contraints)
    }

}

// MARK: Actions

extension PreviewViewController {

    func didTapAccessTokenButton(id: AnyObject) {
        if let accessVC = storyboard?.instantiateViewControllerWithIdentifier("AccessViewController") {
            navigationController?.pushViewController(accessVC, animated: true)
        }
    }
    
    func didTapStylesTokenButton(id: AnyObject) {
        pickerView.hidden = !pickerView.hidden
    }
    
}

// MARK: UIPickerViewDataSource

extension PreviewViewController: UIPickerViewDataSource {
   
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let s = styles else {
           return 0
        }
        return s.count
    }
    
}

// MARK: UIPickerViewDelegate

extension PreviewViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let style = styles![row]
        return style.name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let style = styles![row]
        let urlString = "mapbox://styles/\(style.owner)/\(style.uniqueID)"
        mapView.styleURL = NSURL(string: urlString)
    }
    
}
