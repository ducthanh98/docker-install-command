# Mục lục
1.Kiến trúc MYSQL
2. Benchmark và tìm kiếm nghẽn cổ chai
3. Schema Optimization and indexing
4. Query Performance Optimization
5.Advanced MySQL Features

#  Schema Optimization and indexing
1.Choosing Optimal Data types
  - Smaller is better
  - Simple is good
    - : For example, integers are cheaper to compare than characters, because
character sets and collations (sorting rules) make character comparisons compli-
cated.
   - Avoid NULL if possible. 
     - It’s harder for MySQL to optimize queries that refer to nullable columns,
because they make indexes, index statistics, and value comparisons more com-
plicated
  - These types are useful when you need to store binary data and want MySQL to com-
pare the values as bytes instead of characters, binary comparisons can be much simpler than character comparisons, so they are
faster.
  - Storing the value 'hello' requires the same amount of space in a VARCHAR(5) and a
VARCHAR(200) column. The larger column can use much more mem-
ory, because MySQL often allocates fixed-size chunks of memory to hold values inter-
nally
- A FLOAT column uses four bytes of storage. DOUBLE consumes eight bytes and
has greater precision and a larger range of values

2.Choosing Identifiers
  - String : Each new value you generate with them
will be distributed in arbitrary ways over a large space, which can slow INSERT
and some types of SELECT queries: 
    - They slow INSERT queries because the inserted value has to go in a random
location in indexes. This causes page splits, random disk accesses, and clus-
tered index fragmentation for clustered storage engines.
    - They slow SELECT queries because logically adjacent rows will be widely dis-
persed on disk and in memory.
    - Random values cause caches to perform poorly for all types of queries
because they defeat locality of reference, which is how caching works. If the
entire data set is equally “hot,” there is no advantage to having any particu-
lar part of the data cached in memory, and if the working set does not fit in
memory, the cache will have a lot of flushes and misses




3.Index
  - B-Index 
    - Match the full value
  A match on the full key value specifies values for all columns in the index. For
  example, this index can help you find a person named Cuba Allen who was born
  on 1960-01-01.
    - Match a leftmost prefix
  This index can help you find all people with the last name Allen. This uses only
  the first column in the index.
    - Match a column prefix
  You can match on the first part of a column’s value. This index can help you
  find all people whose last names begin with J. This uses only the first column in
  the index.
    - Match a range of values
  This index can help you find people whose last names are between Allen and
  Barrymore. This also uses only the first column.
    - Match one part exactly and match a range on another part
  This index can help you find everyone whose last name is Allen and whose first
  name starts with the letter K (Kim, Karl, etc.). This is an exact match on last_
  name and a range query on first_name .
    - Index-only queries
  B-Tree indexes can normally support index-only queries, which are queries that
  access only the index, not the row storage. We discuss this optimization in
  “Covering Indexes” on page 120.
  - Hash Index
    - Because the index contains only hash codes and row pointers rather than the val-
    ues themselves, MySQL can’t use the values in the index to avoid reading the
    rows. Fortunately, accessing the in-memory rows is very fast, so this doesn’t usu-
    ally degrade performance.
    - MySQL can’t use hash indexes for sorting because they don’t store rows in
    sorted order.
    - Hash indexes don’t support partial key matching, because they compute the
    hash from the entire indexed value. That is, if you have an index on (A,B) and
    your query’s WHERE clause refers only to A , the index won’t help.
    - Hash indexes support only equality comparisons that use the = , IN( ) , and <=>
    operators (note that <> and <=> are not the same operator). They can’t speed up
    range queries, such as WHERE price > 100 .
    - Accessing data in a hash index is very quick, unless there are many collisions
    (multiple values with the same hash). When there are collisions, the storage
    engine must follow each row pointer in the linked list and compare their values
    to the lookup value to find the right row(s).
    - Some index maintenance operations can be slow if there are many hash colli-
    sions. For example, if you create a hash index on a column with a very low selec-
    tivity (many hash collisions) and then delete a row from the table, finding the
    pointer from the index to that row might be expensive. The storage engine will
    have to examine each row in that hash key’s linked list to find and remove the
    reference to the one row you deleted

# Indexing Strategies for High Performance
  - Isolate the Column
    - “Isolating” the column means it should not be part of an expression or be inside a function in the query.
  - Prefix Indexes and Index Selectivity

  - Clustered Indexes
    - Clustered indexes * aren’t a separate type of index. Rather, they’re an approach to data
storage
    - If you don’t define a primary key, InnoDB will try to use a unique nonnullable index
instead. If there’s no such index, InnoDB will define a hidden primary key for you
and then cluster on that. * InnoDB clusters records together only within a page. Pages
with adjacent key values may be distant from each other


# Using Index Scans for Sorts
  - Here are some queries that cannot use the index for sorting:
    - This query uses two different sort directions, but the index’s columns are all
sorted ascending:
    ... WHERE rental_date = '2005-05-25' ORDER BY inventory_id DESC, customer_id ASC;
    - Here, the ORDER BY refers to a column that isn’t in the index:
    ... WHERE rental_date = '2005-05-25' ORDER BY inventory_id, staff_id;
    - Here, the WHERE and the ORDER BY don’t form a leftmost prefix of the index:
    ... WHERE rental_date = '2005-05-25' ORDER BY customer_id;
