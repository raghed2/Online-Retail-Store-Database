/* Customersجدول ال */
CREATE TABLE Customers (
customer_id INT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(150) UNIQUE NOT NULL,
password_hash VARCHAR(255) NOT NULL,
created_at DATE
);
/* بياناته */
INSERT INTO Customers VALUES (1, 'Sara Ahmed', 'sara@example.com', 'DEMO_HASH_001', DATE '2026-11-01');
INSERT INTO Customers VALUES (2, 'Nora Ali', 'nora@example.com', 'DEMO_HASH_002', DATE '2026-11-02');
INSERT INTO Customers VALUES (3, 'Maha Khalid', 'maha@example.com', 'DEMO_HASH_003', DATE '2026-11-03');
INSERT INTO Customers VALUES (4, 'Lama Saad', 'lama@example.com', 'DEMO_HASH_004', DATE '2026-11-04');
INSERT INTO Customers VALUES (5, 'Reem Omar', 'reem@example.com', 'DEMO_HASH_005', DATE '2026-11-05');
SELECT * FROM Customers;

/* categoriesجدول ال */
CREATE TABLE categories (
category_id INT PRIMARY KEY,
category_name VARCHAR(80) NOT NULL
);
/* بياناته */
INSERT INTO categories VALUES (1, 'Beauty and Care');
INSERT INTO categories VALUES (2, 'Furniture');
INSERT INTO categories VALUES (3, 'Electronics');
INSERT INTO categories VALUES (4, 'Clothing');
INSERT INTO categories VALUES (5, 'Books');
SELECT * FROM categories;

/* Productsجدول ال */
CREATE TABLE Products (
product_id INT PRIMARY KEY,
name VARCHAR2(150) NOT NULL,
price NUMBER(10,2) NOT NULL CHECK (price >= 0),
quantity_in_stock INT NOT NULL CHECK (quantity_in_stock >= 0),
category_id INT,
CONSTRAINT fk_product_category FOREIGN KEY (category_id) 
REFERENCES categories(category_id) 
ON DELETE SET NULL
);
/* بياناته */
INSERT INTO Products VALUES (1, 'Laptop Dell Inspiron', 2500.00, 15, 3);
INSERT INTO Products VALUES (2, 'Wireless Mouse', 75.50, 50, 3);
INSERT INTO Products VALUES (3, 'Office Desk Chair', 450.00, 10, 2);
INSERT INTO Products VALUES (4, 'Bluetooth Headphones', 199.99, 30, 3);
INSERT INTO Products VALUES (5, 'Skincare Serum', 85.00, 25, 1);
SELECT * FROM Products;

/* Ordersجدول ال */
CREATE TABLE Orders (
order_id INT PRIMARY KEY,
customer_id INT NOT NULL,
product_id INT NOT NULL,
quantity INT NOT NULL CHECK (quantity > 0),
order_date DATE NOT NULL,
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
/* بياناته */
INSERT INTO Orders VALUES (1, 1, 1, 1, DATE '2026-11-14');
INSERT INTO Orders VALUES (2, 1, 2, 2, DATE '2026-11-06');
INSERT INTO Orders VALUES (3, 2, 2, 3, DATE '2026-11-08');
INSERT INTO Orders VALUES (4, 3, 4, 1, DATE '2026-11-10');
INSERT INTO Orders VALUES (5, 4, 5, 2, DATE '2026-11-12');
INSERT INTO Orders VALUES (6, 5, 3, 1, DATE '2026-11-13');
SELECT * FROM Orders;

/* Shipments جدول ال */
CREATE TABLE Shipments (
shipment_id INT PRIMARY KEY,
order_id INT NOT NULL,
address VARCHAR2(255) NOT NULL,
shipped_date DATE,
status VARCHAR2(30) DEFAULT 'Pending' NOT NULL CHECK (
status IN ('Pending', 'Shipped', 'In Transit', 'Delivered')
),
CONSTRAINT fk_shipment_order FOREIGN KEY (order_id)
REFERENCES Orders(order_id)
);

/* بياناته */
INSERT INTO Shipments VALUES (1, 1, 'Al Nakheel District, Riyadh', NULL, 'Pending');
INSERT INTO Shipments VALUES (2, 2, 'Al Rawdah District, Jeddah', DATE '2026-11-07', 'Delivered');
INSERT INTO Shipments VALUES (3, 3, 'Al Safra District, Buraydah', DATE '2026-11-09', 'Delivered');
INSERT INTO Shipments VALUES (4, 4, 'Al Olaya District, Al Khobar', DATE '2026-11-11', 'In Transit');
INSERT INTO Shipments VALUES (5, 5, 'Al Narjis District, Riyadh', DATE '2026-11-13', 'Shipped');

SELECT * FROM Shipments;

/* جدول ال Shopping cart */
CREATE TABLE Shopping_Cart (
customer_id INT NOT NULL,
product_id INT NOT NULL,
quantity INT NOT NULL CHECK (quantity > 0),
added_at DATE NOT NULL,
CONSTRAINT pk_cart PRIMARY KEY (customer_id, product_id),
CONSTRAINT fk_cart_customer FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id) ON DELETE CASCADE,
CONSTRAINT fk_cart_product FOREIGN KEY (product_id)
REFERENCES Products(product_id) ON DELETE CASCADE
);

