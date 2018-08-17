
James Rho
-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
        
        SELECT * FROM employee;
-- Task – Select all records from the Employee table where last name is King.
       
        SELECT * FROM employee
	    WHERE lastname = 'King';
-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
       
        SELECT * FROM employee
	    WHERE firstname = 'Andrew' and reportsto IS NULL;
-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.

        SELECT * FROM album
        ORDER BY title DESC;
-- Task – Select first name from Customer and sort result set in ascending order by city
        SELECT firstname FROM customer
        ORDER BY city ASC;
-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
        INSERT INTO genre(genreid,name) VALUES(26,'KPOP'),(27,'Crazy');
-- Task – Insert two new records into Employee table
        INSERT INTO employee(employeeid,lastname,firstname,title,city,state,country) VALUES (9,'Rho','James','IT Staff','Tampa','FL','USA'),
        (10,'Dark','Batman','Hero','Everywhere','Everywhere','Everywhere');
-- Task – Insert two new records into Customer table
        INSERT INTO customer(customerid,lastname,firstname,company,email) VALUES (60,'Rho','James','Revature','no-email'),
        (61,'Dark','Batman','Revature','no-email');
-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
        UPDATE customer
        SET firstname = 'Robert', lastname='Walter'
        WHERE customerid =
        (SELECT customerid FROM customer WHERE firstname = 'Aaron' and lastname = 'Mitchell');

-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
        UPDATE artist
        SET name = 'CCR'
        WHERE name = (SELECT name FROM artist WHERE name = 'Creedence Clearwater Revival');
-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
        SELECT * FROM invoice
        WHERE billingaddress LIKE 'T%';

-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
        SELECT * FROM invoice
        where billingaddress LIKE 'T%';
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
        SELECT * FROM employee
        WHERE hiredate BETWEEN '2003-06-01' and '2004-03-01' ORDER BY employeeid;
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
      DELETE FROM invoiceline
        WHERE invoiceid IN (
                SELECT invoiceid FROM invoice
                WHERE customerid IN (
                        SELECT customerid FROM customer
                        WHERE firstname = 'Robert' AND lastname = 'Walter'));
                        
        DELETE FROM invoice
        WHERE customerid IN (
                SELECT customerid FROM customer
                WHERE firstname = 'Robert' AND lastname = 'Walter');

        DELETE FROM customer
        WHERE firstname = 'Robert' AND lastname = 'Walter';
-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
       CREATE OR REPLACE FUNCTION give_time()
        RETURNS varchar AS $$
        BEGIN
                RETURN (SELECT CURRENT_TIMESTAMP);
        END;
        $$LANGUAGE plpgsql;
        SELECT give_time();
-- Task – create a function that returns the length of a mediatype from the mediatype table
        CREATE OR REPLACE FUNCTION give_length_mediatype(mediatype_id INT)
                RETURNS integer AS $$
        BEGIN
	RETURN (SELECT LENGTH(name) AS LengthOfEntry From mediatype
		   WHERE mediatypeid = mediatype_id);
        END;
        $$LANGUAGE plpgsql;
        select give_length_mediatype(1);
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
        CREATE OR REPLACE FUNCTION give_average_total_allinvoice()
                RETURNS numeric(100,2) AS $$
        BEGIN
	RETURN (SELECT AVG(total)
			FROM invoice);
        END;
        $$LANGUAGE plpgsql;
        SELECT give_average_total_allinvoice();
-- Task – Create a function that returns the most expensive track

        CREATE OR REPLACE FUNCTION give_most_expensiveTrack()
        RETURNS SETOF track AS $$
        BEGIN
        RETURN QUERY SELECT * FROM track WHERE unitprice = (SELECT MAX(unitprice) FROM track);
        END;
        $$ LANGUAGE plpgsql;

        select give_most_expensivetrack();

