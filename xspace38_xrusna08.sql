-----------------------------------------------
-- IDS projekt 1
-- autori: xspace38, xrusna08
--
-----------------------------------------------
-- Delete tabulek
DROP TABLE ZAKAZNIK CASCADE CONSTRAINTS;
DROP TABLE OBJEDNAVKA CASCADE CONSTRAINTS;
DROP TABLE REZERVACE CASCADE CONSTRAINTS;
DROP TABLE SLUZBA CASCADE CONSTRAINTS;
DROP TABLE POKOJ CASCADE CONSTRAINTS;
DROP TABLE PROVEDENA_SLUZBA CASCADE CONSTRAINTS;

-----------------------------------------------
-- Delete sekvenci
DROP SEQUENCE OBJEDNAVKA_SEQ;
DROP SEQUENCE REZERVACE_SEQ;
DROP SEQUENCE PROVEDENA_SLUZBA_SEQ;
DROP SEQUENCE POKOJ_SEQ;

-----------------------------------------------
-- Delete materializovanych pohledu
DROP MATERIALIZED VIEW MV_PLAT_ZAKAZNIKA;

-----------------------------------------------
-- Vytvareni tabulek
CREATE TABLE ZAKAZNIK (
    ID_ZAKAZNIKA NUMBER NOT NULL,
    CHECK(ID_ZAKAZNIKA >= 100000000 AND ID_ZAKAZNIKA <= 999999999), -- kontrola ID obcanskeho prukazu (cesky OP ma standardne 9 cislic)
    JMENO VARCHAR(20) NOT NULL,
    PRIJMENI VARCHAR(20) NOT NULL,
    KONTAKT VARCHAR(50) NOT NULL,
    DATUM_NAROZENI DATE NOT NULL,
    BYDLISTE VARCHAR(50) NOT NULL,
    CONSTRAINT ZAKAZNIK_PK PRIMARY KEY(ID_ZAKAZNIKA)
);

CREATE TABLE SLUZBA (
    ID_SLUZBY NUMBER NOT NULL,
    POPIS VARCHAR(70) NOT NULL,
    CENA NUMBER NOT NULL,
    CONSTRAINT SLUZBA_PK PRIMARY KEY(ID_SLUZBY)
);

CREATE TABLE POKOJ (
    ID_POKOJE NUMBER NOT NULL,
    STAV_POKOJE VARCHAR(70) NOT NULL,
    POCET_LUZEK NUMBER NOT NULL,
    VYBAVENI VARCHAR(70) NOT NULL,
    DOSTUPNOST VARCHAR(30) NOT NULL,
    CENA NUMBER NOT NULL,
    CONSTRAINT POKOJ_PK PRIMARY KEY(ID_POKOJE)
);

CREATE TABLE OBJEDNAVKA (
    ID_OBJEDNAVKY NUMBER NOT NULL,
    DATUM_VYTVORENI DATE NOT NULL,
    UHRAZENO VARCHAR(20) NOT NULL,
    ZPUSOB_PLATBY VARCHAR(50) NOT NULL,
    CELKOVA_CENA NUMBER,
    ZAKAZNIK_ID NUMBER NOT NULL,
    CONSTRAINT OBJEDNAVKA_PK PRIMARY KEY(ID_OBJEDNAVKY),
    CONSTRAINT OBJEDNAVKA_FK FOREIGN KEY(ZAKAZNIK_ID) REFERENCES ZAKAZNIK(ID_ZAKAZNIKA)
);

