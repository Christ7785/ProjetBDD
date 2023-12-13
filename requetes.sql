use projet1;
GO



-- Quel est la liste des séries de la base ?
SELECT Titre FROM projet1.Series;

--Combien de pays différents ont créé des séries dans notre base ?
SELECT COUNT(DISTINCT PaysOrigine) FROM projet1.Series;

--Quels sont les titres des séries originaires du Japon, triés par titre ?
SELECT Titre FROM projet1.Series WHERE PaysOrigine = 'JP' ORDER BY Titre;

--Combien y a-t-il de séries originaires de chaque pays ?
SELECT PaysOrigine, COUNT(*) AS NombreSeries FROM projet1.Series GROUP BY PaysOrigine;

--Combien de séries ont été créés entre 2001 et 2015?
SELECT COUNT(*) AS NombAnnee FROM projet1.Series WHERE Annee BETWEEN 2001 AND 2015;

--Quelles séries sont à la fois du genre « Comédie » et « Science-Fiction » ?
SELECT S.Titre 
FROM projet1.Series S
JOIN projet1.Genres_has_Series GHS ON S.SerieID = GHS.Series_Serie
JOIN projet1.Genres G ON GHS.Genres_Genre = G.GenreID
WHERE G.NomGenre IN ('Comedy', 'Science Fiction')
GROUP BY S.Titre

--Quels sont les séries produites par « Spielberg », affichés par date décroissantes ?
SELECT DISTINCT S.Titre, S.DateCreation 
FROM projet1.Series S
 JOIN projet1.Producteurs P ON S.Producteurs_Producteur = P.ProducteurID
WHERE P.Nom = 'Spielberg'
ORDER BY S.DateCreation DESC ;

--Afficher les séries Américaines par ordre de nombre de saisons croissant.
SELECT S.Titre, COUNT(DISTINCT E.NumeroSaison) AS NombreSaisons
FROM projet1.Series S
JOIN projet1.Episodes E ON S.SerieID = E.Series_Serie
WHERE S.PaysOrigine = 'USA'
GROUP BY S.Titre
ORDER BY NombreSaisons ASC;


--Quelle série a le plus d’épisodes ?
SELECT TOP 1 S.Titre, COUNT(*) AS NombreEpisodes
FROM projet1.Series S
JOIN projet1.Episodes E ON S.SerieID = E.Series_Serie
GROUP BY S.Titre
ORDER BY NombreEpisodes DESC;

--La série « Big Bang Theory » est-elle plus appréciée des hommes ou des femmes ?
SELECT U.Sexe,
       AVG(N.Note) AS MoyenneNotes
FROM projet1.Notes N
JOIN projet1.Utilisateur U ON N.Utilisateur_Utilisateur = U.UtilisateurID
JOIN projet1.Series S ON N.Series_Serie = S.SerieID
WHERE S.Titre = 'Big Bang Theory'
GROUP BY U.Sexe;

--Affichez les séries qui ont une note moyenne inférieure à 5, classé par note.
SELECT S.Titre, AVG(Note) AS NoteMoyenne
FROM projet1.Notes N
JOIN projet1.Series S ON S.SerieID = N.Series_Serie
GROUP BY Titre
HAVING AVG(Note) < 5
ORDER BY NoteMoyenne;

--Pour chaque série, afficher le commentaire correspondant à la meilleure note.
SELECT DISTINCT
    Series_Serie AS SerieID,
    FIRST_VALUE(Commentaire) OVER (PARTITION BY Series_Serie ORDER BY Note DESC) AS MeilleurCommentaire
FROM projet1.Notes;


--Affichez les séries qui ont une note moyenne sur leurs épisodes supérieure à 8.
SELECT S.Titre, AVG(N.Note) AS NoteMoyenne
FROM projet1.Series S
JOIN projet1.Notes N ON S.SerieID = N.Series_Serie
GROUP BY S.Titre
HAVING AVG(N.Note) > 8;