/*بياناته */
INSERT INTO Shopping_Cart VALUES (1, 1, 1, DATE '2026-11-13');
INSERT INTO Shopping_Cart VALUES (1, 2, 2, DATE '2026-11-14');
INSERT INTO Shopping_Cart VALUES (2, 4, 1, DATE '2026-11-15');
INSERT INTO Shopping_Cart VALUES (3, 5, 3, DATE '2026-11-16');
INSERT INTO Shopping_Cart VALUES (4, 3, 1, DATE '2026-11-17');
SELECT * FROM Shopping_Cart;

/* الكويريز، حاليا 20 فقط */
--Q1. Find the customers who have placed more than one order using GROUP BY + HAVING
Select c.customer_id , c.name , count(o.order_id)  total_orders
From Customers  c JOIN Orders  o on c.customer_id = o.customer_id
Group by  c.customer_id, c.name
Having  count(o.order_id) > 1;

--Q2. Find the products that have never been ordered by any customer using  NOT EXISTS
Select p.product_id, p.name
From Products p
where NOT EXISTS (
    Select *
    From Orders o
    Where o.product_id = p.product_id
);

--Q3. Find the customers who have purchased products from the Electronics category
Using EXISTS + JOIN

Select c.customer_id , c.name
From Customers  c Where  EXISTS (
    Select *
    From Orders  o
    JOIN Products  p ON o.product_id = p.product_id
    JOIN Categories   cat ON p.category_id = cat.category_id
    Where  o.customer_id = c.customer_id
    and cat.category_name = 'Electronics'
);

--Q4. Find the most expensive product in each category using Correlated Subquery.

Select p1.name, p1.price, p1.category_id 
From Products  p1 
Where p1.price=(
Select MAX(p2.price)
From Products  p2 
Where p2.category_id = p1.category_id
);

--Q5. Find the customers who placed orders after November 10, 2026 using join and DATE con
Select c.name, o.order_id, o.order_date
From Customers  c
JOIN Orders  o ON c.customer_id = o.customer_id
Where o.order_date > DATE '2026-11-10';

--Q6. Find the products that have been ordered by at least two different customers Using JOIN + GROUP BY + HAVING.

Select p.product_id, p.name,
       Count(DISTINCT o.customer_id) AS total_customers
From Products  p
JOIN Orders  o ON p.product_id = o.product_id
Group by  p.product_id, p.name
Having Count(DISTINCT o.customer_id) >= 2;

---Q7Find customers who have products in their shopping cart but have not ordered them Using LEFT OUTER JOIN + IS NULL

Select DISTINCT c.customer_id, c.name
From Customers c
JOIN Shopping_Cart  sh
ON c.customer_id = sh.customer_id
LEFT OUTER JOIN Orders  o
ON sh.customer_id = o.customer_id
AND sh.product_id = o.product_id
WHERE o.order_id IS NULL;

