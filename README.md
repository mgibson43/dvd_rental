# WGU D326
## PostgreSQL
SQL code to extract a detailed table and summary table from the dvdrental database.
The code utilizes a function to transform the date from a timestamp to a readable varchar.
A stored procedure is created and is used to drop and recreate the detailed and summary table.
A trigger that is activated by insertions on the payment table will call a function that activates the stored procedure to rebuild the tables upon payment table insertion.
