-- We wrote SQL to verfity that our MDX queries return the correct results.


select
  pseudo,
    CASE
          WHEN avg(nutrition_score_fr) < 0 THEN 'A'
          WHEN avg(nutrition_score_fr) < 2.5 THEN 'B'
          WHEN avg(nutrition_score_fr) < 10.5 THEN 'C'
          WHEN avg(nutrition_score_fr) < 18 THEN 'D'
          ELSE 'E' 
    END as letter,
    avg(nutrition_score_fr) as avg_score,
    count(*)
from base_bousse.OFF_2_version_produit as p
inner join (
  select barcode, max(date_modification) as latest_modification
  from base_bousse.OFF_2_version_produit
  group by barcode
) as le on p.barcode = le.barcode and p.date_modification = le.latest_modification
where p.nutrition_score_fr is not null
group by pseudo  
having count(*) >= 5
ORDER BY `avg_score`  DESC  