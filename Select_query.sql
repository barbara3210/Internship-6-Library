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
WHERE b.returntime IS NULL;