# Packed (Prefix-Compressed) Indexes

4.Query Performance Optimization
Follow along with the illustration to see what happens when you send MySQL a
query:
  - The client sends the SQL statement to the server.
  -  The server checks the query cache. If there’s a hit, it returns the stored result
from the cache; otherwise, it passes the SQL statement to the next step.
  -  The server parses, preprocesses, and optimizes the SQL into a query execution
plan.
  -  The query execution engine executes the plan by making calls to the storage
engine API.
  -  The server sends the result to the client.
Here are some types of optimizations MySQL knows how to do:

Reordering joins
Tables don’t always have to be joined in the order you specify in the query.
Determining the best join order is an important optimization; we explain it in
depth in “The join optimizer” on page 173.
Converting OUTER JOIN s to INNER JOIN s
An OUTER JOIN doesn’t necessarily have to be executed as an OUTER JOIN . Some
factors, such as the WHERE clause and table schema, can actually cause an OUTER
JOIN to be equivalent to an INNER JOIN . MySQL can recognize this and rewrite the
join, which makes it eligible for reordering.
Applying algebraic equivalence rules
MySQL applies algebraic transformations to simplify and canonicalize expres-
sions. It can also fold and reduce constants, eliminating impossible constraints
and constant conditions. For example, the term (5=5 AND a>5) will reduce to just
a>5 . Similarly, (a<b AND b=c) AND a=5 becomes b>5 AND b=c AND a=5 . These rules are
very useful for writing conditional queries, which we discuss later in the chapter.
COUNT( ) , MIN( ) , and MAX( ) optimizations
Indexes and column nullability can often help MySQL optimize away these
expressions. For example, to find the minimum value of a column that’s left-
most in a B-Tree index, MySQL can just request the first row in the index. It can
even do this in the query optimization stage, and treat the value as a constant for
the rest of the query. Similarly, to find the maximum value in a B-Tree index, the
server reads the last row. If the server uses this optimization, you’ll see “Select
tables optimized away” in the EXPLAIN plan. This literally means the optimizer
has removed the table from the query plan and replaced it with a constant.
Likewise, COUNT(*) queries without a WHERE clause can often be optimized away
on some storage engines (such as MyISAM, which keeps an exact count of rows
in the table at all times). See “Optimizing COUNT( ) Queries” on page 188, later
in this chapter, for details.
Evaluating and reducing constant expressions
When MySQL detects that an expression can be reduced to a constant, it will do
so during optimization. For example, a user-defined variable can be converted to
a constant if it’s not changed in the query. Arithmetic expressions are another
example.
Perhaps surprisingly, even something you might consider to be a query can be
reduced to a constant during the optimization phase. One example is a MIN( ) on
an index. This can even be extended to a constant lookup on a primary key or
unique index. If a WHERE clause applies a constant condition to such an index, the
optimizer knows MySQL can look up the value at the beginning of the query. It
will then treat the value as a constant in the rest of the query. Here’s an example:
mysql> EXPLAIN SELECT film.film_id, film_actor.actor_id
-> FROM sakila.film
->
INNER JOIN sakila.film_actor USING(film_id)
-> WHERE film.film_id = 1;
+----+-------------+------------+-------+----------------+-------+------+
| id | select_type | table
| type | key
| ref
| rows |
+----+-------------+------------+-------+----------------+-------+------+
| 1 | SIMPLE
| film
| const | PRIMARY
| const |
1 |
| 1 | SIMPLE
| film_actor | ref
| idx_fk_film_id | const |
10 |
+----+-------------+------------+-------+----------------+-------+------+

MySQL executes this query in two steps, which correspond to the two rows in
the output. The first step is to find the desired row in the film table. MySQL’s
optimizer knows there is only one row, because there’s a primary key on the
film_id column, and it has already consulted the index during the query optimi-
zation stage to see how many rows it will find. Because the query optimizer has a
known quantity (the value in the WHERE clause) to use in the lookup, this table’s
ref type is const .
In the second step, MySQL treats the film_id column from the row found in the
first step as a known quantity. It can do this because the optimizer knows that
by the time the query reaches the second step, it will know all the values from
the first step. Notice that the film_actor table’s ref type is const , just as the film
table’s was.
Another way you’ll see constant conditions applied is by propagating a value’s
constant-ness from one place to another if there is a WHERE , USING , or ON clause
that restricts them to being equal. In this example, the optimizer knows that the
USING clause forces film_id to have the same value everywhere in the query—it
must be equal to the constant value given in the WHERE clause.
Covering indexes
MySQL can sometimes use an index to avoid reading row data, when the index
contains all the columns the query needs. We discussed covering indexes at
length in Chapter 3.
Subquery optimization
MySQL can convert some types of subqueries into more efficient alternative
forms, reducing them to index lookups instead of separate queries.
Early termination
MySQL can stop processing a query (or a step in a query) as soon as it fulfills the
query or step. The obvious case is a LIMIT clause, but there are several other
kinds of early termination. For instance, if MySQL detects an impossible condi-
tion, it can abort the entire query. You can see this in the following example:
mysql> EXPLAIN SELECT film.film_id FROM sakila.film WHERE film_id = -1;
+----+...+-----------------------------------------------------+
| id |...| Extra
|
+----+...+-----------------------------------------------------+
| 1 |...| Impossible WHERE noticed after reading const tables |
+----+...+-----------------------------------------------------+

