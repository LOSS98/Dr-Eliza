% ELIZA en Prolog - Simulateur de therapeute 
% Base de connaissances dynamique (prenom et historique)

:- dynamic prenom/1.
:- dynamic historique/1.  % Pour memoriser les entrees precedentes

% Initialisation de l historique
:- asserta(historique([])).

% introduction au dialogue 
start_eliza :-
    write('*** ELIZA - Therapeute Virtuel ***'), nl,
    write('(Tapez "au revoir" pour terminer la conversation)'), nl, nl,
    write('ELIZA: Bonjour, je suis Eliza.'), nl,
    write('quel est votre prenom ?'), nl,
    read_line_to_string(user_input, Prenom),
    asserta(prenom(Prenom)),
    write('Tres bien, '), write(Prenom), write(', comment puis-je vous aider aujourd\'hui?'), nl,
    conversation.

% Boucle de conversation
conversation :-
    prenom(X), write('Vous('), write(X), write(') : '),
    read_line_to_string(user_input, Input),
    string_lower(Input, LowerInput),
    % Memorisation de l entree
    memoriser_entree(LowerInput),
    traiter_entree(LowerInput, Reponse).

% Memorisation des entrees pour relancer la discussion plus tard
memoriser_entree(Entree) :-
    historique(Liste),
    retract(historique(Liste)),
    append(Liste, [Entree], NouvelleListe),
    asserta(historique(NouvelleListe)).

% Traitement de l entree : fin de la conversation
traiter_entree("au revoir", _) :- !, write('ELIZA: C\'etait un plaisir de discuter avec vous. A bientot.'), nl.
% Traitement de l entree : reconnaissance de motifs, affichage de la reponse et poursuite de la conversation
traiter_entree(Entree, Reponse) :- pattern_match(Entree, Pattern, Reponse), !, write('ELIZA: '), write(Reponse), nl, conversation.
% Traitement de l entree : reponse par defaut, affichage de la reponse aleatoire et poursuite de la conversation
traiter_entree(Entree, Reponse) :- 
    % Essayer d utiliser l historique si aucun pattern ne correspond
    (check_historique(Reponse), ! ; random_response(Reponse)),
    write('ELIZA: '), write(Reponse), nl, conversation.

% Verifier l historique pour relancer la conversation
check_historique(Reponse) :-
    historique(Liste),
    length(Liste, L),
    L > 3,  % Si nous avons au moins 3 entrees
    L2 is L - 2,  % Calculer l index correctement
    nth0(L2, Liste, AvantDerniere),  % Recuperer l avant-derniere entree
    contains(AvantDerniere, "je", Suite),
    string_concat("Vous avez mentionne auparavant que vous ", Suite, Reponse).

% Patterns de reconnaissance
% Pattern "je me sens"
pattern_match(Input, "je me sens", Response) :-
    contains(Input, "je me sens", Rest),
    reponse_je_me_sens(Rest, Response).

% Pattern "je suis"
pattern_match(Input, "je suis", Response) :-
    contains(Input, "je suis", Rest),
    reponse_je_suis(Rest, Response).

% Pattern "je pense que"
pattern_match(Input, "je pense que", Response) :-
    contains(Input, "je pense que", Rest),
    reponse_je_pense_que(Rest, Response).

% Pattern "j'ai envie de"
pattern_match(Input, "j'ai envie de", Response) :-
    contains(Input, "j'ai envie de", Rest),
    reponse_envie_de(Rest, Response).

% Pattern "j'ai peur de"
pattern_match(Input, "j'ai peur de", Response) :-
    contains(Input, "j'ai peur de", Rest),
    reponse_peur_de(Rest, Response).

% Pattern "je veux"
pattern_match(Input, "je veux", Response) :-
    contains(Input, "je veux", Rest),
    reponse_je_veux(Rest, Response).

% Pattern "parce que"
pattern_match(Input, "parce que", Response) :-
    contains(Input, "parce que", Rest),
    reponse_parce_que(Rest, Response).

% Pattern "vous"
pattern_match(Input, "vous", Response) :-
    contains(Input, "vous", Rest),
    reponse_vous(Rest, Response).

% Pattern "ma mere"
pattern_match(Input, "ma mere", Response) :-
    contains(Input, "ma mere", Rest),
    reponse_ma_mere(Rest, Response).

% Pattern "mon pere"
pattern_match(Input, "mon pere", Response) :-
    contains(Input, "mon pere", Rest),
    reponse_mon_pere(Rest, Response).

% Pattern "toujours"
pattern_match(Input, "toujours", Response) :-
    contains(Input, "toujours", _),
    reponse_toujours(Response).

% Pattern "jamais"
pattern_match(Input, "jamais", Response) :-
    contains(Input, "jamais", _),
    reponse_jamais(Response).

