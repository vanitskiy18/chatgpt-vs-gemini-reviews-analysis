#' ---
#' title: "Porównawcza analiza opinii użytkowników ChatGPT i Gemini"
#' author: "Arseniy Vanitskiy"
#' date: "2026"
#' output:
#'   html_document:
#'     df_print: paged
#'     theme: cerulean
#'     highlight: default
#'     toc: true
#'     toc_depth: 3
#'     toc_float:
#'       collapsed: false
#'       smooth_scroll: true
#'     code_folding: show
#'     number_sections: true
#' ---

#+ setup, include=FALSE
knitr::opts_chunk$set(
  message = FALSE,
  warning = FALSE
)

#' # Wymagane pakiety

library(data.table)
library(dplyr)
library(tidytext)
library(textdata)
library(ggplot2)
library(ggthemes)
library(stringr)
library(forcats)

#' # Dane tekstowe
#' ## Wczytanie danych

chatgpt <- fread("chatgpt_reviews.csv")

#' ## Czyszczenie danych i ograniczenie liczby opinii

set.seed(123)

chatgpt_clean <- chatgpt %>%
  select(content, score) %>%
  filter(!is.na(content)) %>%
  filter(nchar(content) > 20) %>%
  sample_n(20000) %>%
  mutate(
    review_id = row_number(),
    model = "ChatGPT"
  )

#' # Przygotowanie słowników
#' ## Stopwords i dodatkowe niepotrzebne słowa

data("stop_words")

custom_stopwords <- tibble(
  word = c(
    "app", "apps", "chatgpt", "openai", "gemini", "google", "android",
    "use", "using", "used", "user", "users",
    "one", "get", "got", "also", "really", "even",
    "would", "could", "make", "makes", "made",
    "like", "just", "still", "much", "many",
    "thing", "things", "something", "anything",
    "im", "ive", "id", "ill",
    "dont", "didnt", "doesnt", "cant", "couldnt",
    "wasnt", "werent", "isnt", "arent", "wont",
    "theyre", "youre", "weve", "thats", "theres",
    "please", "thanks", "thank", "okay", "yeah", "yes", "nope"
  ),
  lexicon = "custom"
)

all_stopwords <- bind_rows(stop_words, custom_stopwords)

#' # Tokenizacja i czyszczenie tekstu

tidy_tokeny <- chatgpt_clean %>%
  unnest_tokens(word, content) %>%
  filter(str_detect(word, "^[a-z]+$")) %>%
  filter(nchar(word) > 3) %>%
  anti_join(all_stopwords, by = "word")

head(tidy_tokeny, 10)

#' # Analiza sentymentu NRC
#' ## Wszystkie kategorie NRC

sentiment_review_nrc <- tidy_tokeny %>%
  inner_join(get_sentiments("nrc"), by = "word", relationship = "many-to-many")

nrc_summary <- sentiment_review_nrc %>%
  filter(!sentiment %in% c("surprise", "fear", "anticipation", "joy")) %>%
  count(sentiment, sort = TRUE)

print(nrc_summary)

#' ## Wizualizacja kategorii NRC

ggplot(nrc_summary, aes(x = reorder(sentiment, n), y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Sentyment i emocje w opiniach użytkowników ChatGPT (NRC)",
    x = "Kategoria sentymentu / emocji",
    y = "Liczba wystąpień słów"
  ) +
  theme_gdocs()

#' ## Najczęstsze słowa dla kategorii NRC

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

#' ## Porównanie sentymentu pozytywnego i negatywnego

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

#' # Eksploracyjna analiza słów
#' ## Najczęstsze słowa po czyszczeniu

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

#' # Analiza asocjacji słów
#' ## Przygotowanie danych do analizy asocjacji

library(tm)

set.seed(123)

assoc_sample <- chatgpt_clean %>%
  sample_n(20000) %>%              
  select(content)

assoc_corpus <- VCorpus(VectorSource(assoc_sample$content))

assoc_corpus <- tm_map(assoc_corpus, content_transformer(tolower))
assoc_corpus <- tm_map(assoc_corpus, removePunctuation)
assoc_corpus <- tm_map(assoc_corpus, removeNumbers)
assoc_corpus <- tm_map(assoc_corpus, stripWhitespace)

assoc_corpus <- tm_map(
  assoc_corpus,
  removeWords,
  c(stop_words$word, custom_stopwords$word)
)

tdm_assoc <- TermDocumentMatrix(
  assoc_corpus,
  control = list(
    wordLengths = c(4, Inf)
  )
)

# Usunięcie bardzo rzadkich słów dla przyspieszenia analizy
tdm_assoc <- removeSparseTerms(tdm_assoc, 0.9999)

#' ## Asocjacje dla wybranych słów

findAssocs(tdm_assoc, "recommend", 0.1)
findAssocs(tdm_assoc, "information", 0.1)
findAssocs(tdm_assoc, "subscription", 0.1)
findAssocs(tdm_assoc, "awful", 0.15)
findAssocs(tdm_assoc, "wrong", 0.1)
findAssocs(tdm_assoc, "abilities", 0.1)
findAssocs(tdm_assoc, "understanding", 0.1)
findAssocs(tdm_assoc, "answer", 0.1)

#' ## Wizualizacja asocjacji dla wybranego słowa

plot_associations <- function(tdm, term, min_cor = 0.15) {
  
  associations <- findAssocs(tdm, term, min_cor)
  
  if (length(associations[[1]]) == 0) {
    print(paste("Brak asocjacji dla słowa:", term))
    return(NULL)
  }
  
  assoc_df <- data.frame(
    word = names(associations[[1]]),
    score = as.numeric(associations[[1]])
  ) %>%
    arrange(score) %>%
    mutate(word = fct_reorder(word, score))
  
  ggplot(assoc_df, aes(x = score, y = word)) +
    geom_segment(aes(x = 0, xend = score, y = word, yend = word),
                 color = "#a6bddb", size = 1.2) +
    geom_point(color = "#0570b0", size = 4) +
    geom_text(aes(label = round(score, 2)),
              hjust = -0.3, size = 3.5, color = "black") +
    scale_x_continuous(
      limits = c(0, max(assoc_df$score) + 0.1),
      expand = expansion(mult = c(0, 0.2))
    ) +
    theme_minimal(base_size = 12) +
    labs(
      title = paste0("Asocjacje z terminem: '", term, "'"),
      subtitle = paste0("Próg r >= ", min_cor),
      x = "Współczynnik korelacji Pearsona",
      y = "Słowo"
    ) +
    theme(
      plot.title = element_text(face = "bold"),
      axis.title.x = element_text(margin = margin(t = 10)),
      axis.title.y = element_text(margin = margin(r = 10))
    )
}

plot_associations(tdm_assoc, "recommend", 0.1)
plot_associations(tdm_assoc, "information", 0.1)
plot_associations(tdm_assoc, "subscription", 0.1)
plot_associations(tdm_assoc, "awful", 0.15)
plot_associations(tdm_assoc, "wrong", 0.1)
plot_associations(tdm_assoc, "abilities", 0.1)
plot_associations(tdm_assoc, "understanding", 0.1)
plot_associations(tdm_assoc, "answer", 0.1)