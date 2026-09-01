# **Analytical Requirements**

## 1. Project Definition

### **Project Name**

**Olist E-Commerce Business Intelligence & Data Quality Analytics**

### **Dataset**

**Olist Brazilian E-Commerce Public Dataset**

### **Business Context**

Olist is an e-commerce marketplace connecting customers with sellers. The dataset contains transactional, customer, product, seller, payment, review, and geographic information that can be used to evaluate business performance and customer experience.

### **Primary Stakeholder**

**E-Commerce Management**

The analysis is designed to provide management with visibility into:

* Overall business performance
* Customer behaviour and value
* Product and category performance
* Seller performance
* Logistics and customer experience
* Data quality and reliability

### **Overall Business Objective**

> **To transform Olist's transactional and operational data into reliable business intelligence that enables management to evaluate e-commerce performance, identify operational and customer trends, and make data-driven decisions.**

---

# 2. Analytical Scope

We're going to build **five analytical projects**:

1. **Sales & Revenue Performance**
2. **Customer Analytics**
3. **Product & Category Performance**
4. **Seller Performance**
5. **Logistics & Customer Experience**

And the **Data Quality Monitoring** component will sit across the entire project rather than being treated as just another dashboard.

---

# Project 1 — Sales & Revenue Performance

## **Business Objective**

Evaluate overall sales performance and identify revenue, order-volume, and purchasing trends over time.

## **Key Business Questions**

### Revenue & Sales

* What is the total revenue generated?
* How does revenue change over time?
* How many orders have been placed?
* How many products have been sold?
* What is the average order value?
* Which months or periods generate the highest revenue?
* Which product categories contribute the most revenue?
* Which sellers generate the most revenue?

### Performance Trends

* Are sales increasing or decreasing over time?
* Are increases in revenue driven by more orders or higher order values?
* Which periods demonstrate unusually strong or weak performance?
* Which categories and sellers are driving changes in revenue?

## **Key KPIs**

| KPI                         | Purpose                                    |
| --------------------------- | ------------------------------------------ |
| **Total Revenue**           | Measure overall sales value                |
| **Total Orders**            | Measure transaction volume                 |
| **Units Sold**              | Measure product volume                     |
| **Average Order Value**     | Measure average customer transaction value |
| **Revenue Growth**          | Measure change in revenue over time        |
| **Average Items per Order** | Measure order composition                  |

## **Primary Dimensions**

* Date
* Product Category
* Seller
* Customer Geography

---

# Project 2 — Customer Analytics

## **Business Objective**

Understand customer behaviour, geographic distribution, purchasing activity, and customer value.

## **Key Business Questions**

### Customer Behaviour

* How many unique customers have purchased?
* How many customers are repeat purchasers?
* What is the average customer spend?
* How many orders does the average customer place?
* What proportion of customers purchase more than once?
* Which customers generate the highest revenue?

### Geographic Distribution

* Where are customers located?
* Which states have the most customers?
* Which regions generate the most revenue?
* Does customer concentration correspond with revenue concentration?

### Customer Value

* Which customers have the highest lifetime value within the available dataset?
* What characteristics distinguish high-value customers?
* Are high-value customers concentrated in particular regions?

## **Key KPIs**

| KPI                             | Purpose                              |
| ------------------------------- | ------------------------------------ |
| **Unique Customers**            | Measure customer base                |
| **Repeat Customers**            | Measure repeat purchasing            |
| **Repeat Purchase Rate**        | Measure customer retention behaviour |
| **Average Customer Spend**      | Measure customer value               |
| **Average Orders per Customer** | Measure purchasing frequency         |
| **Customer Revenue**            | Measure revenue contribution         |

### Important caveat

We're working with a **historical public dataset**, so we should be careful about calling this true "customer lifetime value" or long-term retention.

We'll define metrics based on the **observed dataset period**, rather than pretending we have years of customer history beyond what the data provides.

---

# Project 3 — Product & Category Performance

## **Business Objective**

Identify the products and categories driving sales and evaluate their relationship with revenue, pricing, and customer satisfaction.

## **Key Business Questions**

### Sales Performance

* Which product categories sell the most units?
* Which categories generate the most revenue?
* Which products generate the most revenue?
* Which products have the highest sales volume?
* Which categories have the highest average order value?

### Product Economics

* What is the average product price by category?
* Are higher-priced products generating more revenue?
* Which categories have high sales volume but relatively low revenue?
* Which categories have low sales volume but high revenue?

### Customer Satisfaction

