-- Inserting into 'Createurs' (Creators)

GO
INSERT INTO projet1.Createurs ( Nom, Prenom) VALUES
( 'Doe', 'John'),
( 'Smith', 'Jane'),
( 'Jones', 'Emily'),
( 'Williams', 'David'),
( 'Brown', 'Michael'),
( 'Davis', 'Sarah'),
( 'Miller', 'Jessica'),
( 'Wilson', 'Christopher'),
( 'Moore', 'Daniel'),
( 'Taylor', 'Laura');

GO
-- Inserting into 'Producteurs' (Producers)
INSERT INTO projet1.Producteurs ( Nom, Prenom) VALUES
( 'Brown', 'Charlie'),
( 'Wilson', 'Emma'),
( 'Spielberg', 'Steven'),
( 'Martin', 'Amelia'),
( 'Clark', 'Mason'),
( 'Lewis', 'Sophia'),
( 'Walker', 'Ethan'),
( 'Hall', 'Ava'),
( 'Young', 'Alexander');

GO
-- Inserting into 'Acteurs' (Actors)
INSERT INTO projet1.Acteurs ( Nom, Prenom) VALUES
( 'Davis', 'Anthony'),
( 'Miller', 'Sophia'),
( 'Anderson', 'Elijah'),
( 'Taylor', 'Isabella'),
( 'Cranston', 'Bryan'),
( 'Martin', 'Charlotte'),
( 'Jackson', 'James'),
( 'Thompson', 'Harper'),
( 'Garcia', 'Benjamin'),
( 'Martinez', 'Mia');

GO
-- Inserting into 'Realisateurs' (Directors)
INSERT INTO projet1.Realisateurs ( Nom, Prenom) VALUES
( 'Taylor', 'Olivia'),
( 'Moore', 'Liam'),
( 'White', 'Noah'),
( 'Harris', 'Emma'),
( 'Martin', 'Aiden'),
( 'Thompson', 'Lucas'),
( 'Garcia', 'Ava'),
( 'Martinez', 'Isabella'),
( 'Robinson', 'Sophia'),
( 'Clark', 'Mia');

GO
-- Inserting into 'Genres'
INSERT INTO projet1.Genres ( NomGenre) VALUES
( 'Comedy'),
( 'Drama'),
( 'Action'),
( 'Romance'),
( 'Science Fiction'),
( 'Horror'),
( 'Thriller'),
( 'Documentary'),
( 'Animation'),
( 'Musical');

GO
-- Inserting into 'Utilisateur' (Users)
INSERT INTO projet1.Utilisateur ( Pseudo, DateInscription, Age, Sexe) VALUES
( 'User123', '2023-01-01', 25, 1),
( 'User456', '2023-01-02', 30, 2),
( 'CoolUser', '2023-01-03', 22, 1),
( 'StarGazer', '2023-01-04', 28, 2),
( 'MoonWalker', '2023-01-05', 35, 1),
( 'SunShine', '2023-01-06', 29, 2),
( 'RainBow', '2023-01-07', 31, 1),
( 'ThunderStorm', '2023-01-08', 27, 2),
( 'SnowFlake', '2023-01-09', 24, 1),
( 'AutumnLeaves', '2023-01-10', 32, 2);

GO
DBCC CHECKIDENT ('projet1.Series', RESEED, 0);
-- Inserting into 'Series'
INSERT INTO projet1.Series ( Titre, Annee, PaysOrigine, DateCreation, Createurs_Createur, Producteurs_Producteur) VALUES
( 'Big Bang Theory', 2021, 'USA', '2021-06-01', 1, 1),
( 'Serious Talks', 2022, 'UK', '2022-03-15', 2, 2),
( 'Demon Slayer', 2023, 'JP', '2023-07-22', 3, 3),
( 'Tech World', 2021, 'USA', '2021-04-11', 4, 4),
( 'Space Ventures', 2002, 'USA', '2022-05-13', 5, 5),
( 'Historic Times', 2020, 'UK', '2020-09-17', 6, 6),
( 'Animal Kingdom', 2015, 'AUS', '2019-02-27', 7, 7),
( 'Breaking Bad', 2021, 'USA', '2021-11-30', 8, 8),
( 'Sky High', 2023, 'UK', '2023-01-20', 9, 9),
( 'Desert Life', 2022, 'AUS', '2022-08-15', 10, 10);

