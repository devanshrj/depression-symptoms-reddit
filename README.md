# Detecting Symptoms of Depression on Reddit

We use Reddit posts from depression and mental health related subreddits to detect symptoms of depression in a distantly supervised manner. Specifically:
1. We identify the online language markers of 13 symptoms of depression using 1,318,749 posts from 43 subreddit communities. 
2. We build 13 prediction models (based on RoBERTa embeddings) that can detect specific symptom discourse vs. posts
from control subreddits contributed by the same Reddit users.
3. We validate the prediction models on a sample who shared their Facebook posts and also took clinical self-report depression (PHQ-9), anxiety (GAD-7), and loneliness (UCLA-3) surveys.

The description of the data and models is part of our paper published at ACM Web Science Conference 2023.