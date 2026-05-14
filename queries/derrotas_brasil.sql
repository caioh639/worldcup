with brasil_derrotas as (
	select m.stage, 
			count (*) filter (where m.winner != 'Brazil' and m.winner != 'Draw') as derrotas, 
			STRING_AGG(
    			CASE WHEN m.home_team = 'Brazil' THEN m.away_team
         			ELSE m.home_team end || ' ('||(m.year::text) || ') ' ,  ' | ' ORDER BY m.year ) AS adversarios
	from matches m 
	where (m.home_team = 'Brazil' or m.away_team = 'Brazil') and m.winner != 'Brazil' and m.winner != 'Draw'
	group by m.stage
)
select bd.stage, bd.derrotas, bd.adversarios, 
		rank () over (order by derrotas desc)
from brasil_derrotas bd
order by bd.derrotas desc



