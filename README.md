# Super News iOS

![Icône Super News iOS](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/IconeSuperNewsiOS.png)<br>

Projet personnel en développement iOS. Cette idée que je propose ici est basée sur un mini-projet de développement iOS réalisé au sein de mon stage de fin d'études chez Capgemini, lors d'une session d'upskilling iOS en interne. Ici, il s'agit donc d'une version améliorée d'une application récupérant les news avec des fonctionnalités supplémentaires en exploitant davantage les ressources de l'API REST NewsAPI.<br>

Application iOS native de news en temps réel ayant les fonctionnalités suivantes:
- Téléchargement asynchrone et récupération de news locales d'un pays par le biais d'une API REST
- Carte des news par pays (avec option de recherche d'un pays) et suggetion de pays le plus proche avec la localisation GPS
- Paramètres de news locales favorites et de langue des news lors de la recherche.
- Architecture MVVM + programmation réactive fonctionnelle avec **Combine** (le framework officiel d'**Apple**, l'équivalent du fameux framework **RxSwift**)
- Tests Unitaires et UI

## Branche actuelle: MVVM

## Plan de navigation
- [Important: avant d'essayer l'appli iOS](#important)
- [Architecture et Frameworks](#frameworks)
- [Fonctionnalités et captures d'écrans](#features)
    + [News et recherches](#news)
    + [Carte des news](#newsmap)
    + [Paramètres langue et pays des news](#settings)
- [Tests unitaires et UI](#testing)

## <a name="important"></a>IMPORTANT: À LIRE AVANT D'ESSAYER L'APPLI iOS

L'appli exploite l'API REST de **NewsAPI**, une clé d'API est donc requise. Pour cela, obtenez votre clé sur le site de [NewsAPI](https://newsapi.org/), dans la rubrique **Account** du compte que vous avez créé:<br>
![Page clé NewsAPI](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsAPIKey.png)<br>

**Pour des raisons de sécurité, le fichier ApiKey.plist n'est pas présent dans le repo GitHub**.<br>

Une fois la clé récupérée, créez un fichier **ApiKey.plist**, en le plaçant dans le même emplacement du dossier SuperNews du projet Xcode, où se situent les fichiers storyboard. Créez alors une propriété de type **String** avec `ApiKey` en tant que clé, et la clé d'API que vous avez récupérée en tant que valeur. Prenez exemple comme ci-dessous:
![NewsAPI.plist](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsApiKeyPlist.png)<br>

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

La clé sera ensuite récupérée par la fonction privée ci-dessous de la classe `NewsAPIService`, en lisant le contenu du fichier plist créé au préalable et initialisé depuis le constructeur de `NewsAPIService`.
```swift
class NewsAPIService {
    private var apiKey: String = ""
    
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

Dernière chose, ayant utilisé CocoaPods pour exploiter les frameworks tiers Alamofire et Kingfisher, merci d'ouvrir le fichier **xcworkspace** au lieu du fichier **xcodeproj**.

## <a name="frameworks"></a>Architecture et frameworks

Cette application iOS native est réalisée avec:
- Xcode 13
- Swift 5.5

Architecture MVVM (Model View ViewModel):
- Principaux avantages: 
    + Architecture adaptée pour séparer la vue de la logique métier par le biais de `ViewModel`.
    + `ViewController` allégés.
    + Tests facilités de la logique métier
    + Adaptée avec **SwiftUI**
    + Adaptée pour la programmation réactive (**RxSwift, Combine**)
- Inconvénients:
    + Les `ViewModel` deviennent massifs si la séparation des éléments ne sont pas maîtrisés, notamment si le principe de responsabilité unique n'est pas correctement appliqué.
    + Complexe pour des projets de petite taille.
    + Maîtrise compliquée pour les débutants

![MVVM](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/mvvm/MVVM.png)<br>

Patterns:
- DataSource: par le biais des TableView (pour la récupération des données)
- Delegate: par le biais des TableView (pour les actions sur les cellules), pour les barres de recherche, la carte interactive.
- Injection de dépendances

Frameworks officiels:
- UIKit
- Foundation
- MapKit
- Network
- SafariServices
- Combine (programmation réactive fonctionnelle)

Frameworks tiers (par le biais de CocoaPods):
- Alamofire: appels HTTPS et téléchargement des news.
- Kingfisher: téléchargement d'images asynchrones et optimisés avec le cache.

Interface:
- UIKit avec Storyboard.
- Auto Layout (adapté pour les iPhone).
- Support dark mode et light mode.

## <a name="features"></a>Fonctionnalités et captures d'écran

L'application iOS comporte diverses fonctionnalités. À l'ouverture, la page d'accueil s'affiche comme ci-dessous avec la date et heure locale actuelle:<br>
<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/HomeDark.png" width="250"> <img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/HomeLight.png" width="250">

### <a name="news"></a>News et recherche

En cliquant sur "News" dans la barre de navigation du bas, l'interface des news apparaît comme ceci avec les news locales téléchargées et affichées avec leurs images (par défaut ceux de la France, le pays change en fonction du paramètre choisi):<br>
<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsDark.png" width="250"> <img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsLight.png" width="250"><br>

Pour rechercher le contenu, il suffit tout simplement de toucher la barre de recherche puis de saisir le contenu recherché. Par défaut la langue des news est en français.<br>
<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsSearch.png" width="250">

### <a name="newsmap"></a>Carte des news

Avec les possibilités que donne NewsAPI, il est donc possible de récupérer les news en tendance de 54 pays différents dans le monde entier. Je propose donc ici une option de carte interactive où des marqueurs personnalisés apparaîssent sur la carte représentant le pays en question, comme ci-dessous:<br>
<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsMapDark.png" width="250"> <img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsMapLight.png" width="250"><br>

La barre de recherche en haut vous permettra de center la carte sur les pays à leurs positions respectives. En la touchant, une liste d'autocomplétion apparaît et change par un filtrage en fonction de la saisie. Par exemple, si je veux centrer la carte sur les Émirats Arabes Unis, je valide ma recherche soit en saississant le nom du pays, soit en sélectionnant sa cellule de la liste d'autocomplétion, et cela va donc centrer la carte sur le pays et le marqueur en question, comme ci-dessous:<br>
<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsMapSearch1.png" width="250"> <img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsMapSearch2.png" width="250"><br>

En cliquant sur le drapeau de la carte, une info-bulle apparaît, cliquez sur le "i" pour afficher les news locales du pays sélectionné.<br>
<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsMapSearch3.png" width="250"> <img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsMapLocalNews.png" width="250"><br>

### <a name="settings"></a>Paramètres langue et pays des news

<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/Settings.png" width="250"><br>

Pour les paramètres, vous pouvez définir votre pays favori des news en sélectionnant "Pays des news" puis le pays de votre choix parmi les 54 disponibles (par exemple les États-Unis). Une fois sélectionné, allez dans "News" et vous verrez les news locales des États-Unis.<br>
<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/SettingsCountry.png" width="250"> <img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsCountrySettings.png" width="250"><br>

Pour la langue, même chose depuis les paramètres, en sélectionnant "Langue des news" puis la langue de votre choix parmi les 14 langues disponibles (exemple: Arabe). Avec la langue sélectionnée, allez dans "News" et vous verrez dans la barre de recherche la langue sélectionnée (ici: arabe par exemple) et en recherchant un contenu dans la langue choisie, les news s'afficheront s'il y en a de disponibles.<br>
<img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/SettingsLanguage.png" width="250"> <img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsLanguageSettings1.png" width="250"><img src="https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/NewsLanguageSettings2.png" width="250"><br>

## <a name="testing"></a>Tests unitaires et UI

Dans tout développement d'applications iOS, comme sur d'autres plateformes, les tests unitaires et UI (User Interface, traduisez par interface utilisateur) sont essentiels pour vérifier le bon fonctionnement de l'application avant les bêta-tests par des utilisateurs et sa mise en production sur l'AppStore.

En iOS natif, on utilise le framework XCTest. Avec l'architecture MVC, l'inconvénient est la difficulté de tester en profondeur le code et les fonctionnalités de l'application, et particulièrement les `ViewController`, ce qui ne permet pas une couverture du code élevée.

### Tests unitaires (White box)

Les tests unitaires sont les tests en boîte blanche **(White box)** où on a une visibilité sur le code, afin de tester les fonctionnalités de l'application. Je propose 7 tests unitaires indépendants dont certains asynchrones:
1. `testFetchLocalCountriesJSON()`: Un test simple qui vérifie que les données du fichier JSON en objets Swift soient bien lues et décodées pour la liste des pays.
2. `testLocalCountry()`: Un test qui en plus de charger le fichier JSON va vérifier avec certains filtres que les données attendues soient présentes.
3. `testFetchLocalLanguagesJSON()`: Un test simple qui vérifie que les données du fichier JSON en objets Swift soient bien lues et décodées pour la liste des langues.
4. `testFetchLocalNewsNetwork()`: Un test asynchrone qui va vérfier par le biais d'une requête HTTP GET que les news locales de la France soient bien téléchargées et décodées en objets Swift.
5. `testFetchQueryNewsNetwork()`: Un test asynchrone qui va vérfier par le biais d'une requête HTTP GET que les news d'une recherche simple (exemple avec Apple en français) soient bien téléchargées et décodées en objets Swift.
6. `testNoArticlesAvailableFetch()`: Un test asynchrone qui va vérfier par le biais d'une requête HTTP GET que l'erreur `.noArticles` de l'énumération `NewsAPIError`soient disponibles, en effectuant une recherche sur un contenu impossible à trouver dans les news.
7. `testNoAPIKeyFetch()`: Un test asynchrone qui va vérfier par le biais d'une requête HTTP GET que l'erreur 401 se déclenche lorsqu'il y n'y a pas de clé d'API fournie.

Ces tests unitaires couvrent **12%** du code de l'application.<br>
![Couverture tests unitaires](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/UnitTestsCodeCoverage.png)

### Tests UI automatisés (Black box)

Les tests UI sont les tests en boîte noire **(Black box)** où on n'a pas de visibilité sur le code, mais une visibilité sur l'interface visuelle. Pour cela, XCTest utilise `XCUIApplication` pour permettre de simuler les interactions d'une application de façon automatique, et de vérifier l'existence des élements attendus dans l'interface. L'architecture de l'application importe peu dans les tests UI, l'essentiel étant de tester comme un utilisateur lambda. Par rapport au tests unitaires, la couverture du code est donc plus élevée, mais en contrepartie de tests qui peuvent être longs à exécuter.
Je propose 9 tests UI automatisés indépendants dont certains asynchrones:
1. `testHome()`: Un test automatisé simple qui pointe sur la page d'accueil et qui vérifie que le texte du haut **"Bienvenue"** existe.
2. `testNews()`: Un test automatisé asynchrone qui pointe sur la page des news, qui vérifie l'existence de la barre de recherche et qui vérifie l'existence des cellules du TableView après téléchargement des news locales.
3. `testSearchNews()`: Un test automatisé asynchrone qui pointe sur la page des news, qui vérifie l'existence de la barre de recherche, saisit un texte et valide pour rechercher un contenu. Vérifie ensuite l'existence des cellules du TableView après téléchargement des news recherchées.
4. `testNewsSearchFullNavigation()`: Même chose que le test précédent, mais en plus qui clique sur la première cellule, swipe, vérifie l'existence du bouton vers le site web
5. `testMap()`: Un test automatisé qui pointe sur la page de la carte, vérifie l'existence de la carte (MapKit) et la barre de recherche. En cliquant sur cette barre, un TableView doit apparaître pour les options d'auto-complétion parmi les pays disponibles, son existence est vérifie en premier lieu. Le texte "France" est saisi dans la barre de recherche puis validé pour vérifier ensuite qu'il n'y ait que cette cellule dans l'auto-complétion pour y cliquer dessus ensuite.
6. `testSettings()`: Un test automatisé qui pointe sur la page des paramètres, vérifie l'existence du TableView où les 2 options de la langue et du pays des news sont présentes.
7. `testSetNewsCountry()`: Reprend le test précédent, clique sur la seconde cellule, vérifie qu'il y a bien les 54 pays en option conformément au fichier local `countries.json` et à l'API REST **NewsAPI**, dans un TableView. Clique ensuite sur la seconde cellule (exemple: Allemagne).
8. `testSetNewsCountry()`: Comme le test précédent, clique sur la première cellule, vérifie qu'il y a bien les 14 langues en option conformément au fichier local `countries.json` et à l'API REST **NewsAPI**, dans un TableView. Clique ensuite sur la seconde cellule (exemple: Anglais).
9. `testAbout()`: Un test automatisé simple qui pointe sur la page "À propos", vérifie que le texte du haut existe, swipe pour aller en bas du ScrollView, vérifie l'existence du texte du bas et swipe de nouveau pour revenir en haut du ScrollView.

Ces tests UI automatisés couvrent **58,8%** du code de l'application.<br>
![Couverture tests UI](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/UITestCodeCoverage.png)

### Au niveau global pour les tests

En exécutant les 16 tests automatisés, unitaires et UI, la couverture actuelle du code est de **57,3%**.<br>
![Couverture tests unitaires et UI](https://github.com/Kous92/SuperNews-iOS-Swift5/blob/main/Screenshots/TestsCodeCoverage.png)