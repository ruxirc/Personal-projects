use colocviu;

drop table Persoana;
drop table Deviz;
drop table Piesa;
drop table Piesa_Deviz;

create table Persoana(
    id int not null, 
    nume varchar(30), 
    email varchar(50), 
    adresa varchar(100)
);

create table Deviz(
    id_d int not null, 
    data_introducere date,
    aparat varchar(30),
    simptome varchar(50),
    defect varchar(30),
    data_constatare date,
    data_finalizare date,
    durata int,
    manopera_ora int,
    total int,
    id_client int,
    id_depanator int
);

create table Piesa(
    id_p int not null,
    descriere varchar(50),
    fabricant varchar(30),
    cantitate_stoc int,
    pret_c int
);

create table Piesa_Deviz(
    id_d int not null, 
    id_p int not null,
    cantitate int,
    pret_r int
);

alter table Persoana add primary key (id);

alter table Deviz add primary key (id_d);
alter table Deviz add foreign key (id_client) references Persoana(id);
alter table Deviz add foreign key (id_depanator) references Persoana(id);

alter table Piesa add primary key (id_p);

alter table Piesa_Deviz add foreign key (id_d) references Deviz(id_d);
alter table Piesa_Deviz add foreign key (id_p) references Piesa(id_p);
alter table Piesa_Deviz add sursa varchar(100);

-- constrangeri
alter table Persoana add constraint email_symbol check (email like '%@%');

alter table Deviz add constraint date_consecutive check (data_introducere <= data_constatare and data_constatare <= data_finalizare);

UPDATE Deviz d
SET d.total = (
    SELECT IFNULL(SUM(pd.cantitate * pd.pret_r), 0) 
    FROM Piesa_Deviz pd 
    WHERE pd.id_d = d.id_d
) + (
    SELECT *
    FROM (
		select IFNULL(SUM(d.durata * d.manopera_ora), 0)
        from Deviz d
		) as d1
);

-- combinatia (descriere, fabricant) trebuie sa fie unica
ALTER TABLE Piesa
ADD CONSTRAINT unicitate_descriere_fabricant UNIQUE (descriere, fabricant);



-- inserari in tabela Persoana
INSERT INTO Persoana (id, nume, email, adresa)
VALUES (1, 'Ion Popescu', 'ion.popescu@gmail.com', 'Str. Libertății, Nr. 10, București');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (2, 'Ana Ionescu', 'ana.ionescu@gmail.com', 'Str. Victoriei, Nr. 15, Cluj-Napoca');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (3, 'Mihai Radu', 'mihai.radu@gmail.com', 'Str. Unirii, Nr. 5, Timișoara');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (4, 'Elena Marinescu', 'elena.marinescu@gmail.com', 'Bd. Independenței, Nr. 8, Iași');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (5, 'Andrei Dima', 'andrei.dima@gmail.com', 'Str. Revoluției, Nr. 12, Brașov');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (6, 'Cristina Tudor', 'cristina.tudor@gmail.com', 'Bd. 1 Decembrie, Nr. 7, Constanța');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (7, 'Alexandra Gheorghiu', 'alexandra.gheorghiu@gmail.com', 'Str. Cuza Vodă, Nr. 3, Galați');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (8, 'Răzvan Dumitru', 'razvan.dumitru@gmail.com', 'Str. Carol I, Nr. 22, Ploiești');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (9, 'Gabriela Popa', 'gabriela.popa@gmail.com', 'Str. Aviatorilor, Nr. 18, Sibiu');

INSERT INTO Persoana (id, nume, email, adresa)
VALUES (10, 'Doru Vasilescu', 'doru.vasilescu@gmail.com', 'Bd. Tomis, Nr. 25, Mamaia');

