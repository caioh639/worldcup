with gols_champs as (
	select wc.champion, wc."year" ,
			SUM(m.total_goals) as gols_totais,
			SUM(
			case when m.home_team = wc.champion then away_score
				ELSE home_score 
			end ) as gols_sofridos 
	from world_cup wc 
	left join matches m 
	on wc."year" = m."year"
	where m.home_team = wc.champion or m.away_team = wc.champion 
	group by wc.champion, wc."year" 
),
partidas_champs as (
	select wc.champion, wc.year,
			COUNT (*) as total_partidas
	from world_cup wc 
	left join matches m on wc."year" = m."year"
	where m.home_team = wc.champion or m.away_team = wc.champion 
	group by wc.champion, wc.year
)
select  gc.champion,
		gc.year,
		gc.gols_totais,
		pc.total_partidas,
		ROUND ((gc.gols_totais * 1.0 / pc.total_partidas),2) as media_gols_partida,
		gc.gols_sofridos,
		ROUND ((gc.gols_sofridos * 1.0 / pc.total_partidas),2) as media_gols_sofridos_partida ,
		gc.gols_totais - gc.gols_sofridos as saldo_gols
from gols_champs gc
left join partidas_champs pc on gc.year = pc.year and gc.champion = pc.champion 
order by GC.year DESC





