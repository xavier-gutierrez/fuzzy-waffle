options(scipen=999)
library(R.utils)
library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)

path_data <- 'C:/Users/guti220/Desktop/energy_market_shares/data'
# Local path to the cloned data folder in the repository

cap.raw <- read.table(paste(path_data, "capacity_eia.tsv", sep="/"), sep="\t", header=TRUE, comment.char="")
cap.raw$summer_capacity <- as.numeric(as.character(cap.raw$summer_capacity))

# code dictionaries -------------------------------------------------------
eia.dict.1 <- data.frame(status_code_1 = c("BU", "OA", "OP", "OS", "RE", "SB", "SC", "SD", "TS", "A", "CN", "CO", "D", "FC", "IP", "L",
                                          "LE", "M", "MO", "OT", "P", "PL", "RA", "RP", "RT", "T", "U", "V"),
                        status_code_1_text <- c("backup", "out of service but expected to return this year", "operating", "out of service > 365 days not expected to return this year",
                                               "retired", "standby or backup", "cold shutdown", "sold to nonutility", "construction complete but not in commercial operation",
                                               "proposed increase in generator capability", "cancelled", "under construction", "proposed decrease in generator capability",
                                               "planned fuel conversion", "planned, indefinitely postponed", "regulatory approval pending but site prep potentially underway",
                                               "environmental, site or legal challenges", "proposed deactivated shutdown", "modification planned for existing generator", "other",
                                               "planned but no regulatory approvals", "planned not under construction", "planned reactivation of previously retired or deactivated unit",
                                               "proposed repowering", "scheduled for retirement", "regulatory approved but not under construction", "under construction < 50 percent complete",
                                               "under construction > 50 percent complete"))

eia.dict.2 <- data.frame(status_code_2 = c("BU", "OA", "OP", "OS", "RE", "SB", "SC", "SD", "TS", "A", "CN", "CO", "D", "FC", "IP", "L",
                                          "LE", "M", "MO", "OT", "P", "PL", "RA", "RP", "RT", "T", "U", "V"),
                        status_code_2_text = c("backup", "out of service but expected to return this year", "operating", "out of service > 365 days not expected to return this year",
                                               "retired", "standby or backup", "cold shutdown", "sold to nonutility", "construction complete but not in commercial operation",
                                               "proposed increase in generator capability", "cancelled", "under construction", "proposed decrease in generator capability",
                                               "planned fuel conversion", "planned, indefinitely postponed", "regulatory approval pending but site prep potentially underway",
                                               "environmental, site or legal challenges", "proposed deactivated shutdown", "modification planned for existing generator", "other",
                                               "planned but no regulatory approvals", "planned not under construction", "planned reactivation of previously retired or deactivated unit",
                                               "proposed repowering", "scheduled for retirement", "regulatory approved but not under construction",
                                               "under construction < 50 percent complete", "under construction > 50 percent complete"))


eia.dict.3 <- data.frame(prime_mover = c("AB", "BA", "BT", "CA", "CC", "CE", "CG", "CH", "CP", "CS", "CT", "CW", "FC", "FW", "GE", "GT", "HC", "HL", "HR",
                                        "HY", "IC", "IG", "JE", "NB", "NG", "NH", "NP", "OC", "PB", "PS", "PV", "SP", "SS", "ST", "VR", "WT", "OT", "NA"),
                        prime_mover_text = c("Atmospheric Fluidized Bed", "Battery energy storage", "turbines used in a binary cycle", "Combined Cycle Steam Turbine with Supplemental Firing",
                                             "Combine Cycle - Total Unit", "Compressed Air Energy Storage", "not defined", "Steam Turbine, Common Header", "Concentrated solar power energy storage",
                                             "Combined Cycle Single Shaft (gas turbine and steam turbine share a single generator)", "Combined Cycle Combustion Turbine Part",
                                             "Combined Cycle Steam Turbine Part (Waste Heat Boiler Only)", "Fuel Cell (electrochemical)", "Flywheel energy storage", "Steam Turbine (geothermal)",
                                             "Combustion (gas) Turbine",  "Hydraulic Turbine (conventional)",
                                             "Hydraulic Turbine (pipeline)", "Hydraulic Turbine (reversible)",
                                             "Hydraulic Turbine (conventional)", "Internal Combustion", "Integrated Coal Gasification Combined Cycle",
                                             "Jet Engine", "Steam Turbine (Boiling Water Nuclear Reactor)", "Steam Turbine (Graphite Nuclear Reactor)",
                                             "Steam Turbine (High-Temperature Gas-Cooled Nuclear Reactor)", "Steam Turbine (Pressurized Water Nuclear Reactor)",
                                             "Ocean Thermal Turbine", "Pressurized Fluidized Bed Combustion", "Hydraulic Turbine Reversible (pumped storage)",
                                             "Photovoltaic","Photovoltaic", "Steam Turbine (Solar)", "Steam Turbine (Boiler)", "Various Types", "Wind Turbine", "Other (Explained in Notes)",
                                             "Unknown at this Time"))

