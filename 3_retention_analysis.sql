WITH customer_last_pruchase AS (
	SELECT customerkey,
			cleaned_name,
			orderdate,
			ROW_NUMBER() OVER (PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
			first_pruchase_date,
			cohort_year--it should be purchase but WHILE creating the VIEW i made a typo so i just chose TO KEEP it INSTEAD OF dropping the view
	FROM 
			cohort_analysis
			
	), churned_customers AS (
	
	SELECT customerkey,
			cleaned_name,
			orderdate AS last_purchase_date,
			CASE WHEN orderdate < (SELECT MAX (orderdate) FROM sales) - INTERVAL '6 months' THEN  'Churned'
			ELSE 'Active' END AS customer_status,
			cohort_year
	FROM  customer_last_pruchase
	WHERE rn = 1
	AND first_pruchase_date < (SELECT MAX (orderdate) FROM sales) - INTERVAL '6 months' 
	
	)
	SELECT 
	cohort_year,
	customer_status,
	COUNT(customerkey) AS num_customers,
	SUM(COUNT(customerkey)) OVER (PARTITION BY cohort_year) AS total_customers,
	ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER (PARTITION BY cohort_year), 2) AS status_percentage
	FROM churned_customers 
	GROUP BY 
	cohort_year,
	customer_status