% Pattern "j'aime"
pattern_match(Input, "j'aime", Response) :-
    contains(Input, "j'aime", Rest),
    reponse_jaime(Rest, Response).

% Pattern "je deteste"
pattern_match(Input, "je deteste", Response) :-
    contains(Input, "je deteste", Rest),
    reponse_je_deteste(Rest, Response).

% Pattern "je rêve de"
pattern_match(Input, "je rêve de", Response) :-
    contains(Input, "je rêve de", Rest),
    reponse_je_reve_de(Rest, Response).

% Pattern "je doute"
pattern_match(Input, "je doute", Response) :-
    contains(Input, "je doute", Rest),
    reponse_je_doute(Rest, Response).

% Pattern "je me demande"
pattern_match(Input, "je me demande", Response) :-
    contains(Input, "je me demande", Rest),
    reponse_je_me_demande(Rest, Response).

% Pattern "je crois"
pattern_match(Input, "je crois", Response) :-
    contains(Input, "je crois", Rest),
    reponse_je_crois(Rest, Response).

% Pattern "je ne peux pas"
pattern_match(Input, "je ne peux pas", Response) :-
    contains(Input, "je ne peux pas", Rest),
    reponse_je_ne_peux_pas(Rest, Response).

% Pattern "mon ami"
pattern_match(Input, "mon ami", Response) :-
    contains(Input, "mon ami", Rest),
    reponse_mon_ami(Rest, Response).

% Pattern "ma famille"
pattern_match(Input, "ma famille", Response) :-
    contains(Input, "ma famille", Rest),
    reponse_ma_famille(Rest, Response).

% Reponses possibles pour chaque pattern - CORRIGÉES