eia.dict.4 <- data.frame(fuel_1 = c("AB", "ANT", "BFG", "BIO", "BIT", "BL", "BLQ", "COG", "COL", "COM", "CRU", "CWM", "DFO", "FO1", "FO2", "FO3", "FO4",
                                   "FO5", "FO6", "GAS", "GEO", "GST", "JF", "KER", "LFG", "LIG", "LNG", "LPG", "MF", "MSW", "MTE", "MWH", "MTH", "NG", "NUC",
                                   "OBG", "OBL", "OBS", "OG", "OO", "OTH", "PC", "PET", "PL", "PRO", "REF", "RG", "RRO", "SNG", "STM", "SUB", "SUN", "TH", "TOP",
                                   "UR", "WAT", "WC", "WD", "WH", "WND", "OT", "NA", "PG", "PUR", "RC", "RFO", "SC", "SG", "SGC", "SGP", 'SLW', 'SU', 'TDF', 'UNK', 'WDL',
                                   "WDS", "WO", "WOC"),
                        fuel_1_text = c("Agriculture crop byproducts, straw, energy crops", "Anthracite", "blast furnace gas", 'biomass generic', 'bituminous coal', 'not defined',
                                        'black liquor', 'coke oven gas', 'coal generic', 'coal oil mixture', 'crude oil', 'coal water mixture', 'distillate fuel oil', 'no 1 fuel oil',
                                        'no 2 fuel oil', 'no 3 fuel oil', 'no 4 fuel oil', 'no 5 fuel oil', 'no 6 fuel oil', 'gas generic', 'geothermal', 'geothermal steam',
                                        'jet fuel', 'kerosene', 'landfill gas', 'lignite', 'liquified natural gas', 'liquified propane gas', 'multifueled', 'municipal solid waste',
                                        'methane', 'megawatt hour', 'methanol', 'natural gas', 'nuclear', 'other biomass gases', 'other biomass liquids', 'other biomass solids', 'other gas',
                                        'not defined', "other",  'petroleum coke', 'petroleum generic', 'plutonium', 'propane', 'refuse, bagasse and all other nonwood waste',
                                        'refinery gas', 're refined motor oil', 'synthetic natural gas', 'steam', 'subbituminous coal', 'sun', 'thorium',  'topped crude oil', 'uranium',
                                        'water', 'waste coal', 'wood and wood waste', 'waste heat', 'wind', 'other', 'not available', 'propane', 'purchased steam', 'refined coal',
                                        "residual fuel oil", 'coal synfuel', 'synthetic gas other than coal derived', 'coal-derived synthetic gas', 'synthetic gas from petroleum coke',
                                        'sludge waste', 'not defined', 'tires', 'not defined', 'wood waste liquids', 'wood and wood waste solids', 'oil-other and waste oil', 'not defined'))