CREATE TABLE REZERVACE (
    ID_REZERVACE NUMBER NOT NULL,
    CAS_OD DATE NOT NULL,
    CAS_DO DATE NOT NULL,
    POCET_OSOB NUMBER NOT NULL,
    CASTKA NUMBER NOT NULL,
    STORNO VARCHAR(15),
    REZERVACE_POKOJ_ID NUMBER NOT NULL,
    REZERVACE_OBJEDNAVKA_ID NUMBER NOT NULL,
    CONSTRAINT REZERVACE_PK PRIMARY KEY(ID_REZERVACE),
    CONSTRAINT REZERVACE_FK_POKOJ FOREIGN KEY(REZERVACE_POKOJ_ID) REFERENCES POKOJ(ID_POKOJE),
    CONSTRAINT REZERVACE_FK_OBJEDNAVKA FOREIGN KEY(REZERVACE_OBJEDNAVKA_ID) REFERENCES OBJEDNAVKA(ID_OBJEDNAVKY)
);

-- Vztah generalizace/specializace: pro tento vztah vyvtvorime tabulku PROVEDENA_SLUZBA, ktera bude specializaci tabulky SLUZBA.
-- Tato specializace se nam bude hodit pri vytvareni objednavky, kde se podle danych provedenych sluzeb muze odvijet napriklad celkova cena objednavky.
-- Tabulka bude mit tedy 2 cizi klice, ktere budou odkazovat na tabulky SLUZBA a OBJEDNAVKA.
-- Tento vztah generalizace/specializace neni zaznacen v ERD, protoze pri tvoreni ERD nas tento vztah nenapadl. (mysleli jsme si, ze takovy vztah pro nas ERD nebude potreba a vse bude zahrnuto v tabulce SLUZBA)
-- (Prvne jsme chteli generovat ID SLUZBA pomoci sekvence, ale z duvodu vztahu gen/spec bude lepsi dat nabizenym sluzbam staticka ID a pro provedene sluzby generovat ID pomoci sekvence.)

CREATE TABLE PROVEDENA_SLUZBA (
    ID_PROVEDENEJ_SLUZBY NUMBER NOT NULL,
    PROVEDENA_SLUZBA_OBJEDNAVKA_ID NUMBER NOT NULL,
    PROVEDENA_SLUZBA_SLUZBA_ID NUMBER NOT NULL,
    CONSTRAINT PROVEDEN_SLUZBA_PK PRIMARY KEY(ID_PROVEDENEJ_SLUZBY),
    CONSTRAINT PROVEDEN_SLUZBA_FK_OBJEDNAVKA FOREIGN KEY(PROVEDENA_SLUZBA_OBJEDNAVKA_ID) REFERENCES OBJEDNAVKA(ID_OBJEDNAVKY), -- cizi klic na tabulku OBJEDNAVKA
    CONSTRAINT PROVEDEN_SLUZBA_FK_SLUZBA FOREIGN KEY(PROVEDENA_SLUZBA_SLUZBA_ID) REFERENCES SLUZBA(ID_SLUZBY) -- cizi klic na tabulku SLUZBA
);

-----------------------------------------------
-- Vytvoreni sekvenci

-- tyto sekvence generuji automaticky ID (primary key) pro danou polozku tabulky
CREATE SEQUENCE OBJEDNAVKA_SEQ
    START WITH 1
    INCREMENT BY 1;

CREATE SEQUENCE REZERVACE_SEQ
    START WITH 1
    INCREMENT BY 1;

CREATE SEQUENCE POKOJ_SEQ
    START WITH 1
    INCREMENT BY 1;

CREATE SEQUENCE PROVEDENA_SLUZBA_SEQ
    START WITH 1
    INCREMENT BY 1;

-----------------------------------------------
-- Prikladove inserty
-------------------------ID_ZAKAZNIKA -- JMENO -- PRIJMENI -- KONTAKT -- DATUM NAROZENI -- BYDLISTE
INSERT INTO ZAKAZNIK VALUES(123456789, 'Filip', 'Spacek', 'filip.spacek@outlook.com', TO_DATE('16-11-2001', 'dd-mm-yyyy'), 'Kubanska 4 Brno 616 00');
INSERT INTO ZAKAZNIK VALUES(234567891, 'Petr', 'Knakal', '+420 601 385 342', TO_DATE('21-12-1999', 'dd-mm-yyyy'), 'Zizkova 1134 Urcice 798 04');
INSERT INTO ZAKAZNIK VALUES(345678912, 'Petr', 'Cech', 'petr.cech@email.cz', TO_DATE('01-01-2000', 'dd-mm-yyyy'), 'Jiraskova 1204 Kropacova Vrutice 387 16');
INSERT INto ZAKAZNIK VALUES(696969696, 'Juraj', 'Rusnak', '+421 917 304 825', TO_DATE('28-12-2000', 'dd-mm-yyyy'), 'Kolejni 2 Kralovo Pole 61200');

