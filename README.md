# SuperNews iOS

Projet personnel en développement iOS. Application iOS native de news en temps réel ayant les fonctionnalités suivantes:
- Téléchargement et récupération de news locales d'un pays par le biais d'une API REST
- Carte des news par pays.
- Paramètres de localisation GPS, de news locales favorites (automatique avec le GPS ou manuelle)
- Architecture MVC

## IMPORTANT AVANT D'ESSAYER L'APPLI iOS

L'appli exploite l'API REST de **NewsAPI**, une clé d'API est donc requise. Pour cela, obtenez votre clé sur le site de [NewsAPI](https://newsapi.org/):
![Page clé NewsAPI](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/NewsAPIKey.png)<br>

Une fois la clé récupérée, créez un fichier **ApiKey.plist** comme ci-dessous:
![NewsAPI.plist](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/NewsAPIKeyPlist.png)<br>

```swift
private func getApiKey() -> String? {
    guard let path = Bundle.main.path(forResource: "ApiKey", ofType: "plist") else {
        print("ERREUR: Fichier ApiKey.plist inexistant")
        return nil
    }
    
    guard let dictionary = NSDictionary(contentsOfFile: path) else {
        print("ERREUR: Données indisponibles")
        return nil
    }
    
    return dictionary.object(forKey: "NewsApiKey") as? String
}
```
## Frameworks

Frameworks officiels:
- UIKit
- Foundation
- MapKit
- Network
- SafariServices

Frameworks tiers:
- Alamofire
- Kingfisher

## Tests unitaires et UI

Utilise XCTest, couverture actuelle du code: **28,1%**
- Tests unitaires classiques et asynchrones.
- Tests UI classiques et asynchones.