This query stopped during the optimization step, but MySQL can also terminate
execution sooner in some cases. The server can use this optimization when the
query execution engine recognizes the need to retrieve distinct values, or to stop
when a value doesn’t exist. For example, the following query finds all movies
without any actors: *
mysql> SELECT film.film_id
-> FROM sakila.film
->
LEFT OUTER JOIN sakila.film_actor USING(film_id)
-> WHERE film_actor.film_id IS NULL;
This query works by eliminating any films that have actors. Each film might have
many actors, but as soon as it finds one actor, it stops processing the current film
and moves to the next one because it knows the WHERE clause prohibits output-
ting that film. A similar “Distinct/not-exists” optimization can apply to certain
kinds of DISTINCT , NOT EXISTS( ) , and LEFT JOIN queries.
Equality propagation
MySQL recognizes when a query holds two columns as equal—for example, in a
JOIN condition—and propagates WHERE clauses across equivalent columns. For
instance, in the following query:
mysql> SELECT film.film_id
-> FROM sakila.film
->
INNER JOIN sakila.film_actor USING(film_id)
-> WHERE film.film_id > 500;
MySQL knows that the WHERE clause applies not only to the film table but to the
film_actor table as well, because the USING clause forces the two columns to
match.
If you’re used to another database server that can’t do this, you may have been
advised to “help the optimizer” by manually specifying the WHERE clause for both
tables, like this:
... WHERE film.film_id > 500 AND film_actor.film_id > 500
This is unnecessary in MySQL. It just makes your queries harder to maintain.
IN( ) list comparisons
In many database servers, IN( ) is just a synonym for multiple OR clauses, because
the two are logically equivalent. Not so in MySQL, which sorts the values in the
IN( ) list and uses a fast binary search to see whether a value is in the list. This is
O(log n) in the size of the list, whereas an equivalent series of OR clauses is O(n)
in the size of the list (i.e., much slower for large lists).
The preceding list is woefully incomplete, as MySQL performs more optimizations
than we could fit into this entire chapter, but it should give you an idea of the opti-
mizer’s complexity and intelligence. If there’s one thing you should take away from this discussion, it’s don’t try to outsmart the optimizer. You may end up just defeat-
ing it, or making your queries more complicated and harder to maintain for zero ben-
efit. In general, you should let the optimizer do its work.
Of course, as smart as the optimizer is, there are times when it doesn’t give the best
result. Sometimes you may know something about the data that the optimizer
doesn’t, such as a fact that’s guaranteed to be true because of application logic. Also,
sometimes the optimizer doesn’t have the necessary functionality, such as hash
indexes; at other times, as mentioned earlier, its cost estimates may prefer a query
plan that turns out to be more expensive than an alternative.
If you know the optimizer isn’t giving a good result, and you know why, you can
help it. Some of the options are to ad
--
```
STRAIGHT_JOIN
```
mysql> EXPLAIN SELECT STRAIGHT_JOIN film.film_id...\G
*************************** 1. row ***************************
id: 1
select_type: SIMPLE
table: film
type: ALL
possible_keys: PRIMARY
key: NULL
key_len: NULL
ref: NULL
rows: 951
Extra:
*************************** 2. row ***************************
id: 1
select_type: SIMPLE
table: film_actor
type: ref
possible_keys: PRIMARY,idx_fk_film_id
key: idx_fk_film_id
key_len: 2
ref: sakila.film.film_id
rows: 1
Extra: Using index
*************************** 3. row ***************************
id: 1
select_type: SIMPLE
table: actor
type: eq_ref
possible_keys: PRIMARY
key: PRIMARY
key_len: 2
ref: sakila.film_actor.actor_id
rows: 1
Extra:

This shows why MySQL wants to reverse the join order: doing so will enable it to
examine fewer rows in the first table. * In both cases, it will be able to perform fast
indexed lookups in the second and third tables. The difference is how many of these
indexed lookups it will have to do:
• Placing film first will require about 951 probes into film_actor and actor , one
for each row in the first table.
• If the server scans the actor table first, it will have to do only 200 index lookups
into later tables.

# 5.Advanced MySQL Features
## The MySQL Query Cache
- How MySQL Checks for a Cache Hit
  - MySQL’s query cache can improve performance, but there are a few issues you
should be aware of when using it. First, enabling the query cache adds some over-
head for both reads and writes:
    - Read queries must check the cache before beginning.
    - If the query is cacheable and isn’t in the cache yet, there’s some overhead due to
storing the result after generating it.
    - Finally, there’s overhead for write queries, which must invalidate the cache
entries for queries that use tables they change.
