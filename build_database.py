import sqlite3
from pathlib import Path

base_dir = Path(__file__).resolve().parent
sql_path = base_dir / 'ecommerce_analysis.sql'
db_path = base_dir / 'ecommerce.db'

if db_path.exists():
    db_path.unlink()

views_sql = """
CREATE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    c.name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS total_spend
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name, c.city;

CREATE VIEW product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(oi.order_id) AS total_orders,
    ROUND(SUM(oi.quantity), 2) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category;
"""

with sqlite3.connect(db_path) as conn:
    conn.executescript(views_sql)
    conn.executescript(sql_path.read_text(encoding='utf-8'))
    print(f"Database created at: {db_path}")
    print("Schema, sample data, and views imported successfully.")