eia.dict.5 <- data.frame(fuel_2 = c("AB", "ANT", "BFG", "BIO", "BIT", "BL", "BLQ", "COG", "COL", "COM", "CRU", "CWM", "DFO", "FO1", "FO2", "FO3", "FO4",
                                   "FO5", "FO6", "GAS", "GEO", "GST", "JF", "KER", "LFG", "LIG", "LNG", "LPG", "MF", "MSW", "MTE", "MWH", "MTH", "NG", "NUC",
                                   "OBG", "OBL", "OBS", "OG", "OO", "OTH", "PC", "PET", "PL", "PRO", "REF", "RG", "RRO", "SNG", "STM", "SUB", "SUN", "TH", "TOP",
                                   "UR", "WAT", "WC", "WD", "WH", "WND", "OT", "NA", "PG", "PUR", "RC", "RFO", "SC", "SG", "SGC", "SGP", 'SLW', 'SU', 'TDF', 'UNK', 'WDL',
                                   "WDS", "WO", "WOC"),
                        fuel_2_text = c("Agriculture crop byproducts, straw, energy crops", "Anthracite", "blast furnace gas", 'biomass generic', 'bituminous coal', 'not defined',
                                        'black liquor', 'coke oven gas', 'coal generic', 'coal oil mixture', 'crude oil', 'coal water mixture', 'distillate fuel oil', 'no 1 fuel oil',
                                        'no 2 fuel oil', 'no 3 fuel oil', 'no 4 fuel oil', 'no 5 fuel oil', 'no 6 fuel oil', 'gas generic', 'geothermal', 'geothermal steam',
                                        'jet fuel', 'kerosene', 'landfill gas', 'lignite', 'liquified natural gas', 'liquified propane gas', 'multifueled', 'municipal solid waste',
                                        'methane', 'megawatt hour', 'methanol', 'natural gas', 'nuclear', 'other biomass gases', 'other biomass liquids', 'other biomass solids', 'other gas',
                                        'not defined', "other",  'petroleum coke', 'petroleum generic', 'plutonium', 'propane', 'refuse, bagasse and all other nonwood waste',
                                        'refinery gas', 're refined motor oil', 'synthetic natural gas', 'steam', 'subbituminous coal', 'sun', 'thorium',  'topped crude oil', 'uranium',
                                        'water', 'waste coal', 'wood and wood waste', 'waste heat', 'wind', 'other', 'not available', 'propane', 'purchased steam', 'refined coal',
                                        "residual fuel oil", 'coal synfuel', 'synthetic gas other than coal derived', 'coal-derived synthetic gas', 'synthetic gas from petroleum coke',
                                        'sludge waste', 'not defined', 'tires', 'not defined', 'wood waste liquids', 'wood and wood waste solids', 'oil-other and waste oil', 'not defined'))

eia.dict.6 <- data.frame(fuel_3 = c("AB", "ANT", "BFG", "BIO", "BIT", "BL", "BLQ", "COG", "COL", "COM", "CRU", "CWM", "DFO", "FO1", "FO2", "FO3", "FO4",
                                   "FO5", "FO6", "GAS", "GEO", "GST", "JF", "KER", "LFG", "LIG", "LNG", "LPG", "MF", "MSW", "MTE", "MWH", "MTH", "NG", "NUC",
                                   "OBG", "OBL", "OBS", "OG", "OO", "OTH", "PC", "PET", "PL", "PRO", "REF", "RG", "RRO", "SNG", "STM", "SUB", "SUN", "TH", "TOP",
                                   "UR", "WAT", "WC", "WD", "WH", "WND", "OT", "NA", "PG", "PUR", "RC", "RFO", "SC", "SG", "SGC", "SGP", 'SLW', 'SU', 'TDF', 'UNK', 'WDL',
                                   "WDS", "WO", "WOC"),
                        fuel_3_text = c("Agriculture crop byproducts, straw, energy crops", "Anthracite", "blast furnace gas", 'biomass generic', 'bituminous coal', 'not defined',
                                        'black liquor', 'coke oven gas', 'coal generic', 'coal oil mixture', 'crude oil', 'coal water mixture', 'distillate fuel oil', 'no 1 fuel oil',
                                        'no 2 fuel oil', 'no 3 fuel oil', 'no 4 fuel oil', 'no 5 fuel oil', 'no 6 fuel oil', 'gas generic', 'geothermal', 'geothermal steam',
                                        'jet fuel', 'kerosene', 'landfill gas', 'lignite', 'liquified natural gas', 'liquified propane gas', 'multifueled', 'municipal solid waste',
                                        'methane', 'megawatt hour', 'methanol', 'natural gas', 'nuclear', 'other biomass gases', 'other biomass liquids', 'other biomass solids', 'other gas',
                                        'not defined', "other",  'petroleum coke', 'petroleum generic', 'plutonium', 'propane', 'refuse, bagasse and all other nonwood waste',
                                        'refinery gas', 're refined motor oil', 'synthetic natural gas', 'steam', 'subbituminous coal', 'sun', 'thorium',  'topped crude oil', 'uranium',
                                        'water', 'waste coal', 'wood and wood waste', 'waste heat', 'wind', 'other', 'not available', 'propane', 'purchased steam', 'refined coal',
                                        "residual fuel oil", 'coal synfuel', 'synthetic gas other than coal derived', 'coal-derived synthetic gas', 'synthetic gas from petroleum coke',
                                        'sludge waste', 'not defined', 'tires', 'not defined', 'wood waste liquids', 'wood and wood waste solids', 'oil-other and waste oil', 'not defined'))
