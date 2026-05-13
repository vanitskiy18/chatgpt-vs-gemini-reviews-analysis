



# Analiza sentymentu - ChatGPT reviews

library(data.table)
library(dplyr)
library(tidytext)
library(textdata)
library(ggplot2)
library(ggthemes)
library(stringr)
library(forcats)

# 1. Wczytanie danych

chatgpt <- fread("chatgpt_reviews.csv")

# 2. Czyszczenie danych i ograniczenie liczby opinii

set.seed(123)

chatgpt_clean <- chatgpt %>%
  select(content, score) %>%
  filter(!is.na(content)) %>%
  filter(nchar(content) > 20) %>%      # usuwamy bardzo krótkie opinie
  sample_n(20000) %>%                 # ograniczamy liczbę opinii
  mutate(
    review_id = row_number(),
    model = "ChatGPT"
  )

# 3. Stopwords + dodatkowe niepotrzebne słowa

data("stop_words")

custom_stopwords <- tibble(
  word = c(
    # słowa związane z aplikacją / tematem, które mogą dominować wyniki
    "app", "apps", "chatgpt", "openai", "gemini", "google", "android",
    
    # ogólne słowa bez dużej wartości analitycznej
    "use", "using", "used", "user", "users",
    "one", "get", "got", "also", "really", "even",
    "would", "could", "make", "makes", "made",
    "like", "just", "still", "much", "many",
    "thing", "things", "something", "anything",
    
    # krótkie / potoczne formy po usunięciu apostrofów
    "im", "ive", "id", "ill",
    "dont", "didnt", "doesnt", "cant", "couldnt",
    "wasnt", "werent", "isnt", "arent", "wont",
    "theyre", "youre", "weve", "thats", "theres",
    
    # inne częste śmieci z opinii
    "please", "thanks", "thank", "okay", "yeah", "yes", "nope"
  ),
  lexicon = "custom"
)

all_stopwords <- bind_rows(stop_words, custom_stopwords)

# 4. Tokenizacja + czyszczenie tokenów


tidy_tokeny <- chatgpt_clean %>%
  unnest_tokens(word, content) %>%
  filter(str_detect(word, "^[a-z]+$")) %>%  # zostawiamy tylko słowa z liter
  filter(nchar(word) > 3) %>%               # usuwamy krótkie słowa: he, she, it, did itd.
  anti_join(all_stopwords, by = "word")

head(tidy_tokeny, 10)

# 5. Analiza sentymentu NRC - wszystkie emocje


sentiment_review_nrc <- tidy_tokeny %>%
  inner_join(get_sentiments("nrc"), by = "word", relationship = "many-to-many")

# Podsumowanie kategorii NRC
nrc_summary <- sentiment_review_nrc %>%
  count(sentiment, sort = TRUE)

print(nrc_summary)

# 6. Wizualizacja wszystkich kategorii NRC

ggplot(nrc_summary, aes(x = reorder(sentiment, n), y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Sentyment i emocje w opiniach użytkowników ChatGPT (NRC)",
    x = "Kategoria sentymentu / emocji",
    y = "Liczba wystąpień słów"
  ) +
  theme_gdocs()

# 7. Najczęstsze słowa dla każdej kategorii NRC

top_words_nrc <- sentiment_review_nrc %>%
  filter(!sentiment %in% c("surprise", "fear", "anticipation", "joy")) %>%
  count(word, sentiment, sort = TRUE) %>%
  group_by(sentiment) %>%
  slice_max(n, n = 10) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, sentiment))

ggplot(top_words_nrc, aes(x = word, y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ sentiment, scales = "free") +
  coord_flip() +
  scale_x_reordered() +
  labs(
    title = "Najczęstsze słowa w kategoriach NRC - ChatGPT",
    x = "Słowa",
    y = "Liczba wystąpień"
  ) +
  theme_gdocs()

# 8. Positive vs Negative według NRC

nrc_pos_neg <- sentiment_review_nrc %>%
  filter(sentiment %in% c("positive", "negative")) %>%
  count(sentiment)

print(nrc_pos_neg)

ggplot(nrc_pos_neg, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Porównanie słów pozytywnych i negatywnych - ChatGPT (NRC)",
    x = "Sentyment",
    y = "Liczba wystąpień"
  ) +
  theme_gdocs()

# 9. Najczęstsze słowa ogólnie po czyszczeniu

top_words <- tidy_tokeny %>%
  count(word, sort = TRUE) %>%
  slice_max(n, n = 20) %>%
  mutate(word = fct_reorder(word, n))

ggplot(top_words, aes(x = word, y = n)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Najczęstsze słowa w opiniach o ChatGPT po czyszczeniu",
    x = "Słowa",
    y = "Liczba wystąpień"
  ) +
  theme_gdocs()















