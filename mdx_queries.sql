-- number of products per contributor type (on rows) and creation year (on columns)


-- number of versions (i.e. updates) per year and month (on rows) having vs. not having Nutri-Score (on columns).
WITH MEMBER [Measures].[no_nova_score] AS
    [Measures].[number_of_publications] - [Measures].[version_has_nutrition_score]
SELECT
    {
        [Measures].[number_of_publications],
        [Measures].[no_nova_score],
        [Measures].[version_has_nutrition_score]
    } ON COLUMNS,
    [TimeModified].[Year].Members ON ROWS
FROM [Publications]