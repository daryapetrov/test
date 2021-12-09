setwd("/Users/dpetrov/COVID-19-Nonparametric-Inference-India/India/Kerala")
mobility <- read.csv(file = 'google_mobility_India.csv')
mobility_data = mobility[-c(seq(1,46,1)),]

View(mobility_data)

df = mobility_data[-c(1:8) ]

#a = subset(mobility, sub_region_1 == "Kerala")
my_data = subset(mobility, sub_region_1 == "Kerala")

b = subset(my_data, date == "2020-04-01")
names(mobility)



df = subset(b, select = -c(country_region_code, metro_area,iso_3166_2_code,census_fips_code,place_id ) )
mean(df["retail_and_recreation_percent_change_from_baseline"][-1,],na.rm=TRUE)
mean(df["grocery_and_pharmacy_percent_change_from_baseline"][-1,],na.rm=TRUE)
mean(df["parks_percent_change_from_baseline"][-1,],na.rm=TRUE)
mean(df["transit_stations_percent_change_from_baseline"][-1,],na.rm=TRUE)
mean(df["workplaces_percent_change_from_baseline"][-1,],na.rm=TRUE)
mean(df["residential_percent_change_from_baseline"][-1,],na.rm=TRUE)
#
mean(df["retail_and_recreation_percent_change_from_baseline"][,],na.rm=TRUE)
mean(df["grocery_and_pharmacy_percent_change_from_baseline"][,],na.rm=TRUE)
mean(df["parks_percent_change_from_baseline"][,],na.rm=TRUE)
mean(df["transit_stations_percent_change_from_baseline"][,],na.rm=TRUE)
mean(df["workplaces_percent_change_from_baseline"][,],na.rm=TRUE)
mean(df["residential_percent_change_from_baseline"][,],na.rm=TRUE)







setwd("/Users/dpetrov/COVID-19-Nonparametric-Inference-India/India/Kerala")
mobility <- read.csv(file = 'google_mobility_India.csv')
one = subset(mobility, sub_region_1 == "Kerala")
two = subset(one,sub_region_2=="")[-c(seq(1,46,1)),]
keralaMobility = subset(two, select = -c(country_region_code, metro_area,iso_3166_2_code,census_fips_code,place_id ) )
avg = subset(keralaMobility, select = -c(country_region,sub_region_1,sub_region_2,date))
average = rowMeans(avg)
keralaMobilityAvg = cbind(keralaMobility, average)
save(keralaMobilityAvg, file = "keralaMobilityAvg.Rda")


#why this formula?
kappa = (100 + 100*keralaMobilityAvg$average)/100