# Abbreviations explained

cap.eia <- cap.raw %>%
  mutate(fuel_1 = replace(fuel_1, fuel_1=="BL", "BLQ")) %>%
  # We are assuming that BL was incorrectly entered BLQ
  filter(summer_capacity != 0) %>%
  # Remove plants with no summer time capacity (not sure why they exist in the data anyway)
  filter(status_code_1 != "RE" & status_code_2 != "RE") %>%
  # Remove retired plants
  filter(status_code_2 != "RA") %>%
  # Remove not yet reactivated plants
  filter(status_code_2 != "CN") %>%
  # Remove previously planned but now canceled projects
  filter(status_code_2 != "PL" & status_code_2 != "P" & status_code_2 != "IP") %>%
  # Remove planned projects (P and PL) and indefinitely postponed,
  filter(status_code_2 != "CO" & status_code_2 != "L" & status_code_2 != "T") %>%
  # Remove units under construction, units awaiting regulatory approval, and units with regulatory approval but not under construciton
  filter(status_code_2 != "U" & status_code_2 != "V" & status_code_2 != "TS" & status_code_1 != "TS") %>%
  # Remove additional plants under construction (U and V) and constructed power plants not yet in operation
  filter(status_code_2 != "LE") %>%
  # Remove sites that are not constructed (legal delays)
  mutate(in_service = replace(in_service, in_service==0, NA)) %>%
  # recodes an inservice date of '0' as missing
  mutate(age = year - in_service) %>%
  # Calculate the age of the plant
  mutate(summer_capacity = ifelse(year >= 1990 & year <= 2000, summer_capacity/1000, summer_capacity)) %>%
  # For years 1990 to 2000 summer capacity is in kW, which we change to MW
  mutate(summer_capacity = ifelse(summer_capacity < 0, summer_capacity*-1, summer_capacity)) %>%
  # It appears that some capacity values were mistakenly entered as negative, which we correct
  left_join(eia.dict.3) %>%
  # Add a new column that includes an explanation of the prime mover variable
  left_join(eia.dict.1) %>%
  # Add a new column that includes an explanation of the status_code_1
  left_join(eia.dict.2) %>%
  # Add a column that includes an explanation of the status_code_2
  left_join(eia.dict.4) %>%
  left_join(eia.dict.5) %>%
  left_join(eia.dict.6)
  # Add three columns for the primary, secondary, and tertiary fuel used by each unit


