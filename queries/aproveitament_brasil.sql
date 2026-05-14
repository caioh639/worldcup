WITH aproveitamento AS (
    SELECT m.year,
           SUM(
               CASE
                   WHEN winner = 'Brazil' THEN 3
                   WHEN winner = 'Draw'   THEN 1
                   ELSE 0
               END
           ) * 1.0 / (COUNT(*) * 3) AS desemp
    FROM matches m
    WHERE home_team = 'Brazil' OR away_team = 'Brazil'
    GROUP BY m.year
)
SELECT year, round (100* desemp,2) as ratio_perc,
			lag (round (100* desemp,2)) over (order by year),
			round (100* desemp,2) - lag (round (100* desemp,2)) over (order by year) as dif,
			case 
				when round (100* desemp,2) - lag (round (100* desemp,2)) over (order by year) < 0 then '↓ Caiu'
				when round (100* desemp,2) - lag (round (100* desemp,2)) over (order by year) > 0 then '↑ Subiu'
				else '→ Estável'
			end as status,
			AVG(round(100* desemp,2)) OVER (ORDER BY year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as media_movel
FROM aproveitamento
ORDER BY year 