-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
        CREATE OR REPLACE FUNCTION avgPriceofItem()
        RETURNS TABLE(avg_total numeric(10,2) AS $$
        BEGIN
        RETURN QUERY (SELECT AVG(unitprice) FROM invoiceline);
        END;
        $$LANGUAGE plpgsql;

-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
      
        CREATE OR REPLACE FUNCTION find_employees_bornAfter_1968()
        RETURNS SETOF employee  AS $$
        BEGIN
        RETURN QUERY SELECT * FROM employee WHERE birthdate >= '1968-01-01';
        END;
        $$ LANGUAGE plpgsql;

-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
        CREATE OR REPLACE FUNCTION give_first_and_lastname()
        RETURNS Table(f_name VARCHAR(20),l_name VARCHAR(20))  AS $$
        BEGIN
        RETURN QUERY SELECT firstname,lastname FROM employee;
        END;
        $$ LANGUAGE plpgsql;
        select give_first_and_lastname();
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
        CREATE OR REPLACE FUNCTION update_personal_info(old_e_id INTEGER,  l_name VARCHAR(20), f_name VARCHAR(20),new_address VARCHAR(70), new_city VARCHAR(40),new_state VARCHAR(40),
								new_county VARCHAR(40),new_postalcode VARCHAR(10), new_phone VARCHAR(24), new_fax VARCHAR(24),new_email VARCHAR(60))
        RETURNS void AS $$
        BEGIN 
        UPDATE employee
        SET 
        employeeid = old_e_id, lastname = l_name, firstname = f_name, address= new_address, city= new_city,state=new_state,
                                country=new_county,postalcode = new_postalcode,phone=new_phone, fax=new_fax, email = new_email
        WHERE employeeid = old_e_id;
        END;
        $$ LANGUAGE plpgsql;


-- Task – Create a stored procedure that returns the managers of an employee.
        CREATE OR REPLACE FUNCTION give_manager()
        RETURNS SETOF employee AS $$
        BEGIN
        RETURN QUERY SELECT * from employee where title LIKE '%Manager';
        END;
        $$ LANGUAGE plpgsql;

-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
        CREATE OR REPLACE FUNCTION get_name_company_customer()
        RETURNS TABLE(f_name VARCHAR(40),l_name VARCHAR(40),c_name VARCHAR(80)) AS $$
        BEGIN 
                RETURN QUERY select firstname,lastname,company from customer;
        END;
        $$ LANGUAGE plpgsql;
-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
        CREATE OR REPLACE FUNCTION delete_invoice(id INTEGER)
        RETURNS void as $$
        BEGIN 
        DELETE FROM invoiceline
        WHERE invoiceid IN (SELECT invoiceid FROM invoice);
        DELETE FROM invoice
        WHERE invoiceid = id;
        END;
        $$ LANGUAGE plpgsql;
-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
        CREATE OR REPLACE FUNCTION sign_customer(cus_id INTEGER,f_name VARCHAR(40),l_name VARCHAR(20),
									   new_comp VARCHAR(80),new_add VARCHAR(70),new_city VARCHAR(40),
									   new_state VARCHAR(40),new_country VARCHAR(40),new_post VARCHAR(10),
									   new_phone VARCHAR(24),new_fax VARCHAR(24),new_email VARCHAR(60))
        RETURNS void AS $$
        BEGIN
        INSERT INTO customer (customerid, firstname, lastname,company,address,city,state,country,postalcode,phone,fax,email)
        VALUES (cus_id, f_name, l_name, new_comp,new_add,new_city,new_state,new_country,new_post,new_phone,new_fax,new_email);
        END;
        $$ LANGUAGE plpgsql;
-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
        CREATE TABLE e_log(
        new_employeeid VARCHAR(40),
        new_lastname VARCHAR(40),
        new_firstname VARCHAR(40)
  );
        CREATE OR REPLACE FUNCTION employee_trig()
        RETURNS TRIGGER AS $$
        BEGIN
        IF(TG_OP = 'INSERTING') THEN
        INSERT INTO employee_log (
                new_employeeid,
                new_lastname,
                new_firstname
                )
                VALUES (
                NEW.employeeid,
                NEW.lastname,
                NEW.firstname
                );

        END IF;
        RETURN NEW; 
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER employee_trigger
        AFTER INSERT ON employee
        FOR EACH ROW
        EXECUTE PROCEDURE employee_trig();
       
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
        CREATE TABLE album_log(old_albumid VARCHAR(40), new_albumid VARCHAR(40),  old_title VARCHAR(40),  new_title VARCHAR(40), old_artistid VARCHAR(40), new_artistid VARCHAR(40));
        CREATE OR REPLACE FUNCTION update_album_trig()
        RETURNS TRIGGER AS $$
        BEGIN
        IF(TG_OP = 'UPDATING') THEN
        INSERT INTO album_log ( old_albumid, new_albumid,old_title,new_title, old_artistid,new_artistid)
                VALUES (OLD.albumid,NEW.albumid,OLD.title,NEW.title,OLD.artistid,NEW.artistid);

        END IF;
        RETURN NEW; 
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER lbum_trigger
        AFTER UPDATE ON album
        FOR EACH ROW
        EXECUTE PROCEDURE album_trig();

-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
        CREATE TABLE customer_log(old_customerid VARCHAR(20),old_firstname VARCHAR(20),old_lastname VARCHAR(20));
        CREATE OR REPLACE FUNCTION customer_trig()
        RETURNS TRIGGER AS $$
        BEGIN
        IF(TG_OP = 'DELETING') THEN
        INSERT INTO customer_log (
                old_customerid,	
                old_firstname,
                old_lastname
                )
                VALUES (
                OLD.customerid,
                OLD.firstname,
                OLD.lastname
                );

        END IF;
        RETURN NEW; 
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER customer_trigger
        AFTER DELETE ON customer
        FOR EACH ROW
        EXECUTE PROCEDURE customer_trig();

-- 6.2 INSTEAD OF
-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.




-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
    SELECT customer.firstname, customer.lastname, invoice.invoiceid 
    FROM customer INNER JOIN invoice ON (customer.customerid = invoice.customerid);
-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
        SELECT customer.customerid, customer.firstname,
		customer.lastname, invoice.invoiceid,
		invoice.total 
		FROM customer 
                FULL OUTER JOIN invoice ON 
		(customer.customerid = invoice.customerid);
-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
        SELECT artist.name, album.title
	FROM album
	RIGHT JOIN artist ON 
	(album.artistid = artist.artistid);
-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
        SELECT * FROM album
	CROSS JOIN artist
	ORDER BY artist.name ASC;
-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
        SELECT * FROM employee a
	INNER JOIN employee b
	ON a.reportsto = b.employeeid;