# eia.mapping: overnight_categories ---------------------------------------
eia.mapping <- unique(cap.eia[, c('prime_mover', 'fuel_1', 'prime_mover_text', 'fuel_1_text')])
# Grab the unique combinations of primary fuel and production technology (this set will need to be mapped to the overnight costs)
eia.mapping <- eia.mapping %>%
  mutate(overnight_category = "") %>%
  # add a blank column (code doesn't work otherwise)
  mutate(overnight_category = ifelse(prime_mover == "CG" | prime_mover == "OT" | fuel_1 == "WOC" | fuel_1 == "MF" |
                                       fuel_1 == "OTH" | fuel_1 == "" | fuel_1 == "BL", "undefined", overnight_category)) %>%
  # CG, BL, and WOC not defined anywhere in the supporting documentation (that I can find)
  # OT, OTH, "", and MF do not provide enough information to assign either the fuel or production technology to these units
  mutate(overnight_category = ifelse(fuel_1 == "WAT", "hydro", overnight_category)) %>%
  # hydropower assignment, which moves two sets of units from undefined to hydro (HC, "") and (HR, "")
  mutate(overnight_category = ifelse(fuel_1 == "",
                                     ifelse(prime_mover == "HC" | prime_mover == "HR", "hydro",
                                            overnight_category), overnight_category)) %>%
  # some hydropower are missing a fuel so assign these to hydro overnight cost
  mutate(overnight_category = ifelse(fuel_1 == "GEO" | fuel_1 == "GST", "geothermal", overnight_category)) %>%
  # geothermal assignment
  mutate(overnight_category = ifelse(prime_mover == "PV" | prime_mover == "SP", "photovoltaic", overnight_category)) %>%
  # photovoltaic assignment
  mutate(overnight_category = ifelse(prime_mover != "PV" & prime_mover != "SP" & fuel_1 == "SUN",
                                     "solar thermal", overnight_category)) %>%
  # solar thermal assignment
  mutate(overnight_category = ifelse(fuel_1 == "WND", 'wind', overnight_category)) %>%
  # onshore wind assignment
  mutate(overnight_category = ifelse(fuel_1 == "UR" | fuel_1 == "TH" | fuel_1 == "NUC", 'nuclear', overnight_category)) %>%
  # nuclear assignment
  mutate(overnight_category = ifelse(prime_mover == "FC", 'fuel cell', overnight_category)) %>%
  mutate(overnight_category = ifelse(fuel_1 == "MSW", 'municipal solid waste', overnight_category)) %>%
  mutate(overnight_category = ifelse(fuel_1 == "MSW", 'municipal solid waste', overnight_category)) %>%
  mutate(overnight_category = ifelse(prime_mover == "ST",
                                     ifelse(fuel_1 == "LFG" | fuel_1 == "SNG" |  fuel_1 == "OG" |
                                              fuel_1 == "NG" | fuel_1 == "LPG" | fuel_1 == "BFG" |
                                              fuel_1 == "OBG" | fuel_1 == "BLQ",'steam turbine',
                                            overnight_category), overnight_category)) %>%
  # steam turbine running on natural gas assignment
  mutate(overnight_category = ifelse(prime_mover == "ST",
                                     ifelse(fuel_1 == "BLQ" | fuel_1 == "DFO" |  fuel_1 == "FO1" |
                                              fuel_1 == "FO2" | fuel_1 == "FO4" | fuel_1 == "FO6" |
                                              fuel_1 == "RFO" | fuel_1 == "WO" | fuel_1 == "SC" |
                                              fuel_1 == "RFO" | fuel_1 == 'SLW','steam turbine',
                                            overnight_category), overnight_category)) %>%
  # steam turbine running on oil assignment
  mutate(overnight_category = ifelse(prime_mover == "IG", "igcc", overnight_category)) %>%
  # integrated gasification combined cycle assignment
  mutate(overnight_category = ifelse(fuel_1 != "PC" | fuel_1 != "OTH", ifelse(prime_mover == "JE" | prime_mover == "IC" |
                                                                                prime_mover == "GT" | prime_mover == "ic",
                                                                              "conventional combustion turbine", overnight_category), overnight_category)) %>%
  # conventional combustion turbine assignment but don't assign the petroleum coke units (those are more similar to coal fired)
  mutate(overnight_category = ifelse(prime_mover == "CH" & fuel_1 == "NG", "conventional combustion turbine", overnight_category)) %>%
  mutate(overnight_category = ifelse(fuel_1 == "BIT" | fuel_1 == "SUB" | fuel_1 == "LIG" | fuel_1 == "ANT" |
                                       fuel_1 == "COL" | fuel_1 == "RC" | fuel_1=="WC" | fuel_1 == "PC" | fuel_1 == "TDF",
                                     ifelse(prime_mover != "IG" & prime_mover != "CC" & prime_mover != "CA" &
                                              prime_mover != "CT" & prime_mover != "IC", 'coal', overnight_category),
                                     overnight_category)) %>%
  # coal fired power plants not igcc, combined cycle, or internal combustion (conventional combustion)
  mutate(overnight_category = ifelse(fuel_1 != "OTH", ifelse(prime_mover == "CA" | prime_mover == "CC" | prime_mover == "CT" |
                                                               prime_mover == "CS" | prime_mover == "CW", 'conventional combined cycle', overnight_category),
                                     overnight_category)) %>%
  # the combined cycle power plants assignment for plants with a known fuel type
  mutate(overnight_category = ifelse(prime_mover != "CA", ifelse(fuel_1== "WD" | fuel_1== "REF" | fuel_1== "AB" | fuel_1 == "WDS" |
                                                                   fuel_1 == "BIO" | fuel_1 == "OBS", 'biomass', overnight_category), overnight_category)) %>%
  # biomass assignment
  mutate(overnight_category = ifelse(fuel_1 == "MWH" | prime_mover == "CE", "distributed", overnight_category)) %>%
  # distibuted generation assignment
  mutate(overnight_category = ifelse(overnight_category=="", "undefined", overnight_category))


