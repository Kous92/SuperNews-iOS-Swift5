# Super News iOS

![Icône Super News iOS](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/IconeSuperNewsiOS.png)<br>

Projet personnel en développement iOS. Application iOS native de news en temps réel ayant les fonctionnalités suivantes:
- Téléchargement asynchrone et récupération de news locales d'un pays par le biais d'une API REST
- Carte des news par pays (avec option de recherche d'un pays)
- Paramètres de news locales favorites et de langue des news lors de la recherche.
- Architecture MVC
- Tests Unitaires et UI

## Plan de navigation
- [Important: avant d'essayer l'appli iOS](#important)
- [Tests unitaires et UI](#testing)

## <a name="important"></a>IMPORTANT AVANT D'ESSAYER L'APPLI iOS<a>

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

## <a name="testing"></a>Tests unitaires et UI

Dans tout développement d'applications iOS, comme sur d'autres plateformes, les tests unitaires et UI (User Interface, traduisez par interface utilisateur) sont essentiels pour vérifier le bon fonctionnement de l'application avant les bêta-tests par des utilisateurs et sa mise en production sur l'AppStore.

En iOS natif, on utilise le framework XCTest. Avec l'architecture MVC, l'inconvénient est la difficulté de tester en profondeur le code et les fonctionnalités de l'application, et particulièrement les `ViewController`, ce qui ne permet pas une couverture du code élevée.

### Tests unitaires (White box)

Les tests unitaires sont les tests en boîte blanche (White box) où on a une visibilité sur le code, afin de tester les fonctionnalités de l'application. Je propose 7 tests unitaires indépendants dont certains asynchrones:
- 1) `testFetchLocalCountriesJSON()`: Un test simple qui vérifie que les données du fichier JSON en objets Swift soient bien lues et décodées pour la liste des pays.
- 2) `testLocalCountry()`: Un test qui en plus de charger le fichier JSON va vérifier avec certains filtres que les données attendues soient présentes.
- 3) `testFetchLocalLanguagesJSON()`: Un test simple qui vérifie que les données du fichier JSON en objets Swift soient bien lues et décodées pour la liste des langues.
- 4) `testFetchLocalNewsNetwork()`: Un test asynchrone qui va vérfier par le biais d'une requête HTTP GET que les news locales de la France soient bien téléchargées et décodées en objets Swift.
- 5) `testFetchQueryNewsNetwork()`: Un test asynchrone qui va vérfier par le biais d'une requête HTTP GET que les news d'une recherche simple (exemple avec Apple en français) soient bien téléchargées et décodées en objets Swift.
- 6) `testNoArticlesAvailableFetch()`: Un test asynchrone qui va vérfier par le biais d'une requête HTTP GET que l'erreur `.noArticles` de l'énumération `NewsAPIError`soient disponibles, en effectuant une recherche sur un contenu impossible à trouver dans les news.
- 7) `testNoAPIKeyFetch()`: Un test asynchrone qui va vérfier par le biais d'une requête HTTP GET que l'erreur 401 se déclenche lorsqu'il y n'y a pas de clé d'API fournie.

Ces tests unitaires couvrent **10,2%** du code de l'application:<br>
![Tests unitaires et couvertures](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/UnitTestsCodeCoverage.png)

Utilise XCTest, couverture actuelle du code: **28,1%**
- Tests unitaires classiques et asynchrones.
- Tests UI classiques et asynchones.
