-- SQL Server Script
-- Model: New Model    Version: 1.0

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'projet1')
BEGIN
    EXEC('CREATE SCHEMA projet1');
END;

USE projet1;
GO

-- Table Utilisateur
CREATE TABLE projet1.Utilisateur (
    UtilisateurID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Pseudo VARCHAR(45) NOT NULL,
    DateInscription DATE NOT NULL,
    Age INT NOT NULL,
    Sexe INT NOT NULL
);

-- Table Createurs
CREATE TABLE projet1.Createurs (
    CreateurID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nom VARCHAR(45) NOT NULL,
    Prenom VARCHAR(45) NOT NULL
);

-- Table Producteurs
CREATE TABLE projet1.Producteurs (
    ProducteurID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nom VARCHAR(45) NOT NULL,
    Prenom VARCHAR(45) NOT NULL
);


-- Table Series
CREATE TABLE projet1.Series (
    SerieID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Titre VARCHAR(45) NOT NULL,
    Annee INT NOT NULL,
    PaysOrigine VARCHAR(45) NOT NULL,
    DateCreation DATE NOT NULL,
    Createurs_Createur INT NOT NULL,
    Producteurs_Producteur INT NOT NULL,
    CONSTRAINT fk_Series_Createurs1 FOREIGN KEY (Createurs_Createur) REFERENCES projet1.Createurs (CreateurID),
    CONSTRAINT fk_Series_Producteurs1 FOREIGN KEY (Producteurs_Producteur) REFERENCES projet1.Producteurs (ProducteurID)
);

-- Table Genres
CREATE TABLE projet1.Genres (
    GenreID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    NomGenre VARCHAR(45) NOT NULL
);

-- Table Genres_has_Series
CREATE TABLE projet1.Genres_has_Series (
    Genres_Genre INT NOT NULL,
    Series_Serie INT NOT NULL,
    PRIMARY KEY (Genres_Genre, Series_Serie),
    CONSTRAINT fk_Genres_has_Series_Genres1 FOREIGN KEY (Genres_Genre) REFERENCES projet1.Genres (GenreID),
    CONSTRAINT fk_Genres_has_Series_Series1 FOREIGN KEY (Series_Serie) REFERENCES projet1.Series (SerieID)
);

-- Table Realisateurs
CREATE TABLE projet1.Realisateurs (
    RealisateurID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nom VARCHAR(45) NOT NULL,
    Prenom VARCHAR(45) NOT NULL
);

-- Table Acteurs
CREATE TABLE projet1.Acteurs (
    ActeurID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nom VARCHAR(45) NOT NULL,
    Prenom VARCHAR(45) NOT NULL
);

-- Table Episodes
CREATE TABLE projet1.Episodes (
    EpisodeID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Titre VARCHAR(45) NOT NULL,
    Duree INT NOT NULL,
    DateDiffusion DATE NOT NULL,
    Resume VARCHAR(max) NOT NULL,
    NumeroSaison INT NOT NULL,
    Series_Serie INT NOT NULL,
    Realisateurs_Realisateur INT NOT NULL,
    Acteurs_Acteur INT NOT NULL,
    CONSTRAINT fk_Episodes_Series1 FOREIGN KEY (Series_Serie) REFERENCES projet1.Series (SerieID),
    CONSTRAINT fk_Episodes_Realisateurs1 FOREIGN KEY (Realisateurs_Realisateur) REFERENCES projet1.Realisateurs (RealisateurID),
    CONSTRAINT fk_Episodes_Acteurs1 FOREIGN KEY (Acteurs_Acteur) REFERENCES projet1.Acteurs (ActeurID)
);

-- Table Notes
CREATE TABLE projet1.Notes (
    Note INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    NmbNote INT NOT NULL,
    Commentaire VARCHAR(45) NOT NULL,
    DateNote DATE NOT NULL,
    Utilisateur_Utilisateur INT NOT NULL,
    Series_Serie INT NULL,
    Episodes_Episode INT NULL,
    CONSTRAINT fk_Notes_Utilisateur1 FOREIGN KEY (Utilisateur_Utilisateur) REFERENCES projet1.Utilisateur (UtilisateurID),
    CONSTRAINT fk_Notes_Series1 FOREIGN KEY (Series_Serie) REFERENCES projet1.Series (SerieID),
    CONSTRAINT fk_Notes_Episodes1 FOREIGN KEY (Episodes_Episode) REFERENCES projet1.Episodes (EpisodeID)
);

-- Table Forums
CREATE TABLE projet1.Forums (
    ForumID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Titre VARCHAR(45) NOT NULL,
    Series_Serie INT NOT NULL,
    CONSTRAINT fk_Forums_Series1 FOREIGN KEY (Series_Serie) REFERENCES projet1.Series (SerieID)
);

-- Table Messages
CREATE TABLE projet1.Messages (
    MessageID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Texte VARCHAR(45) NOT NULL,
    DateEnvoi DATE NOT NULL,
    Utilisateur_Utilisateur INT NOT NULL,
    Forums_Forum INT NULL,
    reponse INT NULL,
    FirstMessage TINYINT NOT NULL,
    CONSTRAINT fk_Messages_Utilisateur1 FOREIGN KEY (Utilisateur_Utilisateur) REFERENCES projet1.Utilisateur (UtilisateurID),
    CONSTRAINT fk_Messages_Forums1 FOREIGN KEY (Forums_Forum) REFERENCES projet1.Forums (ForumID),
    CONSTRAINT fk_Messages_Messages1 FOREIGN KEY (reponse) REFERENCES projet1.Messages (MessageID)
);
