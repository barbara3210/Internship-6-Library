--●	ime, prezime, spol (ispisati ‘MUŠKI’, ‘ŽENSKI’, ‘NEPOZNATO’, ‘OSTALO’;), ime države i  prosječna plaća u toj državi svakom autoru
SELECT a.first_name,a.last_name,
    CASE
        WHEN a.gender = 'M' THEN 'MALE'
        WHEN a.gender = 'F' THEN 'FEMALE'
        WHEN a.gender = 'U' THEN 'UNDEFINED'
        ELSE 'OTHER'
    END AS "Gender",
    c.name AS "Country",
    c.avg_income 
FROM Authors a
JOIN Countries c ON a.id_country = c.id_country;

--●	naziv i datum objave svake znanstvene knjige zajedno s imenima glavnih autora koji su na njoj radili, pri čemu imena autora moraju biti u jednoj ćeliji i u obliku Prezime, I.; npr. Puljak, I.; Godinović, N.; Bilušić, A.
SELECT bo.title AS "Book",
	--STRING_AGG(CONCAT(a.last_name, ', ', a.first_name, '; '), '') WITHIN GROUP (ORDER BY a.last_name) AS "Glavni autori"
    ARRAY_TO_STRING(ARRAY_AGG(CONCAT(a.last_name, ', ', a.first_name)), '; ') AS "Glavni autori"
FROM BookCopies bc
JOIN Books bo ON bc.id_book = bo.id_book
JOIN Authors a ON bc.id_author = a.id_author
WHERE bo.booktype = 'science'
GROUP BY bo.title;

--●	top 3 knjižnice s najviše primjeraka knjiga
SELECT lib.name AS "Library", COUNT(bc.id_copy) AS "Num_copies"
FROM Libraries lib
JOIN Librarians lb ON lib.id_library = lb.id_library
JOIN BookCopies bc ON lb.id_librarian = bc.id_librarian 
GROUP BY lib.name
ORDER BY COUNT(bc.id_copy) DESC LIMIT 3;

--●	po svakoj knjizi broj ljudi koji su je pročitali (korisnika koji posudili bar jednom)
SELECT bo.title AS "Book",
    COUNT(DISTINCT br.id_user) AS "Users_read"
FROM Books bo
JOIN BookCopies bc ON bo.id_book = bc.id_book
LEFT JOIN Borrowing br ON bc.id_copy = br.id_copy
GROUP BY bo.title;

--●	imena svih korisnika koji imaju trenutno posuđenu knjigu
SELECT u.first_name, u.last_name 
FROM Users u
JOIN Borrowing b ON u.id_user = b.id_user
WHERE b.returnTime IS NULL;

--●	sve autore kojima je bar jedna od knjiga izašla između 2019. i 2022.
SELECT DISTINCT a.first_name, a.last_name, bc.releseDate
FROM Authors a
JOIN BookCopies bc ON a.id_author = bc.id_author
JOIN Books bo ON bc.id_book = bo.id_book
WHERE EXTRACT(YEAR FROM bc.releseDate) BETWEEN 2019 AND 2022;

--●	ime države i broj umjetničkih knjiga po svakoj (ako su dva autora iz iste države, računa se kao jedna knjiga), gdje su države sortirane po broju živih autora od najveće ka najmanjoj 

--●	po svakoj kombinaciji autora i žanra (ukoliko postoji) broj posudbi knjiga tog autora u tom žanru
SELECT a.first_name, a.last_name, bo.booktype,
    COUNT(br.id_borrow) AS borrowed
FROM Authors a
JOIN BookCopies bc ON a.id_author = bc.id_author
JOIN Books bo ON bc.id_book = bo.id_book
LEFT JOIN Borrowing br ON bc.id_copy = br.id_copy
GROUP BY a.first_name, a.last_name, bo.booktype

--●	po svakom članu koliko trenutno duguje zbog kašnjenja; u slučaju da ne duguje ispiši “ČISTO”

--●	autora i ime prve objavljene knjige istog
SELECT a.id_author, a.first_name,a.last_name, bo.title AS "First_book"
FROM Authors a
JOIN BookCopies bc ON a.id_author = bc.id_author
JOIN Books bo ON bc.id_book = bo.id_book
WHERE (a.id_author, bc.relesedate) IN (
        SELECT a.id_author, MIN(bc.relesedate) AS "First_book"
        FROM Authors a
        JOIN BookCopies bc ON a.id_author = bc.id_author
        JOIN Books bo ON bc.id_book = bo.id_book
        GROUP BY a.id_author
    );

--●	knjige i broj aktivnih posudbi, gdje se one s manje od 10 aktivnih ne prikazuju
SELECT bc.id_copy, bo.title,
	COUNT(b.id_borrow) AS "Active_borrow"
FROM BookCopies bc
JOIN Books bo ON bc.id_book = bo.id_book
JOIN Borrowing br ON bc.id_copy = br.id_copy
GROUP BY bc.id_copy, bo.title
HAVING COUNT(br.id_borrow) >= 10;

--●	prosječan broj posudbi po primjerku knjige po svakoj državi
SELECT co.name AS country,
    AVG(COUNT(br.id_borrow)) AS "avg_borrowings_per_copy"
FROM Countries co
JOIN Authors a ON co.id_country = a.id_country
JOIN BookCopies bc ON a.id_author = bc.id_author
JOIN Borrowing br ON bc.id_copy = b.id_copy
GROUP BY co.name;

--●	broj autora (koji su objavili više od 5 knjiga) po struci, desetljeću rođenja i spolu; u slučaju da je broj autora manji od 10, ne prikazuj kategoriju; poredaj prikaz po desetljeću rođenja
SELECT EXTRACT(DECADE FROM a.birth_date) AS "Dacade",
    a.gender,COUNT(DISTINCT a.id_author) AS author_count
FROM Authors a
JOIN BookCopies bc ON a.id_author = bc.id_author
GROUP BY birth_decade, a.gender
HAVING COUNT(DISTINCT a.id_author) > 5
ORDER BY birth_decade, gender;

