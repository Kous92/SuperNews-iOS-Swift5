# SuperNews iOS

Projet personnel en développement iOS. Application iOS native de news en temps réel ayant les fonctionnalités suivantes:
- Téléchargement et récupération de news locales d'un pays par le biais d'une API REST
- Carte des news par pays.
- Paramètres de localisation GPS, de news locales favorites (automatique avec le GPS ou manuelle)
- Architecture MVC

## IMPORTANT AVANT D'ESSAYER L'APPLI iOS

L'appli exploite l'API REST de **NewsAPI**, une clé d'API est donc requise. Pour cela, obtenez votre clé sur le site de [NewsAPI](https://newsapi.org/), dans la rubrique **Account** du compte que vous avez créé:<br>
![Page clé NewsAPI](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/NewsAPIKey.png)<br>

**Pour des raisons de sécurité, le fichier ApiKey.plist n'est pas présent dans le repo GitHub**.<br>

Une fois la clé récupérée, créez un fichier **ApiKey.plist**, en le plaçant dans le même emplacement du dossier SuperNews du projet Xcode, où se situent les fichiers storyboard. Créez alors une propriété de type **String** avec `ApiKey` en tant que clé, et la clé d'API que vous avez récupérée en tant que valeur. Prenez exemple comme ci-dessous:
![NewsAPI.plist](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/NewsApiKeyPlist.png)<br>

Ou bien dans dans ce même fichier en y ajoutant le code sous format XML et en y mettant sa clé d'API entre les balises `</string>`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NewsApiKey</key>
	<string>VOTRE CLÉ D'API</string>
</dict>
</plist>
```

La clé sera ensuite récupérée par la fonction privée ci-dessous de la classe singleton `NewsAPIService`, en lisant le contenu du fichier plist créé au préalable et initialisé depuis le constructeur de `NewsAPIService` via la propriété `shared`.
```swift
class NewsAPIService {
    static let shared = NewsAPIService()

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

    init() {
        self.apiKey = getApiKey() ?? ""
    }
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
