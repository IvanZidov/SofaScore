library(tidyr)
library(ggplot2)


pl <- read.csv("PL20192020.csv",encoding = "utf8")
pl[,70]<-as.character("F")
pl[,37]<-as.character("F")

scores <- c()
for (name in names(pl)){
  if (grepl("score",name, fixed=TRUE)){
    scores<-c(scores,unlist(pl[name]))
  }
}


positions <- c()
for (name in names(pl)){
  if (grepl("position",name, fixed=TRUE)){
    positions<-c(positions,unlist(pl[name]))
    print(unique(unlist(pl[name])))
  }
}

players <- c()
domacini <- c()
gosti <- c()
isHome <-c()
for (name in names(pl)){
  if (grepl("player",name, fixed=TRUE)){
    players<-c(players,unlist(pl[name]))
    domacini <- c(domacini,unlist(pl$homeTeam))
    gosti <- c(gosti,unlist(pl$awayTeam))
    if (grepl("h_",name, fixed=TRUE)){
      isHome <- c(isHome,rep("yes",length(pl$homeTeam)))
    }
    else{
      isHome <- c(isHome,rep("no",length(pl$homeTeam)))
    }
  }
}



df <- data.frame(positions,scores)
ggplot(data=df, aes(x=scores,y = ..density..)) +
  geom_histogram(fill="steelblue")+
  geom_density(aes(y=..density..)) +
  #geom_text(aes(label=Freq), vjust=-0.3, size=3.5,position = position_dodge(width = 1))+
  #geom_text(aes(label=round(prop.table(Freq),4)), vjust=1.6, color="white", size=3.5,position = position_dodge(width = 1))+
  labs(x="Position",y="SofaScore")


df <- data.frame(positions,scores)
ggplot(data=df, aes(x=positions, y=scores)) +
  geom_boxplot(fill="steelblue")+
  #geom_text(aes(label=Freq), vjust=-0.3, size=3.5,position = position_dodge(width = 1))+
  #geom_text(aes(label=round(prop.table(Freq),4)), vjust=1.6, color="white", size=3.5,position = position_dodge(width = 1))+
  labs(x="Position",y="SofaScore")


hist(scores,breaks = 100,density = T)

boxplot(scores~positions)


hist(scores,probability = T)
lines(density(scores,n=100))
d<- plot(density(scores))
polygon(d, col="red", border="blue")


boxplot(scores~positions)


igraci <- data.frame(players,positions,scores)
prosjek <- aggregate(igraci$scores, by=list(players=igraci$players), FUN=mean)
prosjek[order(prosjek$x,decreasing = T),][1:10,]

klubovi <- data.frame(domacini,scores,isHome)
klubovi <- subset(klubovi,klubovi$isHome=="yes")
prosjek <- aggregate(klubovi$scores, by=list(domac=klubovi$domacini), FUN=mean)
prosjek[order(prosjek$x,decreasing = T ),]


klubovi <- data.frame(gosti,scores,isHome)
klubovi <- subset(klubovi,klubovi$isHome=="no")
prosjek <- aggregate(klubovi$scores, by=list(domac=klubovi$gosti), FUN=mean)
prosjek[order(prosjek$x,decreasing = T ),]


model <- lm(scores~positions+isHome+domacini+gosti+players)
summary(model)
model


predict(model,
        data.frame(isHome="no", domacini="Chelsea", gosti="Liverpool",players="Alisson",positions="G"), type="response")

simulate_score <- function(foot_model, homeTeam, awayTeam, position, player, isHome){
  sofascore <- predict(foot_model,
                       data.frame(isHome=isHome, domacini=homeTeam, gosti=awayTeam,players=player,positions=position), type="response")
  
  return(sofascore)
}

#Trent Alexander-Arnold
#Alisson
simulate_score(model,isHome="yes", homeTeam="Chelsea", awayTeam="Arsenal",player="Timo Werner",position="F")