--Q8 Find customers whose shopping cart contains more than one product Using JOIN + GROUP BY + HAVING

Select c.customer_id, c.name
       Count(sh.product_id) AS total_products
From Customers c
LEFT OUTER JOIN Shopping_Cart  sh
ON c.customer_id = sh.customer_id
Group by c.customer_id, c.name
Having count(sh.product_id) > 1 ;

--Q9 Find the shopping cart items of customers who have pending shipments Using JOIN + Subquery

Select sh.customer_id, sh.product_id, sh.quantity
From Shopping_Cart  sh
Where  sh.customer_id IN(
    Select o.customer_id
    From Orders   o
    JOIN Shipments  s
    ON o.order_id = s.order_id
 '); Where s.status = 'Pending
  
--Q10Find products that are not added to any shopping cart using LEFT OUTER JOIN + IS NULL

Select  p.product_id, p.name, p.price
From Products   p
LEFT OUTER JOIN Shopping_Cart  sh
ON p.product_id = sh.product_id
Where sh.product_id IS NULL;

-- 11 عرض العملاء الذين يتجاوز إجمالي إنفاقهم 500 ريال
SELECT
    c.customer_id,
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.quantity * p.price) AS total_spent
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name
HAVING SUM(o.quantity * p.price) > 500
ORDER BY SUM(o.quantity * p.price) DESC;

--عرض فئات المنتجات التي لا تحتوي على أي منتجات حاليا12

SELECT
    cat.category_id,
    cat.category_name
FROM Categories cat
LEFT OUTER JOIN Products p ON cat.category_id = p.category_id
WHERE p.product_id IS NULL;

 --13عرض المنتجات التي سعرها أعلى من متوسط أسعار جميع المنتجات
SELECT
    p.product_id,
    p.name AS product_name,
    cat.category_name,
    p.price
FROM Products p
INNER JOIN Categories cat ON p.category_id = cat.category_id
WHERE p.price > (SELECT AVG(price) FROM Products)
ORDER BY p.price DESC;

--14عرض الطلبات التي لم يتم تسجيل شحنة لها بعد
SELECT
    o.order_id,
    c.name AS customer_name,
    p.name AS product_name,
    o.quantity,
    o.order_date
FROM Orders o
INNER JOIN Customers c ON o.customer_id = c.customer_id
INNER JOIN Products p ON o.product_id = p.product_id
WHERE NOT EXISTS (
    SELECT *
    FROM Shipments s
    WHERE s.order_id = o.order_id
);

-- 15 عرض المنتجات ذات المخزون المنخفض (15 أو أقل) أو التي طُلبت بكمية 2 فأكثر
SELECT
    p.product_id,
    p.name AS product_name,
    p.quantity_in_stock
FROM Products p
WHERE p.quantity_in_stock <= 15
UNION
SELECT
    p.product_id,
    p.name AS product_name,
    p.quantity_in_stock
FROM Products p
INNER JOIN Orders o ON p.product_id = o.product_id
WHERE o.quantity >= 2;

--16 Find customers who do not have a shopping cart.

SELECT customer_id, name
FROM Customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM Shopping_Cart
);

--17 Count shipments for each status.
SELECT status, COUNT(*)
FROM Shipments
GROUP BY status;

--18 Show the total quantity of each product in shopping carts.
SELECT product_id, SUM(quantity)
FROM Shopping_Cart
GROUP BY product_id;

--19 Show the total price of each order.
SELECT o.order_id, o.quantity * p.price AS total_price
FROM Orders o
JOIN Products p ON o.product_id = p.product_id;

--20 Find customers registered after November 2, 2026.
SELECT name, created_at
FROM Customers
WHERE created_at > DATE '2026-11-02';

/* Triggers : كاملة */
-- Prevent inserting a customer with an invalid ID.
CREATE OR REPLACE TRIGGER trg_customer_id
BEFORE INSERT ON Customers
FOR EACH ROW
BEGIN
    IF :NEW.customer_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid customer ID');
    END IF;
