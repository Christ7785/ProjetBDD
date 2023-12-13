IF OBJECT_ID('CHK_SALAIRE_DOUBLE_MOYENNE', 'C') IS NOT NULL
    ALTER TABLE PROFESSEURS DROP CONSTRAINT CHK_SALAIRE_DOUBLE_MOYENNE;

IF OBJECT_ID('CHK_SALAIRE_BASE_ACTUEL', 'C') IS NOT NULL
    ALTER TABLE PROFESSEURS DROP CONSTRAINT CHK_SALAIRE_BASE_ACTUEL;

IF OBJECT_ID('CHK_SEXE', 'C') IS NOT NULL
    ALTER TABLE ELEVES DROP CONSTRAINT CHK_SEXE;

IF OBJECT_ID('CHK_POINTS_RANGE', 'C') IS NOT NULL
    ALTER TABLE RESULTATS DROP CONSTRAINT CHK_POINTS_RANGE;

IF OBJECT_ID('dbo.GetAverageSalary', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetAverageSalary;

IF OBJECT_ID('TRG_SALAIRE_ACTUEL', 'TR') IS NOT NULL
    DROP TRIGGER TRG_SALAIRE_ACTUEL;

IF OBJECT_ID('PROF_SPECIALITE', 'U') IS NOT NULL
    DROP TABLE PROF_SPECIALITE;

IF OBJECT_ID('TRG_UPDATE_PROF_SPECIALITE', 'TR') IS NOT NULL
    DROP TRIGGER TRG_UPDATE_PROF_SPECIALITE;

IF OBJECT_ID('TRG_UPDATE_CHARGE_ON_PROF_DELETE', 'TR') IS NOT NULL
    DROP TRIGGER TRG_UPDATE_CHARGE_ON_PROF_DELETE;

IF OBJECT_ID('AUDIT_RESULTATS', 'U') IS NOT NULL
    DROP TABLE AUDIT_RESULTATS;

IF OBJECT_ID('TRG_AUDIT_RESULTATS', 'TR') IS NOT NULL
    DROP TRIGGER TRG_AUDIT_RESULTATS;

IF OBJECT_ID('TRG_CONFIDENTIALITE_SALAIRE', 'TR') IS NOT NULL
    DROP TRIGGER TRG_CONFIDENTIALITE_SALAIRE;

IF OBJECT_ID('pr_resultat', 'P') IS NOT NULL
    DROP PROCEDURE pr_resultat;

IF OBJECT_ID('fn_moyenne', 'FN') IS NOT NULL
    DROP FUNCTION fn_moyenne;

GO 
-- -- Contrainte verticale : Le salaire d'un professeur ne doit pas dépasser le double de la moyenne des salaires des enseignants de la même spécialité.

CREATE FUNCTION dbo.GetAverageSalary(@Specialite VARCHAR(20))
    RETURNS FLOAT
    AS
    BEGIN
        DECLARE @AvgSalary FLOAT;

        SELECT @AvgSalary = AVG(SALAIRE_ACTUEL)
        FROM PROFESSEURS
        WHERE SPECIALITE = @Specialite;

        RETURN ISNULL(@AvgSalary, 2000000);
    END;

GO
-- La note d'un étudiant doit être comprise entre 0 et 20.
ALTER TABLE RESULTATS
ADD CONSTRAINT CHK_POINTS_RANGE CHECK (POINTS >= 0 AND POINTS <= 20);

-- Le sexe d'un étudiant doit être dans la liste: 'm', 'M', 'f', 'F' ou Null.
ALTER TABLE ELEVES
ADD CONSTRAINT CHK_SEXE CHECK (SEXE IN ('m', 'M', 'f', 'F') OR SEXE IS NULL);

-- Contrainte horizontale : Le salaire de base d’un professeur doit être inférieur au salaire actuel.
ALTER TABLE PROFESSEURS
ADD CONSTRAINT CHK_SALAIRE_BASE_ACTUEL CHECK (SALAIRE_BASE <= SALAIRE_ACTUEL);

-- Contrainte verticale : Le salaire d'un professeur ne doit pas dépasser le double de la moyenne des salaires des enseignants de la même spécialité.
ALTER TABLE PROFESSEURS
ADD CONSTRAINT CHK_SALAIRE_DOUBLE_MOYENNE
CHECK (
    SALAIRE_ACTUEL <= 2 * dbo.GetAverageSalary(SPECIALITE)
);

GO
-- Créez un trigger permettant de vérifier la contrainte : « Le salaire d'un Professeur ne peut pas diminuer ».
CREATE TRIGGER TRG_SALAIRE_ACTUEL
ON PROFESSEURS
AFTER UPDATE
AS
IF UPDATE(SALAIRE_ACTUEL)
BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @CountDecrease INT;

        SELECT @CountDecrease = COUNT(*)
        FROM deleted d
        INNER JOIN inserted i ON d.NUM_PROF = i.NUM_PROF
        WHERE (d.SALAIRE_ACTUEL >= i.SALAIRE_ACTUEL) OR (d.SALAIRE_ACTUEL IS NULL AND i.SALAIRE_ACTUEL IS NOT NULL);

        IF @CountDecrease > 0
            THROW 50000, 'Le salaire un professeur ne peut pas diminuer.', 1;
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
-- Annuler la transaction si le salaire diminue
    IF @@TRANCOUNT > 0
          ROLLBACK TRANSACTION;
END CATCH;

GO

-- Gestion automatique de la redondance
CREATE TABLE PROF_SPECIALITE (
    SPECIALITE VARCHAR(20), 
    NB_PROFESSEURS INT
);

GO
-- Créez un trigger permettant de remplir et mettre à jour automatiquement cette table suite à chaque opération de MAJ (insertion, suppression, modification) sur la table des professeurs.

CREATE TRIGGER TRG_UPDATE_PROF_SPECIALITE
ON PROFESSEURS
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Mise à jour du nombre de professeurs par spécialité
    UPDATE PS
    SET NB_PROFESSEURS = ISNULL((SELECT COUNT(P.NUM_PROF) FROM PROFESSEURS P WHERE PS.SPECIALITE = P.SPECIALITE), 0)
    FROM PROF_SPECIALITE PS;

    -- Insertion des nouvelles spécialités
    INSERT INTO PROF_SPECIALITE (SPECIALITE, NB_PROFESSEURS)
    SELECT DISTINCT SPECIALITE, COUNT(NUM_PROF)
    FROM INSERTED
    GROUP BY SPECIALITE
    HAVING COUNT(NUM_PROF) > 0;

    -- Suppression des spécialités sans professeurs
    DELETE FROM PROF_SPECIALITE
    WHERE SPECIALITE IN (SELECT DISTINCT SPECIALITE FROM DELETED WHERE NUM_PROF IS NOT NULL);
END;

GO

-- Mise à jour en cascade : Créez un trigger qui met à jour la table CHARGE lorsqu’on supprime un professeur dans la table PROFESSEUR ou que l’on change son numéro.

CREATE TRIGGER TRG_UPDATE_CHARGE_ON_PROF_DELETE
ON PROFESSEURS
AFTER DELETE, UPDATE
AS
BEGIN

 IF EXISTS (SELECT * FROM deleted)
    BEGIN
        DELETE FROM CHARGE
        WHERE NUM_PROF IN (SELECT NUM_PROF FROM deleted);
    END

IF EXISTS (SELECT * FROM inserted)
    BEGIN
        UPDATE CHARGE
        SET NUM_PROF = inserted.NUM_PROF
        FROM CHARGE
        INNER JOIN inserted ON CHARGE.NUM_PROF = inserted.NUM_PROF;
    END
END;

GO

-- Créez la table audit_resultats

CREATE TABLE AUDIT_RESULTATS (
    UTILISATEUR VARCHAR(50),
    DATE_MAJ DATETIME,
    DESC_MAJ VARCHAR(20),
    NUM_ELEVE INT NOT NULL,
    NUM_COURS INT NOT NULL,
    POINTS INT
);

GO
-- Créez un trigger qui met à jours la table audit_resultats à chaque modification de la table RÉSULTAT. 
-- Il faut donner l’utilisateur qui a fait la modification (USER), la date de la modification et une description de la modification (‘INSERT’, ‘DELETE’, ‘NOUVEAU’, ‘ANCIEN’)
CREATE TRIGGER TRG_AUDIT_RESULTATS
ON RESULTATS
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @UserName VARCHAR(50);
    SET @UserName = SYSTEM_USER;

    -- Insert audit records for INSERT operations
    INSERT INTO AUDIT_RESULTATS (UTILISATEUR, DATE_MAJ, DESC_MAJ, NUM_ELEVE, NUM_COURS, POINTS)
    SELECT @UserName, GETDATE(), 'INSERT', NUM_ELEVE, NUM_COURS, POINTS
    FROM INSERTED;

    -- Insert audit records for DELETE operations
    INSERT INTO AUDIT_RESULTATS (UTILISATEUR, DATE_MAJ, DESC_MAJ, NUM_ELEVE, NUM_COURS, POINTS)
    SELECT @UserName, GETDATE(), 'DELETE', NUM_ELEVE, NUM_COURS, POINTS
    FROM DELETED;

    -- Insert audit records for UPDATE operations
    INSERT INTO AUDIT_RESULTATS (UTILISATEUR, DATE_MAJ, DESC_MAJ, NUM_ELEVE, NUM_COURS, POINTS)
    SELECT @UserName, GETDATE(), 'NOUVEAU', i.NUM_ELEVE, i.NUM_COURS, i.POINTS
    FROM INSERTED i
    INNER JOIN DELETED d ON i.NUM_ELEVE = d.NUM_ELEVE AND i.NUM_COURS = d.NUM_COURS
    WHERE i.POINTS <> d.POINTS;

    INSERT INTO AUDIT_RESULTATS (UTILISATEUR, DATE_MAJ, DESC_MAJ, NUM_ELEVE, NUM_COURS, POINTS)
    SELECT @UserName, GETDATE(), 'ANCIEN', d.NUM_ELEVE, d.NUM_COURS, d.POINTS
    FROM INSERTED i
    INNER JOIN DELETED d ON i.NUM_ELEVE = d.NUM_ELEVE AND i.NUM_COURS = d.NUM_COURS
    WHERE i.POINTS <> d.POINTS;
END;


GO

-- Confidentialité: On souhaite que seul l'utilisateur 'GrandChef' puisse augmenter les salaires des professeurs de plus de 20%. 
-- Le trigger doit retourner une erreur (No -20002) et le message 'Modification interdite' si la condition n’est pas respectée.

CREATE TRIGGER TRG_CONFIDENTIALITE_SALAIRE
ON PROFESSEURS
AFTER UPDATE
AS
DECLARE @UserName VARCHAR(50);

-- Get the current user
SET @UserName = SYSTEM_USER;
BEGIN TRY
    BEGIN TRANSACTION

    SELECT 1
    FROM inserted i
    JOIN deleted d ON i.NUM_PROF = d.NUM_PROF
    WHERE i.SALAIRE_ACTUEL >= 1.2 * d.SALAIRE_ACTUEL

    -- Check if the user is GrandChef
    IF @UserName <> 'sa'
        THROW -20002, 'Modification interdite', 1;
    COMMIT TRANSACTION
END TRY

BEGIN CATCH
IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
END CATCH


GO
-- Créez une fonction fn_moyenne calculant la moyenne d’un étudiant passé en paramètre.

CREATE FUNCTION fn_moyenne(@NumEleve INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @Average FLOAT;

    SELECT @Average = AVG(POINTS)
    FROM RESULTATS
    WHERE NUM_ELEVE = @NumEleve;

    RETURN ISNULL(@Average, 0);
END;

GO

-- Créez une procédure pr_resultat permettant d’afficher la moyenne de chaque élève avec la mention adéquate : échec, passable, assez bien, bien, très bien.

CREATE PROCEDURE dbo.pr_resultat
AS
SELECT
    NUM_ELEVE,
    MOYENNE = dbo.fn_moyenne(NUM_ELEVE),
    CASE
        WHEN dbo.fn_moyenne(NUM_ELEVE) <= 8 THEN 'Échec'
        WHEN dbo.fn_moyenne(NUM_ELEVE) <= 10 THEN 'Passable'
        WHEN dbo.fn_moyenne(NUM_ELEVE) <= 12 THEN 'Assez bien'
        WHEN dbo.fn_moyenne(NUM_ELEVE) <= 14 THEN 'Bien'
        ELSE 'Très bien'
    END AS MENTION
FROM
    RESULTATS;

GO

-- Commande Test

-- INSERT INTO PROFESSEURS (NUM_PROF, NOM, SPECIALITE, SALAIRE_ACTUEL)
-- VALUES (9, 'John Doe', 'Mathematics', 2250000);

-- UPDATE PROFESSEURS
-- SET SPECIALITE = 'Physics'
-- WHERE NUM_PROF = 9;

-- DELETE FROM PROFESSEURS
-- WHERE NUM_PROF = 9;




-- Testing TRG_SALAIRE_ACTUEL

-- INSERT INTO PROFESSEURS (NUM_PROF, NOM, SPECIALITE, SALAIRE_BASE, SALAIRE_ACTUEL)
-- VALUES (12, 'Professor10', 'Mathematics', 1500000, 1500000);


-- UPDATE PROFESSEURS
-- SET SALAIRE_ACTUEL = 2400001
-- WHERE NUM_PROF = 12;

-- DELETE FROM PROFESSEURS 
-- WHERE NUM_PROF = 12




-- Testing TRG_UPDATE_PROF_SPECIALITE


-- INSERT INTO PROFESSEURS (NUM_PROF, NOM, SPECIALITE, SALAIRE_ACTUEL)
-- VALUES (11, 'Professor2', 'Physics', 1800000);


-- UPDATE PROFESSEURS
-- SET SPECIALITE = 'Mathematics'
-- WHERE NUM_PROF = 11;


-- DELETE FROM PROFESSEURS
-- WHERE NUM_PROF = 1;




-- Testing TRG_AUDIT_RESULTATS


--INSERT INTO RESULTATS (NUM_ELEVE, NUM_COURS, POINTS)
--VALUES (1, 3, 18);

--UPDATE RESULTATS
--SET POINTS = 16
--WHERE NUM_ELEVE = 1 AND NUM_COURS = 3;

 --DELETE FROM RESULTATS
 --WHERE NUM_ELEVE = 1 AND NUM_COURS = 3;




-- Testing TRG_CONFIDENTIALITE_SALAIRE

--UPDATE PROFESSEURS
--SET SALAIRE_ACTUEL = SALAIRE_ACTUEL * 1.3
--WHERE NUM_PROF = 8;




-- Execute the procedure dbo.pr_resultat
-- EXEC dbo.pr_resultat;
