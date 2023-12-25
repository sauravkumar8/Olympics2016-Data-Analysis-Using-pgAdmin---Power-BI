# Olympics Data Analysis Using pgAdmin and Power BI

About Project

In this endeavor, we will engage in crafting SQL queries using an authentic dataset. Our source will be the "120 Years of Olympics History" dataset available on Kaggle, contributed by the user rgriffin. By opting for this real dataset instead of synthetic data, we gain the advantage of working with actual information. This approach enables a deeper understanding of the data, facilitating the creation of diverse and meaningful SQL queries.

Downloaded Data from Kaggle can be accessed here:	
https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results

Content of Data

The data contains 271116 rows and 15 columns. Each row corresponds to an individual athlete competing in an individual Olympic event. The columns are:
1. ID - Unique number for each athlete
2.  Name - Athlete's name
3. Sex - M or F
4. Age - Integer
5. Height - In centimeters
6. Weight - In kilograms
7. Team - Team name
8. NOC - National Olympic Committee 3-letter code
9. Games - Year and season
10. Year - Integer
11. Season - Summer or Winter
12. City - Host city
13. Sport - Sport
14. Event - Event
15. Medal - Gold, Silver, Bronze, or NA

Limitations of Data

The dataset includes information on team sports where each athlete is linked to individual medals instead of being grouped as part of a single team. This necessitates the duplication of data for multiple occurrences of individual athletes.


