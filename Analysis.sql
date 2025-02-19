
/*
Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
*/
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

/*
Task 2: Update an Existing Member's Address
*/

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

/*
Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
*/
SELECT * FROM issued_status

DELETE FROM  issued_status WHERE issued_id = 'IS113'

/*
Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
*/
SELECT * From issued_status
WHERE issued_emp_id = 'E101'

/*
Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book
*/

SELECT issued_emp_id,count(*) as IssuedCNT FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) >1

/*
Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
*/

SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count into book_issued_cnt
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

/*Task 7. Retrieve All Books in a Specific Category:*/
SELECT * FROM books
WHERE category = 'Fantasy'

/*
Task 8: Find Total Rental Income by Category:
*/

SELECT category,Sum(Rental_Price) as Total_rental_income, COUNT(*) as Book_CNT FROM 
books A JOIN issued_status B on a.isbn = b.issued_book_isbn
GROUP BY category
ORder by Sum(Rental_Price) desc



/* TASK9: List Members Who Registered in the Last 2:*/

SELECT * FROM members
WHere YEAR(GETDATE()) - Year(Reg_date)  <=  2

/*TASK 10 : List Employees with Their Branch Manager's Name and their branch details:*/

SELECT Emp.emp_id,Emp.emp_name , Emp.position,BCH.*,Emp2.emp_name as Manager
FROM employees Emp JOIN branch BCH on Emp.branch_id = BCH.branch_id
JOIN employees Emp2 on emp2.emp_id = BCH.manager_id

/*
Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:10
*/
SELECT * into High_rental_books FROM books
WHERE rental_price > 7

/*Task 12: Retrieve the List of Books Not Yet Returned*/

SELECT * FROM return_status R JOIN issued_status I on R.issued_id = I.issued_id 
Where return_id Is NULL

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue.*/

SELECT * From Books
SELECT * FROM return_status
SELECT * FROM issued_status
SELECT * FROM members

BEGIN
SELECT M.member_id,m.member_name,b.book_title,i.issued_date, DATEDIFF(DAY,i.issued_date,GETDATE()) as OVerdue_days FROM 
issued_status I JOIN members m on m.member_id = I.issued_member_id
JOIN books b on b.isbn = i.issued_book_isbn
LEFT Join return_status R on I.issued_book_isbn = R.return_book_isbn
WHERE R.return_date is null and DATEDIFF(DAY,i.issued_date,GETDATE()) > 30;
END
/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/



CREATE OR ALTER PROCEDURE ADD_RETURN_RECORDS(
 @Return_id VARchar(10),
 @Issued_id Varchar(10),
 @book_quality Varchar(10)
)

AS
	DECLARE @bookname Varchar(100)
BEGIN
	-- INSERTING RECORDS BASED ON USER IMPUT
	INSERT INTO return_status(return_id,issued_id,return_date,book_quality)	
	VALUES (@Return_id,@Issued_id,GETDATE(),@book_quality)

	Set @bookname = (SELECT book_title From books where isbn = (SELECT issued_book_isbn FROM issued_status where issued_id = @Issued_id))

	UPDATE books
	SET status = 'yes'
	WHERE ISBN =  (SELECT issued_book_isbn FROM issued_status where issued_id = @Issued_id)
	PRINT('Thank you for return the book:' + @bookname)

END

EXEC ADD_RETURN_RECORDS 'RS148', 'IS140', 'Good'


/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued,
the number of books returned, and the total revenue generated from book rentals.*/

SELECT * FROM branch;
SELECT * FROM books;
SELECT * FROM return_status
SELECT * FROM issued_status
SELECT * FROM members
SELECT * FROM employees

SELECT B.branch_id,B.branch_address,Count(i.issued_id) As Total_books_issued
	,Count(r.return_id) As Total_books_returned
	,Sum(Bk.rental_price) as Total_rental_Income
FROM branch B JOIN employees E on b.branch_id = e.branch_id
JOIN issued_status I on i.issued_emp_id = e.emp_id
JOIN return_status R on R.issued_id = I.issued_id
JOIN books BK on BK.isbn = I.issued_book_isbn
GROUP BY B.branch_id,B.branch_address


/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
*/
SELECT * FROM books
SELECT * FROM issued_status
SELECT * FROM members

SELECT member_name as Active_member FROM members 
WHERE member_id IN (SELECT issued_member_id FROM issued_status
					WHERE DATEDIFF(MONTH,issued_date,GETDATE())<=2)

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.
*/

SELECT TOP 3 E.emp_id,E.emp_name,b.branch_id,Count(i.issued_book_isbn) AS Number_books_processed
FROM employees E JOIN branch B on E.branch_id = B.branch_id
JOIN issued_status I on I.issued_emp_id =E.emp_id
GROUP BY E.emp_id,E.emp_name,b.branch_id
ORDER BY Count(i.issued_book_isbn) DESC

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.
*/