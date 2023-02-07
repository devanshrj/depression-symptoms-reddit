# depr_final is the message table that contains Reddit posts with symptom labels

# clean messages
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id --clean_messages

# extract 1 grams
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id --add_ngrams -n 1


# LDA
# estimate topics
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id -f 'feat$1gram$depr_final$message_id' --estimate_lda_topics --lda_lexicon_name depr_lda200 --lexicondb mh_symptoms --mallet_path /home/sharath/mallet-2.0.8/bin/mallet --num_topics 200 --num_stopwords 100 --num_lda_threads 100 --save_lda_file /sandata/devanshjain/rdoc_depression/dla/depr_lda200

# extract LDA features
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id --lexicondb mh_symptoms --add_lex_table -l depr_lda200_cp --weighted_lexicon

# DLA with LDA features
./dlatkInterface.py -d mh_symptoms -t depr_final -g message_id -f 'feat$cat_depr_lda200_cp_w$depr_final$message_id$1gra' --outcome_table depr_final --group_freq_thresh 10 --outcomes second_level_symptom first_level_symptom --categorical second_level_symptom first_level_symptom --output_name ~/rdoc/dla/cat_lda200_logistic --topic_tagcloud --make_topic_wordcloud --lexicondb mh_symptoms --topic_lexicon depr_lda200_freq_t50ll --tagcloud_colorscheme bluered --logistic --csv

# 5-fold prediction with LDA features
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id -f 'feat$cat_depr_lda200_cp_w$depr_final$message_id$1gra' --outcome_table depr_final --outcomes first_level_symptom --categorical first_level_symptom --combo_test_classifiers --model rfc --folds 5 --stratify_folds --group_freq_thresh 10 --csv --output_name ~/rdoc/prediction/rfc_lda.csv

# validation on FB dataset with LDA features
# train classifier
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id -f 'feat$cat_depr_lda200_cp_w$depr_final$message_id$1gra' --outcome_table depr_final --outcomes first_level_symptom --categorical first_level_symptom --group_freq_thresh 10 --train_classifiers --model rfc --save_model --picklefile ~/rdoc/prediction/first_level.depr_lda200.rfc.gft10.pickle

# generate LDA features on FB dataset
./dlatkInterface.py -d loneliness -t msgs_fb_en -c user_id -f 'feat$1gram$msgs_fb_en$user_id$16to16' --lexicondb mh_symptoms --add_lex_table -l depr_lda200_cp --weighted_lexicon

# create dummy outcome table as per DLATK requirements
CREATE TABLE symptomDummy_user SELECT distinct user_id, 0 as `first_level_symptom__sad_mood`, 0 as `first_level_symptom__self_loathing`, 0 as `first_level_symptom__sleep_problem`, 0 as `first_level_symptom__anger`, 0 as `first_level_symptom__somatic_complaint`, 0 as `first_level_symptom__worthlessness`, 0 as `first_level_symptom__control`, 0 as `first_level_symptom__anhedonia`, 0 as `first_level_symptom__fatigue`, 0 as `first_level_symptom__anxiety`, 0 as `first_level_symptom__concentration_problem`, 0 as `first_level_symptom__suicidal_ideation`, 0 as `first_level_symptom__loneliness`, 0 as `first_level_symptom__eating_complaint` FROM msgs_fb_en;

# apply trained model
./dlatkInterface.py -d loneliness -t msgs_fb_en -c user_id -f 'feat$cat_depr_lda200_cp_w$msgs_fb_en$user_id$1gra' --outcome_table symptomDummy_user --outcomes 'first_level_symptom__sad_mood' 'first_level_symptom__self_loathing' 'first_level_symptom__sleep_problem' 'first_level_symptom__anger' 'first_level_symptom__somatic_complaint' 'first_level_symptom__worthlessness' 'first_level_symptom__control' 'first_level_symptom__anhedonia' 'first_level_symptom__fatigue' 'first_level_symptom__anxiety' 'first_level_symptom__concentration_problem' 'first_level_symptom__suicidal_ideation' 'first_level_symptom__loneliness' 'first_level_symptom__eating_complaint' --group_freq_thresh 10 --predict_classifiers --predict_probs_to_feats lda_symptom --load --picklefile ~/rdoc/prediction/first_level.depr_lda200.rfc.gft10.pickle


# RoBERTa
# extract RoBERTa features
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id --add_bert --bert_model roberta-base --emb_class Roberta --embedding_keep_msg

# 5-fold prediction with RoBERTa features
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id -f 'feat$roberta_ba_meL10con$depr_final$message_id' --outcome_table depr_final --outcomes first_level_symptom --categorical first_level_symptom --combo_test_classifiers --model rfc --folds 5 --stratify_folds --group_freq_thresh 10 --csv --output_name ~/rdoc/prediction/rfc_bert.csv

# validation on FB dataset with RoBERTa features
# train classifier
./dlatkInterface.py -d mh_symptoms -t depr_final -c message_id -f 'feat$roberta_ba_meL10con$depr_final$message_id' --outcome_table depr_modified --outcomes first_level_symptom --categorical first_level_symptom --group_freq_thresh 10 --train_classifiers --model rfc --save_model --picklefile ~/rdoc/prediction/first_level.roberta.rfc.gft10.pickle

# apply trained model using the same dummy outcome table as before
./dlatkInterface.py -d loneliness -t msgs_fb_en -c user_id -f 'feat$roberta_ba_meL10con$msgs_fb_en$user_id$consistent' --outcome_table symptomDummy_user --outcomes 'first_level_symptom__sad_mood' 'first_level_symptom__self_loathing' 'first_level_symptom__sleep_problem' 'first_level_symptom__anger' 'first_level_symptom__somatic_complaint' 'first_level_symptom__worthlessness' 'first_level_symptom__control' 'first_level_symptom__anhedonia' 'first_level_symptom__fatigue' 'first_level_symptom__anxiety' 'first_level_symptom__concentration_problem' 'first_level_symptom__suicidal_ideation' 'first_level_symptom__loneliness' 'first_level_symptom__eating_complaint' --group_freq_thresh 10 --predict_classifiers --predict_probs_to_feats bert_symptom --load --picklefile ~/rdoc/prediction/first_level.roberta.rfc.gft10.pickle