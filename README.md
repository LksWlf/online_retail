# RFM Customer Segmentation for Online Retail Dataset

## Problem Description
Understanding customer behavior is crucial for developing effective marketing strategies as well as steering and developing companies products. One powerful method to gain insights into customer value and loyalty is through **RFM analysis**. RFM stands for Recency, Frequency and Monetary value, which are three key dimensions used to evaluate and segment customers based on their purchasing behavior and activities.

1. **Recency (R)**: How recently a customer has made a purchase.
2. **Frequency (F)**: How often a customer makes a purchase.
3. **Monetary Value (M)**: How much money a customer spends on purchases.

By analyzing these dimensions, businesses can **categorize their customers** into distinct segments, enabling **targeted marketing efforts** and **personalized communication** as well as **improved customer retention strategies**. This segmentation helps identify high-value customers, those at risk of churn, but also potential opportunities for dedicated targeting.

What I personally like about the RFM Segmentation is how **realitvely easy and quick** it can be implemented by using **SQL**, providing **useful insights** for Marketing and Business Teams in a very straightforward and easy to understand way.

## Dataset
In this project, we will perform the RFM segmentation using data from an online Retail Dataset, which I took from the Machine Learning Repository provided by the University of California https://archive.ics.uci.edu/dataset/502/online+retail+ii.

## Method
The Project (and therefore SQL file in this folder) starts as usual: data loading and table creation. I have used MySQL to create the table and write the SQL queries. In the following, we try to understand our dataset and check for missing values as well as outliers, especially when it comes to values, that directly effect our RFM segmentation.

After the data preprocessing, we sort our customers by Frequency, Recency and Monetary values, by calculating how often they purchased (Frequency), when they did their last purchase (Recency) and how much money they spend in their customer lifetime (Monetary). For each metric, we will divide the customer in different quartiles, and assigning the top 25% a score of 5, and so on, until we assign the low 25% a score of 1. To get a final RFM score, we can combine the individual rankings of R, F, and M for each customer.

This rather simple way of assigning values to customers from 1–4 will result in at most 64 different RFM segments (4x4x4), ranging from 1-1-1 to 4-4-4. In some situations it might be sufficent for certain businesses to focus on Recency and Frequency only, as it leads to a lower number of distinct segmentations and provides the opportunity to show the results and the different groups in a 2D visual. For the sake of completeness, this calculation is provided as well, using scores 1-5 in that case.

## Result
The result is an RFM customer segmentation for a company from the online retail business, which enables the individual customer segments to be targeted and the product to be further developed in a controlled manner and adapted to the customers. 
A simplified version of RF segmentation was also calculated as an alternative.
Further development opportunities exist, for example, in the setting of parameters to control the influence per metric (RFM) on the final value.
In addition, a tracking system can be set up in which the values are recalculated after each fixed time-interval and the previous results are saved. This allows a tracking over time.

