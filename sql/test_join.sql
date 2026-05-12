select wc.champion,
	m.year,
	SUM (m.total_goals ) as total_gols
from matches m
	left join world_cup wc 
	on m."year" = wc."year"
group by wc.champion , m.year
order by SUM (m.total_goals ) DESC