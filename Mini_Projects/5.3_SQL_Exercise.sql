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
  
   Ans 1: SELECT * FROM country_club.Facilities WHERE membercost >0;


/* Q2: How many facilities do not charge a fee to members? */

   Ans 2: SELECT COUNT( * ) FROM country_club.Facilities WHERE membercost = 0;


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

   Ans 3: SELECT facid, name, membercost, monthlymaintenance
            FROM `Facilities`
           WHERE membercost >0
             AND membercost < ( monthlymaintenance *20 /100 )


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
  
   Ans 4: SELECT * FROM `Facilities` where facid IN (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

   Ans 5: SELECT f . * , IF( monthlymaintenance >100, 'expensive', 'cheap' ) AS cheap_expensive
          FROM `Facilities` f


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

   Ans 6: SELECT firstname, surname FROM `Members` f
           WHERE joindate IN (SELECT MAX(joindate) FROM `Members`)



/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

   Ans 7: SELECT DISTINCT f.name, CONCAT( m.firstname, ' ', m.surname )
            FROM `Members` m, `Bookings` b, `Facilities` f
           WHERE b.facid = f.facid
             AND b.memid = m.memid
             AND f.name LIKE 'Tennis%'
           ORDER BY m.firstname;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost. 
Order by descending cost, and do not use any subqueries. */

  Ans 8: SELECT f.name, CONCAT( m.firstname, ' ', m.surname ) member_name, IF(b.memid=0 , f.guestcost * b.slots,f.membercost * b.slots ) total_cost
		   FROM Bookings b, Members m, Facilities f
		  WHERE b.memid = m.memid
		    AND b.facid = f.facid
		    AND b.starttime  LIKE '2012-09-14%'
		    AND ((b.memid !=0 AND f.membercost * b.slots >30)
                  OR (b.memid =0 AND f.guestcost * b.slots >30)
                )
         ORDER BY total_cost desc;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

   Ans 9: SELECT a.name,CONCAT( m.firstname, ' ', m.surname ) member_name, a.total_cost
          FROM  Members m, 
               (SELECT f.name,b.memid, IF(b.memid=0 , f.guestcost * b.slots,f.membercost * b.slots ) total_cost
		   FROM Bookings b, Facilities f
		  WHERE b.facid = f.facid
		    AND b.starttime  LIKE '2012-09-14%'
		    AND ((b.memid !=0 AND f.membercost * b.slots >30)
                  OR (b.memid =0 AND f.guestcost * b.slots >30)
                )
               ) a
          ORDER BY a.total_cost desc;


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

   Ans 10: SELECT facid, name,sum(revenue) grossrevenue FROM
           (select f.*, 
                   CASE
                      WHEN memid=0 THEN (slots*guestcost)
                      ELSE (slots*membercost)
                   END as revenue
              from `Bookings` b, `Facilities` f
             WHERE  b.facid = f.facid) a
          GROUP BY facid,name
          HAVING grossrevenue < 1000
          ORDER BY grossrevenue;
