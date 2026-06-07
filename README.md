# 🤖📊 ChatGPT vs Gemini Reviews Analysis

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge\&logo=r\&logoColor=white)
![HTML](https://img.shields.io/badge/HTML_Report-E34F26?style=for-the-badge\&logo=html5\&logoColor=white)
![Data Science](https://img.shields.io/badge/Data_Science-Analysis-blue?style=for-the-badge)
![Sentiment Analysis](https://img.shields.io/badge/Sentiment_Analysis-NRC-green?style=for-the-badge)
![Text Mining](https://img.shields.io/badge/Text_Mining-TidyText-orange?style=for-the-badge)
![PSI](https://img.shields.io/badge/Projektowanie_Systemów_Informatycznych-UW-red?style=for-the-badge)
![University Project](https://img.shields.io/badge/University_Project-2026-purple?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

---

## 📖 Opis projektu

Projekt został wykonany w ramach przedmiotu **Projektowanie Systemów Informatycznych** na **Uniwersytecie Warszawskim**.

Celem projektu jest przeprowadzenie porównawczej analizy opinii użytkowników dwóch najpopularniejszych modeli sztucznej inteligencji:

* 🤖 ChatGPT
* ✨ Gemini

Badanie wykorzystuje metody:

* analizy sentymentu,
* eksploracji tekstu (text mining),
* analizy asocjacji słów,
* wizualizacji danych.

Wyniki prezentowane są w postaci automatycznie generowanego raportu HTML zgodnego z podejściem **Reproducible Research**.

---

## 🎯 Cele projektu

Projekt pozwala:

* porównać odbiór ChatGPT i Gemini przez użytkowników,
* zidentyfikować dominujące emocje i sentyment,
* znaleźć najczęściej występujące słowa,
* wykryć powiązania pomiędzy słowami w recenzjach,
* wygenerować czytelny raport analityczny.

---

## 📂 Wykorzystane dane

Analiza została przeprowadzona na zbiorach recenzji użytkowników:

* ChatGPT Reviews
* Gemini Reviews

Po oczyszczeniu danych:

* usunięto brakujące obserwacje,
* odrzucono bardzo krótkie opinie,
* przeprowadzono tokenizację tekstu,
* usunięto stop words,
* zastosowano dodatkową listę słów wykluczonych.

Łącznie analizowanych jest około **40 000 opinii użytkowników**.

---

## 🔍 Zakres analizy

### 📈 Analiza sentymentu NRC

Badane są kategorie emocji:

* Positive
* Negative
* Trust
* Anger
* Disgust
* Sadness

oraz porównywany jest ogólny sentyment obu modeli.

### 📝 Analiza najczęstszych słów

Projekt identyfikuje:

* najczęściej występujące słowa,
* słowa charakterystyczne dla ChatGPT,
* słowa charakterystyczne dla Gemini.

### 🔗 Analiza asocjacji słów

Dla wybranych pojęć obliczane są zależności na podstawie:

* współczynnika korelacji Pearsona,
* macierzy Term-Document Matrix (TDM).

Pozwala to określić, jakie słowa najczęściej współwystępują z analizowanymi pojęciami.

---

## 📊 Generowane wizualizacje

Projekt automatycznie tworzy:

* wykres najczęstszych słów,
* porównanie emocji NRC,
* porównanie sentymentu pozytywnego i negatywnego,
* wykresy najczęstszych słów dla kategorii sentymentu,
* wykresy asocjacji słów.

---

## 🛠 Wykorzystane technologie

### Język

* R

### Biblioteki

* tidyverse
* dplyr
* tidytext
* textdata
* tm
* ggplot2
* ggthemes
* patchwork
* stringr
* data.table

### Format raportu

* R Markdown
* HTML

### Kontrola wersji

* Git
* GitHub

---

## 📁 Struktura projektu

```text
chatgpt-vs-gemini-reviews-analysis
│
├── data/
│   ├── chatgpt_reviews.csv
│   └── gemini_reviews.csv
│
├── dictionaries/
│
├── analysis.R
├── analysis.html
├── README.md
├── LICENSE
├── Dokumentacja i speyfikacja wymagań - ChaGPT vs Gemini analysis.pdf
└── .gitignore
```

---

## ▶️ Uruchomienie projektu

### 1. Klonowanie repozytorium

```bash
git clone https://github.com/USERNAME/chatgpt-vs-gemini-reviews-analysis.git
```

### 2. Instalacja wymaganych pakietów

```r
install.packages(c(
  "data.table",
  "dplyr",
  "tidytext",
  "textdata",
  "ggplot2",
  "ggthemes",
  "stringr",
  "forcats",
  "tm",
  "patchwork"
))
```

### 3. Uruchomienie analizy

```r
source("analysis.R")
```

---

## 📑 Dokumentacja

Projekt zawiera:

* dokumentację SRS,
* kod źródłowy,
* dane wejściowe,
* raport HTML.

Dokumentacja została przygotowana zgodnie z założeniami przedmiotu **Projektowanie Systemów Informatycznych**.

---

## 👨‍💻 Autorzy

**Arseniy Vanitskiy**
Uniwersytet Warszawski

**Jakub Jankowski**
Uniwersytet Warszawski

---

## 🎓 Cel edukacyjny

Projekt został stworzony w celach edukacyjnych jako przykład zastosowania:

* Data Science,
* Text Mining,
* Sentiment Analysis,
* Reproducible Research,
* Wizualizacji danych.

---

## 📄 Licencja

Projekt udostępniony na licencji MIT.
