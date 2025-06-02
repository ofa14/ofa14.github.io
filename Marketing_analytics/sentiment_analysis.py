import pandas as pd
import os 
import sqlalchemy
import pyodbc
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer

# Download VADER lexicon for sentiment analysis (only needs to run once)
nltk.download('vader_lexicon')

# ===============================
# Function: Fetch data from SQL Server database
# ===============================
def fetch_data_from_sql():
    conn_str = (
        "Driver={SQL Server};"  
        "Server=MSI\\SQLEXPRESS01;"
        "Database=PortfolioProject_MarketingAnalytics;"
        "Trusted_Connection=yes;"
    )
    conn = pyodbc.connect(conn_str)

    # Query to extract review data
    query = "SELECT ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText FROM fact_customer_reviews"
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# Load data into DataFrame
customer_reviews_df = fetch_data_from_sql()

# Initialize VADER sentiment analyzer
sia = SentimentIntensityAnalyzer()

# ===============================
# Function: Calculate sentiment score for each review
# ===============================
def calculate_sentiment(review):
    sentiment = sia.polarity_scores(review)
    # Return the compound score (-1 = most negative, +1 = most positive)
    return sentiment['compound']

# ===============================
# Function: Categorize sentiment using both sentiment score and rating
# ===============================
def categorize_sentiment(score, rating):
    if score > 0.05:  # Positive sentiment
        if rating >= 4:
            return 'Positive'  # High rating and positive sentiment
        elif rating == 3:
            return 'Mixed Positive'  # Neutral rating but positive sentiment
        else:
            return 'Mixed Negative'  # Low rating but positive sentiment
    elif score < 0.05:  # Negative sentiment
        if rating <= 2:
            return 'Negative'  # Low rating and negative sentiment
        elif rating == 3:
            return 'Mixed Negative'  # Neutral rating but negative sentiment
        else:
            return 'Mixed Positive'  # High rating but negative sentiment
    else:  # Neutral sentiment
        if rating >= 4:
            return 'Positive'  # High rating with neutral sentiment
        elif rating <= 2:
            return 'Negative'  # Low rating with neutral sentiment
        else:
            return 'Neutral'  # Neutral sentiment and neutral rating

# ===============================
# Function: Bucket sentiment scores into defined ranges
# ===============================
def sentiment_bucket(score):
    if score >= 0.5:
        return '0.5 to 1.0'  # Strongly positive sentiment
    elif 0.0 <= score < 0.5:
        return '0.0 to 0.49'  # Mildly positive sentiment
    elif -0.5 <= score < 0.0:
        return '-0.49 to 0.0'  # Mildly negative sentiment
    else:
        return '-1.0 to -0.5'  # Strongly negative sentiment

# ===============================
# Apply sentiment analysis and categorization
# ===============================

# Calculate sentiment score for each review
customer_reviews_df['SentimentScore'] = customer_reviews_df['ReviewText'].apply(calculate_sentiment)

# Categorize sentiment using both sentiment score and rating
customer_reviews_df['SentimentCategory'] = customer_reviews_df.apply(
    lambda row: categorize_sentiment(row['SentimentScore'], row['Rating']), axis=1)

# Bucket sentiment scores into ranges
customer_reviews_df['SentimentBucket'] = customer_reviews_df['SentimentScore'].apply(sentiment_bucket)

# ===============================
# Export results to CSV on Desktop
# ===============================

# Define desktop path
desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
file_path = os.path.join(desktop_path, "fact_customer_reviews_with_sentiment.csv")

# Save the DataFrame to CSV
customer_reviews_df.to_csv(file_path, index=False)

# Confirm file export
print(f"File saved to: {file_path}")

# Preview result
print(customer_reviews_df.head())

        
