unit affichage;

interface

uses types,sdl2,sdl2_image,sdl2_ttf,sysutils,traitement;

procedure initialisationAffichagePlateau(var plat:Plateau;var fenetre:PWindow;var renderer : PRenderer;var taille:Integer);
procedure affichagePlateau(plat:Plateau;var fenetre:PWindow;var renderer : PRenderer;taille,nbrTour:Integer);
procedure interactionPlat(taille:Integer;var i,j:Integer);
procedure nettoyagePlateau(plat:Plateau;var fenetre:PWindow;var renderer:PRenderer;nbrTour:Integer);
procedure attendre(n:LongInt);
function getDifficult():boolean;
function getNom():String;
procedure afficherMeilleurScore(difficile: Boolean);
function demanderChoix():Integer;

implementation

// Permet de charger la texture de l'image
function chargerTexture(renderer : PSDL_Renderer;filename : String): PSDL_Texture;
var image : PSDL_Texture;
	chemin : AnsiString;
begin
	// Construit le chemin complet du fichier image
	chemin := 'Images/' + filename + '.png';

	image := IMG_LoadTexture(renderer, PChar(chemin));
	
	// Verifie si le chargement a réussi
	if image = nil then
		writeln('Could not load image : ',IMG_GetError);
	
	chargerTexture := image;
end;

// Permet de charger toutes les textures du plateau
procedure chargerTextures(var plat:Plateau;renderer:PRenderer);
var card : Carte;
	i,j:Integer;
begin
	// Parcours de toutes les cartes du plateau
	for i:=1 to plat.length do
		for j:=1 to plat.length do
			begin
				card := getCase(plat,i,j);
				card.texture := chargerTexture(renderer,card.valeur);
				setCase(plat,i,j,card);
			end;
	
	// Chargement de la texture du dos des cartes
	plat.dos := IMG_LoadTexture(renderer,'Images/dos.png');
	if plat.dos = nil then
		writeln('Could not load image : ',IMG_GetError);
end;

// Initialise la bibliotheque SDL2
procedure initialisationSDL(var sdlwindow:PWindow; var sdlRenderer:PRenderer);
begin
	SDL_Init(SDL_INIT_VIDEO);
	
	SDL_CreateWindowAndRenderer(WINDOW_W,WINDOW_H,SDL_WINDOW_SHOWN,@sdlwindow,@sdlRenderer);
end;

// Initialise l'affichage du plateau et defini les variables des cartes
procedure initialisationAffichagePlateau(var plat:Plateau;var fenetre:PWindow;var renderer : PRenderer;var taille:Integer);
begin
	// Défini la taille des cartes
	if plat.length = 4 then
		taille := 240
	else
		taille := 160;
	
	initialisationSDL(fenetre,renderer);
	
	chargerTextures(plat,renderer);
end;

// Affiche la carte en i,j
procedure affichageCarte(plat:Plateau;i,j:Integer;var fenetre:PWindow;var renderer : PRenderer;taille:Integer);
var card : Carte;
	destination_rect:TSDL_RECT;
begin
	card := getCase(plat,i,j);
	
	// Définit le carre de destination pour l'affichage de la carte
	destination_rect.x:=(i-1)*taille;
	destination_rect.y:=(j-1)*taille;
	destination_rect.w:=taille;
	destination_rect.h:=taille;
	
	if card.visible then
		SDL_RenderCopy(renderer,card.texture,nil,@destination_rect)
	else
		SDL_RenderCopy(renderer,plat.dos,nil,@destination_rect);
end;

// Transforme du texte en une texture
function LoadTextureFromText(renderer:PRenderer; police:PTTF_Font; text:String;color:TSDL_Color):PSDL_Texture;
var surface : PSDL_Surface;
	texture : PSDL_Texture;
	text_compa : Ansistring;
begin
	text_compa := text;
	surface := TTF_RenderText_Solid(police,PChar(text_compa),color);
	
	// Cree une surface SDL contenant le texte rendu avec la police specifiee et la couleur donnee
	texture := SDL_CreateTextureFromSurface(renderer,surface);
	
	LoadTextureFromText := texture;
end;

// Ecrit le texte avec les parametres en entree
procedure ecrireTexte(var renderer:PRenderer;txt:String;x,y,w,h,taille:Integer);
var police:PTTF_Font;
	texteTexture:PSDL_Texture;
	couleur : TSDL_Color;
	textRect : TSDL_Rect;
begin
	// Definit le rectangle de destination pour le texte
	textRect.x := x;
	textRect.y := y;
	textRect.w := w;
	textRect.h := h;
	
	if TTF_INIT=-1 then halt;
	
	couleur.r:=255;
	couleur.g:= 255;
	couleur.b:=255;
	couleur.a:=255;
	
	police := TTF_OpenFont('OpenSans-Regular.ttf',taille);
	
	texteTexture := LoadTextureFromText(renderer,police,txt,couleur);
	SDL_QueryTexture(texteTexture,nil,nil,@textRect.w,@textRect.h);
	
	SDL_RenderCopy(renderer,texteTexture,nil,@textRect);
	
	TTF_CloseFont(police);
	TTF_Quit();
	SDL_DestroyTexture(texteTexture);
