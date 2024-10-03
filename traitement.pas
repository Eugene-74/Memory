unit traitement;

interface

uses Types,TypInfo,sysutils;

function getCase(plat : plateau ; i,j: Integer):carte;
procedure setCase(var plat : plateau ; i,j: Integer ;car : carte);
procedure setJoueur(var joueurs : Tjoueur ; i: Integer ;jou : Joueur);
function getJoueur(joueurs : Tjoueur ; i: Integer):Joueur;
function lireScore(difficile : boolean):Tjoueur;
function EnumToString(val:Cases):String;
procedure setVisible(plat : plateau;i,j: integer;visible : boolean);
function isVisible(plat : plateau; i,j : Integer):boolean;
function verification(plat : plateau; i1,j1,i2,j2 : Integer):boolean;
function creePlateau(difficile : boolean): Plateau;
function interactionValide(plat : plateau ;i2,j2 : Integer): boolean;
procedure sauvegardeScore(nom: String; score: Integer; difficile: boolean);

implementation

// Convertit l'enumération en chaine de caracteres
function EnumToString(val: Cases): String;
begin
	EnumToString := GetEnumName(TypeInfo(Cases), Ord(val));
end;

// Definit la case du plateau a l'index (i-1, j-1) avec la valeur de la carte
procedure setCase(var plat: plateau; i, j: Integer; car: carte);
begin
	plat.tableau[i-1][j-1] := car;
end;


// Renvoie la carte située à l'index (i-1, j-1) dans le plateau
function getCase(plat: plateau; i, j: Integer): carte;
begin
	getCase := plat.tableau[i - 1][j - 1];
end;


// Lit et renvoie les 5 meuilleurs scores en fonction de la diffuculte
function lireScore(difficile : boolean): Tjoueur;
var 
	fichier: file of joueur;
	j: joueur;
	i: Integer;
	list: array of joueur;
	joueursL: Tjoueur;
	nomFichier : String;
begin
	
	joueursL.length := 0;
	i := 1;

	if difficile then
		nomFichier := PATH_FACILE_SAVE_SCORES
	else
		nomFichier := PATH_DIFFICILE_SAVE_SCORES;

	assign(fichier, nomFichier);
	reset(fichier);
	while not eof(fichier) do 
	begin
		read(fichier, j);
		joueursL.length := joueursL.length + 1;
		setlength(list, joueursL.length);
		list[joueursL.length - 1] := j;
		i := i + 1;
	end;
	joueursL.tableau := list;
	lireScore := joueursL;
	close(fichier);
end;


// Affecte le joueur à la position (i-1) dans le tableau de joueurs
procedure setJoueur(var joueurs: Tjoueur; i: Integer; jou: Joueur);
begin
	joueurs.tableau[i - 1] := jou;
end;


// Renvoie le joueur situé à la position (i-1) dans le tableau de joueurs
function getJoueur(joueurs: Tjoueur; i: Integer): Joueur;
begin
	getJoueur := joueurs.tableau[i - 1];
end;


// Renvoie si la carte a la position (i-1, j-1) du plateau est visible
function isVisible(plat: plateau; i, j: Integer): boolean;
begin
	isVisible := false;
	if getCase(plat, i, j).visible then
		isVisible := true;
end;


// Definit la visibilité de la carte a la position (i-1, j-1) sur le plateau
procedure setVisible(plat: plateau; i, j: integer; visible: boolean);
begin
	
	plat.tableau[i - 1][j - 1].visible := visible;
end;

// Verifie si les valeurs des cartes aux positions (i1, j1) et (i2, j2) sont egales
function verification(plat: plateau; i1, j1, i2, j2: integer): boolean;
begin
	verification := false;
	if getCase(plat, i1, j1).valeur = getCase(plat, i2, j2).valeur then
		verification := true;
end;


// Cree le plateau de jeu sous forme d'un tableau dynamique a 2 dimentions
function creePlateau(difficile: boolean): Plateau;
var 
	plat: Plateau;
	length, i, j, x: Integer;
	car: Carte;
	tab: array [Cases] of Integer;
begin
	if difficile then
		length := TAILLE_PLATEAU_DIFFICILE
	else 
		length := TAILLE_PLATEAU_FACILE;

	plat.length := length;
	setLength(plat.tableau, length, length);

	// Initialise le tableau de comptage pour chaque type de carte
	for i := 1 to (length * length) div 2 do 
		tab[Cases(i - 1)] := 0;

	Randomize;

	// Remplit le plateau avec des cartes aleatoires
	for i := 1 to length do
		for j := 1 to length do
		begin
			repeat
				x := Random((length * length) div 2);
			until tab[Cases(x)] < 2;

			tab[Cases(x)] := tab[Cases(x)] + 1;

			car.valeur := EnumToString(Cases(x));
			car.visible := false;

			setCase(plat, i, j, car);
		end;

	creePlateau := plat;
end;

// Verifie si l'interaction avec la carte (i2, j2) est possible
function interactionValide(plat: plateau; i2, j2: Integer): boolean;
begin
	interactionValide := false;

	if not isVisible(plat, i2, j2) then
		interactionValide := true;
end;

// Trie le dernier element du tableau dans l'ordre croissant
procedure trier(var liste: array of joueur; n: integer);
var
	i, j: integer;
	jou: joueur;
begin

	i := n - 1;  
	jou := liste[i]; 
	j := i - 1; 

	// Boucle pour inserer le dernier element à la bonne position dans la partie triee
	while (j >= 0) and (liste[j].score > jou.score) do
	begin
		liste[j + 1] := liste[j];
		j := j - 1;
	end;

	// Place le dernier element à la bonne position
	liste[j + 1] := jou;
end;


// Sauvegarde le score et le nom si il est supperieur a un des anciens meuilleurs scores
procedure sauvegardeScore(nom: String; score: Integer; difficile: boolean);
var
	fichier: file of Joueur;
	j: Joueur;
	joueursL: Tjoueur;
	tab: array of Joueur;
	i: integer;
	nomFichier: String;
begin
	if difficile then
		nomFichier := PATH_FACILE_SAVE_SCORES
	else
		nomFichier := PATH_DIFFICILE_SAVE_SCORES;
    
	assign(fichier, nomFichier);
	if not fileExists(nomFichier) then 
	begin 
		rewrite(fichier);
		close(fichier);
	end;
  
	joueursL := lireScore(difficile);

	j.nom := nom;
	j.score := score;
  
	// Ajout du joueur actuel dans le tableau des scores
	tab := joueursL.tableau;
	setlength(tab, MAX_SAVED_SCORE + 1);
	tab[MAX_SAVED_SCORE] := j;
	trier(tab, MAX_SAVED_SCORE + 1);  
	setlength(tab, MAX_SAVED_SCORE);

	// Reecriture du fichier avec les 5 meilleurs scores
	rewrite(fichier);
	for i := 1 to MAX_SAVED_SCORE do
		if tab[i - 1].score <> 0 then
			write(fichier, tab[i - 1]);
	close(fichier);
end;


end.