% Reponses pour "je me sens"
reponse_je_me_sens(Rest, Response) :-
    string_concat("Depuis combien de temps vous sentez-vous ", Rest, R1),
    string_concat("Qu'est-ce qui vous fait vous sentir ", Rest, R2),
    string_concat("Pouvez-vous m'expliquer pourquoi vous vous sentez ", Rest, R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "je suis"
reponse_je_suis(Rest, Response) :-
    string_concat("Pourquoi pensez-vous être ", Rest, R1),
    string_concat("Depuis quand êtes-vous ", Rest, R2),
    string_concat("Comment vous sentez-vous d'être ", Rest, R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "je pense que"
reponse_je_pense_que(Rest, Response) :-
    string_concat("Pourquoi pensez-vous que ", Rest, R1),
    string_concat("Qu'est-ce qui vous fait croire que ", Rest, R2),
    string_concat("Avez-vous des preuves que ", Rest, R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "j'ai envie de"
reponse_envie_de(Rest, Response) :-
    string_concat("Qu'est-ce qui vous donne envie de ", Rest, R1),
    string_concat("Depuis quand avez-vous envie de ", Rest, R2),
    string_concat("Comment vous sentiriez-vous après avoir ", Rest, R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "j'ai peur de"
reponse_peur_de(Rest, Response) :-
    string_concat("Qu'est-ce qui vous fait peur dans le fait de ", Rest, R1),
    string_concat("Cette peur de ", Rest, " est-elle presente depuis longtemps ?", R2),
    string_concat("Comment cette peur de ", Rest, " vous affecte-t-elle ?", R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "je veux"
reponse_je_veux(Rest, Response) :-
    string_concat("Pourquoi voulez-vous ", Rest, R1),
    string_concat("Que se passerait-il si vous obteniez ", Rest, R2),
    string_concat("Qu'est-ce qui vous empêche d'avoir ", Rest, R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "parce que"
reponse_parce_que(Rest, Response) :-
    string_concat("Est-ce la seule raison : ", Rest, R1),
    string_concat("Y a-t-il d'autres raisons que ", Rest, R2),
    R3 = "Cette explication vous satisfait-elle ?",
    random_select([R1, R2, R3], Response).

% Reponses pour "vous"
reponse_vous(Rest, Response) :-
    R1 = "Nous parlons de vous, pas de moi.",
    string_concat("Pourquoi pensez-vous que je ", Rest, R2),
    R3 = "Qu'est-ce qui vous fait dire cela ?",
    random_select([R1, R2, R3], Response).

% Reponses pour "ma mere"
reponse_ma_mere(Rest, Response) :-
    string_concat("Parlez-moi plus de votre mere qui ", Rest, R1),
    R2 = "Quelle est votre relation avec votre mere ?",
    R3 = "Comment vous sentez-vous vis-a-vis de votre mere ?",
    random_select([R1, R2, R3], Response).

% Reponses pour "mon pere"
reponse_mon_pere(Rest, Response) :-
    string_concat("Parlez-moi plus de votre pere qui ", Rest, R1),
    R2 = "Quelle est votre relation avec votre pere ?",
    R3 = "Comment vous sentez-vous vis-a-vis de votre pere ?",
    random_select([R1, R2, R3], Response).

% Reponses pour "toujours"
reponse_toujours(Response) :-
    Responses = [
        "Pouvez-vous penser a un exemple precis ?",
        "Vraiment ? Toujours ?",
        "N'y a-t-il jamais eu d'exceptions ?"
    ],
    random_select(Responses, Response).

% Reponses pour "jamais"
reponse_jamais(Response) :-
    Responses = [
        "Jamais est un mot tres fort. Êtes-vous certain ?",
        "Il n'y a vraiment eu aucune occasion où cela s'est produit ?",
        "Qu'est-ce qui vous fait dire jamais ?"
    ],
    random_select(Responses, Response).

% Reponses pour "j'aime"
reponse_jaime(Rest, Response) :-
    string_concat("Qu'est-ce qui vous plaît particulierement dans ", Rest, R1),
    string_concat("Depuis quand aimez-vous ", Rest, R2),
    string_concat("Qu'est-ce que ", Rest, " vous apporte ?", R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "je deteste"
reponse_je_deteste(Rest, Response) :-
    string_concat("Pourquoi detestez-vous ", Rest, R1),
    string_concat("Qu'est-ce qui vous deplaît dans ", Rest, R2),
    string_concat("Cette aversion pour ", Rest, " a-t-elle toujours ete presente ?", R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "je rêve de"
reponse_je_reve_de(Rest, Response) :-
    string_concat("Que symbolise pour vous le fait de ", Rest, R1),
    string_concat("Qu'est-ce qui vous empêche de ", Rest, R2),
    string_concat("Que ressentiriez-vous si vous pouviez ", Rest, R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "je doute"
reponse_je_doute(Rest, Response) :-
    string_concat("D'où viennent ces doutes concernant ", Rest, R1),
    R2 = "Qu'est-ce qui pourrait vous aider a surmonter ces doutes ?",
    R3 = "Le doute est normal. Comment y faites-vous face habituellement ?",
    random_select([R1, R2, R3], Response).

% Reponses pour "je me demande"
reponse_je_me_demande(Rest, Response) :-
    string_concat("Qu'est-ce qui vous fait vous interroger sur ", Rest, R1),
    string_concat("Avez-vous cherche des reponses concernant ", Rest, R2),
    R3 = "C'est une question interessante. Qu'en pensez-vous ?",
    random_select([R1, R2, R3], Response).

% Reponses pour "je crois"
reponse_je_crois(Rest, Response) :-
    string_concat("Qu'est-ce qui vous amene a croire ", Rest, R1),
    string_concat("Cette croyance en ", Rest, " est-elle recente ?", R2),
    R3 = "Quelles experiences ont faconne vos croyances ?",
    random_select([R1, R2, R3], Response).

% Reponses pour "je ne peux pas"
reponse_je_ne_peux_pas(Rest, Response) :-
    string_concat("Qu'est-ce qui vous empêche de ", Rest, R1),
    string_concat("Avez-vous deja essaye de ", Rest, R2),
    string_concat("Que se passerait-il si vous pouviez ", Rest, R3),
    random_select([R1, R2, R3], Response).

% Reponses pour "mon ami"
reponse_mon_ami(Rest, Response) :-
    R1 = "Les amities sont importantes. Parlez-moi davantage de cette relation.",
    string_concat("Comment cette amitie influence-t-elle votre vie quand votre ami ", Rest, R2),
    R3 = "Depuis combien de temps connaissez-vous cette personne ?",
    random_select([R1, R2, R3], Response).

% Reponses pour "ma famille"
reponse_ma_famille(Rest, Response) :-
    R1 = "La famille joue souvent un rôle crucial dans notre developpement.",
    string_concat("Comment vous sentez-vous par rapport a votre famille quand elle ", Rest, R2),
    R3 = "Pouvez-vous me parler davantage de vos relations familiales ?",
    random_select([R1, R2, R3], Response).

% Fonction auxiliaire pour verifier si une chaîne contient un motif
contains(Texte, Pattern, Suite) :-
    string_concat(_, Temp, Texte),
    string_concat(Pattern, Suite2, Temp),
    string_concat(" ", Suite, Suite2).

% Fonction pour selectionner une reponse aleatoire dans une liste
random_select(List, Element) :-
    length(List, L),
    random(0, L, Index),
    nth0(Index, List, Element).

% Reponses par defaut si aucun motif n est reconnu
random_response(Response) :- 
    Responses = [
        "Pouvez-vous developper davantage ?",
        "Je comprends. Continuez, je vous ecoute.",
        "Dites-m'en plus a ce sujet.",
        "Comment vous sentez-vous quand vous dites cela ?",
        "Cela semble important pour vous.",
        "Et ensuite ?",
        "Qu'est-ce que cela evoque pour vous ?",
        "Au fond comment vous sentez vous ?"
    ],
    random_select(Responses, Response).

% Pour demarrer ELIZA
:- start_eliza.