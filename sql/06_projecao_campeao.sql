with dados_campeao as (
	select  wc.champion,wc.year,
			count (*) as total_jogos,
			count (case when m.winner = wc.champion then 1 end) as vitorias,
			count (case when m.winner != wc.champion and m.winner != 'Draw' then 1 end) as derrotas,
			sum (
				case 
					when wc.champion = m.home_team then m.home_score else away_score
				end ) as gols_marcados,
			sum (
			case 
					when wc.champion = m.home_team then away_score else home_score
				end 
			) as gols_sofridos
	from world_cup wc 
	left join matches m on wc.year = m.year
	where wc.champion = m.home_team or wc.champion = m.away_team 
	group by wc.champion, wc.year 
		
),

numeros_campeao as (
	select round(avg(dc.vitorias),2) as media_vitorias,
			round (avg(dc.derrotas),2) as media_derrotoas,
			round (avg (dc.gols_marcados),2) as gols_marcados,
			round (avg (dc.gols_sofridos),2) as gols_sofridos
	from dados_campeao dc
),

dados_gerais_selecoes as (
	select home_team as team, home_score as gols_marcados, away_score as gols_sofridos, winner, year
	from matches m 
	union all
	select away_team as team, away_score as gols_marcados, home_score as gols_sofridos, winner, year
	from matches m	
),

perfil_selecoes as (
	select dgs.team as team, dgs.year,
			count (*) as jogos,
			count (case when dgs.winner = dgs.team then 1 else NULL end ) as vitorias_selecoes,
			count (case when dgs.winner != dgs.team and dgs.winner != 'Draw' then 1 else NULL end ) as derrota_selecoes,
			sum (dgs.gols_marcados) as gols_marcados_selecoes,
			sum (dgs.gols_sofridos) as gols_sofridos_selecoes
	from dados_gerais_selecoes dgs
	group by dgs.team, dgs.year
)

select pf.team, pf.year, pf.jogos, pf.vitorias_selecoes, nc.media_vitorias as media_vitorias_campeao,
		ABS(pf.vitorias_selecoes - nc.media_vitorias) AS dif_vitorias,
		ABS(pf.gols_marcados_selecoes - nc.gols_marcados) AS dif_gols_marcados,
		ABS(pf.gols_sofridos_selecoes - nc.gols_sofridos) AS dif_gols_sofridos,
		
		RANK() OVER (
    			ORDER BY 
        			ABS(pf.vitorias_selecoes - nc.media_vitorias) +
        			ABS(pf.gols_marcados_selecoes - nc.gols_marcados) +
        			ABS(pf.gols_sofridos_selecoes - nc.gols_sofridos)
					) AS rank_perfil
		
from perfil_selecoes pf
cross join numeros_campeao nc
where pf.year = (
	select max(pf2.year)
	from perfil_selecoes pf2
	where pf2.team = pf.team
	  and pf2.year >= 2018
)
order by rank_perfil;