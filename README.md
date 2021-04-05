<a href="https://github.com/nag763/monprogrammetv/blob/main/LICENSE" alt="License"><img src="https://img.shields.io/bower/l/bootstrap"></a>
<a href="https://github.com/nag763/monprogrammetv/releases/latest" alt="GitHub release"><img src="https://img.shields.io/github/v/release/nag763/monprogrammetv" ></a>
<a href="" alt="issues"><img src="https://img.shields.io/github/issues/nag763/monprogrammetv"></a>

<p align="center"><img src="https://github.com/nag763/monprogrammetv/blob/main/logos/logo.png"></img></p>

<h2 align="center">MPTVFR</h2>
<h4 align="center">Une application simple pour consulter le programme télé du jour en France.</h4>

![demo](https://github.com/nag763/monprogrammetv/blob/main/demo.gif)

<img src="https://github.com/nag763/monprogrammetv/blob/main/screen1.jpg" width=200>
<img src="https://github.com/nag763/monprogrammetv/blob/main/screen2.jpg" width=200>
<img src="https://github.com/nag763/monprogrammetv/blob/main/screen3.jpg" width=200>

Application pour consulter le programme tv du jour

## Obtenir l'application

L'APK peut être téléchargé directement sur ce lien : [ici](https://github.com/nag763/monprogrammetv/releases/latest).

## A propos

- Mainteneur : LABEYE Loïc <loic.labeye@pm.me>

- Technologies utlisées :

  - Flutter

  - Dart SDK

  - Visual Studio Code

  - Pop_os!

## Architecture projet

- android : code source android
- lib : fichiers sources
- test : fichiers tests (non utilisés)

## Feuille de route

### Expérience Utilisateur

- [ ] Ajouter un mode programme/ chaîne par colonne.
- [ ] Ajouter une alternative lorsqu'aucun programme n'est récupéré à cause d'une erreur, affichant le signe que les programmes n'ont pas pu être récupérés à l'emplacement usuel de la liste.

### Technique

- [X] Privilégier les classes Dart plutôt que les Map.
- [ ] Réaliser tests unitaires.
- [ ] Séparer les parties logiques et visuelles du code.
- [ ] Nettoyer le code.
- [ ] Gérer les problèmes potentiels liés à la taille d'écran.
- [ ] Trouver un meilleur fournisseur de programme.