* Which categories receive the highest review scores?
* Which categories receive the lowest review scores?
* Are high-selling categories also highly rated?
* Are expensive products associated with better or worse reviews?

## **Key KPIs**

| KPI                       | Purpose                       |
| ------------------------- | ----------------------------- |
| **Revenue by Category**   | Measure category contribution |
| **Units Sold**            | Measure product demand        |
| **Average Product Price** | Understand pricing            |
| **Average Review Score**  | Measure customer satisfaction |
| **Revenue per Product**   | Compare product performance   |
| **Products Sold**         | Measure catalogue activity    |

---

# Project 4 — Seller Performance

## **Business Objective**

Evaluate seller sales performance and identify relationships between seller activity, delivery performance, and customer satisfaction.

## **Key Business Questions**

### Sales

* Which sellers generate the most revenue?
* Which sellers process the most orders?
* Which sellers sell the most products?
* Which sellers have the highest average order value?

### Customer Experience

* Which sellers receive the highest review scores?
* Which sellers receive the lowest review scores?
* Which sellers have the longest delivery times?
* Which sellers have the highest proportion of late deliveries?

### Performance Relationships

This is where things get more interesting:

* Does faster delivery correspond with higher review scores?
* Do high-revenue sellers necessarily provide better customer experiences?
* Which sellers have high sales but poor reviews?
* Which sellers have strong reviews but relatively low sales?

## **Key KPIs**

| KPI                             | Purpose                       |
| ------------------------------- | ----------------------------- |
| **Seller Revenue**              | Measure seller contribution   |
| **Seller Orders**               | Measure transaction volume    |
| **Units Sold per Seller**       | Measure sales volume          |
| **Average Seller Review Score** | Measure satisfaction          |
| **Average Delivery Time**       | Measure logistics performance |
| **Late Delivery Rate**          | Measure delivery reliability  |

---

# Project 5 — Logistics & Customer Experience

## **Business Objective**

Evaluate delivery performance and determine whether logistics outcomes are associated with customer satisfaction.

## **Key Business Questions**

### Delivery Performance

* What is the average delivery time?
* How long does it take to deliver orders by region?
* Which sellers have the longest delivery times?
* Which states experience the longest delivery times?
* How does actual delivery time compare with estimated delivery time?

### Delivery Reliability

* How many orders were delivered late?
* What percentage of orders were delivered late?
* Which sellers have the highest late-delivery rates?
* Which regions experience the most delivery delays?

### Customer Experience

And here's the important analytical relationship:

> **Does delivery performance influence customer satisfaction?**

We can investigate:

* Do late deliveries receive lower review scores?
* Do faster deliveries receive higher review scores?
* Is there a relationship between delivery delay and review score?
* Which combinations of seller and geography create poor customer experiences?

## **Key KPIs**

| KPI                                 | Purpose                                                  |
| ----------------------------------- | -------------------------------------------------------- |
| **Average Delivery Time**           | Measure delivery speed                                   |
| **Average Delivery Delay**          | Measure deviation from expectation                       |
| **Late Delivery Rate**              | Measure delivery reliability                             |
| **Average Review Score**            | Measure customer satisfaction                            |
| **Review Score by Delivery Status** | Evaluate relationship between logistics and satisfaction |

---

# 6. Cross-Project Analytical Questions

We're going to connect the analytical areas.

### Sales × Customers

> Which customer groups and regions contribute the most revenue?

### Sales × Products

> Which categories drive revenue and sales volume?

### Sales × Sellers

> Which sellers contribute the most to overall business performance?

### Sellers × Logistics

> Are high-performing sellers also operationally reliable?

### Logistics × Reviews

> Does delivery performance influence customer satisfaction?

### Products × Reviews

> Are the best-selling categories also the highest-rated?

### Geography × Logistics

> Are certain regions consistently associated with longer delivery times?


---

# 7. Data Quality Requirements

The analytical layer should support monitoring of things like:

### **Completeness**

* Missing customer information
* Missing product information
* Missing seller information
* Missing order dates
* Missing review information

### **Validity**

* Invalid geographic coordinates
* Invalid ZIP/postal-code formats
* Invalid dates
* Invalid numeric values
* Invalid categorical values

### **Consistency**

* Standardised city/state values
* Standardised product categories
* Consistent ZIP-code formats
* Consistent identifiers

### **Uniqueness**

* Duplicate records
* Duplicate identifiers
* Unexpected duplicate combinations

### **Integrity**

* Orders without corresponding customers
* Order items without corresponding orders
* Order items without corresponding products
* Order items without corresponding sellers
* Reviews without corresponding orders

