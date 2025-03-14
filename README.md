# TP ELIZA en Prolog - Réponses aux questions
**Khalil MZOUGHI - 3A FISA INFO**

ELIZA est l'un des premiers programmes de type "ChatBot", un TALN (traitement du langage naturel) créé par J. Weizenbaum au MIT entre 1964 et 1966.

Ce programme simulait un psychothérapeute en utilisant des techniques simples de reformulation et de reconnaissance de motifs. 
Les versions les plus abouties de ELIZA, reconnaissant un grand nombre de motifs, et ayant un nombre suffisant de relances différentes, donnaient souvent l'illusion d'une compréhension réelle.
Certaines personnes se sont attachées à cet algorithme, comme certaines maintenant s'attachent à des LLM.

## Question 1 : Explication de la règle contains

La règle `contains(Texte, Pattern, Suite)` permet de vérifier si une chaîne (Texte) contient un motif spécifique (Pattern) et d'extraire le texte qui suit ce motif (Suite).

```prolog
contains(Texte, Pattern, Suite) :-
    string_concat(_, Temp, Texte),
    string_concat(Pattern, Suite2, Temp),
    string_concat(" ", Suite, Suite2).
```
### Fonctionnement :

1. `string_concat(_, Temp, Texte)` : 
   - Cette ligne divise `Texte` en deux parties : une partie ignorée (représentée par `_`) et une partie temporaire (`Temp`).
   - L'utilisation de la variable anonyme `_` permet de ne pas se préoccuper du début de la chaîne.
   - Cela permet donc de trouver le motif n'importe où dans le texte, pas seulement au début.

2. `string_concat(Pattern, Suite2, Temp)` :
   - Cette ligne vérifie que `Temp` commence par le motif recherché (`Pattern`).
   - Si c'est le cas, le reste de `Temp` après le motif est stocké dans `Suite2`.

3. `string_concat(" ", Suite, Suite2)` :
   - Cette ligne vérifie que `Suite2` commence par un espace suivi du reste de la chaîne (`Suite`) afin de garantir que le motif trouvé est un mot ou une phrase complète, et non une partie de mot.
   - Par exemple, cela permettrait de différencier "je pense" de "je pensais" en s'assurant qu'il y a un espace après le motif.


## Question 2 : Règle random_select

La règle `random_select(Liste, Element)` permet de sélectionner aléatoirement un élément dans une liste.

```prolog
random_select(List, Element) :-
    length(List, L),
    random(0, L, Index),
    nth0(Index, List, Element).
```

### Fonctionnement :

1. `length(List, L)` calcule la longueur L de la liste `list` donnée.
2. `random(0, L, Index)` génère un nombre entier aléatoire entre 0 (inclus) et L (exclu) et le stocke dans la variable `Index`.
3. `nth0(Index, List, Element)` récupère l'élément à la position Index dans la liste et le stocke dans la variable Element.

## Question 3 : Règle random_response

La règle `random_response(Reponse)` génère une réponse aléatoire parmi un ensemble prédéfini de phrases génériques. Son implémentation est la suivante :

```prolog
random_response(Response) :- 
    Responses = [
        "Pouvez-vous développer davantage ?",
        "Je comprends. Continuez, je vous écoute.",
        "Dites-m'en plus à ce sujet.",
        "Comment vous sentez-vous quand vous dites cela ?",
        "Cela semble important pour vous.",
        "Et ensuite ?",
        "Qu'est-ce que cela évoque pour vous ?",
        "Au fond comment vous sentez vous ?"
    ],
    random_select(Responses, Response).
```

### Fonctionnement :

1. Elle définit une liste `Responses` contenant plusieurs phrases génériques qui peuvent être utilisées lorsqu'aucun motif spécifique n'est reconnu dans l'entrée de l'utilisateur.
2. Elle utilise la règle `random_select`, définie précédemment, pour choisir aléatoirement une de ces phrases et la stocker dans la variable `Response`.

## Question 4 : Ajout de patterns

J'ai ajouté les patterns "je suis", "je pense que", "j'ai envie de", "j'ai peur de", "je veux", "parce que", "vous", "ma mère", "mon père", "toujours", "jamais", "j'aime", "je déteste", "je rêve de", "je doute", "je me demande", "je crois", "je ne peux pas", "mon ami", "ma famille" avec plusieurs réponses possibles pour chacun.

Pour chaque pattern, j'ai créé :
1. Une règle `pattern_match` qui détecte le motif dans l'entrée utilisateur
2. Une fonction de réponse spécifique (comme `reponse_je_suis`) qui choisit aléatoirement parmi plusieurs réponses possibles

Voici un exemple pour le pattern "toujours" :

```prolog
% Pattern "toujours"
pattern_match(Input, "toujours", Response) :-
    contains(Input, "toujours", _),
    reponse_toujours(Response).

% Réponses pour "toujours"
reponse_toujours(Response) :-
    Responses = [
        "Pouvez-vous penser à un exemple précis ?",
        "Vraiment ? Toujours ?",
        "N'y a-t-il jamais eu d'exceptions ?"
    ],
    random_select(Responses, Response).
```

Cette structure permet à ELIZA de varier ses réponses, ce qui rend la conversation plus naturelle et moins prévisible pour l'utilisateur.

Aussi, pour que les réponses d'ELIZA s'affichent correctement, pour les patterns qui nécessitent l'intégration de texte de l'utilisateur, nous devons évaluer les expressions `string_concat` avant de les placer dans la liste pour `random_select` :

