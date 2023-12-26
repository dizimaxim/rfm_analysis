WITH rfm_table AS 
	(WITH score_table AS 
	 (WITH rfm_table AS
		(WITH recency_table AS (
			SELECT no, EXTRACT (DAY FROM ('2011-12-09 12:50:00+02'-TO_TIMESTAMP (datei, 'MM/DD/YYYY HH24:MI'))) as recency 
			FROM (SELECT * FROM eco WHERE quantity>0 AND unitprice>0) AS pozitif GROUP BY no,datei),
		freq_table AS (SELECT no, SUM(quantity) as frequency
			FROM (SELECT * FROM eco WHERE quantity>0 AND unitprice>0) AS pozitif
			GROUP BY no,quantity),
		monetary_table AS (SELECT no, SUM(toplam_satış_ücreti) as monetary
			FROM (SELECT no, quantity, unitprice, unitprice*quantity AS toplam_satış_ücreti
					FROM (SELECT * FROM eco WHERE quantity>0 AND unitprice>0) AS pozitif) as toplam
					GROUP BY no)
	SELECT r.no, r.recency, f. frequency, m.monetary
	FROM recency_table r
	LEFT JOIN freq_table f on r.no=f.no
	LEFT JOIN monetary_table m on r.no=m.no)

SELECT no, 
		 recency, 
		 frequency,
		 monetary, 
		 NTILE (5) OVER (ORDER BY recency DESC) as recency_score, 
		 NTILE (5) OVER (ORDER BY frequency ASC) as frequency_score,
		 NTILE (5) OVER (ORDER BY monetary DESC) as monetary_score
FROM rfm_table)
  
  
SELECT
	no, 
	  recency_score,
	  frequency_score,
	  monetary_score,
	  recency_score:: text || '-' || frequency_score:: text ||'-'  ||monetary_score:: text as rfm,
	  CASE WHEN (recency_score BETWEEN 4 AND 5) AND (frequency_score BETWEEN 4 AND 5) THEN 'champions'
	  WHEN (recency_score BETWEEN 3 AND 4) AND (frequency_score BETWEEN 4 AND 5) THEN 'loyal_customers'
	  WHEN (recency_score BETWEEN 4 AND 5) AND (frequency_score BETWEEN 2 AND 3) THEN 'potential_loyalists'
	  WHEN (recency_score BETWEEN 3 AND 4) AND (frequency_score BETWEEN 0 AND 1) THEN 'promising'
	  WHEN (recency_score BETWEEN 1 AND 2) AND (frequency_score BETWEEN 4 AND 5) THEN 'cannot lose them'
	  WHEN (recency_score BETWEEN 1 AND 2) AND (frequency_score BETWEEN 3 AND 4) THEN 'at risk'
	  WHEN (recency_score BETWEEN 2 AND 3) AND (frequency_score BETWEEN 1 AND 2) THEN 'about_to_slip'
	  WHEN (recency_score BETWEEN 1 AND 2) AND (frequency_score BETWEEN 1 AND 2) THEN 'hibernating'
	  WHEN (recency_score BETWEEN 4 AND 5) AND (frequency_score BETWEEN 0 AND 1) THEN 'new customer'
	  WHEN (recency_score BETWEEN 2 AND 3) AND (frequency_score BETWEEN 2 AND 3) THEN 'need_attention'
	  END AS recency_frequency
FROM score_table)
	 
SELECT	 
*
FROM rfm_table
