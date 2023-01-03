#############
## packages
#############

library(dplyr)
library(tidyr)
library(rvest)
library(quantmod)
library(httr)
library(tibble)

#############
##  kaggle Dataset netflix
#############

## read csv
df1 <- read.csv("netflix_titles.csv", header = TRUE, sep = ',')


## Fix durations and cast columns => separando a coluna de duração
## em duas partes (numero de minutos e temporadas e o tipo (minutos ou temporadas))
## separando as linhas do cast
ds_netflix_titles <- df1 %>% 
  separate(duration, into = c("duration_num", "duration_type" ), sep = " ") %>% 
  separate_rows(cast, sep = ", ")


## export file
write.csv2(ds_netflix_titles, "ds_netflix_titles.csv", sep = ';')

#############
##  wikipedia html table
#############

## URL wikipedia
oscars_url <- "https://en.wikipedia.org/wiki/List_of_Academy_Award-winning_films"

## pegando tabela html dos oscars (usando classes)
 ds_oscars <- read_html(oscars_url) 
 # html_node("table") %>% 
 # html_table()

## segunda forma de pegar tabelas html (usando xpath)
ds_oscars <- read_html(oscars_url) %>% 
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table') %>% 
  html_table() %>% 
  select(title = Film, Awards) #selecionou apenas as colunas que serão utilizadas

# export oscars table
write.csv2(ds_oscars, "ds_oscars.csv", sep = ';')


#############
##  ranking IMDB html table
#############
imdb_ranking_url <- "https://www.imdb.com/chart/top/?ref_=nv_mv_250"

## passando os titulos do ranking IMDB para ingles
ds_imdb_title <- imdb_ranking_url %>% 
  html_session(add_headers("Accept-Language" = "en")) %>% 
  read_html() %>% 
  html_nodes(".titleColumn a") %>% 
  html_text()

## pegando as avaliações do top rated movies IMDB
ds_imdb_rating <- read_html(imdb_ranking_url) %>% 
  html_nodes(".imdbRating strong") %>% 
  html_text()

## criando a tabela imdb (juntando a lista com o nome dos filmes e as avaliações)
ds_imdbTible <- as.tibble(cbind(Title = ds_imdb_title, Rating = ds_imdb_rating))

## export file
write.csv2(ds_imdbTible, "ds_imdbTibble.csv", sep = ";")

## yahoo finance (ações da netflix)
getSymbols("NFLX", src = "yahoo")

## criando uma coluna para as datas e pegando as colunas de fechamento (close) e volume das ações 
ds_stocks <- as.data.frame(NFLX) %>% 
  rownames_to_column(var = "Date") %>%
  select(Date, Price = NFLX.Close, Volume = NFLX.Volume)

## export file
write.csv2(ds_stocks, "ds_stocks.csv", sep = ';')