-------------------------ID_SLUZBY -- POPIS -- CENA
INSERT INTO SLUZBA VALUES(1111, 'Vymena rucniku za nove', 300);
INSERT INTO SLUZBA VALUES(1112, 'Vyprat obleceni s vyzehlenim', 400);
INSERT INTO SLUZBA VALUES(1113, 'Sauna + masaze', 1000);
INSERT INTO SLUZBA VALUES(1114, 'Vecere ve forme svedskeho stolu', 750);
INSERT INTO SLUZBA VALUES(1115, 'Lahev sampanskeho na pokoj', 200);

------------------------ ID_POKOJE -- STAV POKOJE -- POCET LUZEK -- VYBAVENI -- DOSTUPNOST -- CENA POKOJE
INSERT INTO POKOJ VALUES(POKOJ_SEQ.NEXTVAL, 'Cisty', 2, 'Televize, minibar, Wi-Fi', 'Obsazeny', 1000);
INSERT INTO POKOJ VALUES(POKOJ_SEQ.NEXTVAL, 'Rozbita postel', 4, 'Televize, minibar, Wi-Fi, sauna', 'Obsazeny', 2000);
INSERT INTO POKOJ VALUES(POKOJ_SEQ.NEXTVAL, 'Neuklizeny', 1, 'Minibar, Wi-Fi', 'Obsazeny', 500);
INSERT INTO POKOJ VALUES(POKOJ_SEQ.NEXTVAL, 'Cisty', 3, 'Televize, Minibar, Wi-Fi', 'Volny', 1500);
INSERT INTO POKOJ VALUES(POKOJ_SEQ.NEXTVAL, 'Neuklizeny', 6, 'Televize, Minibar, Wi-Fi', 'Volny', 3000);
INSERT INTO POKOJ VALUES(POKOJ_SEQ.NEXTVAL, 'Cisty', 3, 'Televize, Minibar, Wi-Fi', 'Volny', 1500);

-------------------------ID_OBJEDNAVKY -- DATUM VYTVORENI -- STAV PLATBY -- FORMA PLATBY -- CELKOVA CENA -- ID_ZAKAZNIKA
INSERT INTO OBJEDNAVKA VALUES(OBJEDNAVKA_SEQ.NEXTVAL, TO_DATE('24-03-2023', 'dd-mm-yyyy'), 'Neuhrazeno', 'Hotovost', 999, 123456789);
INSERT INTO OBJEDNAVKA VALUES(OBJEDNAVKA_SEQ.NEXTVAL, TO_DATE('24-03-2023', 'dd-mm-yyyy'), 'Neuhrazeno', 'Kreditni karta', 6969, 234567891);
INSERT INTO OBJEDNAVKA VALUES(OBJEDNAVKA_SEQ.NEXTVAL, TO_DATE('24-03-2023', 'dd-mm-yyyy'), 'Neuhrazeno', 'Kreditni karta', 8888, 345678912);
INSERT INTO OBJEDNAVKA VALUES(OBJEDNAVKA_SEQ.NEXTVAL, TO_DATE('24-03-2023', 'dd-mm-yyyy'), 'Uhrazeno', 'Kreditni karta', 2222, 696969696);

