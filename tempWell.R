setwd('C:/Users/Karina/Documents/waterSharing')

rm(list = ls(all = TRUE)) #CLEAR WORKSPACE

# info for URL
siteNo = '402750078452201'
beginDate = '2010-01-01'
endDate = '2015-01-01'

# read information from the USGS page
pageLink = paste0('http://nwis.waterdata.usgs.gov/nwis/uv?cb_72019=on&format=rdb_meas&',
                  'site_no=',siteNo,'&period=&',
                  'begin_date=',beginDate,
                  '&end_date=',endDate)
thepage = readLines(pageLink)

# get rid of lines starting with #
idxKeep = which(substr(thepage,1,1)!='#') # idx of lines not starting with #
data = thepage[idxKeep]
data = str_trim(data) # get rid of tabs at begining and end of lines
listVals = strsplit(data,split = '\t')[3:length(data)]
# get rid of lines with wrong number of values
# HERE write a way to get how many elements there should be per line
idxKeep = which(unlist(lapply(listVals,FUN = length))==6)
tableVals = matrix(unlist(listVals[idxKeep]),ncol=6,byrow = T)
colnames(tableVals) = unlist(strsplit(data[1],split = '\t'))[1:6]
write.table(tableVals[,c('datetime','tz_cd','01_72019')],
            file=paste0(siteNo,'_',beginDate,'_',endDate,'.csv'),
            row.names=F,sep=';',quote=F)


# plot
xDateTime = as.POSIXct(tableVals[,'datetime'],format = '%Y-%m-%d %H:%M')
plot(x=xDateTime,y=-as.numeric(tableVals[,'01_72019']),type='l',
     xaxt='n',xlab='',
     ylab='groundwater depth [feet below ground]')
axis.POSIXct(1,xDateTime,format = '%Y-%m')