```prolog
% Réponses pour "je veux"
reponse_je_veux(Rest, Response) :-
    string_concat("Pourquoi voulez-vous ", Rest, R1),
    string_concat("Que se passerait-il si vous obteniez ", Rest, R2),
    string_concat("Qu'est-ce qui vous empêche d'avoir ", Rest, R3),
    random_select([R1, R2, R3], Response).
```

Cette méthode évalue d'abord chaque expression `string_concat` et stocke les résultats dans des variables (R1, R2, R3), puis utilise ces variables contenant les chaînes complètes dans la liste pour `random_select`.

## Question 5 : Mémorisation des entrées

J'ai implémenté une fonctionnalité qui permet à ELIZA de mémoriser les entrées précédentes de l'utilisateur et de les utiliser pour relancer la conversation.

### 1. Gestion de l'historique

Tout d'abord, j'ai créé un prédicat dynamique pour stocker l'historique des entrées de l'utilisateur :

```prolog
:- dynamic historique/1.
:- asserta(historique([])).
```

- `dynamic historique/1` déclare un prédicat dynamique qui peut être modifié pendant l'exécution du programme.
- `asserta(historique([]))` initialise ce prédicat avec une liste vide.

Cette structure constitue la "mémoire" d'ELIZA, où sera conservé l'ensemble de la conversation.

### 2. Entregistrer les entrées

À chaque tour de conversation, les entrées de l'utilisateur sont automatiquement mémorisées grâce à la fonction `memoriser_entree` :

```prolog
memoriser_entree(Entree) :-
    historique(Liste),
    retract(historique(Liste)),
    append(Liste, [Entree], NouvelleListe),
    asserta(historique(NouvelleListe)).
```

#### Fonctionnement :
1. Récupère la liste actuelle de l'historique (`historique(Liste)`)
2. Supprime cette version de l'historique de la base de connaissances (`retract(historique(Liste))`)
3. Ajoute la nouvelle entrée à la fin de la liste (`append(Liste, [Entree], NouvelleListe)`)
4. Enregistre la nouvelle liste dans la base de connaissances (`asserta(historique(NouvelleListe))`)

Cette fonction est appelée dans la boucle principale de conversation :

```prolog
conversation :-
    prenom(X), write('Vous('), write(X), write(') : '),
    read_line_to_string(user_input, Input),
    string_lower(Input, LowerInput),
    % Mémorisation de l'entrée
    memoriser_entree(LowerInput),
    traiter_entree(LowerInput, Reponse).
```

### 3. Utiliser l'historique

Le cœur du mécanisme de "mémoire" se trouve dans la fonction `check_historique` qui analyse l'historique et génère des réponses contextuelles :

```prolog
check_historique(Reponse) :-
    historique(Liste),
    length(Liste, L),
    L > 3,  % Si nous avons au moins 3 entrées
    L2 is L - 2,  % Calculer l'index correctement
    nth0(L2, Liste, AvantDerniere),  % Récupérer l'avant-dernière entrée
    contains(AvantDerniere, "je", Suite),
    string_concat("Vous avez mentionne auparavant que vous ", Suite, Reponse).
```

#### Fonctionnement :
1. Vérifie que l'historique contient suffisamment d'entrées (`L > 3`)
2. Calcule l'index de l'avant-dernière entrée (`L2 is L - 2`) - cette étape est cruciale car en Prolog, les opérations arithmétiques nécessitent l'opérateur `is`
3. Extrait l'avant-dernière entrée (`nth0(L2, Liste, AvantDerniere)`) 
4. Recherche si cette entrée contient le motif "je" (`contains(AvantDerniere, "je", Suite)`)
5. Si oui, formule une réponse qui fait référence à cette entrée antérieure

### 4. Traitement des entrées

Ce mécanisme de mémorisation est intégré dans le traitement des entrées. Lorsqu'aucun pattern standard n'est reconnu, le système tente d'abord d'utiliser l'historique avant de recourir à une réponse aléatoire :

```prolog
traiter_entree(Entree, Reponse) :- 
    % Essayer d'utiliser l'historique si aucun pattern ne correspond
    (check_historique(Reponse), ! ; random_response(Reponse)),
    write('ELIZA: '), write(Reponse), nl, conversation.
```

L'opérateur `(A, !; B)` est un "ou" conditionnel qui tente d'abord d'exécuter `A` et, en cas d'échec seulement, exécute `B`. Le `!` empêche le backtracking si `A` réussit.

### Voici un exemple de discussion où Eliza fait appel à sa mémoire
```
ELIZA - Therapeute Virtuel 
(Tapez "au revoir" pour terminer la conversation)

ELIZA: Bonjour, je suis Eliza.
quel est votre prenom ?
|    jean
Tres bien, jean, comment puis-je vous aider aujourd'hui?
Vous(jean) : je me sens fatigué ces derniers temps
ELIZA: Depuis combien de temps vous sentez-vous fatigué ces derniers temps
Vous(jean) : depuis environ deux semaines
ELIZA: Je comprends. Continuez, je vous ecoute.
Vous(jean) : je pense que c'est à cause du travail
ELIZA: Avez-vous des preuves que c'est à cause du travail
Vous(jean) : j'ai beaucoup de projets en même temps
ELIZA: Vous avez mentionne auparavant que vous pense que c'est à cause du travail
Vous(jean) : je ne sais pas quoi dire d'autre
ELIZA: Pouvez-vous developper davantage ?
Vous(jean) : non
ELIZA: Vous avez mentionne auparavant que vous ne sais pas quoi dire d'autre
Vous(jean) : au revoir
ELIZA: C'etait un plaisir de discuter avec vous. a bientot.
```