# Library-System-Management
## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. 

![Library_project](https://github.com/Idris-lawal/Library-System-Management/blob/main/library.jpg)




## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD]((https://github.com/Idris-lawal/Library-System-Management/blob/main/library_erd.png))

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql

DROP DATABASE  library_db;

CREATE DATABASE library_db;

USE  library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(10),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```
**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * From issued_status
WHERE issued_emp_id = 'E101'
```
**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_emp_id,count(*) as IssuedCNT FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) >1
```

### 3. CTAS (Create Table As Select)
 not available in MSSQL so i used SELECT into instead
**Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count into book_issued_cnt
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```

### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Fantasy'
```

 **Task 8: Find Total Rental Income by Category**:

```sql
SELECT category,Sum(Rental_Price) as Total_rental_income, COUNT(*) as Book_CNT FROM 
books A JOIN issued_status B on a.isbn = b.issued_book_isbn
GROUP BY category
ORder by Sum(Rental_Price) desc
```

**Task 9: List Members Who Registered in the the Last 2**:
```sql
SELECT * FROM members
WHere YEAR(GETDATE()) - Year(Reg_date)  <=  2
```
**List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT Emp.emp_id,Emp.emp_name , Emp.position,BCH.*,Emp2.emp_name as Manager
FROM employees Emp JOIN branch BCH on Emp.branch_id = BCH.branch_id
JOIN employees Emp2 on emp2.emp_id = BCH.manager_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
SELECT * into High_rental_books FROM books
WHERE rental_price > 7
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM return_status R JOIN issued_status I on R.issued_id = I.issued_id 
Where return_id Is NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT M.member_id,m.member_name,b.book_title,i.issued_date, DATEDIFF(DAY,i.issued_date,GETDATE()) as OVerdue_days FROM 
issued_status I JOIN members m on m.member_id = I.issued_member_id
JOIN books b on b.isbn = i.issued_book_isbn
LEFT Join return_status R on I.issued_book_isbn = R.return_book_isbn
WHERE R.return_date is null and DATEDIFF(DAY,i.issued_date,GETDATE()) > 30;
```

**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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
```


**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
SELECT B.branch_id,B.branch_address,Count(i.issued_id) As Total_books_issued
	,Count(r.return_id) As Total_books_returned
	,Sum(Bk.rental_price) as Total_rental_Income
FROM branch B JOIN employees E on b.branch_id = e.branch_id
JOIN issued_status I on i.issued_emp_id = e.emp_id
JOIN return_status R on R.issued_id = I.issued_id
JOIN books BK on BK.isbn = I.issued_book_isbn
GROUP BY B.branch_id,B.branch_address
```
**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
SELECT member_name as Active_member FROM members 
WHERE member_id IN (SELECT issued_member_id FROM issued_status
					WHERE DATEDIFF(MONTH,issued_date,GETDATE())<=2)
```

**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT TOP 3 E.emp_id,E.emp_name,b.branch_id,Count(i.issued_book_isbn) AS Number_books_processed
FROM employees E JOIN branch B on E.branch_id = B.branch_id
JOIN issued_status I on I.issued_emp_id =E.emp_id
GROUP BY E.emp_id,E.emp_name,b.branch_id
ORDER BY Count(i.issued_book_isbn) DESC
```








