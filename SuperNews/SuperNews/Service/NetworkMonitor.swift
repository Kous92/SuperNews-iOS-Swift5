//
//  NetworkMonitor.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 14/04/2021.
//

import Foundation
import Network

class NetworkStatus {
    
    // Ici une seule instance (singleton) suffit pour le monitoring du réseau
    static let shared = NetworkStatus()
    
    // Si on stoppe le monitoring avec monitor.cancel(), il n'est plus possible de le redémarrer. Il faut donc le réinstancier.
    var monitor: NWPathMonitor?
    var isMonitoring: Bool = false
    
    /* Ces handlers vont permettre d'appliquer du background thread au main thread (la partie visuelles) les changements liés au réseau
    La closure en paramètre sera là où le code sera écrit pour appliquer les changements dans le ViewController */
    
    // Le monitoring réseau est lancé
    var didStartMonitoringHandler: (() -> Void)?
    
    // Le monitoring est stoppé
    var didStopMonitoringHandler: (() -> Void)?
    
    // Le statut réseau change
    var netStatusChangeHandler: (() -> Void)?
    
    // Si le monitoring est actif, on retourne l'état de la connectivité
    var isConnected: Bool {
        guard let monitor = monitor else {
            return false
        }
        
        return monitor.currentPath.status == .satisfied
    }
    
    // Le réseau provient d'un forfait de données cellulaires.
    var isExpensive: Bool {
        return monitor?.currentPath.isExpensive ?? false
    }
    
    public private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case loopback
        case unknown
    }
    
    // De ce fait, l'instance partagée va donc utiliser un constructeur privé
    private init() {
        
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        guard !isMonitoring else {
            return
        }
        
        monitor = NWPathMonitor()
        
        // Le monitoring de la connexion se fait dans un thread de fond (background thread)
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)
        print("Monitoring activé")
        
        /* Dans cette closure, c'est ici que le changement en temps réel s'applique.
        -> On va appeler le handler de changement de statut réseau, le traitement sera effectué dans le ViewController de façon asynchrone.
        -> On va récupérer le type de connectivité.
        */
        monitor?.pathUpdateHandler = { [unowned self] path in
            self.netStatusChangeHandler?()
            getConnectionType(path)
        }
        
        isMonitoring = true
        didStartMonitoringHandler?()
    }
    
    func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else {
            return
        }
        
        // Avant la désinstaniciation, il faut stopper le thread du monitoring réseau.
        monitor.cancel()
        // Le fait que monitor soit optionnel permettra de réinstancier un NWPathMonitor et redémarrer un monitoring
        self.monitor = nil
        print("Monitoring désactivé")
        isMonitoring = false
        didStopMonitoringHandler?()
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            print("Wifi")
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("Données cellulaires")
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            print("Ethernet")
        } else if path.usesInterfaceType(.loopback) {
            connectionType = .loopback
            print("Localhost")
        } else {
            connectionType = .unknown
            print("Inconnu")
        }
    }
}
