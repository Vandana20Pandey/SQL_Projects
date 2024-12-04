This case study explores the Google Play Store dataset using SQL to extract valuable insights about app categories, ratings, pricing structures, and market share. By analyzing this dataset, we aim to answer critical business and user-behavior questions, providing actionable insights into app trends and performance.

Dataset Description
The dataset contains information about apps on the Google Play Store. Key columns include:

App: Name of the application.
Category: App category (e.g., Tools, Entertainment).
Rating: Average user rating of the app.
Reviews: Number of user reviews.
Size: Size of the app (e.g., 15 MB).
Installs: Number of times the app was installed.
Type: Whether the app is Free or Paid.
Price: Price of the app (if applicable).
Content Rating: Target audience of the app (e.g., Everyone, Teen).
Genres: Additional genre information.
Last Updated: The date the app was last updated.
Current Version : The current version of app which is available.
Android Version : The Android version on which the app the app will run.

SQL Techniques Used
Data Aggregation: GROUP BY, SUM(), AVG(), COUNT().
Filtering: WHERE, HAVING.
Sorting: ORDER BY.
Joins and Subqueries: For multi-dimensional analysis.
Date Functions: To analyze trends over time.
Case Statements: For conditional categorization.
Triggers : For storing the log record.
Stored Procedure : For getting the apps real time feedback by providing the category.

Insights Gained
1. The most promising categories which have more than average rating are events, education,
   Art and Design, Books and Reference, Parenting.
2. Lifestyle, Finance and Photography are the three most revenue generating categories in paid 
   apps.
3. Game, Communication, Productivity, Social, Tools, Family, Photography, News and Magazines, Travel and Local, Video Players are these topmost categories having maximum no of installs.




