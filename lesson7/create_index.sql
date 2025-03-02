/*
Я не эксперт в оптимизации запросов, но в целом вроде как в рамках задачи :)

select COUNT(*) 
from orders o 
INNER JOIN books b ON o.book_id = b.id 
INNER JOIN clients c ON o.client_id = c.id <= Для этого условия нет индекса
WHERE c.id = 7;


webbooks=# \d orders
                           Table "public.orders"
  Column   |  Type   | Collation | Nullable |           Default
-----------+---------+-----------+----------+------------------------------
 id        | integer |           | not null | generated always as identity
 client_id | integer |           | not null |
 book_id   | integer |           | not null |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
    "orders_book_id_key" UNIQUE CONSTRAINT, btree (book_id)
Foreign-key constraints:
    "orders_book_id_fkey" FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
    "orders_client_id_fkey" FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
	
webbooks=# explain (analyze, timing) select COUNT(*) from orders o INNER JOIN books b ON o.book_id = b.id INNER JOIN
clients c ON o.client_id = c.id WHERE c.id = 7;
                                                        QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=3.30..3.31 rows=1 width=8) (actual time=0.041..0.043 rows=1 loops=1)
   ->  Nested Loop  (cost=1.05..3.29 rows=2 width=0) (actual time=0.033..0.038 rows=2 loops=1)
         ->  Seq Scan on clients c  (cost=0.00..1.10 rows=1 width=4) (actual time=0.011..0.012 rows=1 loops=1)
               Filter: (id = 7)
               Rows Removed by Filter: 7
         ->  Hash Join  (cost=1.05..2.17 rows=2 width=4) (actual time=0.020..0.023 rows=2 loops=1)
               Hash Cond: (b.id = o.book_id)
               ->  Seq Scan on books b  (cost=0.00..1.09 rows=9 width=4) (actual time=0.003..0.003 rows=9 loops=1)
               ->  Hash  (cost=1.02..1.02 rows=2 width=8) (actual time=0.008..0.009 rows=2 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
                     ->  Seq Scan on orders o  (cost=0.00..1.02 rows=2 width=8) (actual time=0.004..0.004 rows=2 loops=1)
                           Filter: (client_id = 7) <= Для этого условия нет индекса
 Planning Time: 0.209 ms
 Execution Time: 0.073 ms
(14 rows)


Добавляем индекс под условие соединения
create index orders_client_id_idx on orders (client_id);
webbooks=# explain (analyze, timing) select COUNT(*) from orders o INNER JOIN books b ON o.book_id = b.id INNER JOIN
clients c ON o.client_id = c.id WHERE c.id = 7;
                                                        QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=3.30..3.31 rows=1 width=8) (actual time=0.023..0.025 rows=1 loops=1)
   ->  Nested Loop  (cost=1.05..3.29 rows=2 width=0) (actual time=0.019..0.022 rows=2 loops=1)
         ->  Seq Scan on clients c  (cost=0.00..1.10 rows=1 width=4) (actual time=0.007..0.007 rows=1 loops=1)
               Filter: (id = 7)
               Rows Removed by Filter: 7
         ->  Hash Join  (cost=1.05..2.17 rows=2 width=4) (actual time=0.011..0.013 rows=2 loops=1)
               Hash Cond: (b.id = o.book_id)
               ->  Seq Scan on books b  (cost=0.00..1.09 rows=9 width=4) (actual time=0.001..0.002 rows=9 loops=1)
               ->  Hash  (cost=1.02..1.02 rows=2 width=8) (actual time=0.004..0.005 rows=2 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
                     ->  Seq Scan on orders o  (cost=0.00..1.02 rows=2 width=8) (actual time=0.002..0.002 rows=2 loops=1)
                           Filter: (client_id = 7) 
 Planning Time: 0.183 ms
 Execution Time: 0.046 ms
(14 rows)

Полагаю, что Seq Scan не меняется на Index Only Scan т.к. данных маловато и оптимизатор решил, что ему проще просканить таблицу.
*/

create index if not exists orders_client_id_idx on orders (client_id);