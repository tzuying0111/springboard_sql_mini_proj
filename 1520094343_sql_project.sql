/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM country_club.Facilities
WHERE membercost >0;


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( FACID )
FROM Facilities
WHERE MEMBERCOST =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name AS facility_name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid
BETWEEN 1
AND 5;


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance >100
THEN 'expensive'
ELSE 'cheap'
END as Expensive_or_Cheap
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT a.firstname, a.surname
FROM Members a
INNER JOIN (

SELECT MAX( joindate ) AS last_date
FROM Members
)b ON a.joindate = b.last_date;

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name AS court_name, CONCAT( m.firstname, ' ', m.surname ) AS member_name
FROM Bookings b
INNER JOIN Facilities f ON f.facid = b.facid
INNER JOIN Members m ON m.memid = b.memid
WHERE f.name LIKE 'tennis%'
ORDER BY member_name;

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS facility_name,
CASE WHEN m.memid =0
THEN m.firstname
ELSE CONCAT( m.firstname, ' ', m.surname )
END AS member_name,
CASE WHEN b.memid =0
THEN f.guestcost * SUM( b.slots )
ELSE f.membercost * SUM( b.slots )
END AS total_cost
FROM Bookings b
INNER JOIN Facilities f ON f.facid = b.facid
INNER JOIN Members m ON m.memid = b.memid
WHERE starttime LIKE '2012-09-14%'
GROUP BY f.name, member_name, b.bookid
HAVING total_cost >30
ORDER BY total_cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */



/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT f.name, SUM( a.total_revenue ) total_revenue
FROM Facilities f
JOIN (
SELECT b.memid,
CASE WHEN b.memid =0
THEN f.guestcost
ELSE f.membercost
END AS cost, b.slots,
CASE WHEN b.memid =0
THEN f.guestcost
ELSE f.membercost
END * b.slots AS total_revenue, f.facid
FROM Bookings b
INNER JOIN Facilities f ON f.facid = b.facid
)a ON a.facid = f.facid
GROUP BY f.name
HAVING SUM( a.total_revenue ) <1000;