end;

// Affiche le plateau en entree
procedure affichagePlateau(plat:Plateau;var fenetre:PWindow;var renderer : PRenderer;taille,nbrTour:Integer);
var i,j : Integer;
	texte : String;
begin
	SDL_RenderClear(renderer);
	
	// Parcours toutes les cartes du plateau
	for i:=1 to plat.length do
		for j:=1 to plat.length do
		begin
			affichageCarte(plat,i,j,fenetre,renderer,taille);
		end;
	
	texte := 'Tour : '+IntToStr(nbrTour);
	
	// Ecrit le texte avec les parametres entrees
	ecrireTexte(renderer,texte,WINDOW_W div 2 - 100,960,960,200,35);
	
	SDL_RenderPresent(renderer);
end;

// Calcul des indices de la carte sur laquelle la souris a clique
procedure gestionSouris(mouseEvent:TSDL_MouseButtonEvent;taille:Integer;var i,j:Integer);
begin
	i := (mouseEvent.x div taille) + 1;
	j := (mouseEvent.y div taille) + 1;
end;

// Met en pause l'execution du programme pendant n millisecondes
procedure attendre(n:LongInt);
begin
	SDL_Delay(n);
end;

procedure interactionPlat(taille:Integer;var i,j:Integer);
var event:TSDL_Event;
	suite : Boolean;
	b:Integer;
begin
	// Boucle de gestion des événements SDL
	repeat
		suite := false;
		attendre(10);
		for b:=1 to 10 do
		begin
			SDL_PollEvent(@event);
			
			if event.type_ = SDL_MOUSEBUTTONDOWN then
			begin
				gestionSouris(event.button,taille,i,j);
				suite := true;
			end;
		end;
	until suite;
end;

// Libere la memoire utilisee par les textures des cartes et du dos des cartes
procedure nettoyagePlateau(plat:Plateau;var fenetre:PWindow;var renderer:PRenderer;nbrTour:Integer);
var i,j:Integer;
	card : Carte;
	texteTour,texteScore : String;
begin
	for i:=1 to plat.length do
		for j:=1 to plat.length do
		begin
			card := getCase(plat,i,j);
			SDL_DestroyTexture(card.texture);
			setCase(plat,i,j,card);
		end;
	SDL_DestroyTexture(plat.dos);
	
	SDL_RenderClear(renderer);
	
	texteTour := 'Vous avez fini en '+IntToStr(nbrTour)+' tours !';
	texteScore := 'Score : '+IntToStr(nbrTour);
	ecrireTexte(renderer,texteTour,WINDOW_W div 2 - 400,WINDOW_H div 2 - 100,960,200,35);
	ecrireTexte(renderer,texteScore,WINDOW_W div 2 - 400,WINDOW_H div 2,960,200,35);
	
	SDL_RenderPresent(renderer);
	
	attendre(3500);
	
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(fenetre);
	IMG_Quit();
	SDL_Quit();
end;

// Recupere la difficulte
function getDifficult(): Boolean;
var
  val: String;
  difficile: Boolean;
begin
	// Demande a l'utilisateur de choisir la difficulte jusqu'a ce qu'une entree valide soit saisie
	repeat
		writeln('Quelle difficulté souhaitez-vous ? f = facile, d = difficile');
		readln(val);
		difficile := false;

		// Verifie si l'utilisateur a saisi 'd' pour choisir la difficulte difficile
		if (val = 'd') then
		difficile := true;

	until (val = 'f') or (val = 'd');

	getDifficult := difficile;
end;

// Recupere le nom du joueur
function getNom(): String;
begin
	writeln('Quel est votre nom ?');
	readln(getNom);
end;

// Affiche les meilleurs scores
procedure afficherMeilleurScore(difficile: Boolean);
var
	joueurs: Tjoueur;
	i: Integer;
	fichier: String;
begin
	// Determine le chemin du fichier en fonction de la difficulte
	if (difficile) then
		fichier := PATH_FACILE_SAVE_SCORES
	else
		fichier := PATH_DIFFICILE_SAVE_SCORES;

	// Verifie si le fichier de scores existe
	if (fileExists(fichier)) then
	begin
		joueurs := lireScore(difficile);
		// Affiche les scores sauvegardes
		for i := 1 to joueurs.length do
		begin
			write(i);
			write('/ ');
			write(getJoueur(joueurs, i).nom);
			write(' avec un score de : ');
			writeln(getJoueur(joueurs, i).score);
		end;
	end
	else
		writeln('Il n''y a pas encore de scores sauvegardés');
end;

// Affiche le menu de choix
function demanderChoix():Integer;
begin
	writeln('Que voulez-vous faire ? : ');
    writeln('1/ Faire une partie');
    writeln('2/ Regarder le tableau des scores');
    writeln('3/ Arrêter');
    readln(demanderChoix);
end;

end.

