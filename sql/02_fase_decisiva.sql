with champ_fase as (
	select wc.year, wc.champion, m.stage,
			SUM (
			case when wc.champion = m.home_team then home_score
			else away_score 
			END
				) / count (*) as gols_fase
	from world_cup wc 
	left join  matches m on wc.year = m.year
	where m.home_team = wc.champion or m.away_team = wc.champion 
	group by wc.year, wc.champion, m.stage
	order by wc.year DESC
)
select cf.stage, round(avg(cf.gols_fase),2) as media_gols, 
		rank () over( order by avg(gols_fase) desc)
from champ_fase as cf
group by cf.stage