-- inserari in tabela Deviz
INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (192, str_to_date('01-Jan-2020', '%d-%b-%Y'), 'Laptop', 'Ecran negru', 'Defect la placa video', NULL, NULL, 3, 50, NULL, 1, 2);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (10, str_to_date('10-Feb-2021', '%d-%b-%Y'), 'Telefon', 'Baterie descarcata', 'Inlocuire baterie', NULL, NULL, 4, 40, NULL, 3, 1);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (86, str_to_date('05-Mar-2022', '%d-%b-%Y'), 'Tableta', 'Ecran spart', 'Inlocuire ecran', NULL, NULL, 5, 60, NULL, 4, 3);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (36, str_to_date('15-Apr-2020', '%d-%b-%Y'), 'Smart TV', 'Nu se aprinde', 'Reparatie sursa', NULL, NULL, 4, 55, NULL, 2, 4);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (61, str_to_date('20-May-2021', '%d-%b-%Y'), 'Frigider', 'Nu raceste', 'Inlocuire compresor', NULL, NULL, 5, 75, NULL, 1, 2);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (52, str_to_date('10-Jun-2022', '%d-%b-%Y'), 'Masina de spalat', 'Nu stocheaza apa', 'Reparatie pompa', NULL, NULL, 4, 45, NULL, 3, 7);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (71, str_to_date('25-Jul-2023', '%d-%b-%Y'), 'Aer conditionat', 'Nu raceste', 'Reincarcare freon', NULL, NULL, 5, 65, NULL, 6, 8);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (140, str_to_date('12-Aug-2020', '%d-%b-%Y'), 'Imprimanta', 'Nu printeaza', 'Curatare cap de printare', NULL, NULL, 4, 30, NULL, 4, 9);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (48, str_to_date('05-Sep-2021', '%d-%b-%Y'), 'Smartphone', 'Ecran spart', 'Inlocuire ecran', NULL, NULL, 5, 50, NULL, 9, 3);

INSERT INTO Deviz (id_d, data_introducere, aparat, simptome, defect, data_constatare, data_finalizare, durata, manopera_ora, total, id_client, id_depanator)
VALUES (95, str_to_date('18-Oct-2022', '%d-%b-%Y'), 'Laptop', 'Nu se incarca bateria', 'Inlocuire baterie', NULL, NULL, 4, 40, NULL, 8, 7);

-- inserari in tabela Piesa
INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (1236, 'Placă de bază', 'Asus', 20, 150);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (6589, 'Procesor', 'Intel', 15, 300);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (6645, 'Memorie RAM', 'Corsair', 30, 80);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (9514, 'Hard disk', 'Seagate', 25, 120);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (3215, 'Placă video', 'Nvidia', 10, 250);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (1986, 'Sursă de alimentare', 'EVGA', 18, 100);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (1360, 'SSD', 'Samsung', 12, 180);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (5684, 'Cooler procesor', 'Noctua', 22, 70);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (7887, 'Carcasă', 'NZXT', 17, 200);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (2648, 'Mouse', 'Logitech', 40, 40);


-- inserari in tabela Piesa_Deviz
INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (192, 1236, 2, 160, 'Depozit Electronice SRL');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (10, 6589, 1, 300, 'Retailer Altex');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (86, 6645, 3, 240, 'Importator Tech Solutions');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (36, 9514, 2, 240, 'Retailer Altex');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (61, 3215, 1, 250, 'Importator Tech Solutions');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (52, 1986, 2, 200, 'Importator Tech Solutions');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (71, 1360, 1, 180,'Depozit Electronice SRL');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (140, 5684, 3, 210, 'Importator Tech Solutions');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (48, 7887, 1, 200, 'Retailer Altex');

INSERT INTO Piesa_Deviz (id_d, id_p, cantitate, pret_r, sursa)
VALUES (95, 2648, 2, 80, 'Importator Tech Solutions');


-- ------------------------------------------------

UPDATE Deviz
SET data_constatare = STR_TO_DATE('12-Aug-2023', '%d-%b-%Y')
WHERE id_d = 52;

UPDATE Deviz
SET data_constatare = STR_TO_DATE('30-Dec-2022', '%d-%b-%Y')
WHERE id_d = 48;

UPDATE Deviz
SET data_constatare = STR_TO_DATE('16-Apr-2022', '%d-%b-%Y')
WHERE id_d = 140;

UPDATE Deviz
SET data_constatare = STR_TO_DATE('23-Sep-2023', '%d-%b-%Y')
WHERE id_d = 10;

SELECT *
FROM Deviz
WHERE data_constatare IS NOT NULL
  AND data_finalizare IS NULL
  AND STR_TO_DATE('01-Sep-2023', '%d-%b-%Y') >= data_constatare
ORDER BY data_introducere;

