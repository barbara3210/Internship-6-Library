-- Database: Library_DUMP

CREATE TABLE Libraries(
	id_library SERIAL PRIMARY KEY,
	name VARCHAR(50),
	openTime TIME,
	closeTime TIME
);

CREATE TABLE Books(
	id_book SERIAL PRIMARY KEY,
	title VARCHAR(100),
	booktype VARCHAR(50)
);

CREATE TABLE Countries(
	id_country SERIAL PRIMARY KEY,
	name VARCHAR(50),
	population INT,
	avg_income DECIMAL
);

CREATE TABLE Authors(
	id_author SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	id_country INT,
	gender VARCHAR(1),
	FOREIGN KEY (id_country) REFERENCES Countries(id_country)
);

CREATE TABLE Librarians(
	id_librarian SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	id_country INT,
	id_library INT,
	gender VARCHAR(1),
	FOREIGN KEY (id_country) REFERENCES Countries(id_country),
	FOREIGN KEY (id_library) REFERENCES Libraries(id_library)
	
);

CREATE TABLE BookCopies (
    code VARCHAR(255) NOT NULL,
    id_book INT,
	id_author INT,
	releseDate DATE,
	PRIMARY KEY (id_book, id_author)
    
);

CREATE TABLE Users(
	id_user SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	gender VARCHAR(10)
);

CREATE TABLE Borrowing (
    id_user INT,
    id_copy INT,
	id_librarian INT,
    borrowTime DATE,
    PRIMARY KEY (id_user, id_copy),
	FOREIGN KEY (id_librarian) REFERENCES Librarians(id_librarian)
);


CREATE OR REPLACE PROCEDURE BookBorrowing(in_id_copy INT, in_id_user INT)
LANGUAGE plpgsql
AS $$
DECLARE
    borrowTime DATE;
    dueDate DATE;
    summerSeason BOOLEAN;
    fee DECIMAL;
    lektira BOOLEAN;
    v_copy INT;
    v_code VARCHAR(255);
BEGIN
    -- borrowed when
    SELECT borrowTime INTO borrowTime
    FROM Borrowing
    WHERE id_copy = in_id_copy AND id_user = in_id_user;

    -- seasons
    summerSeason := CASE
                        WHEN EXTRACT(MONTH FROM borrowTime) BETWEEN 6 AND 9 THEN TRUE
                        ELSE FALSE
                    END;

    -- copy type
    SELECT bc.id_copy, bc.code, bo.booktype
    INTO v_copy, v_code, lektira
    FROM BookCopies bc
    JOIN Books bo ON bc.id_book = bo.id_book
    WHERE bc.id_copy = in_id_copy;

    -- update borrow time NOW
    borrowTime := CURRENT_DATE;

    dueDate := CURRENT_DATE + INTERVAL '20 days';

    IF summerSeason THEN
        IF EXTRACT(ISODOW FROM dueDate) IN (6, 7) THEN
            fee := 0.2;
        ELSE
            fee := 0.3;
        END IF;
    ELSE
        IF lektira THEN
            fee := 0.5;
        ELSE
            IF EXTRACT(ISODOW FROM dueDate) IN (6, 7) THEN
                fee := 0.2;
            ELSE
                fee := 0.4;
            END IF;
        END IF;
    END IF;

    INSERT INTO Borrowing (id_user, id_copy, borrowTime)
    VALUES (in_id_user, in_id_copy, borrowTime);

    RAISE NOTICE 'Zakasnina iznosi % EUR po danu.', fee;

END;
$$;