GO
-- Inserting into 'Genres_has_Series' (Assuming this is a many-to-many relationship table)
INSERT INTO projet1.Genres_has_Series (Genres_Genre, Series_Serie) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

GO
-- Insertion de notes pour la série "Big Bang Theory" (SerieID = 1)
INSERT INTO projet1.Notes ( NmbNote, Commentaire, DateNote, Utilisateur_Utilisateur, Series_Serie, Episodes_Episode) VALUES 
(6, 'Très bien!', '2023-12-10', 1, 2, NULL),
(5, 'Pas mal', '2023-12-11', 2, 1, NULL),
(10, 'Excellent!', '2023-12-12', 1, 3, NULL),
(8, 'Excellent!', '2022-12-11', 2, 1, NULL),
(10, 'Excellent!', '2022-12-11', 3, 2, NULL),
(9, 'Très bien!', '2023-12-10', 3, 3, NULL);

GO

DBCC CHECKIDENT ('projet1.Episodes', RESEED, 0);
-- Episodes for Series 1
INSERT INTO projet1.Episodes ( Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
( 'Beginnings', 40, '2023-01-01', 'The series kicks off with an unexpected event.', 1, 1, 1, 1),
( 'The Journey Starts', 40, '2023-01-08', 'Characters embark on a grand journey.', 1, 1, 2, 2),
( 'Discovery', 40, '2023-01-15', 'A major discovery changes everything.', 1, 1, 3, 3),
( 'Alliances Formed', 40, '2023-01-22', 'New alliances are forged.', 1, 1, 4, 4),
( 'The Great Divide', 40, '2023-01-29', 'The group splits over a disagreement.', 1, 1, 5, 5),
( 'Confrontation', 40, '2023-02-05', 'Tensions come to a head in a dramatic confrontation.', 1, 1, 6, 6),
( 'Revelations', 40, '2023-02-12', 'Secrets are revealed, altering the course of the journey.', 1, 1, 7, 7),
( 'Betrayal', 40, '2023-02-19', 'A betrayal by one of the characters shocks everyone.', 1, 1, 8, 8),
( 'The Chase', 40, '2023-02-26', 'A thrilling chase ensues after a critical event.', 1, 1, 9, 9);


GO
-- Episodes for Series 2
INSERT INTO projet1.Episodes ( Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
( 'New Horizons', 40, '2023-01-01', 'Exploring uncharted territories.', 1, 2, 1, 1),
( 'Troubled Waters', 40, '2023-01-08', 'Navigating through challenges.', 1, 2, 2, 2),
( 'Allies and Enemies', 40, '2023-01-15', 'Determining friend from foe.', 1, 2, 3, 3),
( 'Hidden Agendas', 40, '2023-01-22', 'Uncovering hidden motives.', 1, 2, 4, 4),
( 'Under Siege', 40, '2023-01-29', 'The group faces a siege.', 1, 2, 5, 5),
( 'Breaking Point', 40, '2023-02-05', 'Loyalties are tested.', 1, 2, 6, 6),
( 'Mysteries Unfold', 40, '2023-02-12', 'Unraveling mysteries.', 1, 2, 7, 7),
( 'Shifting Tides', 40, '2023-02-19', 'Fortunes change as the tides shift.', 1, 2, 8, 8),
( 'The Gauntlet', 40, '2023-02-26', 'Facing a formidable challenge.', 1, 2, 9, 9);


GO
-- Episodes for Series 3
INSERT INTO projet1.Episodes ( Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
( 'A New Beginning', 45, '2023-01-01', 'A new threat emerges from the shadows.', 1, 3, 1, 1),
( 'Crossing Paths', 45, '2023-01-08', 'Allies from the past return at a crucial moment.', 1, 3, 2, 2),
( 'The Labyrinth', 45, '2023-01-15', 'The heroes navigate through a perilous maze.', 1, 3, 3, 3),
( 'Shadows and Whispers', 45, '2023-01-22', 'Secrets whispered in the dark come to light.', 1, 3, 4, 4),
( 'Echoes of the Past', 45, '2023-01-29', 'Ancient history reveals new paths to the heroes.', 1, 3, 5, 5),
( 'Forks in the Road', 45, '2023-02-05', 'Difficult choices split the group.', 1, 3, 6, 6),
( 'The Gathering Storm', 45, '2023-02-12', 'A storm brews, promising chaos.', 1, 3, 7, 7),
( 'Dances with Dragons', 45, '2023-02-19', 'Mythic creatures are more than mere legend.', 1, 3, 8, 8),
( 'Ashes to Ashes', 45, '2023-02-26', 'The aftermath of a great battle leaves the group scattered.', 1, 3, 9, 9);


GO
-- Episodes for Series 4
INSERT INTO projet1.Episodes ( Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
( 'Silent City', 45, '2023-01-01', 'The silent city holds many secrets.', 1, 4, 1, 1),
( 'The Oracle’s Vision', 45, '2023-01-08', 'A prophecy foretells an uncertain future.', 1, 4, 2, 2),
( 'Tides of Change', 45, '2023-01-15', 'The tides of magic ebb and flow.', 1, 4, 3, 3),
( 'Fire and Ice', 45, '2023-01-22', 'Elements clash in a land of extremes.', 1, 4, 4, 4),
( 'The Iron Throne', 45, '2023-01-29', 'A battle for the throne begins.', 1, 4, 5, 5),
( 'The Forgotten', 45, '2023-02-05', 'The forgotten ones return to claim whats theirs.', 1, 4, 6, 6),
( 'The Broken Chain', 45, '2023-02-12', 'A chain broken sets off a chain of events.', 1, 4, 7, 7),
( 'Whispers in the West', 45, '2023-02-19', 'Whispers of a new power rising in the west.', 1, 4, 18, 8),
( 'The Siege', 45, '2023-02-26', 'The city under siege holds its breath.', 1, 4, 9, 9);


GO
-- Episodes for Series 5
INSERT INTO projet1.Episodes ( Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
( 'The Enigma', 45, '2023-01-01', 'A puzzle that baffles the mind emerges.', 1, 5, 1, 1),
( 'Lost Time', 45, '2023-01-08', 'The characters grapple with lost time.', 1, 5, 2, 2),
( 'Parallel Worlds', 45, '2023-01-15', 'A discovery of parallel dimensions takes place.', 1, 5, 3, 3),
( 'The Quantum Leap', 45, '2023-01-22', 'A leap through time changes history.', 1, 5, 4, 4),
( 'The Anomaly', 45, '2023-01-29', 'An anomaly in space threatens existence.', 1, 5, 5, 5),
( 'The Void', 45, '2023-02-05', 'The void of space holds a secret.', 1, 5, 6, 6),
( 'Galactic Run', 45, '2023-02-12', 'A race across galaxies ensues.', 1, 5, 7, 7),
( 'Starlight', 45, '2023-02-19', 'A message from the stars is received.', 1, 5, 8, 8),
( 'Celestial Dance', 45, '2023-02-26', 'Celestial events bring awe and wonder.', 1, 5, 9, 9);


GO
-- Episodes for Series 6
INSERT INTO projet1.Episodes ( Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
( 'The Frozen Tundra', 45, '2023-01-01', 'Survival is key in the frozen wilderness.', 1, 6, 1, 1),
( 'The Thaw', 45, '2023-01-08', 'The ice melts, revealing ancient secrets.', 1, 6, 2, 2),
( 'The Expedition', 45, '2023-01-15', 'An expedition to the unknown begins.', 1, 6, 3, 3),
( 'Whiteout', 45, '2023-01-22', 'A whiteout brings danger and disorientation.', 1, 6, 4, 4),
( 'The Frost Giants', 45, '2023-01-29', 'Myths become reality with the appearance of giants.', 1, 6, 5, 5),
( 'The Ice Cavern', 45, '2023-02-05', 'A cavern holds the key to an ancient mystery.', 1, 6, 6, 6),
( 'Subzero', 45, '2023-02-12', 'Temperatures drop, challenging the survivors.', 1, 6, 7, 7),
( 'Polar Night', 45, '2023-02-19', 'The long night tests the human spirit.', 1, 6, 8, 8),
( 'Aurora', 45, '2023-02-26', 'The aurora lights the way to salvation.', 1, 6, 9, 9);


GO
-- Episodes for Series 7
INSERT INTO projet1.Episodes ( Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
( 'The Desert Winds', 45, '2023-01-01', 'The winds uncover more than just sand.', 1, 7, 1, 1),
( 'Mirage', 45, '2023-01-08', 'Visions in the sand lead to confusion.', 1, 7, 2, 2),
( 'The Oasis', 45, '2023-01-15', 'A haven in the desert offers respite and danger.', 1, 7, 3, 3),
( 'Sandstorm', 45, '2023-01-22', 'A sandstorm brings chaos and revelation.', 1, 7, 4, 4),
( 'The Caravan', 45, '2023-01-29', 'A caravan holds the key to an ancient prophecy.', 1, 7, 5, 5),
( 'The Dunes', 45, '2023-02-05', 'Whispers of the past echo through the dunes.', 1, 7, 6, 6),
( 'Sun Scorched', 45, '2023-02-12', 'The scorching sun reveals a hidden curse.', 1, 7, 7, 7),
( 'The Nomads', 45, '2023-02-19', 'Nomads tell tales of a lost city of gold.', 1, 7, 8, 8),
( 'The Pharaoh’s Riddle', 45, '2023-02-26', 'A riddle from the past perplexes the present.', 1, 7, 9, 9);


GO
-- Episodes for Series 8
INSERT INTO projet1.Episodes ( Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
( 'The Jungle’s Heart', 45, '2023-01-01', 'The jungle beats with a heart of its own.', 1, 8, 1, 1),
( 'The Canopy', 45, '2023-01-08', 'Above the jungle floor, a new world awaits.', 1, 8, 2, 2),
( 'Predators', 45, '2023-01-15', 'The hunters and the hunted face off.', 1, 8, 3, 3),
( 'The Hidden Temple', 45, '2023-01-22', 'Ancient ruins hold dark secrets.', 1, 8, 4, 4),
( 'Rituals', 45, '2023-01-29', 'Tribal rituals lead to unexpected consequences.', 1, 8, 5, 5),
( 'The Monsoon', 45, '2023-02-05', 'The rains bring life and death in equal measure.', 1, 8, 6, 6),
( 'Quicksand', 45, '2023-02-12', 'A step off the path leads to a deadly trap.', 1, 8, 7, 7),
( 'The Serpent’s Embrace', 45, '2023-02-19', 'A legendary serpent guards a powerful artifact.', 1, 8, 8, 8),
( 'The Tiger’s Eye', 45, '2023-02-26', 'A tiger’s gaze reveals an untold truth.', 1, 8, 9, 9);


GO
-- Episodes for Series 9
INSERT INTO projet1.Episodes (Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
('City of Lights', 45, '2023-01-01', 'A city that never sleeps holds many secrets.', 1, 9,1,1),
('The Underbelly', 45, '2023-01-08', 'The dark underbelly of the city comes to light.', 1, 9,2,2),
('Neon Dreams', 45, '2023-01-15', 'Dreams are bought and sold under the neon lights.', 1, 9,3,3),
('The Heist', 45, '2023-01-22', 'A heist that could change everything.', 1, 9,4,4),
('The Chase', 45, '2023-01-29', 'A high-speed chase through the city streets.', 1, 9,5,5),
('The Showdown', 45, '2023-02-05', 'A showdown that will be remembered for ages.', 1, 9,6,6),
('The Fall', 45, '2023-02-12', 'A fall from grace, a rise from the ashes.', 1, 9,7,7),
('The Power Play', 45, '2023-02-19', 'A game of power plays out in the shadows.', 1, 9,8,8),
('The Takeover', 45, '2023-02-26', 'A takeover threatens the balance of power.', 1, 9,9,9);


GO
-- Episodes for Series 10
INSERT INTO projet1.Episodes (Titre, Duree, DateDiffusion, Resume, NumeroSaison, Series_Serie, Realisateurs_Realisateur, Acteurs_Acteur) VALUES
('The New World', 45, '2023-01-01', 'Explorers discover a world unlike any other.', 1, 10,1,1),
('Uncharted', 45, '2023-01-08', 'The uncharted territory holds wonders and horrors.', 1, 10,2,2),
('The Settlement', 45, '2023-01-15', 'A new settlement brings hope and conflict.', 1, 10,3,3),
('The Storm', 45, '2023-01-22', 'A storm threatens the fragile new community.', 1, 10,4,4),
('The Unknown', 45, '2023-01-29', 'The unknown tests the limits of bravery.', 1, 10,5,5),
('The Foothold', 45, '2023-02-05', 'A foothold is established, but at what cost?', 1, 10,6,6),
('The Outpost', 45, '2023-02-12', 'An outpost on the edge of the world faces dangers.', 1, 10,7,7),
('The Wilderness', 45, '2023-02-19', 'The wilderness holds ancient secrets.', 1, 10,8,8),
('The Frontier', 45, '2023-02-26', 'The frontier pushes back against the settlers.', 1, 10,9,9);
