#Analytics 101 Session 2 Intro to SQL and R!
#Install Packages
install.packages("sqldf")
install.packages("RCurl")
install.packages("ggplot2")

#Load Packages
library(sqldf)
library(RCurl)
library(ggplot2)

#Load Data
football_text <- getURL("https://raw.githubusercontent.com/jsoslow2/Data-Nite-1/master/football.csv")
football <- read.csv(text = football_text)

football2_text <- getURL("https://raw.githubusercontent.com/jsoslow2/Data-Nite-1/master/NFLPlaybyPlay2015.csv")
football2 <- read.csv(text = football2_text) 


#Selecting Data using SQL
names(football)
summary(football)

#select everything
View(sqldf("select * from football"))

#Select some columns
View(sqldf("select 
              OffenseTeam,
              DefenseTeam, 
              Down, 
              ToGo 
           from football"))

#Select some columns with filter
View(sqldf("select 
              OffenseTeam,
           DefenseTeam, 
           Down, 
           ToGo,
           yards
           from football
           where Down > 0"))

#Select some columns with multiple filters
View(sqldf("select 
           OffenseTeam,
           DefenseTeam, 
           Down, 
           ToGo,
           yards
           from football
           where Down > 0
           and PlayType in ('PASS', 'RUSH')"))

#Order some columns with filter
View(sqldf("select 
              OffenseTeam,
              DefenseTeam, 
              Quarter,
              Minute,
              Second,
              Down, 
              ToGo,
              yards
           from football
           where Down > 0
           and PlayType in ('PASS', 'RUSH')
           order by GameId, Quarter asc, Minute desc, Second desc"))

#Using R for Data Manipulation
football$TimeSecs <- ((4 - football$Quarter) * 900) + (60 * football$Minute) + football$Second

#Same Query but with new variable
football_clean <- sqldf("select *
          from football
          where Down > 0
          and PlayType in ('PASS', 'RUSH')
          order by GameId, TimeSecs desc")


#Grouping!!

#Group average yards by play type
View(sqldf("Select PlayType, avg(yards), stdev(yards) from football_clean
           group by PlayType"))

#Which team had the best offense?
View(sqldf("Select OffenseTeam, avg(yards) as yards from football_clean
           group by OffenseTeam
           order by avg(yards) desc"))

#Which teams were most likely to pass?
View(sqldf("Select OffenseTeam, (sum(isPass)*1.0 / count(*)) as percent_pass from football_clean
           group by OffenseTeam
           order by percent_pass desc"))

#Which formations are most likely to pass?
View(sqldf("Select Formation, (sum(isPass)*1.0 / count(*)) as percent_pass from football_clean
           group by Formation
           order by percent_pass desc"))

#[TEST]What Defense gave up the most yards during the season?
View(sqldf("Select DefenseTeam, sum(yards) as total from football_clean
           group by DefenseTeam
           order by total desc"))



#Conditional Case Statements

#What plays were over 10, 20, 30 yards?
View(sqldf("Select OffenseTeam, yards, 
             case when yards >= 30 then '30+'
                  when yards >= 20 then '20-30'
                  when yards >= 10 then '10-20'
                  else 'less than 10' end as yard_groups
             from football_clean
             "))

#[TEST] Create a variable 'Half' that when TimeSecs is greater than 1800 then it is 1, else 2
View(sqldf("Select TimeSecs, 
           case when TimeSecs > 1800 then 1 
           else 2 end as Half
           from football_clean"))


#Nesting select statements (look to the inside first)
#What team had the most plays over 10 yards
View(sqldf("
Select OffenseTeam, sum(ten_plus_indicator) as total_ten_plus

from

(Select OffenseTeam,
           case when yards >= 10 then 1
           else 0 end as ten_plus_indicator
           from football_clean)

group by OffenseTeam
order by total_ten_plus desc
           "))



#JOINS!!!!!!
View(football2)
View(football_clean)

football_join <- sqldf('Select 
  a.*,  
  yrdline100, 
  PosTeamScore, 
  DefTeamScore, 
  ScoreDiff from football_clean a
      join football2 b
                  on a.gameID = b.gameID
                  and a.TimeSecs = b.TimeSecs
')


#Basic analysis
#pass percent by down
pass_by_down <- sqldf("Select (1.0*sum(isPass) / count(*)) as percent_pass, Down 
           from football_join
           group by Down
           order by Down asc")

plot(pass_by_down$Down, pass_by_down$percent_pass)

#pass percent by distance
pass_by_distance <- sqldf("Select (1.0*sum(isPass) / count(*)) as percent_pass, ToGo
                          from football_join
                          group by ToGo
                          order by ToGo asc")
plot(pass_by_distance$percent_pass ~ pass_by_distance$ToGo)

abline(lm(pass_by_distance$percent_pass ~ pass_by_distance$ToGo))


#Pass percent by yardline
pass_by_yardline <- sqldf("Select (1.0*sum(isPass) / count(*)) as percent_pass, YardLine
                          from football_join
                          group by YardLine
                          order by YardLine asc")

plot(pass_by_yardline$percent_pass ~ pass_by_yardline$YardLine)




