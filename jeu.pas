Unit jeu;

interface

Uses types,affichage,traitement,sysutils;

procedure menu();

implementation

// Effectue un tour
procedure tour(var plat: plateau; var fenetre: PWindow; var renderer: PRenderer; taille, nbrTour: Integer; var nbrCase: Integer);
var 
	i1, j1, i2, j2: Integer;
begin
	// Interaction pour la première case
	repeat
		interactionPlat(taille, i1, j1);
	until not isVisible(plat, i1, j1);  

	setVisible(plat, i1, j1, true);
	affichagePlateau(plat, fenetre, renderer, taille, nbrTour);

	// Interaction pour la deuxième case
	repeat
		interactionPlat(taille, i2, j2);
	until interactionValide(plat, i2, j2);  
	
	setVisible(plat, i2, j2, true);
	affichagePlateau(plat, fenetre, renderer, taille, nbrTour);

	// Vérification si les deux cases sont identiques
	if not verification(plat, i1, j1, i2, j2) then
	begin
		attendre(750);  
		// Rendre les cases non visibles si elles ne sont pas identiques
		setVisible(plat, i1, j1, false);
		setVisible(plat, i2, j2, false);

		affichagePlateau(plat, fenetre, renderer, taille, nbrTour);
	end
	else
		nbrCase := nbrCase + 2;
end;


// Lance un nouvelle partie
procedure partie();
var 
	plat: Plateau;
	stop: boolean;
	nbrTour, nbrCase: Integer;
	nom: string;
	fenetre: PWindow;
	renderer: PRenderer;
	taille: Integer;
	difficile: boolean;
begin
	// Demande la difficile à l'utilisateur
	difficile := getDifficult();
	
	// Cree le plateau en fonction du niveau de difficulte
	plat := creePlateau(difficile);
	
	// Demande le nom du joueur à l'utilisateur
	nom := getNom();
	
	nbrTour := 0;
	nbrCase := 0;
	stop := false;

	initialisationAffichagePlateau(plat, fenetre, renderer, taille);
	while not stop do
	begin
		affichagePlateau(plat, fenetre, renderer, taille, nbrTour);

		nbrTour := nbrTour + 1;

		tour(plat, fenetre, renderer, taille, nbrTour, nbrCase);
		if (nbrCase = plat.length * plat.length) then
		begin
			// Arrete le jeu si toutes les cases sont remplies
			stop := true;
			nettoyagePlateau(plat, fenetre, renderer, nbrTour);
			sauvegardeScore(nom, nbrTour, difficile);
		end;
	end;
end;


// Ouvre le menu
procedure menu();
var 
	val: integer;
begin
	repeat
		val := demanderChoix();

		case val of 
			1: partie();  
			2: afficherMeilleurScore(getDifficult());  
		end;
	until (val < 1) or (val >= 3);  // Sort de la boucle si l'utilisateur choisit d'arreter
end;

end.
