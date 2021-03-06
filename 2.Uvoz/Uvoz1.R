# Uvozimo potrebne knjižnice
library(rvest)
library(dplyr) 
library(gsubfn)

#########################################################################################

#RELIGIJE

link3 <- "https://en.wikipedia.org/wiki/Religions_by_country"
stran3 <- html_session(link3) %>% read_html()

religije <- stran3 %>% html_nodes(xpath="//table[@class='wikitable sortable']") %>%
  .[[1]] %>% html_table()           #RELIGIJE

names(religije)<- c("country","Region","Subregion","Population","Christian","Christian%",
                    "Muslim","Muslim%","Unaffiliated","Unaffiliated%","Hindu","Hindu%",
                    "Buddhist","Buddhist%","Folk Religion","Folk Religion%",
                    "Other Religion","Other Religion%","Jewish","Jewish%")

#odvečne vrstice
religije<-religije[-c(22,33,40,60,64,71,81,88,96,97,108,121,130,140,155,161,169,181,191,203,229,239,256,263,278),]


Encoding(religije$country) <- "UTF-8"
religije$country <- religije$country %>% strapplyc("([a-zA-Z -]+)") %>%
  sapply(. %>% .[[1]]) %>% trimws()


religije[,6] <- religije[,6] %>% strapplyc("([0-9.]+)") %>%
  unlist() %>% as.numeric()

religije$Population <- religije$Population %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()

religije[,8] <- religije[,8] %>% strapplyc("([0-9.]+)") %>%
  sapply(. %>% .[[1]]) %>% as.numeric()

religije[,10] <- religije[,10] %>% strapplyc("([0-9.]+)") %>%
  unlist() %>% as.numeric()
religije[,12] <- religije[,12] %>% strapplyc("([0-9.]+)") %>%
  unlist() %>% as.numeric()
religije[,14] <- religije[,14] %>% strapplyc("([0-9.]+)") %>%
  unlist() %>% as.numeric()
religije[,16] <- religije[,16] %>% strapplyc("([0-9.]+)") %>%
  sapply(. %>% .[[1]]) %>% as.numeric()
religije[,18] <- religije[,18] %>% strapplyc("([0-9.]+)") %>%
  unlist() %>% as.numeric()
religije[,20] <- religije[,20] %>% strapplyc("([0-9.]+)") %>%
  unlist() %>% as.numeric()

religije$Christian <- religije$Christian %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()

religije$Muslim <- religije$Muslim  %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()

religije$Unaffiliated <- religije$Unaffiliated %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()

religije$Hindu <- religije$Hindu %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()

religije$Buddhist <- religije$Buddhist %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()

religije$`Folk Religion` <- religije$`Folk Religion` %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()

religije$`Other Religion` <- religije$`Other Religion` %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()

religije$Jewish <- religije$Jewish %>% strsplit(split = " ") %>%
  sapply(. %>% paste(collapse = "")) %>% as.numeric()



# uvozi2 <- function() {
#   return(read.csv("3.Podatki/drzave.csv", sep = ",", as.is = TRUE,
#                   fileEncoding = "Windows-1250"))
# }
# 
# drzave <- uvozi2() 
# 
# dr <- drzave[,0:2]
# rl <- religije[,20:21]
# anti_join(dr, rl)
# anti_join(rl,dr)
religije<- religije[ ,-c(2,3,4)]


religije$country[39] <- c("Burkina Faso")
religije$country[26] <- c("Congo, Democratic Republic of the")
religije$country[27] <- c("Congo, Republic of the")
religije$country[108] <- c("East Timor")
religije$country[41] <- c("Gambia")
religije$country[27] <- c("Congo, Republic of the")
religije$country[262]<-c("Vietnam")
religije[262,2:17]<-c(0,0,0,0,0,0,0,0,0,0,67971428,73.2,0,0,0,0)



# neww <- c(0,0,0,0,0,0,0,0,0,0,67971428,73.2,0,0,0,0)
# new<-c("Vietnam",neww)
# religije <- rbind  (religije[1:(length(religije$country)-2),], new, religije[(length(religije$country)),])

