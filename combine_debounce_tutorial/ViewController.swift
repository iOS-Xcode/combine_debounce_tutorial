//
//  ViewController.swift
//  combine_debounce_tutorial
//
//  Created by Seokhyun Kim on 2021-03-18.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var myLabel: UILabel!
    private lazy var searchController : UISearchController = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .black
        searchController.searchBar.searchTextField.accessibilityIdentifier = "mySearchBarTextField"
        return searchController
    }()
    
    var mySubscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = searchController
        searchController.isActive = true
        searchController.searchBar.searchTextField
            .myDebouceSearchPublisher
            .sink { [weak self] (receivedValue) in
                guard let self = self else { return }
                print("receivedValue: \(receivedValue)")
                //self는 리테인 사이클에 걸리고 메모리를 먹음. 가드렛으로 언레핑.
                self.myLabel.text = receivedValue
            }.store(in: &mySubscription)
    }
}

extension UISearchTextField {
    var myDebouceSearchPublisher : AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: self)
        //노티피케이션 센터에서 UISearchTextField 가져옴
            .compactMap{ $0.object as? UISearchTextField }
        //UISearchTextField 에서 String 가져오기
            .map{ $0.text ?? "" }
            //디바운스
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            //글자가 있을 때만.
            .filter{ $0.count > 0 }
            .print()
            .eraseToAnyPublisher()
    }
}