-------------------------ID_REZERVACE -- CAS OD -- CAS DO -- POCET OSOB -- CASTKA -- STORNO -- REZERVACE_POKOJ_ID -- REZERVACE_OBJEDNAVKA_ID
INSERT INTO REZERVACE VALUES(REZERVACE_SEQ.NEXTVAL, TO_DATE('24-03-2023', 'dd-mm-yyyy'), TO_DATE('25-03-2023', 'dd-mm-yyyy'), 2, 2000, 'Ne', 1, 1);
INSERT INTO REZERVACE VALUES(REZERVACE_SEQ.NEXTVAL, TO_DATE('24-03-2023', 'dd-mm-yyyy'), TO_DATE('26-03-2023', 'dd-mm-yyyy'), 4, 4000, 'Ne', 2, 2);
INSERT INTO REZERVACE VALUES(REZERVACE_SEQ.NEXTVAL, TO_DATE('20-03-2023', 'dd-mm-yyyy'), TO_DATE('01-04-2023', 'dd-mm-yyyy'), 1, 500, 'Ne', 3, 3);

-------------------------ID_PROVEDENEJ_SLUZBY -- PROVEDENA_SLUZBA_OBJEDNAVKA_ID -- PROVEDENA_SLUZBA_SLUZBA_ID
INSERT INTO PROVEDENA_SLUZBA VALUES(PROVEDENA_SLUZBA_SEQ.NEXTVAL, 1, 1111);
INSERT INTO PROVEDENA_SLUZBA VALUES(PROVEDENA_SLUZBA_SEQ.NEXTVAL, 1, 1112);
INSERT INTO PROVEDENA_SLUZBA VALUES(PROVEDENA_SLUZBA_SEQ.NEXTVAL, 2, 1115);
INSERT INTO PROVEDENA_SLUZBA VALUES(PROVEDENA_SLUZBA_SEQ.NEXTVAL, 3, 1113);

-----------------------------------------------
-- Selecty

--ke kteremu zakaznikovi pripada jaka objednavka
SELECT ID_ZAKAZNIKA, JMENO, PRIJMENI, ID_OBJEDNAVKY FROM ZAKAZNIK INNER JOIN OBJEDNAVKA ON ID_ZAKAZNIKA = ZAKAZNIK_ID;

-- ke ktere rezervaci spada jaky pokoj
SELECT ID_REZERVACE, CAS_OD, CAS_DO, ID_POKOJE FROM REZERVACE INNER JOIN POKOJ ON REZERVACE_POKOJ_ID = ID_POKOJE;

-- kteremu zakaznikovi patri jaka objednavka pod kterou spada jaka rezervace
SELECT ID_ZAKAZNIKA, JMENO, PRIJMENI, ID_OBJEDNAVKY, ID_REZERVACE FROM ZAKAZNIK 
INNER JOIN OBJEDNAVKA ON ID_ZAKAZNIKA = ZAKAZNIK_ID
INNER JOIN REZERVACE ON ID_OBJEDNAVKY = REZERVACE_OBJEDNAVKA_ID;

-- celkovy pocet volnych luzek
SELECT SUM(POCET_LUZEK) AS CELKOVY_POCET_VOLNYCH_LUZEK FROM POKOJ
WHERE DOSTUPNOST = 'Volny'
GROUP BY DOSTUPNOST;

-- hledani nejvetsiho dluhu
SELECT MAX(CELKOVA_CENA) AS NEJVETSI_DLH FROM OBJEDNAVKA
WHERE UHRAZENO = 'Neuhrazeno'
GROUP BY UHRAZENO;

-- jestli existuje sluzba, ktera ma byla provedena
SELECT ID_SLUZBY, POPIS, CENA FROM SLUZBA WHERE EXISTS (SELECT ID_PROVEDENEJ_SLUZBY FROM PROVEDENA_SLUZBA WHERE ID_SLUZBY = PROVEDENA_SLUZBA_SLUZBA_ID);

-- hledame objednavku ve ktere byla provedena nejaka sluzba
SELECT * FROM OBJEDNAVKA WHERE ID_OBJEDNAVKY IN (SELECT PROVEDENA_SLUZBA_OBJEDNAVKA_ID FROM PROVEDENA_SLUZBA);