update Piesa
set cantitate_stoc = 5
where id_p = 3215;

update Piesa
set cantitate_stoc = 4
where id_p = 7887;

update Piesa
set cantitate_stoc = 4
where id_p = 9514;

update Piesa
set cantitate_stoc = 2
where id_p = 6645;

select *
from Piesa
where cantitate_stoc < 5
order by cantitate_stoc asc, descriere desc;

-- ---------------------
update Piesa
set pret_c = 450
where id_p = 1986;

update Piesa
set pret_c = 700
where id_p = 9514;

update Piesa
set pret_c = 350
where id_p = 1236;

update Piesa
set pret_c = 80
where id_p = 2648;

select p.id_p, p.descriere, p.pret_c, pd.pret_r
from Piesa p join Piesa_Deviz pd on (p.id_p = pd.id_p)
where p.pret_c > pd.pret_r;

update Piesa_Deviz
set id_d = 61
where id_p = 6589;

update Piesa_Deviz
set id_d = 61
where id_p = 9514;

update Piesa_Deviz
set id_d = 192
where id_p in (7887, 2648, 1986);

select distinct pd1.id_p as id_p1, pd2.id_p as id_p2
from Piesa_Deviz pd1 join Piesa_Deviz pd2 on (pd1.id_d = pd2.id_d) and pd1.id_p < pd2.id_p 
where pd1.cantitate = pd2.cantitate
order by id_p1, id_p2;

-- -----------------------------------------------------
update Piesa
set descriere = 'Surub'
where id_p in (2648, 7887, 9514);

INSERT INTO Piesa (id_p, descriere, fabricant, cantitate_stoc, pret_c)
VALUES (1111, 'Surub', 'Bosch', 100, 3);

select *
from Deviz
where id_d in (
    select pd.id_d
    from Piesa p join Piesa_Deviz pd on (p.id_p = pd.id_p)
    where lower(descriere) = lower('surub')
);

SELECT p.descriere, p.fabricant
FROM Piesa p
WHERE EXISTS (
    SELECT *
    FROM Piesa_Deviz pd
    WHERE p.id_p = pd.id_p
    AND pd.pret_r >= ALL (
        SELECT pret_r
        FROM Piesa_Deviz
    )
);

-- -----------------------------------------------------------

UPDATE Deviz
SET data_finalizare = STR_TO_DATE('15-Sep-2023', '%d-%b-%Y')
WHERE id_d IN (52, 140, 48);

UPDATE Deviz
SET data_constatare = STR_TO_DATE('28-Jul-2023', '%d-%b-%Y')
WHERE id_d IN (71, 61, 95, 86);

UPDATE Deviz
SET id_depanator = 7
WHERE id_d IN (61, 95);

UPDATE Deviz
SET data_finalizare = STR_TO_DATE('29-Sep-2023', '%d-%b-%Y')
WHERE id_d IN (71, 61, 95);

DROP PROCEDURE IF EXISTS CountDevizeByDepanator;

DELIMITER //

CREATE PROCEDURE CountDevizeByDepanator()
BEGIN
    SELECT p.nume AS nume_depanator, COUNT(*) AS cate_devize
    FROM Persoana p
    JOIN Deviz d ON d.id_depanator = p.id
    WHERE UPPER(DATE_FORMAT(d.data_finalizare, '%b-%Y')) = 'SEP-2023'
    GROUP BY p.nume;
END //

DELIMITER ;

call CountDevizeByDepanator();

update Piesa
set fabricant = 'Samsung'
where id_p in (1986, 7887, 3215);

DELIMITER $$

DROP PROCEDURE IF EXISTS GetPiesaSummary;

CREATE PROCEDURE GetPiesaSummary()
BEGIN
    SELECT p.descriere AS descriere, p.fabricant AS fabricant, SUM(pd.cantitate) AS cantitate_totala
    FROM Piesa p
    JOIN Piesa_Deviz pd ON p.id_p = pd.id_p
    JOIN Deviz d ON pd.id_d = d.id_d
    WHERE UPPER(DATE_FORMAT(d.data_finalizare, '%b-%Y')) = 'Sep-2023'
    GROUP BY p.descriere, p.fabricant;
END $$

DELIMITER ;

call GetPiesaSummary();