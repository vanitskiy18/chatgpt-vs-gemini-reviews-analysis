
#' ---
#' title: "Porównawcza analiza opinii użytkowników ChatGPT i Gemini"
#' author: "Arseniy Vanitskiy, Jakub Jankowski"
#' date: "06.06.2026"
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
library(tm)
library(patchwork)

#' # Dane tekstowe
#' ## Wczytanie danych

chatgpt <- fread("data/chatgpt_reviews.csv")
gemini <- fread("data/gemini_reviews.csv")

#' ## Czyszczenie i integracja danych

set.seed(123)

chatgpt_clean <- chatgpt %>%
  select(content, score) %>%
  filter(!is.na(content)) %>%
  filter(nchar(content) > 20) %>%
  sample_n(20000) %>%
  mutate(model = "ChatGPT")

gemini_clean <- gemini %>%
  select(content, score) %>%
  filter(!is.na(content)) %>%
  filter(nchar(content) > 20) %>%
  sample_n(20000) %>%
  mutate(model = "Gemini")

all_reviews <- bind_rows(chatgpt_clean, gemini_clean) %>%
  mutate(review_id = row_number())

#' # Przygotowanie słowników
#' ## Stopwords i dodatkowe słowa usuwane z analizy

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

tidy_tokeny <- all_reviews %>%
  unnest_tokens(word, content) %>%
  filter(str_detect(word, "^[a-z]+$")) %>%
  filter(nchar(word) > 3) %>%
  anti_join(all_stopwords, by = "word")

#' # Eksploracyjna analiza słów
#' ## Najczęstsze słowa w podziale na modele

top_words <- tidy_tokeny %>%
  group_by(model) %>%
  count(word, sort = TRUE) %>%
  slice_max(n, n = 15) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, model))
#+ fig.width=9, fig.height=6
ggplot(top_words, aes(x = word, y = n, fill = model)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ model, scales = "free") +
  coord_flip() +
  scale_x_reordered() +
  labs(
    title = "Najczęstsze słowa w opiniach: ChatGPT vs Gemini",
    x = "Słowa",
    y = "Liczba wystąpień"
  ) +
  theme_gdocs() +
  scale_fill_manual(values = c("ChatGPT" = "#10a37f", "Gemini" = "#1a73e8"))

#' # Analiza sentymentu NRC
#' ## Porównanie kategorii NRC

sentiment_review_nrc <- tidy_tokeny %>%
  inner_join(get_sentiments("nrc"), by = "word", relationship = "many-to-many")

nrc_summary <- sentiment_review_nrc %>%
  filter(!sentiment %in% c("surprise", "fear", "anticipation", "joy")) %>%
  count(model, sentiment)

ggplot(nrc_summary, aes(x = reorder(sentiment, n), y = n, fill = model)) +
  geom_col(position = "dodge") +
  geom_text(
    aes(label = n),
    position = position_dodge(width = 0.9),
    hjust = -0.2,
    size = 4,
    color = "black"
  ) +
  coord_flip() +
  labs(
    title = "Struktura emocji: ChatGPT vs Gemini",
    x = "Kategoria sentymentu / emocji",
    y = "Liczba wystąpień słów z danej kategorii",
    fill = "Model AI"
  ) +
  theme_gdocs() +
  scale_fill_manual(values = c("ChatGPT" = "#10a37f", "Gemini" = "#1a73e8")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)))

#' ## Porównanie sentymentu pozytywnego i negatywnego

nrc_pos_neg <- sentiment_review_nrc %>%
  filter(sentiment %in% c("positive", "negative")) %>%
  count(model, sentiment) %>%
  group_by(model) %>%
  mutate(procent = n / sum(n) * 100) %>%
  ungroup()
#+ fig.width=9, fig.height=6
ggplot(nrc_pos_neg, aes(x = sentiment, y = procent, fill = model)) +
  geom_col(position = "dodge") +
  labs(
    title = "Słowa pozytywne i negatywne: ChatGPT vs Gemini",
    x = "Sentyment",
    y = "Odsetek słów wewnątrz modelu (%)",
    fill = "Model AI"
  ) +
  theme_gdocs() +
  scale_fill_manual(values = c("ChatGPT" = "#10a37f", "Gemini" = "#1a73e8"))

#' ## Najczęstsze słowa dla kategorii NRC: ChatGPT

#+ fig.height=7, fig.width=10
top_words_nrc_chatgpt <- sentiment_review_nrc %>%
  filter(model == "ChatGPT") %>%
  filter(!sentiment %in% c("surprise", "fear", "anticipation", "joy")) %>%
  count(sentiment, word, sort = TRUE) %>%
  group_by(sentiment) %>%
  slice_max(n, n = 5, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, sentiment))

ggplot(top_words_nrc_chatgpt, aes(x = word, y = n)) +
  geom_col(show.legend = FALSE, fill = "#10a37f") +
  facet_wrap(~ sentiment, scales = "free", ncol = 2) +
  coord_flip() +
  scale_x_reordered() +
  labs(
    title = "Top 5 najczęstszych słów w kategoriach NRC: ChatGPT",
    x = "Słowa",
    y = "Liczba wystąpień"
  ) +
  theme_gdocs()