#Damo drzave ven iz csv, da lahko uporabimo samo tiste države ki jih imamo
dr<-read.csv("3.Podatki/drzave.csv",fileEncoding = "Windows-1250",stringsAsFactors=FALSE)
dr$population<-as.numeric(gsub(",","",dr$population))
dr$area<-as.numeric(gsub(",","",dr$area))
drzave <- subset(dr, select=-X)
drzave$country[drzave$country=="Korea, South"] <- "South Korea"
drzave$country[drzave$country=="Korea, North"] <- "North Korea"
drzave$country[drzave$country=="The Bahamas"] <- "Bahamas"
drzave$country[drzave$country=="Micronesia, Federated States of"] <- "Micronesia"
drzave$country[drzave$country=="Myanmar (Burma)"]<- "Burma"
drzave$country[drzave$country=="Timor-Leste"]<- "Timor-Leste"

#združimo katere države so v data.frame drzave in religije
rel <- semi_join(religije,drzave,by="country")

#glavne religije držav
religion <- data.frame(country=rel$country,name=NA,followers=NA,proportion=NA)

for (k in 1:length(religion$country)){
  i <- 2
  for (j in seq(4,16,2)){
    if (rel[k,j]>rel[k,i]){
      i <- j
    }
  religion$name[k] <- colnames(rel)[i]
  religion$followers[k] <- rel[k,i]
  religion$proportion[k] <- rel[k,i+1]
  }
}

#write.csv(religion, "3.Podatki/religije_relacija.csv")
write.csv(religion, "3.Podatki/religije.csv")

#naredimo novi data frame, kjer bodo not imena religij in koliko ljudi pripada tej religiji po svetu
main_religion <- data.frame(name=colnames(religije)[c(seq(2,16,2))],followers=NA,proportion=NA)
n <- length(religije$country);
m <- 2;
for (i in 1:length(main_religion$name)){
  main_religion$followers[i] <- religije[n,m]
  main_religion$proportion[i] <- religije[n,m+1]
  m <- m+2;
}

write.csv(main_religion,"3.Podatki/glavne_religije.csv")
#######################################################################################################

#KONTINENTI 

uvozi1 <- function() {
  return(read.csv("2.Uvoz/Kontinenti.csv", sep = ",", as.is = TRUE,
                  na.strings=c("-", "z") ,
                  fileEncoding = "Windows-1250"))
}

kontinenti <- uvozi1()
kontinenti[86,2]<-"Russia"; #spremenila Russian Federation v Russia
kontinenti$Country[12]<-c("Congo, Democratic Republic of the")
kontinenti$Country[13]<-c("Congo, Republic of the")
kontinenti$Country[72]<-c("North Korea")
kontinenti$Country[73]<-c("South Korea")
kontinenti$Country[86]<-c("Russia")
kontinenti$Country[60]<-c("Burma")

sk<-data.frame(Continent=c("Europe","Asia"),Country=c("Kosovo","Taiwan")) #manjkata Kosovo in Taiwan
celine1<- kontinenti[,0:2] #celine - polepšana tabela                #CELINE

celine2 <- rbind(celine1,sk) #dodala South Korea

celine <- arrange(celine2, Continent, Country) #urejeno po abecedi


#Preimenovala stolpce z malimi črkami
names(celine)[names(celine) %in% c("Continent","Country")] <- c("name","country")
celine$country[celine$country=="Burkina"]<-"Burkina Faso"
celine$country[celine$country=="East Timor"]<-"Timor-Leste"
#dokument kjer so našteti vsi kontinenti
vsi_kontinenti <- data.frame(sort(unique(celine$name)))
names(vsi_kontinenti)<-"continent"

# Zapišemo v datoteko CSV
write.csv(celine, "3.Podatki/celine.csv")
write.csv(vsi_kontinenti,"3.Podatki/vsi_kont.csv")

############################################################################################

#GLAVNA MESTA