END;

-- خصم الكمية من المخزون عند إضافة طلب جديد
CREATE OR REPLACE TRIGGER trg_deduct_stock
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    UPDATE Products
    SET quantity_in_stock = quantity_in_stock - :NEW.quantity
    WHERE product_id = :NEW.product_id;
END;


--استرجاع الكمية إلى المخزون عند حذف أو إلغاء طلب 
CREATE OR REPLACE TRIGGER trg_restore_stock
AFTER DELETE ON Orders
FOR EACH ROW
BEGIN
    UPDATE Products
    SET quantity_in_stock = quantity_in_stock + :OLD.quantity
    WHERE product_id = :OLD.product_id;
END;


/*View 1*/
-- display details of the products currently in customers' shopping carts
CREATE VIEW Customer_Cart_Details AS
SELECT
    c.customer_id,
    c.name,
    p.product_id,
    p.name AS product_name,
    sh.quantity,
    p.quantity_in_stock,
    sh.added_at
FROM Shopping_Cart sh
JOIN Customers c ON sh.customer_id = c.customer_id
JOIN Products p ON sh.product_id = p.product_id;

/*View 2*/
-- Display a summary that provides a comprehensive overview of each customer's activity.
CREATE VIEW Customer_Activity_Summary AS
SELECT
    c.customer_id,
    c.name,
    c.email,
    c.created_at,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT sh.product_id) AS cart_items_count
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Shopping_Cart sh ON c.customer_id = sh.customer_id
GROUP BY c.customer_id, c.name, c.email, c.created_at;

/*View 3*/
-- Display product details along with category name and stock status
CREATE OR REPLACE VIEW Product_Catalog_Details AS
SELECT 
    p.product_id,
    p.name AS product_name,
    p.price,
    p.quantity_in_stock,
    c.category_name,
    CASE 
        WHEN p.quantity_in_stock = 0 THEN 'Out of Stock'
        WHEN p.quantity_in_stock <= 15 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM Products p
LEFT JOIN categories c ON p.category_id = c.category_id;

/*View 4*/
-- Summarize total products and total inventory value per category
CREATE OR REPLACE VIEW Category_Inventory_Summary AS
SELECT 
    c.category_id,
    c.category_name,
    COUNT(p.product_id) AS total_products,
    SUM(p.quantity_in_stock) AS total_units_in_stock,
    SUM(p.price * p.quantity_in_stock) AS total_inventory_value
FROM categories c
LEFT JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;


--role 1
CREATE ROLE ShippingManager;
-- grant privileges to shippingManager
GRANT SELECT, INSERT, UPDATE ON Shipments TO ShippingManager;
GRANT SELECT ON Orders TO ShippingManager;
--check
SELECT *
FROM ROLE_TAB_PRIVS
WHERE ROLE = 'SHIPPINGMANAGER';

--role 2
CREATE ROLE DataEntry;
-- grant privileges to dataentry
GRANT SELECT, INSERT, UPDATE, DELETE ON Customers TO DataEntry;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categories TO DataEntry;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO DataEntry;
GRANT SELECT, INSERT, UPDATE, DELETE ON Orders TO DataEntry;
GRANT SELECT, INSERT, UPDATE, DELETE ON Shipments TO DataEntry;
GRANT SELECT, INSERT, UPDATE, DELETE ON Shopping_Cart TO DataEntry;
-- Check role
SELECT *
FROM ROLE_TAB_PRIVS
WHERE ROLE = 'DATAENTRY';


-- role 3
CREATE ROLE CustomerRole;
-- grant privileges to CustomerRole
GRANT SELECT ON Products TO CustomerRole;
GRANT SELECT ON Categories TO CustomerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Shopping_Cart TO CustomerRole;
GRANT SELECT, INSERT ON Orders TO CustomerRole;
GRANT SELECT ON Shipments TO CustomerRole;
-- Check role
SELECT *
FROM ROLE_TAB_PRIVS
WHERE ROLE = 'CUSTOMERROLE';