# summary files -----------------------------------------------------------
cap.eia <- cap.eia %>%
  left_join(eia.mapping) %>%
  mutate(heat_rate = ifelse(heat_rate == 0, NA, heat_rate))

cap.eia.total <- cap.eia %>%
  group_by(year, prime_mover, fuel_1, prime_mover_text, fuel_1_text) %>%
  # Add three new columns explaining the fuel type abbreviation
  summarize(total_summer_capacity = sum(summer_capacity, na.rm=TRUE))
# Generate a new dataframe that is the sum of summer capacity by primary fuel and production technology

summary.cap.eia <- cap.eia %>%
  group_by(overnight_category, fuel_1, year) %>%
  summarize(capacity_tw = sum(summer_capacity)/1000000,
            # Capacity (TW) by overnight category, fuel, and year
            n = n(),
            # Count of plants (same divisions)
            avg_size_mw = sum(summer_capacity)/n(),
            # Average size of the plants (same divisions)
            heat_rate = mean(heat_rate, na.rm=TRUE)) %>%
            # Average heat rate (same divisions)
  ungroup() %>% #1189 rows
  group_by(overnight_category, fuel_1) %>%
  complete(year = seq(from = 1990, to =2014, by = 1)) %>% # 2700 rows
  ungroup() %>%
  mutate(heat_rate = ifelse(is.nan(heat_rate), NA, heat_rate)) %>%
  arrange(overnight_category, fuel_1, year)

summary.cap.eia.year <- cap.eia %>%
  group_by(overnight_category, year, fuel_1) %>%
  summarize(capacity_mw = sum(summer_capacity),
            n = n(),
            avg_size_mw = sum(summer_capacity)/n(),
            avg_age = mean(age),
            heat_rate = mean(heat_rate, na.rm=TRUE)) %>%
  ungroup() %>%
  group_by(overnight_category, fuel_1) %>%
  complete(year = seq(from = 1990, to = 2014, by = 1)) %>%
  mutate(heat_rate = ifelse(is.nan(heat_rate), NA, heat_rate)) %>%
  mutate(diff_mw = capacity_mw - lag(capacity_mw)) %>%
  mutate(outlier = ifelse(heat_rate <= mean(heat_rate, na.rm=TRUE) - 2*sd(heat_rate, na.rm=TRUE) |
                            heat_rate >= mean(heat_rate, na.rm=TRUE) + 2*sd(heat_rate, na.rm=TRUE), 1, 0)) %>%
  # Identify potential outliers (most of the outliers identified are a simple case of no variance (i.e., identical values))
  mutate(heat_rate = replace(heat_rate, overnight_category=="biomass" & fuel_1=="REF" & year==1993, NA)) %>%
  # One proposed outlier (replace the heat_rate value with NA)[see supporting documentation for more detail]
  mutate(heat_rate = replace(heat_rate, overnight_category=="steam turbine" & fuel_1=="FO4" & year==1993, NA)) %>%
  # Second proposed outlier (replace the heat_rate value with NA)
  ungroup() %>%
  arrange(year) %>%
  arrange(overnight_category, fuel_1, year)