# library(rvest)
# library(dplyr)
# url.mesta <- "http://www.go4quiz.com/1023/lworld-countries-and-their-capitals/"
# stran <- html_session(url.mesta) %>% read_html()
# 
# gl.mesta <- stran %>% html_nodes(xpath="//table") %>%
#   .[[1]] %>% html_table()
# 
# gl.mesta$"No." <- NULL              #GL.MESTA
# 
# names(gl.mesta)<- c("Country","Capital")
# 
# ##########################################################################################
# 
# #DRŽAVE - area, population 
# library(XML)
# ustvari_area<- function(){
#   naslov <- "http://www.infoplease.com/ipa/A0004379.html"
#   area <- readHTMLTable(naslov, which=2, stringsAsFactors = FALSE)
# }
# area.pop <- ustvari_area()                                        #AREA.POP
# names(area.pop)<- c("Country", "Population","Area")
# 
# ############################################################################################
# 
# #UREJANJE PODATKOV - ISTA IMENA
# anti_join(gl.mesta, area.pop)
# anti_join(area.pop, gl.mesta)
# 
# #UREDITEV DRŽAV
# gl.mesta$Country[187]<-c("United States")
# gl.mesta$Country[63]<-c("Gambia")
# gl.mesta$Country[42]<-c("Ivory Coast")
# gl.mesta$Country[51]<-c("Timor-Leste")
# gl.mesta$Country[126]<-c("Netherlands")
# gl.mesta$Country[191]<-c("Vatican City")
# 
# area.pop$Country[12]<-c("The Bahamas")
# area.pop$Country[42]<-c("Ivory Coast")
# area.pop[-c(194),]
# 
# #ZDRUŽITEV gl-mest in area
# drzave <- inner_join(area.pop, gl.mesta)
# 
# #UREDITEV GLAVNIH MEST
# drzave$Capital[6]<- c("Saint John's")
# drzave$Capital[34]<- c("N'Djamena")
# drzave$Capital[67]<- c("Saint George's")
# drzave$Capital[81]<- c("Jerusalem")
# drzave$Capital[177]<- c("Nuku'alofa")
# drzave$Capital[21]<- c("La Paz")
# drzave$Capital[123]<- c("Yaren")
# drzave$Capital[161]<- c("Cape Town")
# drzave$Capital[164]<- c("Colombo")
# drzave$Capital[167]<- c("Lobamba")
# drzave$Capital[173]<- c("Dodoma")
# 
# #Ko bo link spet delal, 
# #Potrebno zamenjati vrstni red stolpcev in urediti imena (vsa z malo in enaka kot za bazo)
# #names(drzave)[names(drzave) %in% c("Country","Population","Area (in sq mi)","Capital)]<-c("country","population","area","capital")
# #drzave1 <- drzave[,c("country","capital","population","area")]
# 
# #Potem odkomentiraj še ta ukaz in zbriši prejšnjega (z drzave)
# #write.csv(drzave1, "3.Podatki/drzave.csv")
# # Zapišemo v datoteko CSV
# write.csv(drzave, "3.Podatki/drzave.csv")
# 
# ##############################################################################
# uvozi2 <- function() {
#   return(read.csv("3.Podatki/drzave.csv", sep = ",", as.is = TRUE,
#                   fileEncoding = "Windows-1250"))
# }
# 
# drzave <- uvozi2()
# 
# #UREDI ŠE Z CELINAMI
# anti_join(drzave, celine)
# anti_join(celine,drzave)
# 
# drzave$Country[27]<-c("Burkina")
# drzave$Country[89]<-c("North Korea")
# drzave$Country[90]<-c("South Korea")
# drzave$Country[114]<-c("Micronesia")
# drzave$Country[121]<-c("Burma")
# drzave$Country[175]<-c("East Timor")
# drzave$Country[12]<-c("Bahamas")
# drzave<- drzave[-c(91,171),]
# 
# celine$Country[12]<-c("Congo, Democratic Republic of the")
# celine$Country[13]<-c("Congo, Republic of the")
# celine$Country[72]<-c("North Korea")
# celine$Country[73]<-c("South Korea")
# celine$Country[86]<-c("Russia")
# celine$Country[60]<-c("Burma")


##############################################################################



#UREDI ŠE Z RELIGIJAMI (pri religijah vsem odstrani prvo črko!!!)
# anti_join(drzave, religije)
# anti_join(religije,drzave)



# Zapišemo v datoteko CSV
#write.csv(religije, "3.Podatki/religije.csv")

# Zapišemo v datoteko CSV
#write.csv(drzave, "3.Podatki/drzave.csv")