#' ## Najczęstsze słowa dla kategorii NRC: Gemini

#+ fig.height=7, fig.width=10
top_words_nrc_gemini <- sentiment_review_nrc %>%
  filter(model == "Gemini") %>%
  filter(!sentiment %in% c("surprise", "fear", "anticipation", "joy")) %>%
  count(sentiment, word, sort = TRUE) %>%
  group_by(sentiment) %>%
  slice_max(n, n = 5, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, sentiment))

ggplot(top_words_nrc_gemini, aes(x = word, y = n)) +
  geom_col(show.legend = FALSE, fill = "#1a73e8") +
  facet_wrap(~ sentiment, scales = "free", ncol = 2) +
  coord_flip() +
  scale_x_reordered() +
  labs(
    title = "Top 5 najczęstszych słów w kategoriach NRC: Gemini",
    x = "Słowa",
    y = "Liczba wystąpień"
  ) +
  theme_gdocs()

#' # Analiza asocjacji słów
#' ## Przygotowanie macierzy TDM dla modeli

create_model_tdm <- function(data, target_model, stopwords_list) {
  model_data <- data %>%
    filter(model == target_model)
  
  corpus <- VCorpus(VectorSource(model_data$content))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeWords, stopwords_list)
  
  tdm <- TermDocumentMatrix(corpus, control = list(wordLengths = c(4, Inf)))
  tdm <- removeSparseTerms(tdm, 0.999)
  
  return(tdm)
}

stopwords_vec <- c(stop_words$word, custom_stopwords$word)

tdm_chatgpt <- create_model_tdm(all_reviews, "ChatGPT", stopwords_vec)
tdm_gemini <- create_model_tdm(all_reviews, "Gemini", stopwords_vec)

#' ## Funkcja wizualizacji asocjacji

plot_associations <- function(tdm, term, model_name, min_cor = 0.05) {
  associations <- findAssocs(tdm, term, min_cor)
  
  if (length(associations[[1]]) == 0) {
    p <- ggplot() +
      annotate(
        "text",
        x = 0.5,
        y = 0.5,
        label = paste("Brak silnych asocjacji\n(r >", min_cor, ")")
      ) +
      theme_void() +
      labs(title = paste0("Asocjacje z: '", term, "' (", model_name, ")"))
    
    return(p)
  }
  
  assoc_df <- data.frame(
    word = names(associations[[1]]),
    score = as.numeric(associations[[1]])
  ) %>%
    arrange(score) %>%
    mutate(word = fct_reorder(word, score))
  
  ggplot(assoc_df, aes(x = score, y = word)) +
    geom_segment(
      aes(x = 0, xend = score, y = word, yend = word),
      color = "gray70",
      linewidth = 1.2
    ) +
    geom_point(
      color = ifelse(model_name == "ChatGPT", "#10a37f", "#1a73e8"),
      size = 4
    ) +
    geom_text(
      aes(label = round(score, 2)),
      hjust = -0.3,
      size = 3.5,
      color = "black"
    ) +
    scale_x_continuous(
      limits = c(0, max(assoc_df$score) + 0.1),
      expand = expansion(mult = c(0, 0.2))
    ) +
    theme_minimal(base_size = 12) +
    labs(
      title = paste0("Asocjacje z: '", term, "' (", model_name, ")"),
      subtitle = paste0("Próg r >= ", min_cor),
      x = "Korelacja Pearsona",
      y = "Słowo"
    ) +
    theme(plot.title = element_text(face = "bold"))
}

#' ## Obliczenie asocjacji dla wybranych słów

plot_wrong_chatgpt <- plot_associations(tdm_chatgpt, "wrong", "ChatGPT", 0.05)
plot_wrong_gemini <- plot_associations(tdm_gemini, "wrong", "Gemini", 0.05)

plot_answer_chatgpt <- plot_associations(tdm_chatgpt, "answer", "ChatGPT", 0.05)
plot_answer_gemini <- plot_associations(tdm_gemini, "answer", "Gemini", 0.05)

plot_subscription_chatgpt <- plot_associations(tdm_chatgpt, "subscription", "ChatGPT", 0.05)
plot_subscription_gemini <- plot_associations(tdm_gemini, "subscription", "Gemini", 0.05)

plot_understanding_chatgpt <- plot_associations(tdm_chatgpt, "understanding", "ChatGPT", 0.05)
plot_understanding_gemini <- plot_associations(tdm_gemini, "understanding", "Gemini", 0.05)

#' ## Porównanie asocjacji dla słowa "wrong"

#+ fig.width=10, fig.height=5
plot_wrong_chatgpt + plot_wrong_gemini

#' ## Porównanie asocjacji dla słowa "answer"

#+ fig.width=10, fig.height=5
plot_answer_chatgpt + plot_answer_gemini

#' ## Porównanie asocjacji dla słowa "subscription"

#+ fig.width=10, fig.height=5
plot_subscription_chatgpt + plot_subscription_gemini

#' ## Porównanie asocjacji dla słowa "understanding"

#+ fig.width=10, fig.height=5
plot_understanding_chatgpt + plot_understanding_gemini
