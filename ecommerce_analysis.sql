DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    signup_date TEXT NOT NULL
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    price REAL NOT NULL
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TEXT NOT NULL,
    total_amount REAL NOT NULL,
    status TEXT NOT NULL,
    shipping_city TEXT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price REAL NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers (customer_id, name, city, signup_date) VALUES
(1, 'Aisha Khan', 'Delhi', '2024-01-15'),
(2, 'Rohan Mehta', 'Mumbai', '2024-01-20'),
(3, 'Sneha Patel', 'Bengaluru', '2024-02-02'),
(4, 'Omar Ali', 'Hyderabad', '2024-02-12'),
(5, 'Priya Nair', 'Kochi', '2024-03-01'),
(6, 'Zaid Siddiqui', 'Pune', '2024-03-15');

INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Wireless Mouse', 'Electronics', 799),
(2, 'Mechanical Keyboard', 'Electronics', 2499),
(3, 'Office Chair', 'Furniture', 6999),
(4, 'Running Shoes', 'Sports', 3499),
(5, 'Coffee Maker', 'Home', 3999),
(6, 'Backpack', 'Lifestyle', 1599),
(7, 'Smartwatch', 'Electronics', 5299),
(8, 'Water Bottle', 'Lifestyle', 899);

INSERT INTO orders (order_id, customer_id, order_date, total_amount, status, shipping_city) VALUES
(1, 1, '2024-04-01', 2398, 'Completed', 'Delhi'),
(2, 1, '2024-04-10', 12298, 'Completed', 'Delhi'),
(3, 2, '2024-04-03', 5297, 'Completed', 'Mumbai'),
(4, 3, '2024-04-11', 3298, 'Pending', 'Bengaluru'),
(5, 2, '2024-04-17', 3999, 'Completed', 'Mumbai'),
(6, 4, '2024-04-18', 13897, 'Completed', 'Hyderabad'),
(7, 5, '2024-04-25', 2497, 'Shipped', 'Kochi'),
(8, 6, '2024-05-02', 4298, 'Completed', 'Pune');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 799),
(1, 6, 1, 1599),
(2, 7, 1, 5299),
(2, 3, 1, 6999),
(3, 4, 1, 3499),
(3, 8, 2, 899),
(4, 2, 1, 2499),
(4, 1, 1, 799),
(5, 5, 1, 3999),
(6, 3, 1, 6999),
(6, 7, 1, 5299),
(6, 6, 1, 1599),
(7, 1, 2, 799),
(7, 8, 1, 899),
(8, 4, 1, 3499),
(8, 1, 1, 799);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- View definitions are created in build_database.py so this SQL file stays compatible with editor parsing.

-- Query 1: Basic filtering and sorting
SELECT customer_id, name, city
FROM customers
WHERE city IN ('Delhi', 'Mumbai')
ORDER BY name;

-- Query 2: INNER JOIN across customer and order tables
SELECT c.name, c.city, o.order_id, o.order_date, o.total_amount, o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
ORDER BY o.order_date;

-- Query 3: LEFT JOIN showing all customers and their order totals
SELECT c.name, COUNT(o.order_id) AS order_count, ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS total_spend
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC;

-- Query 4: SQLite equivalent of RIGHT JOIN by reversing the join order
SELECT c.name, o.order_id, o.total_amount
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id;

-- Query 5: Subquery to identify customers above the average spend
SELECT name, total_spend
FROM (
    SELECT c.name, COALESCE(SUM(o.total_amount), 0) AS total_spend
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.name
) t
WHERE total_spend > (
    SELECT AVG(total_spend)
    FROM (
        SELECT COALESCE(SUM(o.total_amount), 0) AS total_spend
        FROM customers c
        LEFT JOIN orders o ON o.customer_id = c.customer_id
        GROUP BY c.customer_id
    )
)
ORDER BY total_spend DESC;

-- Query 6: Aggregate functions for monthly revenue and average order value
SELECT
    month,
    ROUND(SUM(total_amount), 2) AS monthly_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    COUNT(order_id) AS order_count
FROM (
    SELECT order_id, total_amount, substr(order_date, 1, 7) AS month
    FROM orders
) grouped_orders
GROUP BY month
ORDER BY month;

-- Query 7: View usage for analysis
SELECT *
FROM customer_order_summary
ORDER BY total_spend DESC;

-- Query 8: Query optimization example using indexed join lookup
SELECT o.order_id, o.order_date, o.total_amount, c.name, c.city
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.customer_id = 1
ORDER BY o.order_date;
