##################################################
##################################################
library(tm)


setwd('/Users/Diego/Desktop/Projects_Code/waterequity/waterequity.github.io')

# 1. Define functions and merge data
# 2. Creating variables to plot


####### 1. Define Functions and Merge Data

#Returns character with and without leading and trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#Making a list of words that prevent us from making a clean merge
clearwords = c("Golden State Water Company Bell-","Gardens","Commission", "Dept of Water & Power",", Dept of Water & Power","Land","and","Golden","State","Utility","Public","City of","Water District",", City of","Community","Service","District","Services","Water","Agency","County","Utilities",",","Company","Mutual","California Water Service Company","California-American Water Company","/Suburban","Municipal","Department","Irrigation")

#Cleaning the data
time_series_data <- read.csv('june2014_august2015.csv') %>% mutate(name=Supplier.Name)
  time_series_data$clean_name <- removeWords(as.character(time_series_data$name),clearwords)
  time_series_data$clean_name <- trim(time_series_data$clean_name)
  
socio_economic_data <- read.csv('data.csv')
  socio_economic_data$clean_name <- removeWords(as.character(socio_economic_data$name),clearwords)
  socio_economic_data$clean_name <- trim(socio_economic_data$clean_name)
  socio_economic_data$ln_income_capita <- log(socio_economic_data$Income)
  socio_economic_data$ln_liters_capita <- log(socio_economic_data$liters.2014.capita)
  socio_economic_data$ln_liters <- log(socio_economic_data$liters.2014)
  socio_economic_data$ln_population <- log(socio_economic_data$Population)
  socio_economic_data$ln_population_served <- log(socio_economic_data$Population.served)
   
  


#Merge data
all_merged <- merge(time_series_data,socio_economic_data,by=c('clean_name'))
    #Unmerged Cities?
      all_merged_towns <- data.frame(x=unique(all_merged$clean_name))
      all_socioeconomic_towns <- data.frame(y=unique(socio_economic_data$clean_name))
      unmerged_towns <- subset(all_socioeconomic_towns, !(all_socioeconomic_towns$y %in% all_merged_towns$x))
      paste("There are ",length(unmerged_towns$y)," unmerged towns.")
    #Creating date variables
      all_merged$month <- tolower(substring(all_merged$Reporting.Month,4,6))
      all_merged$month_num <- match(all_merged$month, tolower(month.abb))
      all_merged$year <- strftime(as.numeric(substring(all_merged$Reporting.Month,1,2)),format="%m")
      


####### 2 Creating variables to plot

#Percentage difference between 2013 and 2014 & 2015
all_merged$pct_diff_2013 <- abs(((all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015 - all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013)/all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013))*100
#Was there an increase or decrease?
all_merged$inc_dc_2013 <- ifelse(all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015 > (all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013 - all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013*all_merged$Conservation),"Increase","Decrease" )
#Did the town meet its target every month? CATEGORICAL VARIABLE IN CHARACTER
all_merged$target_met_unmet <- ifelse(all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015 > (all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013 - all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013*all_merged$Conservation),"Unmet Conservation Target","Met Conservation Target")
#Did the town meet its target every month? CATEGORICAL VARIABLE IN NUMERICAL
all_merged$target_met_unmet_num <- ifelse(all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015 > (all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013 - all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013*all_merged$Conservation),1,0)
#How far were towns from meeting the target?
all_merged$pct_difference_target <- ((all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015 - (all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013 - all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013*all_merged$Conservation))/(all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013 - all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013*all_merged$Conservation))*100
#How many liters were they supposed to reduce?
all_merged$liters_to_conserve <- all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013*all_merged$Conservation
all_merged$ln_liters_to_conserve <- log(all_merged$liters_to_conserve)
#How many liters to conserve per capita?
all_merged$liters_to_conserve_capita <- (all_merged$REPORTED.Total.Monthly.Potable.Water.Production.2013*all_merged$Conservation)/all_merged$Population.served
all_merged$ln_liters_to_conserve_capita <- log(all_merged$liters_to_conserve_capita)


#Is there a difference in the difficulty for different towns to be able to meet their targets?







## 2.1 Plotting all the data on whether or not the different towns met their monthly targets

ggplot(all_merged, aes(REPORTED.Total.Monthly.Potable.Water.Production.2013, REPORTED.Total.Monthly.Potable.Water.Production.2014.2015,group=inc_dc_2013,colour=inc_dc_2013)) + geom_point(aes(size = pct_diff_2013))  + geom_abline(slope=1, intercept=0)
ggplot(all_merged, aes(REPORTED.Total.Monthly.Potable.Water.Production.2013, REPORTED.Total.Monthly.Potable.Water.Production.2014.2015,group=target_met_unmet,colour=target_met_unmet)) + geom_point(aes(size = pct_diff_2013),alpha=0.6)  +xlab("2013 Total Monthly Potable Water Production (Gallons)") + ylab("2014-2015 Total Monthly Potable Water Production (Gallons)") +geom_abline(slope=1, intercept=0) + theme(panel.background = element_blank(),axis.text=element_text(size=13),axis.title=element_text(size=14,face="bold")) + theme(legend.title=element_blank()) 

## 2.2 Plotting and exploring relationships between all variables and the difference between the target and the actual reductions for all months

