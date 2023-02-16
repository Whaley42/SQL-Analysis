-- Olympic Data Analysis
use olympics;

-- How many olympic games have been held?
SELECT COUNT(DISTINCT games)
FROM olympics_history;

-- All olympic games that have been held
SELECT distinct year, season, city
FROM olympics_history
ORDER BY year;

-- Total countries in each game
SELECT games, COUNT(distinct n.region) as country_count
FROM olympics_history o
JOIN olympics_history_noc_regions n ON n.noc = o.noc
GROUP BY games;

-- lowest and highest participation
with total_countries_by_event as
	(SELECT games, COUNT(distinct n.region) as country_count
		FROM olympics_history o
		JOIN olympics_history_noc_regions n ON n.noc = o.noc
		GROUP BY games),
	highest_participation as
	(SELECT DISTINCT FIRST_VALUE(games) OVER (ORDER BY country_count desc) as event_year,
		FIRST_VALUE(country_count) OVER (ORDER BY country_count desc) as participation
	FROM total_countries_by_event),
    lowest_participation as
    (SELECT DISTINCT FIRST_VALUE(games) OVER (ORDER BY country_count asc) as event_year,
		FIRST_VALUE(country_count) OVER (ORDER BY country_count asc) as participation
	FROM total_countries_by_event)
SELECT *
FROM highest_participation, lowest_participation;

-- Which nations have participated in all olympic games?

with total_games as
	(SELECT count(distinct games) as total_games
    FROM olympics_history),
    country_count as
    (SELECT n.region as country, COUNT(distinct games) as country_count
		FROM olympics_history o
		JOIN olympics_history_noc_regions n ON n.noc = o.noc
		GROUP BY n.region)
SELECT ct.country, ct.country_count
FROM country_count ct, total_games tg
WHERE ct.country_count = tg.total_games;


-- Oldest athlete to win a gold medal
with gold_medal_winners as
	(SELECT *
    FROM olympics_history 
    WHERE medal="gold" AND age != "NA"),
    ranked_by_age as
    (SELECT name, age, sport, year, RANK() OVER (ORDER BY age desc) as rnk
    FROM gold_medal_winners
    )
SELECT name, age, sport, year
FROM ranked_by_age
WHERE rnk = 1;


-- total ratio of athletes
with by_sex as 
	(SELECT sex, COUNT(*) as total_count
    FROM olympics_history
    GROUP BY sex),
    sex_ranked as
    (SELECT sex, total_count, RANK() OVER (ORDER BY total_count desc) as rnk
    FROM by_sex),
    max_rank as
    (SELECT sex, total_count
    FROM sex_ranked
    WHERE rnk = 1),
    min_rank as
    (SELECT sex, total_count
    FROM sex_ranked
    WHERE rnk = 2)
SELECT CASE
		WHEN mar.sex = "f" THEN concat("Male to Female: 1:", round(mar.total_count/mir.total_count, 2))
        ELSE concat("Female to Male 1:", round(mar.total_count/mir.total_count, 2))
        END as ratio
FROM max_rank mar, min_rank mir;


-- Top 5 athletes with total medals
with athlete_medals as
	(SELECT name, COUNT(medal) as medal_count
    FROM olympics_history
    WHERE medal <> "NA"
    GROUP BY id),
    ranked_athletes as
    (SELECT name, medal_count, RANK() OVER (ORDER BY medal_count desc) as rnk
    FROM athlete_medals)
SELECT name, medal_count
FROM ranked_athletes
WHERE rnk < 6;