-------------------------------------------------------------------------------------------
-- SELECT zo 4.faze zo zakaznika vybereme jeho meno a zistime, aku castku zaplatil za pokoj
WITH objednavky_zakaznika AS (
    SELECT
        c.JMENO || ' ' || c.PRIJMENI AS jmeno_zakaznika,
        co.ID_OBJEDNAVKY,
        co.ZPUSOB_PLATBY,
        co.CELKOVA_CENA
    FROM
        ZAKAZNIK c
        JOIN OBJEDNAVKA co ON c.ID_ZAKAZNIKA = co.ZAKAZNIK_ID
)
SELECT
    jmeno_zakaznika,
    ID_OBJEDNAVKY,
    ZPUSOB_PLATBY,
    CELKOVA_CENA,
    CASE
        WHEN CELKOVA_CENA >= 1000 THEN 'Vysoka cena'
        WHEN CELKOVA_CENA BETWEEN 500 AND 999 THEN 'Stredna cena'
        ELSE 'Nizka cena'
    END AS velikost_castky
FROM
    objednavky_zakaznika;

--------------------------------------------------------------------------------
--triggers

-- trigger na aktualizaciu dostupnosti pokoje, ked si zakaznik zarezervuje pokoj
CREATE OR REPLACE TRIGGER AKTUALIZUJ_DOSTUPNOST
AFTER INSERT ON REZERVACE
FOR EACH ROW
BEGIN
    UPDATE POKOJ
    SET DOSTUPNOST = 'obsazeny'
    WHERE ID_POKOJE = :NEW.REZERVACE_POKOJ_ID;
END;
/

-- trigger se spusti tehdy, kdy do provedenej sluzbi vlozime riadok a aktualizuje celkovu cenu
CREATE OR REPLACE TRIGGER AKTUALIZUJ_CASTKU_OBJEDNAVKY
AFTER INSERT ON PROVEDENA_SLUZBA
FOR EACH ROW
BEGIN
    UPDATE OBJEDNAVKA
    SET CELKOVA_CENA = CELKOVA_CENA + (SELECT CENA FROM SLUZBA WHERE ID_SLUZBY = :NEW.PROVEDENA_SLUZBA_SLUZBA_ID)
    WHERE ID_OBJEDNAVKY = :NEW.PROVEDENA_SLUZBA_OBJEDNAVKA_ID;
END;
/

-----------------------------------------------------------
-- index
--indexujeme zakaznik id v objednavke, pre lehci vyhledavani v tabulke objednavka
CREATE INDEX IDX_ZAKAZNIK_ID ON OBJEDNAVKA(ZAKAZNIK_ID);

-----------------------------------------------------------
-- Procedury
CREATE OR REPLACE PROCEDURE proc1 AS
  v_order OBJEDNAVKA%ROWTYPE;
  CURSOR cur_orders IS SELECT * FROM OBJEDNAVKA;
BEGIN
  OPEN cur_orders;
  LOOP
    FETCH cur_orders INTO v_order;
    EXIT WHEN cur_orders%NOTFOUND;
    -- do some processing with v_order
    IF v_order.CELKOVA_CENA > 500 THEN
      -- raise an exception if the order amount is too high
      RAISE_APPLICATION_ERROR(-20001, 'Order amount exceeds limit');
    END IF;
  END LOOP;
  CLOSE cur_orders;
EXCEPTION
  WHEN OTHERS THEN
    -- log the error message to a table
    INSERT INTO OBJEDNAVKA (CELKOVA_CENA) VALUES (-1);
    INSERT INTO OBJEDNAVKA (UHRAZENO) VALUES ('ERROR');
    -- re-raise the exception
    RAISE;
END proc1;
/


CREATE OR REPLACE PROCEDURE proc2(p_order_id OBJEDNAVKA.ID_OBJEDNAVKY%TYPE) AS
  v_order OBJEDNAVKA%ROWTYPE;