# heat rate modeling ------------------------------------------------------

# heat rates across category-fuel pairs
heat.categories <- summary.cap.eia.year %>% # 2700 rows
  filter(heat_rate>0) %>% # 173 rows
  group_by(overnight_category, fuel_1) %>%
  summarise(heat_rate = mean(heat_rate), na.rm=TRUE) %>%
  ungroup()
ggplot(heat.categories, aes(overnight_category, heat_rate)) +
  geom_bar(stat='identity', aes(fill=fuel_1), position='dodge') +
  theme(axis.text.x=element_text(angle=90))

h.r.model <- summary.cap.eia.year %>% #2700 rows
  filter(heat_rate > 0) %>% #173 rows
  group_by(overnight_category, fuel_1) %>%
  complete(year = seq(from = 1990, to = 2014, by = 1)) %>% # 925 rows
  ungroup() %>%
  group_by(overnight_category, fuel_1) %>%
  do({
    mod <- lm(heat_rate ~ year, data = .)
    pred <- predict(mod, newdata = .["year"])
    data.frame(., pred)
    })
## spread of heatrates over time 
# filtered data
heat.year <- summary.cap.eia.year %>%
  filter(heat_rate > 0)
ggplot(heat.year, aes(year, heat_rate)) +
  geom_point(aes(color=overnight_category)) +
  theme(axis.text.x=element_text(angle=90))
# modeled data
ggplot(h.r.model, aes(year, pred)) +
  geom_point(aes(color=overnight_category))

summary.cap.eia.year <- summary.cap.eia.year %>%
  left_join(h.r.model, by = c("overnight_category", "fuel_1", "fuel_1_text", "year")) %>%
  arrange(overnight_category, fuel_1, year)


# save files --------------------------------------------------------------

gz1 <- file(paste(path_data,"capacity_eia_fueluse_productiontechnology_1990_2014.tsv", sep=""), "w")
write.table(cap.eia, file = gz1, sep="\t",col.names = TRUE, row.names = FALSE)
close(gz1)
# Output the cleaned up data to the data folder as a .tsv file

gz1 <- file(paste(path_data,"total_annual_capacity_eia_fueluse_technology_1990_2014.tsv", sep=""), "w")
write.table(cap.eia.total, file = gz1, sep="\t", col.names=TRUE, row.names=FALSE)
close(gz1)
# Output the total capacity by fuel and production technology to the data folder as a .tsv file

gz1 <- file(paste(path_data,"clean_capacity_eia_860_overnight_cost.tsv", sep=""), "w")
write.table(cap.eia, file = gz1, sep="\t",col.names = TRUE, row.names = FALSE)
close(gz1)
# Output the cleaned up data to the data folder as a .tsv file

gz1 <- file(paste(path_data,"summary_summer_cap_eia_860_overnight_cost.tsv", sep=""), "w")
write.table(summary.cap.eia, file = gz1, sep="\t",col.names = TRUE, row.names = FALSE)
close(gz1)
# Output the cleaned up data to the data folder as a .tsv file

gz1 <- file(paste(path_data,"summary_year_summer_cap_eia_860_overnight_cost.tsv", sep=""), "w")
write.table(summary.cap.eia.year, file = gz1, sep="\t",col.names = TRUE, row.names = FALSE)
close(gz1)
# Output the cleaned up data to the data folder as a .tsv file

ggplot(summary.cap.eia.year, aes(year, capacity_tw)) +
  geom_line(color='steelblue') +
  facet_wrap(~ overnight_category)

ggplot(summary.cap.eia.year, aes(overnight_category, capacity_tw)) +
  geom_bar(stat="identity") +
  facet_wrap(~ year)

ggplot(summary.cap.eia, aes(year, heat_rate)) +
  geom_line() +
  facet_wrap(~ overnight_category + fuel_1)