explore_vars <- c("ln_liters_to_conserve_capita","liters_to_conserve_capita","ln_liters_to_conserve","month_num","liters_to_conserve","ln_population_served","ln_population","ln_liters","ln_liters_capita","ln_income_capita","Population","Income","Gini", "White..","Household.size","Agriculture.employ.","liters.2014","liters.2014.capita","Population.served","Conservation", "SPEI_3YEARS","SPI_3YEARS")

# Exploring Relationships Between Targets Met
for(i in 1:length(explore_vars)){

  density_plot <- ggplot(all_merged, aes(get(explore_vars[i]),pct_difference_target)) + geom_point(aes(size=Income,alpha=0.1)) + theme(panel.background = element_blank(),axis.text=element_text(size=13),axis.title=element_text(size=14,face="bold")) + theme(legend.title=element_blank()) 

  
  selected.var <- explore_vars[i]
  mypath <- file.path("/Users/Diego/Desktop/Projects_Code/waterequity/waterequity.github.io/plots/pct_difference_target",paste(selected.var,".jpg",sep=""))
  
  jpeg(file=mypath)
  print(density_plot)
  dev.off()
}


## 2.3 Investigating characteristics of towns which most frequently met their reduction targets

met_targets_data <-aggregate(all_merged$target_met_unmet_num, by=list(all_merged$clean_name),FUN=sum, na.rm=TRUE) %>% mutate(clean_name=Group.1,sum=x) %>% select(clean_name,sum)
met_targets_data <- subset(met_targets_data,met_targets_data$sum <=15)

met_targets_data_complete <- merge(met_targets_data,all_merged,by=c("clean_name"),type="left")

explore_vars <- c("month_num","liters_to_conserve","ln_population_served","ln_population","ln_liters","ln_liters_capita","ln_income_capita","Population","Income","Gini", "White..","Household.size","Agriculture.employ.","liters.2014","liters.2014.capita","Population.served","Conservation", "SPEI_3YEARS","SPI_3YEARS")

# Exploring Relationships Between Targets Met
for(i in 1:length(explore_vars)){
  
  density_plot <- ggplot(met_targets_data_complete, aes(get(explore_vars[i]),sum)) + geom_point(aes(size=Income,alpha=0.1))  + scale_x_continuous(breaks = round(seq(min(get(explore_vars[i])), max(get(explore_vars[i])), by = 0.5),1))
  
  selected.var <- explore_vars[i]
  mypath <- file.path("/Users/Diego/Desktop/Projects_Code/waterequity/waterequity.github.io/plots/met_targets",paste(selected.var,".jpg",sep=""))
  
  jpeg(file=mypath)
  print(density_plot)
  dev.off()
}



######################  Plots for Poster


#Plot of conservation group
all_merged$conservation_group <- ifelse(all_merged$Conservation>=0.035 & all_merged$Conservation<0.05,"Group 1",ifelse(all_merged$Conservation>=0.05 & all_merged$Conservation<0.09,"Group 2",ifelse(all_merged$Conservation>=0.1 & all_merged$Conservation<0.14,"Group 3",ifelse(all_merged$Conservation>=0.14 & all_merged$Conservation<0.19,"Group 4",ifelse(all_merged$Conservation>=0.17 & all_merged$Conservation<0.23,"Group 5",ifelse(all_merged$Conservation>=0.23 & all_merged$Conservation<0.26,"Group 6",ifelse(all_merged$Conservation>=0.26 & all_merged$Conservation<0.29,"Group 7",ifelse(all_merged$Conservation>=0.29 & all_merged$Conservation<0.34,"Group 8","Group 9"))))))))
ggplot(all_merged,aes(factor(conservation_group),pct_difference_target)) + geom_boxplot() + xlab("Conservation Group")+ylab("Percentage Difference between Target (2013) and Actual Consumption (2014-2015)")+ geom_jitter(aes(factor(conservation_group),pct_difference_target,size=Income,alpha=0.05),color="blue",width = 0.5,height=0.2) + theme(panel.background = element_blank(),axis.text=element_text(size=13),axis.title=element_text(size=14,face="bold")) + theme(legend.title=element_blank()) 

#Plot of liters per capita
subset_liters_capita <- subset(all_merged,all_merged$ln_liters_capita < 14)

ggplot(subset_liters_capita,aes(ln_liters_capita,pct_difference_target)) + geom_point(aes(size=subset_liters_capita$SPEI_3YEARS,alpha=0.01),colour="yellowgreen") + xlab("ln(Liters per Capita)")+ylab("Percentage Difference between Target (2013) and Actual Consumption (2014-2015)") + theme(panel.background = element_blank(),axis.text=element_text(size=13),axis.title=element_text(size=14,face="bold")) + theme(legend.title=element_blank()) + geom_smooth(method = "lm",color="red", se = FALSE)



######################  Stats and calculations in text


passed_limit <- sum(all_merged$target_met_unmet_num)/length(all_merged$target_met_unmet_num)
paste("Conservation limits were surpassed ",as.character(1-passed_limit)," percent of the time")

unmet_target_data <- subset(all_merged,all_merged$target_met_unmet=="Unmet Conservation Target")

mean(unmet_target_data$pct_diff_2013,na.rm=TRUE)


last_group <- subset(all_merged,all_merged$conservation_group=="Group 9")