BEGIN
  SELECT * INTO v_order FROM OBJEDNAVKA WHERE ID_OBJEDNAVKY = p_order_id;
  -- do some processing with v_order
  IF v_order.CELKOVA_CENA < 100 THEN
    -- raise an exception if the order amount is too low
    RAISE_APPLICATION_ERROR(-20002, 'Order amount is too low');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- log the error message to a table
    INSERT INTO OBJEDNAVKA (UHRAZENO) VALUES ('ERROR');
    -- re-raise the exception
    RAISE_APPLICATION_ERROR(-20003, 'Order not found');
  WHEN OTHERS THEN
    -- log the error message to a table
    INSERT INTO OBJEDNAVKA (UHRAZENO) VALUES ('ERROR');
    -- re-raise the exception
    RAISE;
END proc2;
/

-----------------------------------------------------------
-- Prava

-- XRUSNA08
GRANT ALL ON ZAKAZNIK TO XRUSNA08;
GRANT ALL ON OBJEDNAVKA TO XRUSNA08;
GRANT ALL ON REZERVACE TO XRUSNA08;
GRANT ALL ON POKOJ TO XRUSNA08;
GRANT ALL ON SLUZBA TO XRUSNA08;
GRANT ALL ON PROVEDENA_SLUZBA TO XRUSNA08;

GRANT EXECUTE ON proc1 TO XRUSNA08;
GRANT EXECUTE ON proc2 TO XRUSNA08;

-- XSPACE38
GRANT ALL ON ZAKAZNIK TO XSPACE38;
GRANT ALL ON OBJEDNAVKA TO XSPACE38;
GRANT ALL ON REZERVACE TO XSPACE38;
GRANT ALL ON POKOJ TO XSPACE38;
GRANT ALL ON SLUZBA TO XSPACE38;
GRANT ALL ON PROVEDENA_SLUZBA TO XSPACE38;

GRANT EXECUTE ON proc1 TO XSPACE38;
GRANT EXECUTE ON proc2 TO XSPACE38;

-----------------------------------------------------------
-- Explain Plan
EXPLAIN PLAN FOR
SELECT ro.POCET_LUZEK, COUNT(*) AS NUM_RESERVATIONS
FROM POKOJ ro
JOIN REZERVACE re ON ro.ID_POKOJE = re.REZERVACE_POKOJ_ID
GROUP BY ro.POCET_LUZEK;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- explain plan s indexem, pro ukazku optimalizace selectu
CREATE INDEX x ON POKOJ(POCET_LUZEK);
EXPLAIN PLAN FOR
SELECT ro.POCET_LUZEK, COUNT(*) AS NUM_RESERVATIONS
FROM POKOJ ro
JOIN REZERVACE re ON ro.ID_POKOJE = re.REZERVACE_POKOJ_ID
GROUP BY ro.POCET_LUZEK;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY('ALL +INDEXES'));

-----------------------------------------------------------
-- Materializovany pohled

CREATE MATERIALIZED VIEW MV_PLAT_ZAKAZNIKA
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT c.JMENO || ' ' || c.PRIJMENI AS MENO_ZAKAZNIKA,
SUM(r.CASTKA) AS CELKOVY_PLAT
FROM ZAKAZNIK c
JOIN OBJEDNAVKA co ON c.ID_ZAKAZNIKA = co.ZAKAZNIK_ID
JOIN REZERVACE r ON co.ID_OBJEDNAVKY = r.REZERVACE_OBJEDNAVKA_ID
GROUP BY c.ID_ZAKAZNIKA, c.JMENO, c.PRIJMENI;

-----------------------------------------------------------
-- Materializovany pohled - permissions

GRANT ALL ON MV_PLAT_ZAKAZNIKA TO XRUSNA08;
GRANT ALL ON MV_PLAT_ZAKAZNIKA TO XSPACE38;