library(ggplot2)
library(dplyr)
library(tidyr)

setwd('/Users/Diego/Desktop/Projects_Code/waterequity/waterequity.github.io')

data1<- read.csv('diego_df.csv')
data2<- read.csv('data.csv')

# NOTE: As you go, and you find outliers and interesting things Googgle them and keep a list


### 1st. Exploring the entire data set
    # Summaries, plots of many variables, color, sizes, histograms, etc
    # Plot EVERYTHING

### 2nd. Sub group analysis
    # Income subgroups, race subrgroups, agriculture employment , drought index variables, inequality 
    # Create climatezones variables    
    # Summaries, plots of many variables, color, sizes, histograms, etc
    # Plot EVERYTHING

### What data are we missing that's important? Lets create a list of things that would be nice to have 

### 3rd. MAPS
    # What variables should, what insights are really interesting?



### What is my data?

#head
#names
#lenght
#dim

## Interesting news pieces with information

# http://www.mercurynews.com/science/ci_25090363/california-drought-water-use-varies-widely-around-state



##### Exploratory

# 1. Corralelograms
# 2. Historgrams with varying number of bins
# 3. Summary of your data
# 3. Descriptive statistics by:
#   # Missing a 'region' variable (https://www.google.com/search?q=california+climate+zones&espv=2&biw=1440&bih=740&tbm=isch&tbo=u&source=univ&sa=X&ved=0ahUKEwiq3ZXeyObKAhVEymMKHYeAAjwQsAQIMQ)
    # By: Income group - create income classes in the state    
    # By: water subgroups


# Create an income group variable 

# Histogram
hist(data2$Income,breaks=30)



#Create Variables that might be useful and start getting insights from them

data2$Income.Group <- ifelse(data2$Income>10000 & data2$Income<20000,'very poor','the others')

the.very.poor <- subset(data2,data2$Income.Group == 'very poor') #subset(dataframe,variables that are you selecting)
everyone.else <- subset(data2,data2$Income.Group == 'the others') 

# Lets compare
summary(the.very.poor)
summary(everyone.else)

#Lets update our income group variable to create more income groups

data2$Income.Group <- ifelse(data2$Income>10000 & data2$Income<=20000,'very poor',ifelse(data2$Income >20000 & data2$Income <=30000,'poor',ifelse(data2$Income >30000 & data2$Income <=40000,'sort of poor',ifelse(data2$Income >40000 & data2$Income <=50000,'low-middle',ifelse(data2$Income >50000 & data2$Income <=60000,'middle','rich')))))


# Aggregate command in R

lcapita.income <- aggregate(data2$liters.2014.capita,list(data2$Income.Group),FUN=mean) %>% mutate(Income.Label=Group.1,WaterCapita=x) %>% select(Income.Label,WaterCapita)
Income.income <- aggregate(data2$Income,list(data2$Income.Group),FUN=mean) %>% mutate(Income.Label=Group.1,Income=x) %>% select(Income.Label,Income)

WhatSeigiWanted <- merge(lcapita.income,Income.income,by=c('Income.Label'))
WhatSeigiWanted <- WhatSeigiWanted[order(WhatSeigiWanted$Income),]

newdata <- mtcars[order(mpg, -cyl),] 


# The bad way of renaming a variable
#names(lcapita.income)[1] <- 'Income Group'
#names(lcapita.income)[2] <- 'water consumption capita'


#### Lets dig into the very poor a little more 

ggplot(the.very.poor,aes(liters.2014.capita,Income)) + geom_point(aes(size=1)) + geom_text(aes(label=name),hjust=0, vjust=1,size=4)

# We already Vernon is an ouliter? Could it be that it is skewing our analsys? Lets remove vernong from the analysis for now.


the.very.poor.without.Vernon <- subset(the.very.poor,the.very.poor$name != 'Vernon')

    #check if i did it write
    subset(the.very.poor.without.Vernon,the.very.poor.without.Vernon$name == 'Vernon')
    
ggplot(the.very.poor.without.Vernon,aes(liters.2014.capita,Income)) + geom_point(aes(size=1)) + geom_text(aes(label=name),hjust=1, vjust=1,size=4)

  # http://lostcoastoutpost.com/2015/apr/6/midst-statewide-drought-humboldt-has-too-much-wate/

# We can do the same with Humboldt Bay 







#### General Plotting




ggplot(data2,aes(liters.2014.capita,Agriculture.employ.)) + geom_point(aes(size=data2$Income,color=data2$Household.size)) + geom_text(aes(label=name),hjust=0, vjust=1,size=4)
# We have a plot with 4 dimensions literspercapita, agricultural employment, household size and data income
# The graph may not make much sense but we can clean and find data to make it more useful.

# Step 1: Google and investigate outliers and try to understand if the outliers are 'true outliers' (that is they are actually consuming much more than everyone else)
#         or, if they are 'false outliers' (in the sense that it is a data problem, code problem, or something else)
#         The examples include Arvin, Vernon, etc....

# Step 2: Remove the outliers and plot again to get further insights



geom_text(aes(label=Country.Name),hjust=1, vjust=1,size=3) + xlab(plot.var) + ylab(evar)
  





