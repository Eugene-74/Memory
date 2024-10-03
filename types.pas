unit types;

interface

uses SDL2, SDL2_image;

Const 
	TAILLE_PLATEAU_FACILE = 4;
	TAILLE_PLATEAU_DIFFICILE = 6;
	MAX_SAVED_SCORE = 5;
	PATH_FACILE_SAVE_SCORES = 'scores facile.dat';
	PATH_DIFFICILE_SAVE_SCORES = 'scores difficile.dat';
	WINDOW_W = 960;
	WINDOW_H = 1160;

Type Cases = (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R);

Type Carte = record
	visible : Boolean;
	valeur : String;
	texture : PSDL_Texture;
end;

Type Joueur = record
	nom : String;
	score : Integer;
end;

Type PWindow = PSDL_Window;

Type PRenderer = PSDL_Renderer;

Type Plateau = record
	tableau : Array of Array of Carte;
	length : Integer;
	dos : PSDL_Texture;
end;

Type Tjoueur = record
	tableau : Array of Joueur;
	length : Integer;
end;

implementation

end.