import pandas as pd

dates = pd.date_range('2020-01-01', '2030-12-31')
df = pd.DataFrame({
    'date_key':      dates.strftime('%Y%m%d').astype(int),
    'full_date':    dates.strftime('%Y-%m-%d'),
    'year':         dates.year,
    'quarter':      dates.quarter,
    'month':        dates.month,
    'month_name':   dates.strftime('%B'),
    'week_of_year': dates.isocalendar().week.values,
    'day_of_week':  dates.day_of_week + 1,
    'day_name':     dates.strftime('%A'),
    'is_weekend':   (dates.day_of_week >= 5).astype(int)
})
df.to_csv('seeds/dim_date.csv', index=False)