--Afficher le nombre moyen d’épisodes des séries avec l’acteur « Bryan Cranston ».
SELECT AVG(Compte) AS MoyenneEpisodes
FROM (SELECT COUNT(*) AS Compte
      FROM projet1.Episodes E
      JOIN projet1.Acteurs A ON E.Acteurs_Acteur = A.ActeurID
      WHERE A.Nom = 'Cranston' AND A.Prenom = 'Bryan'
      GROUP BY E.Series_Serie) AS SubQuery;

--Quels acteurs ont réalisé des épisodes de série ?
SELECT DISTINCT A.Nom, A.Prenom
FROM projet1.Acteurs A
JOIN projet1.Episodes E ON E.Realisateurs_Realisateur = A.ActeurID;

--Quels acteurs ont joué ensemble dans plus de 80% des épisodes d’une série ? 
GO
CREATE VIEW TotalEpisodesPerSeries AS
SELECT Series_Serie, COUNT(*) AS TotalEpisodes
FROM projet1.Episodes
GROUP BY Series_Serie;
GO

CREATE VIEW ActorPairsPerEpisode AS
SELECT E1.Series_Serie, E1.EpisodeID, E1.Acteurs_Acteur AS Actor1, E2.Acteurs_Acteur AS Actor2
FROM projet1.Episodes E1
JOIN projet1.Episodes E2 ON E1.Series_Serie = E2.Series_Serie AND E1.EpisodeID = E2.EpisodeID AND E1.Acteurs_Acteur <= E2.Acteurs_Acteur;

GO
CREATE VIEW ActorPairCounts AS
SELECT Series_Serie, Actor1, Actor2, COUNT(*) AS EpisodesTogether
FROM ActorPairsPerEpisode
GROUP BY Series_Serie, Actor1, Actor2;

GO

SELECT AP.Series_Serie, A1.Nom AS Actor1Name, A2.Nom AS Actor2Name, AP.EpisodesTogether, TE.TotalEpisodes
FROM ActorPairCounts AP
JOIN TotalEpisodesPerSeries TE ON AP.Series_Serie = TE.Series_Serie
JOIN projet1.Acteurs A1 ON AP.Actor1 = A1.ActeurID
JOIN projet1.Acteurs A2 ON AP.Actor2 = A2.ActeurID
WHERE CAST(AP.EpisodesTogether AS FLOAT) / TE.TotalEpisodes > 0.8;

--Quels acteurs ont joué dans tous les épisodes de la série « Breaking Bad » ?
SELECT A.Nom, A.Prenom
FROM projet1.Acteurs A
JOIN projet1.Episodes E ON E.Acteurs_Acteur = A.ActeurID
WHERE E.Series_Serie = (SELECT SerieID FROM projet1.Series WHERE Titre = 'Breaking Bad');

--Quels utilisateurs ont donné une note à chaque série de la base ?
CREATE VIEW TotalSeriesCount AS
SELECT COUNT(*) AS TotalSeries
FROM projet1.Series;

CREATE VIEW UserSeriesRatingCount AS
SELECT U.UtilisateurID, U.Pseudo, COUNT(DISTINCT S.SerieID) AS RatedSeries
FROM projet1.Utilisateur U
JOIN projet1.Notes N ON U.UtilisateurID = N.Utilisateur_Utilisateur
JOIN projet1.Series S ON N.Series_Serie = S.SerieID
GROUP BY U.UtilisateurID, U.Pseudo;

SELECT U.Utilisateur
FROM UserSeriesRatingCount U, TotalSeriesCount T
WHERE U.RatedSeries = T.TotalSeries;

--Pour chaque message, affichez son niveau et si possible le titre de la série en question.
SELECT M.MessageID, M.Niveau, S.Titre
FROM projet1.Messages M
JOIN Series S ON M.Series_Serie = S.Serie;

--Les messages initiés par « Azrod95 » génèrent combien de réponses en moyenne ?
SELECT AVG(Compte) AS MoyenneReponses
FROM (SELECT COUNT(*) AS Compte
      FROM Messages
      WHERE ParentId IN (SELECT MessageId FROM Messages WHERE Utilisateur = 'Azrod95')
      GROUP BY ParentId) AS SubQuery;