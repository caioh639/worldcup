with todos_jogos as (
	select year, home_team as team, winner from matches m 
	union all 
	select year, away_team, winner from matches
),
aproveitamento_por_copa as (
	select  tj.team,
			tj.year,	
			count (*) as qtd_jogos, 
			ROUND (SUM (case 
				when tj.team = winner then 3 
				when tj.winner = 'Draw' then 1
				else 0 
			end) * 1.0 / (COUNT (*)* 3),2) *100 as aproveitamento
	from todos_jogos tj
	group by tj.team, tj.year
),

comp_times as (
	select ac.team, ac.year, ac.aproveitamento,
			lag (ac.aproveitamento) over (partition by ac.team order by ac.year) as  evo
	from aproveitamento_por_copa as ac

)

select ct.team, ct.year, ct.aproveitamento, ct.evo,
		ct.aproveitamento - ct.evo as variacao,
		dense_rank()over (order by( ct.aproveitamento - ct.evo) desc ) as rank_evolucao
from comp_times as ct
where year >= 2002 and ct.evo is not null 
order by rank_evolucao

