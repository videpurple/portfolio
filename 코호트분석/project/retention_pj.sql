-- customer_stats 테이블 생성
CREATE TABLE customer_stats AS
SELECT DISTINCT CustomerNo
     , MIN(Date) first_order_date
     , MAX(Date) last_order_date
     , COUNT(DISTINCT TransactionNo) cnt_orders
     , ROUND(SUM(Price * Quantity), 2) sum_sales
FROM total
GROUP BY CustomerNo

-- 구매 주기 구하기
WITH cycle AS (
	SELECT ROUND(DATEDIFF(last_order_date, first_order_date) / (cnt_orders - 1), 0) AS purchase_cycle 
		 , CustomerNo
	FROM customer_stats
	WHERE cnt_orders >= 2
	GROUP BY purchase_cycle, CustomerNo HAVING purchase_cycle > 0
	ORDER BY purchase_cycle
)
SELECT COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 1 AND 60 THEN CustomerNo END) AS '1~60'
	 , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 61 AND 120 THEN CustomerNo END) AS '61~120'
     , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 121 AND 180 THEN CustomerNo END) AS '121~180'
     , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 181 AND 240 THEN CustomerNo END) AS '181~240'
     , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 241 AND 300 THEN CustomerNo END) AS '241~300'
     , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 301 AND 360 THEN CustomerNo END) AS '301~360'
     , COUNT(DISTINCT CASE WHEN purchase_cycle > 360 THEN CustomerNo END) AS '360~'
FROM cycle;

-- 구매주기 평균 및 중앙값은 구글 시트를 이용하였습니다.

-- 코호트 차트
WITH records_preprocessed AS (
SELECT t.CustomerNo
	 , DATE_FORMAT(t.Date, '%Y-%m-01') order_month
     , DATE_FORMAT(c.first_order_date, '%Y-%m-01') first_order_month
FROM total t
	 INNER JOIN customer_stats c ON t.CustomerNo = c.CustomerNo
)
SELECT first_order_month
	 , COUNT(DISTINCT CustomerNo) 'Month 0'
     , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 1 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 2 MONTH)
			 THEN CustomerNo END) 'Month 2'
     , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 3 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 4 MONTH)
			 THEN CustomerNo END) 'Month 4'
     , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 5 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 6 MONTH)
			 THEN CustomerNo END) 'Month 6'
     , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 7 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 8 MONTH)
			 THEN CustomerNo END) 'Month 8'
     , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 9 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 10 MONTH)
			 THEN CustomerNo END) 'Month 10'
     , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 11 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 12 MONTH)
			 THEN CustomerNo END) 'Month 12'
FROM records_preprocessed
GROUP BY first_order_month
ORDER BY first_order_month;


-- 10월 첫구매자 구매 제품 확인
WITH records_join AS (
SELECT t.CustomerNo
	 , t.Date
     , DATE_FORMAT(c.first_order_date, '%Y-%m-01') first_order_month
     , t.ProductName
     , t.Price
     , t.Quantity
     , t.Country
FROM total t
	 INNER JOIN customer_stats c ON t.CustomerNo = c.CustomerNo
)
SELECT DISTINCT ProductName
		 , SUM(Quantity) cnt_product
FROM records_join
WHERE first_order_month = '2019-10-01'
AND Date BETWEEN '2019-10-01' AND '2019-10-31'
GROUP BY ProductName
ORDER BY cnt_product DESC;

-- 11월 첫구매자 구매 제품 확인
WITH records_join AS (
SELECT t.CustomerNo
	 , t.Date
     , DATE_FORMAT(c.first_order_date, '%Y-%m-01') first_order_month
     , t.ProductName
     , t.Price
     , t.Quantity
     , t.Country
FROM total t
	 INNER JOIN customer_stats c ON t.CustomerNo = c.CustomerNo
)
SELECT DISTINCT ProductName
		 , SUM(Quantity) cnt_product
FROM records_join
WHERE first_order_month = '2019-11-01'
AND Date BETWEEN '2019-11-01' AND '2019-11-30'
GROUP BY ProductName
ORDER BY cnt_product DESC;




