

################################################################################
#                     Summary of this NOVA on NDNS code                        #
################################################################################
# 1. Applying the NOVA classification on the NDNS database
#         - Import database
#         - STEP 1 - exclude NDNS groups we don't want to work with for our NOVA classification
#         - STEP 2 - put all the item link to these keywords into adequate NOVA group
#         - STEP 3 - check if every item list with these BRAND is on group 4
#         - STEP 4 - assigning a group for every other food and beverage
#         - STEP 5 - Check that everything is well classified
# 
# 2. Calculating the means 
################################################################################

#Run before go any further
library(haven)
library(stringr)                            
library(table1)
library(xlsx)
library(dplyr)
library(data.table)
library(survey)
library(readxl)
library(tidyverse)
library(knitr)
library(lsmeans)
library(jtools)

archived <- function(x) {
  saveRDS(x, file=paste0(substitute(x),".rds"))
}
import <- function(x) {
  readRDS(paste0(substitute(x),".rds"))
}
`%nin%` = Negate(`%in%`)


################################################################################
#            1. Applying the NOVA classification on the NDNS database          #
################################################################################

###################
# Import datasets #
###################
#name your dataset test

test <- YOURDATA
#RecipeName only applied when you studied only Y9-11
#Thus, to be consistent across Years, we implemented NULL for everyone
test$RecipeName <- ""


#STEP 1 - exclude NDNS groups we don't want to work with for our NOVA classification
test$NOVA0 <- as.factor(ifelse(test$RecipeName=="Tumeric capsule" |
                               test$RecipeName=="Abidec Advanced Multivitamins Syrup plus omega 6 & 9" |
                               test$RecipeName=="Advanced marine nutrient complex" |                                                   
                               test$RecipeName=="Aflofarm Neomag Forte" | 
                               test$RecipeName=="Alcon 1-caps - Vitamin A/B2 with Zinc" |
                               test$RecipeName=="ALG" | 
                               test$RecipeName=="Bach rescue remedy" |
                               str_detect(test$RecipeName, "Basset") | 
                               test$RecipeName=="Benevita go go fat absorber vitamins" | test$RecipeName=="Benevita recover fat absorber & release vitamins" |
                                 str_detect(test$RecipeName, "Berry Blend") |
                               test$RecipeName=="Berry mix" | 
                               test$RecipeName=="Bobik DHA" |
                               test$RecipeName=="Boots high strenth omega 3 fish oil 1000mg" |
                               test$RecipeName=="Boots vit.C 500mg + zinc 10mg" |  
                               test$RecipeName=="Camberts tablet" | 
                               test$RecipeName=="Centrum 50+" |   
                               str_detect(test$RecipeName, "Coenzyme 10") |  
                               test$RecipeName=="Colfarm Fish oil" |  
                               test$RecipeName=="Creche guard immue multivit syrup" |  
                               test$RecipeName=="Cytoplan Adrenal support" |   
                               test$RecipeName=="DFH Complete Much Dietary Supplement" |
                               test$RecipeName=="EQ Strength Surge" |          
                               test$RecipeName=="Eskimo little cubs omega 3 fish oil" | 
                               test$RecipeName=="Extreme burner" |
                               test$RecipeName=="Fat metaboliser" | 
                               str_detect(test$RecipeName, "Floradix") |    
                               str_detect(test$RecipeName, "Fruit Blend") |
                               test$RecipeName=="Hair burst chewable hair vitamins" |
                               str_detect(test$RecipeName, "Haliborange") |
                               str_detect(test$RecipeName, "Healthspan") | 
                               test$RecipeName=="Herbalife Energy powder" | 
                               test$RecipeName=="High 12 B complex B12, viridian" |  
                               test$RecipeName=="Higher nature supplement" |   
                               str_detect(test$RecipeName, "Holland & Barret") |  str_detect(test$RecipeName, "Holland and Barret") | 
                               str_detect(test$RecipeName, "Holland & barret") |  str_detect(test$RecipeName, "Holland and barret") |  
                               test$RecipeName=="Hydroxtryptophan" |  
                               test$RecipeName=="Igennus Vegepa Healthcare Nutrition" |  
                               test$RecipeName=="Iiaa skin omegas+ vitamin a for skin health" | 
                               str_detect(test$RecipeName, "Jointace Max") |      
                               str_detect(test$RecipeName, "Juice Plus") |
                               test$RecipeName=="Kirkland Omega 3 fish oil 1000mg" |  
                               test$RecipeName=="Kyani Sunrise sachet" |
                               test$RecipeName=="Marine collagen" | 
                               test$RecipeName=="Minavex Multivitamin" | 
                               test$RecipeName=="Mojito" | 
                               test$RecipeName=="Mango Mojito" |  
                               test$RecipeName=="Mollers fish oil" | test$RecipeName=="Mollers norweski omega 3, vit A, D, E" |  
                               test$RecipeName=="Mr men little miss omega 3 & multivitamins" | 
                               test$RecipeName=="Multibionta 50+" |  
                               test$RecipeName=="Multivitamin" |  test$RecipeName=="Multivitamins" |  
                               test$RecipeName=="multivitamin and mineral" |
                               test$RecipeName=="MyOva myo plus" |
                               test$RecipeName=="My Protein Thermo Extreme" |    
                               test$RecipeName=="Natural Health Practice Healthy Woman Complex" |   
                               test$RecipeName=="Neals yard frankincense intense beauty boost nutritional supplement" |   
                               test$RecipeName=="NHP - Ostero support" | 
                               test$RecipeName=="Omega 3, Myprotein" |          
                               test$RecipeName=="Pre-pregnancy multivitamin" |  
                               test$RecipeName=="Protein milk" |
                               test$RecipeName=="Real health wholefood energy capsule" |  
                               test$RecipeName=="Refreshall Natures Best" |                                                                 
                               test$RecipeName=="Retinex" | 
                               test$RecipeName=="Rubicon Spring Strawberry & Kiwi Water" |
                               test$RecipeName=="Sanofi Magne B6 (48mg magnesium + 5mg B6 vit)" |
                               test$RecipeName=="Stirling health collegen ultra" | 
                               test$RecipeName=="Supplements" | 
                               test$RecipeName=="Thorne Basic Nutrients multivitamin" |   
                               test$RecipeName=="Ultra probioplex" |
                               test$RecipeName=="USN phedra cut lipo" |   
                               str_detect(test$RecipeName, "Vegetable Blend") | 
                               test$RecipeName=="Vibovit Goal" |  
                               str_detect(test$RecipeName, "Vitabiotics") | 
                               test$RecipeName=="Vitamin B and Vitamin C" | 
                               test$RecipeName=="Vitamin store magnesium and vit B6" |                     
                               test$RecipeName=="Vitamins direct glucosamine and chondrotin capsules" | 
                               str_detect(test$RecipeName, "Wellkid") | 
                               test$RecipeName=="Wellteen him" |                            
                               test$RecipeName=="Wilko cod liver oil and evening primrose oil" |
                               test$RecipeName=="yeast flakes engevita marigold" | 
                               test$RecipeName=="Yokebe Active Food" | 
                                 
                               test$RecipeName=="Desperados Lager" |  
                               test$RecipeName=="Vodka lime and soda", "NC",
                       
                        ifelse(test$RecipeName=="" & 
                              (test$SubFoodGroupCode=="54A" |
                               test$SubFoodGroupCode=="54B" |
                               test$SubFoodGroupCode=="54C" |
                               test$SubFoodGroupCode=="54D" |
                               test$SubFoodGroupCode=="54E" |
                               test$SubFoodGroupCode=="54F" |
                               test$SubFoodGroupCode=="54G" |
                               test$SubFoodGroupCode=="54H" |
                               test$SubFoodGroupCode=="54I" |
                               test$SubFoodGroupCode=="54J" |
                               test$SubFoodGroupCode=="54K" |
                               test$SubFoodGroupCode=="54L" | 
                               test$SubFoodGroupCode=="54M" | 
                               test$SubFoodGroupCode=="54N" |   
                               test$SubFoodGroupCode=="54P"), "NC", "NA")))

#CHECK
#zz <- subset(test, select=c(FoodName, SubFoodGroupCode, NOVA0), NOVA0=="NC")                      
#zzz <- subset(zz, !duplicated(SubFoodGroupCode))


#STEP 2 - put all the item link to these keywords into adequate NOVA group
test$NOVA1 <- as.factor(ifelse(test$NOVA0=="NC", "NC",
                        ifelse(test$NOVA0=="4", "4",
                        ifelse((str_detect(test$FoodName, "ARTIFICIAL") & !str_detect(test$FoodName, "NOT ARTIFICIAL"))
                               | (str_detect(test$FoodName, "CHOCOLATE") & !str_detect(test$FoodName, "NOT CHOCOLATE"))
                               | (str_detect(test$FoodName, "FLAVOURED") & !str_detect(test$FoodName, "NOT FLAVOURED"))
                               | (str_detect(test$FoodName, "ICE CREAM") & (!str_detect(test$FoodName, "NOT ICE CREAM") & !str_detect(test$FoodName, "HOMEMADE")))
                               | (str_detect(test$FoodName, "ICECREAM") & !str_detect(test$FoodName, "NOT ICECREAM"))
                               | (str_detect(test$FoodName, "MARGARINE") & !str_detect(test$FoodName, "NOT MARGARINE"))
                               | (str_detect(test$FoodName, "MARG") & !str_detect(test$FoodName, "NOT MARG"))
                               | (str_detect(test$FoodName, "MILKSHAKE") & !str_detect(test$FoodName, "NOT MILKSHAKE"))
                               | (str_detect(test$FoodName, "SANDWICH") & !str_detect(test$FoodName, "NOT SANDWICH"))
                               | (str_detect(test$FoodName, "SAUSAGE") & !str_detect(test$FoodName, "NOT SAUSAGE"))
                               
                               | (str_detect(test$RecipeName, "sausage") | str_detect(test$RecipeName, "Sausage"))
                               | (str_detect(test$RecipeName, "Sandwich") | str_detect(test$RecipeName, "sandwich"))
                               | (str_detect(test$RecipeName, "Panini") | str_detect(test$RecipeName, "panini"))
                               | (str_detect(test$RecipeName, "Bagel") | str_detect(test$RecipeName, "bagel"))
                               | (str_detect(test$RecipeName, "Wrap") | str_detect(test$RecipeName, "wrap"))
                               | (str_detect(test$RecipeName, "Flavoured") & !str_detect(test$FoodName, "not"))
                               | (str_detect(test$RecipeName, "flavoured") & !str_detect(test$FoodName, "not"))
                               | (str_detect(test$RecipeName, "chocolate") & !str_detect(test$RecipeName, "not chocolate"))
                               | (str_detect(test$RecipeName, "Chocolate") & !str_detect(test$RecipeName, "not Chocolate"))
                               | (str_detect(test$RecipeName, "choc") & !str_detect(test$RecipeName, "not choc"))
                               | (str_detect(test$RecipeName, "ice cream") & !str_detect(test$RecipeName, "not ice cream"))
                               
                               | ((str_detect(test$FoodName, "PASTRY") | str_detect(test$FoodName, "CRUST")) & 
                                 ((str_detect(test$FoodName, "PURCHASE") & !str_detect(test$FoodName, "NOT PURCHASE")) 
                                | (str_detect(test$FoodName, "RETAIL") & !str_detect(test$FoodName, "NOT RETAIL")) 
                                | (str_detect(test$FoodName, "MARG") & !str_detect(test$FoodName, "NOT MARG"))
                                | (str_detect(test$FoodName, "SHORTCRUST PASTRY NOT WHOLEMEAL CCF & PUFA COOKED"))
                                | (str_detect(test$FoodName, "FROZEN") & !str_detect(test$FoodName, "NOT FROZEN"))))
                                
                              | (str_detect(test$FoodName, "BREADCRUMB") & 
                                ((str_detect(test$FoodName, "FROZEN") & !str_detect(test$FoodName, "NOT FROZEN"))
                                | (str_detect(test$FoodName, "RETAIL") & !str_detect(test$FoodName, "NOT RETAIL"))
                                | (str_detect(test$FoodName, "SAUSAGEMEAT") & !str_detect(test$FoodName, "NOT SAUSAGEMEAT"))))
                              
                              | (str_detect(test$FoodName, "BATTER") & 
                                   ((str_detect(test$FoodName, "PURCHASED") & !str_detect(test$FoodName, "NOT PURCHASED"))
                                    | str_detect(test$FoodName, "M&S")
                                    | (str_detect(test$FoodName, "FROZEN") & !str_detect(test$FoodName, "NOT FROZEN")))), "4", "NA"))))
                               #not putting burger in RecipeName because the bread is not in "burgers" recipe, thus its 3 or 4
#CHECK
#zz <- subset(test, select=c(FoodName, RecipeName, RecipeMainFoodGroupDesc,NOVA0, NOVA1), NOVA1=="4")                      
#zzz <- subset(zz, !duplicated(FoodName,RecipeMainFoodGroupDesc))
#tableautest <- table(test$NOVA0,test$NOVA1)
#print(tableautest)

#classify alcohol groups
test$NOVA2 <- as.factor(ifelse(test$NOVA1=="NC", "NC",
                           ifelse(test$NOVA1=="4", "4",
                           ifelse(test$NOVA1=="NA" & (test$SubFoodGroupCode=="47A" | test$SubFoodGroupCode=="47B" | 
                                                      test$SubFoodGroupCode=="48B" | test$SubFoodGroupCode=="48C" | 
                                                      test$SubFoodGroupCode=="49C" | test$SubFoodGroupCode=="49D" |
                                                      test$SubFoodGroupCode=="49E"), "4", 
                           ifelse(test$NOVA1=="NA" & (test$SubFoodGroupCode=="48A" | test$SubFoodGroupCode=="49A" | 
                                                      test$SubFoodGroupCode=="49B"), "3","NA")))))
                                              
#STEP 3 - classify according to the brand
# Run the  code and check if every item list with these BRAND really belongs in group 4.
# If not, modify the code in accordance.
test$NOVA3 <- as.factor(ifelse(test$NOVA2=="NC", "NC",
                        ifelse(test$NOVA2=="3", "3",
                        ifelse(test$NOVA2=="4", "4",
                        ifelse((test$RecipeName=="9 bar super seeds"
                              | str_detect(test$RecipeName, "Aah Bisto")
                              | (str_detect(test$RecipeName, "Aldi") & !(test$RecipeName=="Aldi peppery salad"
                                                                            | test$RecipeName=="Aldi full fat greek style natural yogurt, with cream 500g per pot"
                                                                            | test$RecipeName=="Aldi salmon with ginger, chilli & lime"))
                              | test$RecipeName=="Alesto honey roasted peanuts, 200g pack"
                              | test$RecipeName=="Alfez moroccan meatball sauce"
                              | str_detect(test$RecipeName, "Alpen")  
                              | str_detect(test$RecipeName, "Alpro") 
                              | str_detect(test$RecipeName, "Aloe vera drink") | str_detect(test$RecipeName, "Aloe Vera Drink") |  str_detect(test$RecipeName, "aloe vera drink")
                              | str_detect(test$RecipeName, "Amy's Kitchen") 
                              | str_detect(test$RecipeName, "Ann Forshaw") 
                              | test$RecipeName=="Apple and cinnamon flakes"
                              | str_detect(test$RecipeName, "Appleby") 
                              | (str_detect(test$RecipeName, "Arla") & !test$RecipeName=="Arla BOB milk")
                              | ((str_detect(test$RecipeName, "Asda") | str_detect(test$RecipeName, "ASDA"))
                                                                     & !(test$RecipeName=="Asda apple & mango juice" | test$RecipeName=="Asda Classic Salad" 
                                                                       | test$RecipeName=="Asda golden sunrise seed, fruit & nut mix" | test$RecipeName=="Asda mixed vegetables"
                                                                       | test$RecipeName=="Asda minty baby potatoes" | test$RecipeName=="Asda root veg" 
                                                                       | test$RecipeName=="Asda garlic passata"  | test$RecipeName=="Asda semi-dried tomatoes and mozzarella pot" 
                                                                       | test$RecipeName=="Asda Wholegrain Micro Rice"))
                              | str_detect(test$RecipeName, "Ashfield") 
                              | str_detect(test$RecipeName, "Askeys")  
                              | str_detect(test$RecipeName, "Attack a snack") | str_detect(test$RecipeName, "Attack a snak") 
                              | str_detect(test$RecipeName, "Aunt") | str_detect(test$FoodName, "AUNT BESSIE")  #Aunt Bessie & Aunty's golden syrup steamed pudding
                              | str_detect(test$RecipeName, "B free") 
                              | str_detect(test$RecipeName, "Balocco") 
                              | str_detect(test$RecipeName, "Batchelors") | str_detect(test$RecipeName, "batchelors") | str_detect(test$FoodName, "BATCHELORS")
                              | str_detect(test$RecipeName, "Barny") 
                              | str_detect(test$RecipeName, "Barney bear") 
                              | str_detect(test$RecipeName, "Bernard Mat") #Bernard Matthews
                              | test$RecipeName=="Bilash garlic & coriander naan bread"
                              | test$RecipeName=="Billionaires meringue stack"
                              | str_detect(test$RecipeName, "Billy bear") | str_detect(test$RecipeName, "Billy Bear")   
                              | test$RecipeName=="Bioset salty spice mix"
                              | test$RecipeName=="Birds eye breaded haddock" | test$RecipeName=="Birds eye burger"
                              | test$FoodName ==" BIRDS EYE LIVER & ONION GRAVY"
                              | str_detect(test$RecipeName, "Bonne Maman")                                                                      
                              | str_detect(test$RecipeName, "Bon apetit") | str_detect(test$RecipeName, "Bon Appetit")  
                              | str_detect(test$RecipeName, "Bottlegreen") 
                              | str_detect(test$RecipeName, "Britaninia") 
                              | str_detect(test$RecipeName, "Brompton house") 
                              | test$RecipeName=="Brown ciabatta roll (GF)" 
                              | str_detect(test$RecipeName, "Butterkist") 
                              | str_detect(test$RecipeName, "Cadbury")
                              | str_detect(test$RecipeName, "Cambridge die") 
                              | str_detect(test$RecipeName, "Caramac") 
                              | str_detect(test$RecipeName, "Cathedral City") 
                              | test$RecipeName=="Caxton Pink 'N' Whites wafers"
                              | test$RecipeName=="Charlie Bingham fish pie"
                              | test$RecipeName=="Claudi & fin mini greek yogurt lolly" | test$RecipeName=="Claudi & Fin mini lolly"
                              | str_detect(test$RecipeName, "Co-op") | str_detect(test$RecipeName, "Co op") | str_detect(test$RecipeName, "coop") 
                                                                     | str_detect(test$RecipeName, "Coop")
                              | str_detect(test$RecipeName, "Costa")
                              | test$RecipeName=="COOK Roasted Vegetable Lasagne"
                              | test$RecipeName=="Cordial squash with carobel"
                              | str_detect(test$RecipeName, "Crownfield") 
                              | str_detect(test$RecipeName, "Cheetos") 
                              | str_detect(test$RecipeName, "Chicago") #Chicago town 
                              | str_detect(test$RecipeName, "Crestwood") 
                              | str_detect(test$RecipeName, "Daim") 
                              | str_detect(test$RecipeName, "Dessert Menu") | str_detect(test$RecipeName, "Dessert menu")
                              | str_detect(test$RecipeName, "Del monte raspberry iced smoothie")    
                              | str_detect(test$RecipeName, "Diet Cola") | str_detect(test$RecipeName, "in cola") | str_detect(test$RecipeName, "Cherry-cola")
                              | str_detect(test$RecipeName, "Dimme") 
                              | str_detect(test$RecipeName, "Disney")
                              | str_detect(test$RecipeName, "Dolce cappucino") | str_detect(test$RecipeName, "dolce gusto")
                              | str_detect(test$RecipeName, "Dolmio") | str_detect(test$FoodName, "PASTA SAUCE WITH ONIONS MUSHROOM AND DOLMIO")
                              | str_detect(test$RecipeName, "Domino") 
                              | str_detect(test$RecipeName, "Dorset") | str_detect(test$FoodName, "DORSET")
                              | test$RecipeName=="Eat & Go Cheese & Tomato Pasta Pot"
                              | test$RecipeName=="EAT ham & jarlsberg baguette "
                              | str_detect(test$RecipeName, "Emporium") | str_detect(test$RecipeName, "Dip-It cheese dip") 
                              | test$RecipeName=="Fage strawberry yogurt"
                              | str_detect(test$RecipeName, "Fanta")
                              | str_detect(test$RecipeName, "Ferrero") | str_detect(test$RecipeName, "Ferro rocher")
                              | str_detect(test$RecipeName, "five guys") | str_detect(test$RecipeName, "Five guys")
                              | test$RecipeName=="Figo Cuttlefish Balls  "        
                              | test$RecipeName=="Findlater's Fine Foods Sesame Seed Buns"
                              | test$RecipeName=="Fit Kitchen pad thai chicken with zesty sauce"
                              | test$RecipeName=="Figo Cuttlefish Balls" 
                              | str_detect(test$RecipeName, "Frappacino") 
                              | test$RecipeName=="Fruit & nut bar"
                              | test$RecipeName=="Fruit twist"
                              | test$RecipeName=="Frusli bar" 
                              | str_detect(test$RecipeName, "Genesis") 
                              | str_detect(test$RecipeName, "Genius")  
                              | test$RecipeName=="Gianni's Cookie dough Ice cream"     
                              | str_detect(test$RecipeName, "Ginsters") 
                              | test$RecipeName=="Glorious goan tomato & lentil soup"
                              | test$RecipeName=="Golden sweet & salty popcorn" 
                              | str_detect(test$RecipeName, "Goodfellas") 
                              | test$RecipeName=="Grace aloe vera reduced sugar drink" 
                              | str_detect(test$FoodName, "GRACE INSTANT CORNMEAL PORRIDGE") 
                              | str_detect(test$RecipeName, "Graze mini protein balls") | test$RecipeName=="Graze Protein Peanut Butter Dipper with Baked Hemp Seeds"
                              | str_detect(test$RecipeName, "Greggs") 
                              | str_detect(test$RecipeName, "Grenadine")
                              | test$RecipeName=="Gressingham Bistro Duck Legs in Plum Sauce" 
                              | test$RecipeName=="Gu zillionaires cheesecake" 
                              | test$RecipeName=="Gullon sugar free shortbread biscuits" 
                              | test$RecipeName=="h@sbal glucose fructose syrup with honey" 
                              | str_detect(test$RecipeName, "Harvest") #Harvest Morn
                              | str_detect(test$RecipeName, "Hartley") 
                              | str_detect(test$RecipeName, "Hearty food") 
                              | str_detect(test$RecipeName, "Hershey") 
                              | str_detect(test$RecipeName, "Heinz") 
                              | str_detect(test$RecipeName, "Herta") 
                              | str_detect(test$RecipeName, "Hi-fi") | str_detect(test$RecipeName, "Hifi") | str_detect(test$RecipeName, "Hi fi")
                              | str_detect(test$RecipeName, "High five") 
                              | test$RecipeName=="Holland's meat & potato pie" 
                              | test$RecipeName=="Hollands potato & meat pie" 
                              | test$RecipeName=="Hollands potato and meat pies" 
                              | test$RecipeName=="Homepride pasta bake" 
                              | test$RecipeName=="Honeybuns brownie" 
                              #for Iceland luxury aberdeen angus quarter pounders, RecipeMainFoodGroupDesc is "burger and kebab" so 4
                              | (str_detect(test$RecipeName, "Iceland") & !(test$RecipeName=="Iceland 4 multi greens steam bags, 150g per steam bag"))
                              | test$RecipeName=="Indomie chicken noodles" 
                              | test$RecipeName=="Innocent diary free coocnut milk" | test$RecipeName=="Innocent super smoothie berry protein, 750ml"
                              | test$RecipeName=="Instant mash potato" 
                              | str_detect(test$RecipeName, "Irwin") | str_detect(test$RecipeName, "irwin")
                              | test$RecipeName=="Itsu vegetable dumplings" 
                              | test$RecipeName=="Jack Link's Meat Snacks Beef Jerky Original" 
                              | test$RecipeName=="Jacobs flatbread salt & cracked pepper" 
                              | test$RecipeName=="Jelly Bean Sports Beans" 
                              | test$RecipeName=="John West tuna infusions chilli & garlic" 
                              | test$RecipeName=="Jordans fruit & nut granola" 
                              | test$RecipeName=="Just Tasty Cheese Layered Salad" 
                              | str_detect(test$RecipeName, "Kefco")
                              | str_detect(test$RecipeName, "Kellogg") 
                              | test$RecipeName=="Kershaws Beef Dinner" 
                              | str_detect(test$RecipeName, "KFC")
                              | str_detect(test$RecipeName, "Kiddylicious")
                              | str_detect(test$RecipeName, "Kinder") 
                              | test$RecipeName=="Kings Rib Eye Flavour Biltong" 
                              | str_detect(test$RecipeName, "Koka") 
                              | str_detect(test$RecipeName, "Koko") 
                              | str_detect(test$RecipeName, "Knorr gravy") 
                              | test$RecipeName=="Kubus carrot apple and raspberry" 
                              | str_detect(test$RecipeName, "Laughing cow cheese")    
                              | str_detect(test$RecipeName, "Lidl")
                              | str_detect(test$RecipeName, "Lighthouse bay") 
                              | str_detect(test$RecipeName, "Linda Mccartney") | str_detect(test$RecipeName, "Linda McCartney") 
                              | str_detect(test$RecipeName, "Lindt")
                              | str_detect(test$RecipeName, "Lindhouse") 
                              | str_detect(test$RecipeName, "Linwood")  
                              | str_detect(test$RecipeName, "Little angels") 
                              | str_detect(test$RecipeName, "Little coco") 
                              | str_detect(test$RecipeName, "Little dish") 
                              | test$RecipeName=="Little yeo yogurt" | test$RecipeName=="Little yeos fromage frais"
                              | str_detect(test$RecipeName, "Lizi") 
                              | str_detect(test$RecipeName, "Lotus") 
                              | str_detect(test$FoodName, "LOPROFIN LOW PROTEIN PASTA") 
                              | str_detect(test$RecipeName, "Loyd grossman") 
                              | str_detect(test$RecipeName, "Lucky Charms") 
                              | str_detect(test$RecipeName, "lunchables") | str_detect(test$RecipeName, "Lunchables") 
                              | test$RecipeName=="Ma Raeburn's 12 sweetened pancakes" 
                              | test$RecipeName=="Mae's Kitchen 4 Spicy Bean Quarter Pounders, 105g per quarter pounder" 
                              | str_detect(test$RecipeName, "Maxwell") 
                              | test$RecipeName=="McVities bonkers berry jaffa cake bar" 
                              | str_detect(test$RecipeName, "Maggi")
                              | str_detect(test$RecipeName, "Malteyasers") 
                              | ((str_detect(test$RecipeName, "Marks and") | str_detect(test$RecipeName, "Marks &") | str_detect(test$RecipeName, "M&S")) 
                                                                            & !(test$RecipeName=="M&S chicken & lentil soup"
                                                                                | test$RecipeName=="M&S Chicken and Grain Soup"
                                                                                | test$RecipeName=="M&S Colcannon Potato Mash"
                                                                                | test$RecipeName=="M&S new potatoes with butter, parsley, chives and mint 385g pack"
                                                                                | test$RecipeName=="M&S new potatoes with herbs"
                                                                                | test$RecipeName=="M&S santini tomato side salad"
                                                                                | test$RecipeName=="M&S Rainbow Salad"
                                                                                | test$RecipeName=="M&S Spicy lenti soup"
                                                                                | test$RecipeName=="M&S super broccoli, spinach & pea soup"
                                                                                | test$RecipeName=="Marks and spencers chicken & supergrain soup"
                                                                                | test$RecipeName=="M&S fruit salad"))
                              | test$RecipeName=="mario breadsticks"
                              | str_detect(test$RecipeName, "Mars protein bar") | str_detect(test$RecipeName, "Mars bar") 
                              | test$RecipeName=="Mazadar chickpea dahl"
                              | str_detect(test$RecipeName, "Mc Cain") | str_detect(test$RecipeName, "McCain") | str_detect(test$RecipeName, "Mccain")
                              | str_detect(test$RecipeName, "Mcdonald") | str_detect(test$RecipeName, "McDonald") | str_detect(test$RecipeName, "Mcmuffin") 
                                                                        | test$RecipeName=="McD Fiery Buffalo Chicken one - crispy" 
                              | test$RecipeName=="Mesa sunrise" 
                              | test$RecipeName=="Milbona stracciatella creamy yogurt" 
                              | str_detect(test$RecipeName, "Milky bar") | str_detect(test$RecipeName, "Milkybar")
                              | ((str_detect(test$RecipeName, "Morrison") | str_detect(test$RecipeName, "Morrsions"))
                                                                          & !(test$RecipeName=="Morrisons ranch salad"
                                                                          | test$RecipeName=="Morrisons Cod in Parsley Sauce with mash, carrots and peas"
                                                                          | test$RecipeName=="Morrisons pilau rice (if microwave flavouring so 4)"))
                              | str_detect(test$RecipeName, "Muller") 
                              | test$RecipeName=="Ms Molly's strawberry milk lolly" 
                              | test$RecipeName=="Mug Shot chicken & sweetcorn noodles" 
                              | test$RecipeName=="Multi seed roll" 
                              | test$RecipeName=="MyProtein Traditional Oat Flavour Flapjack" 
                              | str_detect(test$RecipeName, "Nairn") | str_detect(test$RecipeName, "nairns") 
                              | test$RecipeName=="Naked Noodle Singapore Curry" | test$RecipeName=="Naked singapore curry noodles" | str_detect(test$RecipeName, "Nakd")
                              | test$RecipeName=="Naked Green Machine apple & banana smoothie"  
                              | test$FoodName=="NAKED MANGO MACHINE SMOOTHIE, FORTIFIED" | test$FoodName=="NAKED BLUE MACHINE BLUEBERRY SMOOTHIE"
                              | test$FoodName=="NAKED STRAWBERRY, RASBERRY & CRANBERRY JUICE SMOOTHIE FORTIFIED"
                              | test$RecipeName=="Nandos peri peri hot sauce"       
                              | test$RecipeName=="Nando's peri peri sauce medium"       
                              | test$RecipeName=="Naturis ACE Vitamin Juice Drink"  
                              | str_detect(test$RecipeName, "Nature Valley") | str_detect(test$RecipeName, "Nature valley")
                              | str_detect(test$RecipeName, "Nescafe")  
                              | str_detect(test$RecipeName, "Nestle") 
                              | test$RecipeName=="New covent garden chicken & vegetable soup" | test$RecipeName=="New covent garden classic chicken soup"
                              | test$RecipeName=="New covent garden mushroom soup" | test$RecipeName=="New covent garden slow roasted tomato soup"
                              | test$RecipeName=="New York red onion & chive bagel" 
                              | test$RecipeName=="Nobbly Bobbly"                               
                              | test$RecipeName=="Nobbly Dobbly"       
                              | test$RecipeName=="Nomadic yogurt & oats crunch clusters strawberry"       
                              | test$RecipeName=="Nongshim Shin Ramyun Noodle Soup"       
                              | test$RecipeName=="Noodles koka"       
                              | str_detect(test$RecipeName, "Nush almond") | str_detect(test$RecipeName, "Nush Almond")
                              | test$RecipeName=="Nut bar"       
                              | str_detect(test$RecipeName, "Nutella") 
                              | str_detect(test$RecipeName, "Oakhouse Foods")
                              | test$RecipeName=="Oat so simple coconut" 
                              | test$RecipeName=="Onken 0% fat strawberry yogurt"
                              | str_detect(test$RecipeName, "oreo") | str_detect(test$RecipeName, "Oreo")
                              | str_detect(test$RecipeName, "Pasta n sauce")  | str_detect(test$RecipeName, "Pasta 'n' sauce") 
                              | test$RecipeName=="Paluszki breadsticks"                               
                              | test$RecipeName=="Parsnip nut burger"       
                              | test$RecipeName=="Peter's potato, beef, onion, carrot, and swede in puff pastry"  
                              | str_detect(test$RecipeName, "Phadelphia") | str_detect(test$RecipeName, "Philadelphia")
                              | str_detect(test$RecipeName, "Pieminister") 
                              | str_detect(test$RecipeName, "Pizza express") | str_detect(test$RecipeName, "pizza express") | str_detect(test$RecipeName, "Pizza Express")
                              | str_detect(test$RecipeName, "Pizza Hut") 
                              | str_detect(test$RecipeName, "Pop chips") | str_detect(test$RecipeName, "Popchips")
                              | str_detect(test$RecipeName, "Popeyes chicken") | str_detect(test$RecipeName, "Popeye chicken")
                              | test$RecipeName=="Pran Special Chicken Flavour Instant Noodles"                               
                              | test$RecipeName=="Pret an manger breakfast muffin"       
                              | test$RecipeName=="Pret blueberry muffin"       
                              | test$RecipeName=="Pret breakfast muffin"       
                              | test$RecipeName=="Pret chicken and bacon baguette"   
                              | test$RecipeName=="Pronutro cooked with milk" 
                              | test$RecipeName=="Propercorn sweet & salty popcorn" 
                              | test$RecipeName=="Provenance Sweet Chilli & Cranberry Coleslaw"       
                              | test$RecipeName=="Pureety Ultimate Soup Kit Fragrant Thai Broth with Vermicelli Noodles"  
                              | test$RecipeName=="Quaker golden syrup porridge"                               
                              | test$RecipeName=="Quaker oats sultana, raisin & apple porridge"       
                              | str_detect(test$RecipeName, "Radnor Fizz") | str_detect(test$RecipeName, "Radnor fizz")
                              | test$RecipeName=="Rankin irish barmbrack"       
                              | test$RecipeName=="Raspberry Smoothie lolly"       
                              | str_detect(test$RecipeName, "Reese")   
                              | test$RecipeName=="Regal Original Cake Rusks"  
                              | test$RecipeName=="Regal rusk cakes"       
                              | test$RecipeName=="Rivercote lightly salted rice crackers"       
                              | test$RecipeName=="Roast in the bag chicken pork sage and onion"   
                              | test$RecipeName=="Roll ups"       
                              | str_detect(test$RecipeName, "Roosters chicken")
                              | str_detect(test$RecipeName, "Rustlers") | str_detect(test$RecipeName, "rustlers")
                              | (str_detect(test$RecipeName, "Sainsbury") & !(test$RecipeName=="Sainsburys Sweet and Crunchy Stir Fry"
                                                                              | test$RecipeName=="Sainsburys Red Cabbage"
                                                                              | test$RecipeName=="Sainsbury's Indian Pilau"
                                                                              | test$RecipeName=="Sainsbury's Sweet Potato Fries with a Polenta and Herb Crumb"
                                                                              | test$RecipeName=="Sainsburys Sweet Potato Fries with a Polenta and Herb Crumb"
                                                                              | test$RecipeName=="Sainsbury's Sweet potato, coconut and chilli soup"
                                                                              | test$RecipeName=="Sainsbury's Wensleydale Cheese with Cranberries"
                                                                              | test$RecipeName=="Sainsburys parsley sauce"
                                                                              | test$RecipeName=="Sainsburys tomato, lentil & red pepper soup"
                                                                              | test$RecipeName=="Sainsburys roasted red pepper houmous"))
                              | test$RecipeName=="Salted caramel crunch costa"  
                              | test$RecipeName=="Savagers pork meateors"   
                              | test$RecipeName=="Science in Sport Go Isotonic Energy Gel" 
                              | str_detect(test$RecipeName, "Schar") 
                              | str_detect(test$RecipeName, "Screwball")
                              | test$RecipeName=="Seafood sticks" 
                              | test$RecipeName=="Seeds of change classic bolognese sauce"
                              | test$RecipeName=="Sharwood's Low Fat Poppadoms"
                              | test$RecipeName=="Shangri-la chicken flavour noodles"       
                              | test$RecipeName=="Shwartz parsley sauce"       
                              | test$RecipeName=="Sicilian lemon yogurt" 
                              | test$RecipeName=="Ski Yogurt"  
                              | test$RecipeName=="Skyr fat free icelandic style strained vanilla yogurt"       
                              | test$RecipeName=="Skyr strawberry yogurt"
                              | str_detect(test$RecipeName, "Slimming World")
                              | str_detect(test$RecipeName, "Smarties")  
                              | test$RecipeName=="Smak American Cola"  
                              | test$RecipeName=="Smiley faces"
                              | test$RecipeName=="Snackster breakfast muffin"  
                              | test$RecipeName=="Snaktastic sweet & salted popcorn" 
                              | str_detect(test$RecipeName, "Snack a Jack") | str_detect(test$RecipeName, "Snack a jack")
                              | str_detect(test$RecipeName, "Snack stop")
                              | str_detect(test$RecipeName, "Snackrite")
                              | str_detect(test$RecipeName, "Soreen")
                              | str_detect(test$RecipeName, "Southern fried")
                              | str_detect(test$RecipeName, "sparkling ice black raspberry")
                              | test$RecipeName=="Spar Chicken Mayo and Stuffing"       
                              | test$RecipeName=="Spelga low fat toffee yogurt" 
                              | test$RecipeName=="Starbucks Chai Latte"       
                              | str_detect(test$FoodName, "STORK WITH BUTTER SPREAD ONLY")
                              | str_detect(test$RecipeName, "Subway") | str_detect(test$RecipeName, "subway")
                              | test$RecipeName=="Sula butterscotch" 
                              | test$RecipeName=="Sunbites popcorn"       
                              | test$RecipeName=="Super easy birthday cake - cocoa cake" 
                              | test$RecipeName=="Taiko yasai sushi"       
                              | str_detect(test$RecipeName, "Tassimo") 
                              | test$RecipeName=="Tasty foods chicken & ham pie" 
                              | test$RecipeName=="Teasers bar"       
                              | test$RecipeName=="Tempeh maple bacon style tofurky" 
                              | test$RecipeName=="Tempur mini fillets" 
                              | ((str_detect(test$RecipeName, "Tesco") | str_detect(test$RecipeName, "tesco"))
                                                     & !(test$RecipeName=="Tesco apple & mango juice" | test$RecipeName=="Tesco golden syrup instant oats"
                                                         | (test$RecipeName=="Tesco houmous" & test$FoodName!="HUMMUS/HOUMOUS, LOW/REDUCED FAT")
                                                         | test$RecipeName=="Tesco lentil curls" | test$RecipeName=="Tesco spanish chicken & rice soup"
                                                         | test$RecipeName=="Tesco Peppery Babyleaf Salad" | test$RecipeName=="Tesco mediterranean roasting vegetables"))
                              | str_detect(test$RecipeName, "The City Kitchen")
                              | test$RecipeName=="The collective dairy peach & apricot yogurt"
                              | test$RecipeName=="The Delicatessen Wasabi Peanuts"       
                              | test$RecipeName=="The food doctor mild korma corn & soy crisps"
                              | test$RecipeName=="The foodie market paleo macadamia & coconut" 
                              | test$RecipeName=="The Great Dairy Collective for Kids, Banana Suckies"
                              | test$RecipeName=="The original oatley vanilla custard"       
                              | test$RecipeName=="The Original Patty Co. Vegetable Jamaican Patty" 
                              | str_detect(test$RecipeName, "The village bakery") | str_detect(test$RecipeName, "The Village bakery")
                              | test$RecipeName=="Tilda chilli & lime basmati rice"
                              | test$RecipeName=="Tilda Kids Mild Curry Rice"
                              | test$RecipeName=="Tilda mushroom rice"
                              | test$RecipeName=="Tilda wholegrain pilau basmati rice"
                              | str_detect(test$FoodName, "TIPTOP") | str_detect(test$FoodName, "TIP TOP")
                              | test$RecipeName=="Tiramisu"       
                              | test$RecipeName=="Trek cocoa oat protein bar" 
                              | test$RecipeName=="Trifle"       
                              | test$RecipeName=="Trop 50 Mixed Fruit Juice Drink with Sweetener and Vits C, B3, B5 & B6" 
                              | test$RecipeName=="Tropicana Trop 50 orange and mango juice drink"  
                              | str_detect(test$FoodName, "TYPHOO QT") 
                              | test$RecipeName=="Ufit Protein Shake Drink Strawberry"       
                              | test$RecipeName=="Uncle Ben's Mediun Curry with Rice" | test$RecipeName=="Uncle Ben's Mexican Style Rice" 
                                                                                      | test$RecipeName=="Uncle bens spicy mexican rice"
                              | test$RecipeName=="Uncle Rons Mutton Pattie" 
                              | test$RecipeName=="Uncle sams original skinny sweet 'n' salt popcorn"       
                              | test$RecipeName=="USN lactose free protein strawberry milkshake" 
                              | test$RecipeName=="Vegan cheese slices"       
                              | test$RecipeName=="Vegan raspberry doughnuts" 
                              | test$RecipeName=="Vidal Strawberry pencils"       
                              | str_detect(test$RecipeName, "Violife") 
                              | str_detect(test$RecipeName, "Wacko")
                              | (str_detect(test$RecipeName, "Waitrose") & !(test$RecipeName=="Waitrose essential houmous"
                                                                             | (test$RecipeName=="Waitrose wheatberries, lentils & green vegetables")
                                                                             | test$RecipeName=="Waitrose wholesome & herby chickpea, spinach & quinoa"))
                              | str_detect(test$RecipeName, "Wagon wheel") | str_detect(test$RecipeName, "wagon wheely")
                              | test$RecipeName=="Walnut cob Sainsburys"
                              | test$RecipeName=="Warburtons fruit teacake"       
                              | test$RecipeName=="weight watchers wrap" 
                              | str_detect(test$RecipeName, "Whitworth")
                              | str_detect(test$RecipeName, "Wicked kitchen") 
                              | test$RecipeName=="Worldwide foods classic egg fried rice"  
                              | test$RecipeName=="Yarden aubergine salad"       
                              | str_detect(test$RecipeName, "Ye Olde") | str_detect(test$RecipeName, "Ye olde")
                              | test$RecipeName=="Yeo satay sauce" 
                              | test$RecipeName=="Yeo valley lemon curd"    
                              | str_detect(test$RecipeName, "Yollies")
                              | str_detect(test$RecipeName, "Yoo moo")
                              | test$RecipeName=="Yoplait hazelnut yogurt" 
                              | str_detect(test$RecipeName, "Young")
                              | test$RecipeName=="Yushoi"
                              | str_detect(test$RecipeName, "Yutaka Takoyaki octopus balls")
                              | test$RecipeName=="coconut n honey kefir"
                              | str_detect(test$RecipeName, "Trek protein cocoa coconut flapjack")), "4",
                              
                              ifelse((test$RecipeName=="Aldi peppery salad" | test$RecipeName=="Aldi full fat greek style natural yogurt, with cream 500g per pot"
                                   | test$RecipeName=="Arla BOB milk"
                                   | test$RecipeName=="Asda apple & mango juice" | test$RecipeName=="Asda Classic Salad" 
                                   | test$RecipeName=="Asda golden sunrise seed, fruit & nut mix" | test$RecipeName=="Asda mixed vegetables"
                                   | test$RecipeName=="Birds eye steamfresh mixed veg"
                                   | str_detect(test$RecipeName, "Copella apple and mango juice")
                                   | test$RecipeName=="Cypressa seeds & fruits mix"
                                   | str_detect(test$RecipeName,"Ellas kitchen") | str_detect(test$RecipeName, "Ella's Kitchen") | str_detect(test$RecipeName, "ellas kitchen")
                                   | test$RecipeName=="Iceland 4 multi greens steam bags, 150g per steam bag" 
                                   | test$RecipeName=="Innocent apple & mango fruit juice"
                                   | test$RecipeName=="Milled linseed"
                                   | test$RecipeName=="Morrisons ranch salad"
                                   | test$RecipeName=="M&S fruit salad"
                                   | test$RecipeName=="Rude health bircher soft and fruity"
                                   | test$RecipeName=="Sainsburys Sweet and Crunchy Stir Fry" 
                                   | test$RecipeName=="Tesco apple & mango juice" | test$RecipeName=="Tesco Peppery Babyleaf Salad" 
                                                      | test$RecipeName=="Tesco mediterranean roasting vegetables"
                                   | test$RecipeName=="Tetley superfruits boost tea with vitamin B6"
                                   | test$RecipeName=="tilda brown basmati" | test$RecipeName=="Tilda brown basmati & wild rice" | test$RecipeName=="Tilda wholegrain rice"
                                   | test$RecipeName=="Total 5% fat green yogurt"
                                   | test$RecipeName=="Tropicana orange, grape & lime juice"
                                   | test$RecipeName=="Waitrose mushroom stirfry"), "1",
                                   
                              ifelse((test$RecipeName=="Aldi salmon with ginger, chilli & lime"
                                   | test$RecipeName=="Asda minty baby potatoes" | test$RecipeName=="Asda root veg" | test$RecipeName=="Asda garlic passata"
                                   | test$RecipeName=="Asda semi-dried tomatoes and mozzarella pot" | test$RecipeName=="Asda Wholegrain Micro Rice"
                                   | test$RecipeName=="Birds eye steamfresh golden vegetable rice"
                                   | test$RecipeName=="Covent Garden Chicken Soup" | test$RecipeName=="Covent garden chicken soup"
                                   | test$RecipeName=="Daria unsalted nuts"
                                   | test$RecipeName=="Itsu crispy seaweed thin"
                                   | test$RecipeName=="James white beetroot juice"
                                   | test$RecipeName=="Little Dish 1yr+ Mild Korma Cooking Sauce"
                                   |  str_detect(test$RecipeName, "Mash Direct")
                                   | test$RecipeName=="M&S chicken & lentil soup"
                                             | test$RecipeName=="M&S Chicken and Grain Soup"
                                             | test$RecipeName=="M&S Colcannon Potato Mash"
                                             | test$RecipeName=="M&S new potatoes with butter, parsley, chives and mint 385g pack"
                                             | test$RecipeName=="M&S new potatoes with herbs"
                                             | test$RecipeName=="M&S santini tomato side salad"
                                             | test$RecipeName=="M&S Rainbow Salad"
                                             | test$RecipeName=="M&S Spicy lenti soup"
                                             | test$RecipeName=="M&S super broccoli, spinach & pea soup"
                                             | test$RecipeName=="Marks and spencers chicken & supergrain soup"
                                             | test$RecipeName=="Marks & Spencers Super Rice & quinoa"
                                   | test$RecipeName=="McGerty Fine Foods Caramelised Red Onion Marmalade"
                                   | test$RecipeName=="Mestemacher organic sunflower seed bread"
                                   | test$RecipeName=="Morrisons Cod in Parsley Sauce with mash, carrots and peas"
                                   | test$RecipeName=="Morrisons pilau rice "
                                   | test$RecipeName=="Multigrain alphabites "
                                   | test$RecipeName=="Naked coconut water "
                                   | test$RecipeName=="Natures pick oriental stir fry"
                                   | test$RecipeName=="Quaker Oats so simple pot made up with water"
                                   | test$RecipeName=="Riya's Farsi Puri"
                                   | test$RecipeName=="Sainsbury's Indian Pilau"
                                   | test$RecipeName=="Sainsbury's Sweet Potato Fries with a Polenta and Herb Crumb"
                                             | test$RecipeName=="Sainsburys Sweet Potato Fries with a Polenta and Herb Crumb"
                                             | test$RecipeName=="Sainsbury's Sweet potato, coconut and chilli soup"
                                             | test$RecipeName=="Sainsbury's Wensleydale Cheese with Cranberries"
                                             | test$RecipeName=="Sainsburys parsley sauce"
                                             | test$RecipeName=="Sainsburys tomato, lentil & red pepper soup"
                                             | test$RecipeName=="Sainsburys roasted red pepper houmous"
                                   | test$RecipeName=="Tesco golden syrup instant oats"
                                             | (test$RecipeName=="Tesco houmous" & test$FoodName!="HUMMUS/HOUMOUS, LOW/REDUCED FAT")
                                             | test$RecipeName=="Tesco lentil curls"
                                             | test$RecipeName=="Tesco spanish chicken & rice soup"
                                   | test$RecipeName=="The Artisan Bread Company garlic & chilli flatbreads"
                                   | test$RecipeName=="Tropicana orange & mango juice"
                                   | test$RecipeName=="Unearthed spanish potato omelette"
                                   | test$RecipeName=="Uncle Ben Golden Vegetable Rice" | test$RecipeName=="Uncle Ben's Golden Vegetable Rice" 
                                             | test$RecipeName=="Wholegrain med rice"
                                   | test$RecipeName=="Waitrose essential houmous"
                                             | test$RecipeName=="Waitrose wheatberries, lentils & green vegetables"
                                             | test$RecipeName=="Waitrose wholesome & herby chickpea, spinach & quinoa"),"3","NA")))))))


#NOTE THAT "Iceland luxury aberdeen angus quarter pounders" seem to be part of a burger so we put 4
#DO NOT INCLUDE : Fajita mix / Old el paso mince mix for taco

#CHECK
#zz <- subset(test, select=c(FoodName, RecipeName,RecipeMainFoodGroupDesc, RecipeSubFoodGroupDesc, NOVA1, NOVA2, NOVA3), NOVA3!="NA" & NOVA3!="NC")                      
#zzz <- subset(zz, !duplicated(RecipeName,RecipeMainFoodGroupDesc))
#write.xlsx(zzz, file="C:\\Users\\zoe_c\\OneDrive - The University of Liverpool\\ZOE PROJECT 2\\Datas\\NDNS NOVA\\asupp.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

#table(test$NOVA2)
#table(test$NOVA3)
#tableautest <- table(test$NOVA2,test$NOVA3)
#print(tableautest)


 


#STEP 4 - assigning a group for every other food and beverage
test$NOVA4 <- as.factor(ifelse(test$NOVA3=="NC", "NC",  
                        ifelse(test$NOVA3=="1", "1",
                        ifelse(test$NOVA3=="2", "2",
                        ifelse(test$NOVA3=="3", "3",
                        ifelse(test$NOVA3=="4", "4",
                           ifelse((test$SubFoodGroupCode=="1C" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade")
                                                                  | str_detect(test$FoodName, "HOMEMADE"))), "3",
                           ifelse(test$SubFoodGroupCode=="1C", "4", 
                           ifelse(test$SubFoodGroupCode=="1D", "4",
                           ifelse((test$SubFoodGroupCode=="1E" & (str_detect(test$FoodName, "REDUCED FAT") | str_detect(test$FoodName, "BACON")
                                                               | str_detect(test$FoodName, "PACKET MIX") | str_detect(test$FoodName, "SAUCE MIXES"))), "4",
                           ifelse((test$SubFoodGroupCode=="1E" & ((str_detect(test$FoodName, "BOILED") & !str_detect(test$FoodName, "NOT BOILED"))
                                                               | (str_detect(test$FoodName, "DRY") & !str_detect(test$FoodName, "NOT DRY")
                                                               | str_detect(test$FoodName, "DRIED")))), "1",
                           ifelse(test$SubFoodGroupCode=="1E", "3",
                           ifelse(test$SubFoodGroupCode=="1F", "4",     
                           ifelse((test$SubFoodGroupCode=="1G" & ((str_detect(test$FoodName, "FRIED") & !str_detect(test$FoodName, "NOT FRIED"))
                                                               | str_detect(test$FoodName, "WITH PUFA OIL") | str_detect(test$FoodName, "RICE AND VEGETABLES")
                                                               | str_detect(test$FoodName, "VEGETABLE RISOTTO") | str_detect(test$FoodName, "PRAWN RISOTTO") 
                                                               | str_detect(test$FoodName, "GROUND RICE"))), "3",
                           ifelse(test$SubFoodGroupCode=="1G", "1",
                           ifelse((test$SubFoodGroupCode=="1R" & ((str_detect(test$FoodName, "CHEESE") & !str_detect(test$FoodName, "NOT CHEESE"))
                                                               | (str_detect(test$FoodName, "MARG") & !str_detect(test$FoodName, "NOT MARG"))                                              
                                                               | (str_detect(test$FoodName, "PURCHASED") & !str_detect(test$FoodName, "NOT PURCHASED")) 
                                                               | str_detect(test$FoodName, "CUSTARD POWDER") | str_detect(test$FoodName, "DUMPLINGS MADE WITH") 
                                                               | str_detect(test$FoodName, "PANCAKES, SERVED WITH DUCK")  | str_detect(test$FoodName, "POT NOODLE") 
                                                               | str_detect(test$FoodName, "PRAWN CRACKERS") | str_detect(test$FoodName, "SESAME PRAWN TOASTS")
                                                               | str_detect(test$FoodName, "YORKSHIRE PUDDING MADE WITH WHOLE MILK AND BEEF DRIPPING")
                                                               | str_detect(test$FoodName, "PACKET MIX") | str_detect(test$FoodName, "BVO")
                                                               | (str_detect(test$FoodName, "YORKSHIRE PUDD") & str_detect(test$FoodName, "FROZEN")))), "4",
                           ifelse((test$SubFoodGroupCode=="1R" & ((str_detect(test$FoodName, "BATTER WITH") & !str_detect(test$FoodName, "NOT BATTER WITH"))
                                                               | (str_detect(test$FoodName, "FRIED") & !str_detect(test$FoodName, "NOT FRIED"))                                              
                                                               | str_detect(test$FoodName, "COUS COUS WITH")| str_detect(test$FoodName, "POPPADOMS GRILLED") 
                                                               | str_detect(test$FoodName, "SESAME PRAWN TOASTS") | str_detect(test$FoodName, "WEST INDIAN DUMPLING")
                                                               | (str_detect(test$FoodName, "MILK") & !(str_detect(test$FoodName, "NO MILK") | str_detect(test$FoodName, "WITHOUT MILK")))
                                                               | str_detect(test$FoodName, "YORKSHIRE PUDD"))), "3",
                           ifelse(test$SubFoodGroupCode=="1R", "1",
                           #check that the bread recipes do not contain homemade bread
                           #zz <- subset(test, select=c(FoodName, RecipeName, NOVA3), test$SubFoodGroupCode=="2R" & (str_detect(test$RecipeName, "home") | str_detect(test$RecipeName, "Home")))                          
                           #zz <- subset(test, select=c(FoodName, RecipeName, FoodName, NOVA3), (test$SubFoodGroupCode=="2R" & test$FoodName=="BREADCUMBS WHITE HOMEMADE DRIED"))
                           ifelse(test$SubFoodGroupCode=="2R" & test$FoodName=="BREADCUMBS WHITE HOMEMADE DRIED" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade")),"3",                          
                           ifelse(test$SubFoodGroupCode=="2R", "4",
                           #zz <- subset(test, select=c(FoodName, RecipeName, NOVA3), test$SubFoodGroupCode=="3R" & (str_detect(test$RecipeName, "home") | str_detect(test$RecipeName, "Home")))                          
                           ifelse(test$SubFoodGroupCode=="3R", "4",
                           #zz <- subset(test, select=c(FoodName, RecipeName, NOVA3), test$SubFoodGroupCode=="4R" & (str_detect(test$RecipeName, "home") | str_detect(test$RecipeName, "Home")))                          
                           ifelse(test$SubFoodGroupCode=="4R", "4",
                           ifelse((test$SubFoodGroupCode=="5R" & (str_detect(test$FoodName, "MUESLI, NO ADDED SUGAR") 
                                                               | str_detect(test$FoodName, "OAT AND BRAN FLAKES NO ADDITIONS OWN BRAND") 
                                                               | test$FoodName=="OAT GRANOLA")), "3",
                           ifelse(test$SubFoodGroupCode=="5R", "4",
                           ifelse(test$SubFoodGroupCode=="6R", "4",
                           ifelse(test$SubFoodGroupCode=="7A", "4",
                           ifelse(test$SubFoodGroupCode=="7B" & str_detect(test$FoodName, "FLAVOURED"), "4", 
                           ifelse(test$SubFoodGroupCode=="7B", "3",
                           ifelse(test$SubFoodGroupCode=="8B", "4", 
                           ifelse(test$SubFoodGroupCode=="8C" & (str_detect(test$FoodName, "PURCHASED") | str_detect(test$FoodName, "MARGARINE")), "4",
                           ifelse(test$SubFoodGroupCode=="8C", "3", 
                           ifelse(test$SubFoodGroupCode=="8D", "4", 
                           ifelse(test$SubFoodGroupCode=="8E" & ((str_detect(test$FoodName, "CHOCOLATE") & !str_detect(test$FoodName, "NOT CHOCOLATE"))
                                                                | (str_detect(test$FoodName, "MARGARINE") & !str_detect(test$FoodName, "NOT MARGARINE"))
                                                                | (str_detect(test$FoodName, "MARG") & !str_detect(test$FoodName, "NOT MARG"))
                                                                | (str_detect(test$FoodName, "ARTIFICIAL") & !str_detect(test$FoodName, "NOT ARTIFICIAL"))
                                                                | (str_detect(test$FoodName, "CHEESE") & !str_detect(test$FoodName, "NOT CHEESE"))
                                                                | (str_detect(test$FoodName, "JAM") & !str_detect(test$FoodName, "NOT JAM"))
                                                                | str_detect(test$FoodName, "FLAKY PASTRY COOKED")  
                                                                | str_detect(test$FoodName, "MINCE PIES") 
                                                                | str_detect(test$FoodName, "VIC. SPONGEWITH FONDANT ICING")), "4",
                           ifelse(test$SubFoodGroupCode=="8E", "3",
                           ifelse(test$SubFoodGroupCode=="9C", "4", 
                           #check in the 9D recipes if some "manufactured" recipe remains
                           #zz <- subset(test, select=c(FoodName, RecipeName, NOVA3), test$SubFoodGroupCode=="9D" & test$RecipeName!="")
                           ifelse(test$SubFoodGroupCode=="9D", "3",
                           ifelse(test$SubFoodGroupCode=="9E", "4",
                           #check in the 9F recipes if some "manufactured" recipe remains
                           #zz <- subset(test, select=c(FoodName, RecipeName, NOVA3), test$SubFoodGroupCode=="9F" & test$RecipeName!="")
                           ifelse(test$SubFoodGroupCode=="9F" & ((str_detect(test$FoodName, "CHOCOLATE") & !str_detect(test$FoodName, "NOT CHOCOLATE"))
                                                               | test$FoodName=="STEAMED SPONGE PUDDING WITH SYRUP OR JAM"), "4",
                           ifelse(test$SubFoodGroupCode=="9F", "3",
                           ifelse(test$SubFoodGroupCode=="9G", "4",
                           #check in the 9F recipes if some "manufactured" recipe remains
                           #zz <- subset(test, select=c(FoodName, RecipeName, NOVA3), test$SubFoodGroupCode=="9H" & test$RecipeName!="")
                           ifelse(test$SubFoodGroupCode=="9H" & ((str_detect(test$FoodName, "CHOCOLATE") & !str_detect(test$FoodName, "NOT CHOCOLATE"))
                                                                | (str_detect(test$FoodName, "ARTIFICIAL") & !str_detect(test$FoodName, "NOT ARTIFICIAL"))
                                                                | str_detect(test$FoodName, "BANOFFEE") 
                                                                | str_detect(test$FoodName, "CHEESECAKE") 
                                                                | str_detect(test$FoodName, "TRIFLE")  
                                                                | str_detect(test$FoodName, "JELLY")
                                                                | str_detect(test$RecipeName, "cheese") | str_detect(test$RecipeName, "Cheese")), "4",
                          ifelse(test$SubFoodGroupCode=="9H", "3",      
                          ifelse(test$SubFoodGroupCode=="10R", "1", 
                          ifelse(test$SubFoodGroupCode=="11R", "1", 
                          ifelse((test$SubFoodGroupCode=="12R" & test$FoodName=="FLORA PRO ACTIV SKIMMED MILK"), "4",  
                          ifelse(test$SubFoodGroupCode=="12R", "1",
                          ifelse(test$SubFoodGroupCode=="13A", "4", "NA")))))))))))))))))))))))))))))))))))))))))))))))

gc()
test$NOVA5 <- as.factor(ifelse(test$NOVA4=="NC", "NC",  
                        ifelse(test$NOVA4=="1", "1",
                        ifelse(test$NOVA4=="2", "2",
                        ifelse(test$NOVA4=="3", "3",
                        ifelse(test$NOVA4=="4", "4",  
                         ifelse((test$SubFoodGroupCode=="13B" & (str_detect(test$FoodName, "DREAM TOPPING") |  str_detect(test$FoodName, "AEROSOL")
                                                                       |  str_detect(test$FoodName, "ALTERNATIVE")
                                                                       | str_detect(test$FoodName, "EMLEA") |  str_detect(test$FoodName, "ELMLEA")
                                                                       | str_detect(test$FoodName, "VERY LOW FAT CR"))), "4", 
                         ifelse(test$SubFoodGroupCode=="13B", "1", 
                         ifelse((test$SubFoodGroupCode=="13R" & (str_detect(test$FoodName, "FLAVOURED") | str_detect(test$FoodName, "WEETABIX")
                                                               | (str_detect(test$FoodName, "CHOCOLATE") & !str_detect(test$FoodName, "NOT CHOCOLATE"))
                                                               | str_detect(test$FoodName, "MILK SHAKE") | str_detect(test$FoodName, "MILKSHAKE")
                                                               | str_detect(test$FoodName, "MARS BAR MILK") 
                                                               | (str_detect(test$FoodName, "SWEETENED") & !str_detect(test$FoodName, "UNSWEETENED"))
                                                               | str_detect(test$FoodName, "ALTERNATIVE") | str_detect(test$FoodName, "MILK DRINK")
                                                               | str_detect(test$FoodName, "COFFEE CREAMER") | str_detect(test$FoodName, "COFFEE WHITENER")
                                                               | str_detect(test$FoodName, "COFFEE MATE POWDER") | str_detect(test$FoodName, "PROTEIN FREE")
                                                               | str_detect(test$FoodName, "LACTOFREE") | str_detect(test$FoodName, "LACTOSE FREE")
                                                               | str_detect(test$FoodName, "EVAPORATED") 
                                                               | str_detect(test$FoodName, "SOYA CUSTARD") | str_detect(test$FoodName, "FORTIFIED SOYA DRINK"))), "4", 
                          ifelse(test$SubFoodGroupCode=="13R", "1", 
                          ifelse(test$SubFoodGroupCode=="14A", "3",
                          ifelse((test$SubFoodGroupCode=="14B" & (str_detect(test$FoodName, "REDUCED FAT") | str_detect(test$FoodName, "LOW FAT")
                                                               | str_detect(test$FoodName, "VEGETARIAN") | str_detect(test$FoodName, "HALF FAT"))), "4",       
                          ifelse(test$SubFoodGroupCode=="14B", "3",
                          ifelse((test$SubFoodGroupCode=="14R" & (str_detect(test$FoodName, "PURCHASED") | str_detect(test$FoodName, "PROCESSED")
                                                               | str_detect(test$FoodName, "REDUCED FAT") | str_detect(test$FoodName, "TOAST TOPPERS CANNED") 
                                                               | str_detect(test$FoodName, "CHEESE SOFT") | str_detect(test$FoodName, "CHEESE SPREAD")
                                                               | str_detect(test$FoodName, "DAIRYLEA") | str_detect(test$FoodName, "LAUGHING COW")
                                                               | str_detect(test$FoodName, "LACTOSE FREE SOFT") | str_detect(test$FoodName, "SMOKED HARD")
                                                               | str_detect(test$FoodName, "CHEESE CREAM") | str_detect(test$FoodName, "MASCARPONE")
                                                               | str_detect(test$FoodName, "KERRY FOODS CHEESTRINGS") | str_detect(test$FoodName, "LOW FAT")
                                                               | str_detect(test$FoodName, "SOYA") | str_detect(test$FoodName, "TOFU"))), "4",       
                          ifelse(test$SubFoodGroupCode=="14R", "3", 
                          #check in the 15B if some other Yogurt 1 have to be added to the list
                          #zz <- subset(test, select=c(FoodName, RecipeName, NOVA3), test$SubFoodGroupCode=="15B")       
                          ifelse((test$SubFoodGroupCode=="15B" &  (test$FoodName=="YOGURT, GREEK STYLE, COWS, NATURAL, WHOLE MILK" | test$FoodName=="KEFIR"
                                                               | test$FoodName=="YOGURT , WHOLE MILK, NATURAL, UNSWEETENED" 
                                                               | test$FoodName=="GREEK YOGURT SHEEP"
                                                               | test$FoodName=="YOGURT GOAT MILK")), "1",
                          ifelse(test$SubFoodGroupCode=="15B", "4",
                          ifelse((test$SubFoodGroupCode=="15C" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))
                                                               & (test$FoodName=="FRUIT BASED PANNACOTTA" | test$FoodName=="FRUIT FOOL, FULL FAT"
                                                                | test$FoodName=="JELLY MADE WITH SEMI-SKIMMED MILK")), "3",
                          ifelse((test$SubFoodGroupCode=="15C" & (test$FoodName=="FROMAGE FRAIS, FULL FAT, NATURAL, UNSWEETENED" | test$FoodName=="QUARK")), "3",
                          ifelse(test$SubFoodGroupCode=="15C", "4",
                          ifelse((test$SubFoodGroupCode=="15D" & ((str_detect(test$FoodName, "FLAVOUR") & !str_detect(test$FoodName, "NOT FLAVOUR"))
                                                               | (str_detect(test$FoodName, "CHOCOLATE") & !str_detect(test$FoodName, "NOT CHOCOLATE"))
                                                               | str_detect(test$FoodName, "PURCHASED") | str_detect(test$FoodName, "PROCESSED")
                                                               | (str_detect(test$FoodName, "SWEETENED") & !str_detect(test$FoodName, "UNSWEETENED"))
                                                               | str_detect(test$FoodName, "ALTERNATIVE")
                                                               | str_detect(test$FoodName, "SOYA")
                                                               | str_detect(test$FoodName, "RASMALAI INDIAN DESSERT MILK CREAM"))), "4",                
                          ifelse((test$SubFoodGroupCode=="15D" & (test$FoodName=="BAKED EGG CUSTARD (WITH SEMI-SKIMMED MILK)" | test$FoodName=="EGG CUSTARD BAKED"
                                                               | test$FoodName=="CREME CARAMEL HOMEMADE"  | test$FoodName=="CREME CARAMEL MADE W S/SKIMMED MILK"
                                                               | test$FoodName=="CREME BRULEE")), "3",
                          ifelse((test$SubFoodGroupCode=="15D" & !test$RecipeName==""), "3",
                          ifelse((test$SubFoodGroupCode=="15D" & test$RecipeName==""), "NA", 
                          ifelse(test$SubFoodGroupCode=="16C", "4",
                          ifelse((test$SubFoodGroupCode=="16D" & (str_detect(test$FoodName, "MERINGUES FILLED WITH WHIPPED CREAM") | str_detect(test$FoodName, "HAM")
                                                                | str_detect(test$FoodName, "SPREADABLE BUTTER") 
                                                                | str_detect(test$FoodName, "REDUCED FAT PUFA SPREAD") | str_detect(test$FoodName, "WITH REDUCED FAT SPREAD"))), "4",
                          ifelse((test$SubFoodGroupCode=="16D" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",
                          ifelse((test$SubFoodGroupCode=="16D" & ((str_detect(test$FoodName, "FRIED") & !str_detect(test$FoodName, "WITHOUT FAT"))
                                                               | str_detect(test$FoodName, "COOKED IN") |  str_detect(test$FoodName, "SOUFFLE")
                                                               | str_detect(test$FoodName, "OMELETTE WITH POTATOES CHEESE AND ONION")
                                                               | (str_detect(test$FoodName, "MILK") & !(str_detect(test$FoodName, "NO MILK") | str_detect(test$FoodName, "WITHOUT MILK")))
                                                               | str_detect(test$FoodName, "SCRAMBLED EGG WITH SEMI") | str_detect(test$FoodName, "EGG & CRUMB") 
                                                               | str_detect(test$FoodName, "QUICHE") | str_detect(test$FoodName, "EGG FU YUNG") 
                                                               | str_detect(test$FoodName, "EGG NO FAT SEMI SKIMMED MILK") 
                                                               | str_detect(test$FoodName, "WITH ADDED FAT") | str_detect(test$FoodName, "WITH OMEGA 3"))), "3",       
                          ifelse(test$SubFoodGroupCode=="16D", "1",   
                          ifelse(test$SubFoodGroupCode=="17R" & str_detect(test$FoodName, " SPREAD"), "4",
                          ifelse(test$SubFoodGroupCode=="17R", "2",
                          ifelse(test$SubFoodGroupCode=="18A", "4",
                          ifelse(test$SubFoodGroupCode=="18B", "2",
                          ifelse(test$SubFoodGroupCode=="19A", "4",
                          ifelse(test$SubFoodGroupCode=="19R", "4",
                          ifelse(test$SubFoodGroupCode=="20A", "4",
                          ifelse(test$SubFoodGroupCode=="20B", "4",
                          ifelse(test$SubFoodGroupCode=="20C", "2",
                          ifelse(test$SubFoodGroupCode=="21A", "4",
                          ifelse(test$SubFoodGroupCode=="21B", "4",
                          ifelse(test$SubFoodGroupCode=="22A", "4",
                          ifelse((test$SubFoodGroupCode=="22B" & test$FoodName=="PORK SHOULDER"), "1",
                          ifelse((test$SubFoodGroupCode=="22B" & str_detect(test$FoodName,"RASHERS") & str_detect(test$FoodName," SMOKED") & str_detect(test$FoodName,"NOT SMOKED")), "3",
                          ifelse((test$SubFoodGroupCode=="22B" & str_detect(test$FoodName,"RASHERS") & !str_detect(test$FoodName," SMOKED")), "3",
                          ifelse(test$SubFoodGroupCode=="22B", "4","NA")))))))))))))))))))))))))))))))))))))))))))))

test$NOVA6 <- as.factor(ifelse(test$NOVA5=="NC", "NC",  
                        ifelse(test$NOVA5=="1", "1",
                        ifelse(test$NOVA5=="2", "2",
                        ifelse(test$NOVA5=="3", "3",
                        ifelse(test$NOVA5=="4", "4",  
                          ifelse(test$SubFoodGroupCode=="23A", "4", 
                          ifelse((test$SubFoodGroupCode=="23B" & (str_detect(test$FoodName, "BOTTLED PASTA SAUCE") | str_detect(test$FoodName, "DOLMIO WHITE SAUCE")
                                                               | (str_detect(test$FoodName, "MARG") & !str_detect(test$FoodName, "NOT MARG")))), "4",
                          ifelse((test$SubFoodGroupCode=="23B" & (str_detect(test$FoodName, "NOT SALT") 
                                                               & (str_detect(test$FoodName, "BRAISED") | str_detect(test$FoodName, "BOILED")
                                                               | str_detect(test$FoodName, "GRILLED") | str_detect(test$FoodName, "ROAST"))
                                                               & !(str_detect(test$FoodName, "IN RED WINE") 
                                                               | str_detect(test$FoodName, "BEEF TOPSIDE ROAST LEAN AND FAT") 
                                                               | str_detect(test$FoodName, "BEEF TOPSIDE ROAST LEAN ONLY")                                                                                                                                            
                                                               | str_detect(test$FoodName, "ROAST BEFF COOKED SLICES") 
                                                               | str_detect(test$FoodName, "SILVERSIDE SALTED BOILED")
                                                               | str_detect(test$FoodName, "SILVERSIDE NOT SALTED POT-ROASTED BRAISED LEAN")
                                                               | str_detect(test$FoodName, "SILVERSIDE NOT SALTED POT-ROASTED BRAISED LEAN+FAT")))), "1",
                          ifelse(test$SubFoodGroupCode=="23B", "3", 
                          ifelse(test$SubFoodGroupCode=="24A", "4",
                          ifelse((test$SubFoodGroupCode=="24B" & (str_detect(test$FoodName, "LAMB BURGER") | str_detect(test$FoodName, "WITH CANNED CURRY SAUCE"))), "4",
                          ifelse((test$SubFoodGroupCode=="24B" & (str_detect(test$FoodName, "BRAISED") | str_detect(test$FoodName, "BOILED")
                                                               | str_detect(test$FoodName, "GRILLED") | str_detect(test$FoodName, "ROAST"))
                                                               & !(str_detect(test$FoodName, " SALTED") | str_detect(test$FoodName, "IN RED WINE") 
                                                               | str_detect(test$FoodName, "LAMB LEG RAW LEAN AND FAT"))), "1",
                          ifelse((test$SubFoodGroupCode=="24B" & (str_detect(test$FoodName, "FRIED") | str_detect(test$FoodName, "STEW") 
                                                               | str_detect(test$FoodName, "HOMEMADE") | str_detect(test$FoodName, "TAKEAWAY"))                                                                           
                                                               & !(str_detect(test$FoodName, "SHISH KEBAB"))), "3",      
                          ifelse(test$SubFoodGroupCode=="24B", "3", 
                          ifelse(test$SubFoodGroupCode=="25A", "4",                                   
                          ifelse((test$SubFoodGroupCode=="25B" & (str_detect(test$FoodName, "PORK BURGERS MADE WITH EXTRA LEAN PORK") | str_detect(test$FoodName, "BARBECUE SAUCE")
                                                               | str_detect(test$FoodName, "BARBECUE STYLE") | str_detect(test$FoodName, "BACON"))), "4", 
                          ifelse((test$SubFoodGroupCode=="25B" & (str_detect(test$FoodName, "BRAISED") | str_detect(test$FoodName, "BOILED")
                                                               | str_detect(test$FoodName, "GRILLED") | str_detect(test$FoodName, "ROAST"))
                                                               & !(str_detect(test$FoodName, " SALTED") | str_detect(test$FoodName, "IN RED WINE"))), "1",
                          ifelse((test$SubFoodGroupCode=="25B" & (str_detect(test$FoodName, "FRIED") | str_detect(test$FoodName, "STEW") 
                                                               | str_detect(test$FoodName, "HOMEMADE"))), "3",    
                          ifelse(test$SubFoodGroupCode=="25B", "3",
                          ifelse(test$SubFoodGroupCode=="26A", "4",
                          ifelse(test$SubFoodGroupCode=="27A", "4",
                          ifelse((test$SubFoodGroupCode=="27B" & (str_detect(test$FoodName, "SAUCE MIX") | str_detect(test$FoodName, "WITH JAR CURRY SAUCE")
                                                               | str_detect(test$FoodName, "WITH CANNED/BOTTLE SAUCE"))), "4",
                          ifelse((test$SubFoodGroupCode=="27B" & (str_detect(test$FoodName, "BRAISED") | str_detect(test$FoodName, "BOILED")
                                                               | str_detect(test$FoodName, "GRILL") | str_detect(test$FoodName, "ROAST"))
                                                               & !(str_detect(test$FoodName, " SALTED") | str_detect(test$FoodName, "IN RED WINE") 
                                                               | test$FoodName=="CHICKEN WINGS MARINATED OR BBQ OR GRILLED" 
                                                               | test$FoodName=="CHICKEN TIKKA, GRILLED, NO BONES INCLUDES TAKEAWAY")), "1",
                          ifelse((test$SubFoodGroupCode=="27B" & (str_detect(test$FoodName, "FRIED") | str_detect(test$FoodName, "STEW") 
                                                               | str_detect(test$FoodName, "HOMEMADE") | str_detect(test$FoodName, "TAKEAWAY"))                                                                           
                                                               & !(test$FoodName=="CHICKEN STIR FRIED WITH PEPPERS IN BLACK BEAN SAUCE")), "3",      
                          ifelse(test$SubFoodGroupCode=="27B", "3",
                          ifelse((test$SubFoodGroupCode=="28R" & (str_detect(test$FoodName, "PURCHASED") | str_detect(test$FoodName, "LIVER PATE"))), "4",
                          ifelse((test$SubFoodGroupCode=="28R" & ((str_detect(test$FoodName, "BRAISED") & !str_detect(test$FoodName, "BRAISED IN"))
                                                               | str_detect(test$FoodName, "BOILED")
                                                               | str_detect(test$FoodName, "GRILL") | str_detect(test$FoodName, "ROAST")
                                                               | test$FoodName=="LIVER OX BAKED IN OVEN NO FAT" 
                                                               | test$FoodName=="LAMBS LIVER WITH LOSSES")
                                                               & !(str_detect(test$FoodName, " SALTED") | str_detect(test$FoodName, "IN RED WINE"))), "1",
                          ifelse((test$SubFoodGroupCode=="28R" & (str_detect(test$FoodName, "FRIED") | str_detect(test$FoodName, "STEW") 
                                                               | str_detect(test$FoodName, "HOMEMADE"))), "3",        
                          ifelse(test$SubFoodGroupCode=="28R", "3",
                          ifelse(test$SubFoodGroupCode=="29R", "4",
                          ifelse(test$SubFoodGroupCode=="30A", "4",
                          ifelse(test$SubFoodGroupCode=="30B", "4",
                          ifelse(test$SubFoodGroupCode=="31A", "4",
                          #check in the 31B if some other foods are not 4
                          #zz <- subset(test, select=c(FoodName, RecipeName, NOVA6), test$SubFoodGroupCode=="31B")    
                          ifelse(test$SubFoodGroupCode=="31B", "4",
                          ifelse(test$SubFoodGroupCode=="32A", "4", "NA"))))))))))))))))))))))))))))))))))))


gc()
test$NOVA7 <- as.factor(ifelse(test$NOVA6=="NC", "NC",  
                        ifelse(test$NOVA6=="1", "1",
                        ifelse(test$NOVA6=="2", "2",
                        ifelse(test$NOVA6=="3", "3",
                        ifelse(test$NOVA6=="4", "4",  
                           ifelse((test$SubFoodGroupCode=="32B" & (test$FoodName=="CORNED BEEF HASH" | test$FoodName=="CHOPPED HAM AND PORK WITH EGG" 
                                                                | str_detect(test$FoodName, "SPAM FRITTERS")  
                                                                | str_detect(test$FoodName, "SAUSAGE"))), "4",
                           ifelse((test$SubFoodGroupCode=="32B" & (str_detect(test$FoodName, "BRAISED") | str_detect(test$FoodName, "BOILED")
                                                                | str_detect(test$FoodName, "GRILL") | str_detect(test$FoodName, "ROAST"))
                                                                & !(str_detect(test$FoodName, " SALTED") | str_detect(test$FoodName, "IN RED WINE"))), "1",
                           ifelse((test$SubFoodGroupCode=="32B" & (str_detect(test$FoodName, "FRIED") | str_detect(test$FoodName, "STEW") 
                                                                | str_detect(test$FoodName, "HOMEMADE"))), "3",
                           ifelse((test$SubFoodGroupCode=="32B" & test$FoodName=="DUCK, CRISPY CHINESE, MEAT ONLY"
                                                                & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",  
                           ifelse((test$SubFoodGroupCode=="32B" & test$FoodName=="DUCK, CRISPY CHINESE, MEAT ONLY"), "4",      
                           ifelse(test$SubFoodGroupCode=="32B", "3", 
                           ifelse((test$SubFoodGroupCode=="33R" & (str_detect(test$FoodName, "NO COATING") | str_detect(test$FoodName, "NOCOAT")
                                                                | str_detect(test$FoodName, "COATED IN FLOUR") | str_detect(test$FoodName, "LEMON SOLE FRIED IN OLIVE OIL")
                                                                | str_detect(test$FoodName, "PLAICE NO BONES FLOUR BLENDED")  | str_detect(test$FoodName, "HOMEMADE")
                                                                | str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",  
                           ifelse(test$SubFoodGroupCode=="33R", "4",
                           ifelse(test$SubFoodGroupCode=="34C", "4", 
                           ifelse(test$SubFoodGroupCode=="34D" & str_detect(test$FoodName, "IN CHEESE SAUCE"), "4", 
                           ifelse((test$SubFoodGroupCode=="34D" & (str_detect(test$FoodName, "GRILLED WITH BUTTER") | str_detect(test$FoodName, "WITH OLIVE OIL")
                                                                | str_detect(test$FoodName, "POACHED IN SEMI-SKIMMED MILK") | str_detect(test$FoodName, "POACHED IN MILK")
                                                                | str_detect(test$FoodName, "POACHED IN WHOLE MILK")
                                                                | str_detect(test$FoodName, "FROM A RESTAURANT") | str_detect(test$FoodName, "HOMEMADE"))), "3",
                           ifelse((test$SubFoodGroupCode=="34D" & ((str_detect(test$FoodName, "STEAMED") & test$FoodName!="CHINESE FISH BALLS STEAMED")
                                                                | test$FoodName=="CAVIAR" 
                                                                | str_detect(test$FoodName, "GRILL") | str_detect(test$FoodName, "POACHED") 
                                                                | str_detect(test$FoodName, "COD HADDOCK WITH LOSSES"))), "1",
                           ifelse(test$SubFoodGroupCode=="34D", "3", 
                           ifelse(test$SubFoodGroupCode=="34E" & str_detect(test$FoodName, "CANNED"), "3", 
                           ifelse(test$SubFoodGroupCode=="34E", "4", 
                           ifelse((test$SubFoodGroupCode=="34F" & (str_detect(test$FoodName, "FISH AND SEAFOOD CHOWDER"))), "4",
                           ifelse((test$SubFoodGroupCode=="34F" & (str_detect(test$FoodName, "FRIED IN") 
                                                                | str_detect(test$FoodName, "TAKEAWAY") | str_detect(test$FoodName, "HOMEMADE"))), "3",
                           ifelse((test$SubFoodGroupCode=="34F" & (str_detect(test$FoodName, "STEAMED") | str_detect(test$FoodName, "BOILED") 
                                                                | str_detect(test$FoodName, "MUSSELS NOT CANNED NO SHELLS"))), "1",
                           ifelse(test$SubFoodGroupCode=="34F", "3",
                           ifelse((test$SubFoodGroupCode=="34G" & ((str_detect(test$FoodName,"CANNED") & str_detect(test$FoodName, "ONLY"))
                                                                | str_detect(test$FoodName, "TUNA IN OIL FISH AND OIL"))), "3",
                           ifelse(test$SubFoodGroupCode=="34G" & str_detect(test$RecipeName, "toastie"), "4",
                           ifelse(test$SubFoodGroupCode=="34G", "4", 
                           ifelse(test$SubFoodGroupCode=="34H" & str_detect(test$RecipeName, "Tuna crunch"), "4",
                           ifelse(test$SubFoodGroupCode=="34H" & (str_detect(test$FoodName, "& SAUCE") | test$FoodName=="TUNA PASTA"), "4",
                           ifelse(test$SubFoodGroupCode=="34H", "3",
                           ifelse((test$SubFoodGroupCode=="35A" & (test$FoodName=="SUSHI, SALMON BASED" | test$FoodName=="SUSHI, TUNA BASED")), "3",
                           ifelse(test$SubFoodGroupCode=="35A", "4",
                           ifelse((test$SubFoodGroupCode=="35B" & (str_detect(test$RecipeName, "Itsu") | str_detect(test$FoodName, "KIPPER BOIL IN BAG")
                                                                | str_detect(test$RecipeName, "Trout cooked with vegetables") 
                                                                | str_detect(test$RecipeName, "Tuna steak"))), "4",
                           ifelse((test$SubFoodGroupCode=="35B" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",  
                           ifelse((test$SubFoodGroupCode=="35B" & (str_detect(test$FoodName, "FRIED IN") | str_detect(test$FoodName, "STEWED")
                                                                | str_detect(test$FoodName, "BAKED BUTTER") | str_detect(test$FoodName, "WITH BUTTER")
                                                                | str_detect(test$FoodName, "CURRIED") | str_detect(test$FoodName, "SAUCE")
                                                                | str_detect(test$FoodName, "SMOKED") | str_detect(test$FoodName, "COATED")
                                                                | str_detect(test$FoodName, "TAKEAWAY") | str_detect(test$FoodName, "HOMEMADE")
                                                                | test$FoodName=="TUNA PASTA")), "3",
                           ifelse((test$SubFoodGroupCode=="35B" & str_detect(test$FoodName, "FISHCAKES")), "4",
                           ifelse(test$SubFoodGroupCode=="35B", "1","NA"))))))))))))))))))))))))))))))))))))))
                                  
                                  
                  
test$NOVA8 <- as.factor(ifelse(test$NOVA7=="NC", "NC",  
                        ifelse(test$NOVA7=="1", "1",
                        ifelse(test$NOVA7=="2", "2",
                        ifelse(test$NOVA7=="3", "3",
                        ifelse(test$NOVA7=="4", "4",
                           ifelse(test$SubFoodGroupCode=="36A" &  str_detect(test$RecipeName, "Wagamama Chicken Katsu Curry"), "3",
                           ifelse((test$SubFoodGroupCode=="36A" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade")
                                                                | str_detect(test$RecipeName, "Coleslaw"))), "3",
                           ifelse(test$SubFoodGroupCode=="36A", "1",
                           ifelse(test$SubFoodGroupCode=="36B" & str_detect(test$FoodName, "Homemade juice"), "1",
                           ifelse((test$SubFoodGroupCode=="36B" & (str_detect(test$FoodName, "PURCHAED") | str_detect(test$FoodName, "PURCHASED"))), "4",
                           ifelse((test$SubFoodGroupCode=="36B" & (str_detect(test$FoodName, "CUCUMBER & YOGURT RAITA") | str_detect(test$FoodName, "TZATZIKI")
                                                                | str_detect(test$FoodName, "COLESLAW") | str_detect(test$RecipeName, "Coleslaw")
                                                                | str_detect(test$FoodName, "OIL & VINEGAR DRESSING")
                                                                | str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",
                           ifelse(test$SubFoodGroupCode=="36B", "1", 
                           ifelse((test$SubFoodGroupCode=="36C" & (str_detect(test$RecipeName, "toast") | str_detect(test$RecipeName, "Ham") 
                                                               | str_detect(test$RecipeName, "burger"))), "4",
                           ifelse((test$SubFoodGroupCode=="36C" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",
                           ifelse(test$SubFoodGroupCode=="36C", "1", 
                           ifelse((test$SubFoodGroupCode=="37A" & ((str_detect(test$FoodName, "ADDED SUGAR AND/OR SALT") & !str_detect(test$FoodName, "NO ADDED SUGAR AND/OR SALT"))
                                                                | str_detect(test$RecipeName, "Corned beef")
                                                                | str_detect(test$RecipeName, "ham") | str_detect(test$RecipeName, "Ham") 
                                                                | str_detect(test$RecipeName, "bacon") | str_detect(test$RecipeName, "Bacon") 
                                                                | str_detect(test$RecipeName, "Chorizo") | str_detect(test$RecipeName, "chorizo"))), "4",
                           ifelse((test$SubFoodGroupCode=="37A" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",
                           ifelse((test$SubFoodGroupCode=="37A" & test$RecipeName!=""), "3",
                           ifelse((test$SubFoodGroupCode=="37A" & (str_detect(test$FoodName, "CANNED") & !str_detect(test$FoodName, "NOT CANNED"))), "3",
                           ifelse(test$SubFoodGroupCode=="37A", "1", 
                           ifelse((test$SubFoodGroupCode=="37B" & (str_detect(test$FoodName, "ADDED SUGAR AND/OR SALT") & !str_detect(test$FoodName, "NO ADDED SUGAR AND/OR SALT"))), "4",
                           ifelse((test$SubFoodGroupCode=="37B" & test$RecipeName!=""), "3",
                           ifelse((test$SubFoodGroupCode=="37B" & ((str_detect(test$FoodName, "CANNED") & !str_detect(test$FoodName, "NOT CANNED"))
                                                                  | str_detect(test$FoodName, "FRIED IN"))), "3",
                           ifelse(test$SubFoodGroupCode=="37B", "1",
                           ifelse(test$SubFoodGroupCode=="37C", "4",
                           ifelse((test$SubFoodGroupCode=="37D" & (str_detect(test$FoodName, "FRIED IN") | (str_detect(test$FoodName, "CANNED") & !str_detect(test$FoodName, "NOT CANNED"))
                                                                | str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",
                           ifelse((test$SubFoodGroupCode=="37D" & test$RecipeName!=""), "3",
                           ifelse(test$SubFoodGroupCode=="37D", "1",
                           ifelse((test$SubFoodGroupCode=="37E" & ((str_detect(test$FoodName, "ADDED SUGAR AND/OR SALT") & !str_detect(test$FoodName, "NO ADDED SUGAR AND/OR SALT"))
                                                                | str_detect(test$RecipeName, "Corned beef")
                                                                | str_detect(test$RecipeName, "ham") | str_detect(test$RecipeName, "Ham") 
                                                                | str_detect(test$RecipeName, "bacon") | str_detect(test$RecipeName, "Bacon") 
                                                                | str_detect(test$RecipeName, "Chorizo") | str_detect(test$RecipeName, "chorizo"))), "4",
                           ifelse((test$SubFoodGroupCode=="37E" & test$RecipeName!=""), "3",
                           ifelse((test$SubFoodGroupCode=="37E" & ((str_detect(test$FoodName, "CANNED") & !str_detect(test$FoodName, "NOT CANNED"))
                                                                | str_detect(test$FoodName, "FRIED"))), "3",
                           ifelse(test$SubFoodGroupCode=="37E", "1",
                           ifelse((test$SubFoodGroupCode=="37F" & ((str_detect(test$FoodName, "ADDED SUGAR AND/OR SALT") & !str_detect(test$FoodName, "NO ADDED SUGAR AND/OR SALT"))
                                                                | str_detect(test$RecipeName, "Corned beef")
                                                                | str_detect(test$RecipeName, "ham") | str_detect(test$RecipeName, "Ham") 
                                                                | str_detect(test$RecipeName, "bacon") | str_detect(test$RecipeName, "Bacon") 
                                                                | str_detect(test$RecipeName, "Chorizo") | str_detect(test$RecipeName, "chorizo"))), "4",
                           ifelse((test$SubFoodGroupCode=="37F" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade")
                                                                | str_detect(test$RecipeName, "Vegetables oven cooked"))), "3",
                           ifelse((test$SubFoodGroupCode=="37F" & test$RecipeName!=""), "3",
                           ifelse(test$SubFoodGroupCode=="37F" & str_detect(test$FoodName, "GRILLED"), "1",
                           ifelse(test$SubFoodGroupCode=="37F", "3", 
                           ifelse((test$SubFoodGroupCode=="37I" & ((str_detect(test$FoodName, "ADDED SALT") & !str_detect(test$FoodName, "NO ADDED SALT"))
                                                                | str_detect(test$FoodName, "LOW/REDUCED FAT") | str_detect(test$FoodName, "PURCHASED")
                                                                | str_detect(test$FoodName, "CHICKPEA AND VEGETABLE CURRY WITH COOK IN SAUCE AND PEPPERS")
                                                                | str_detect(test$FoodName, "BEANS PINTO REFRIED BEANS EG ELPASO")  | str_detect(test$RecipeName, "Corned beef")
                                                                | str_detect(test$RecipeName, "ham") | str_detect(test$RecipeName, "Ham") 
                                                                | str_detect(test$RecipeName, "bacon") | str_detect(test$RecipeName, "Bacon") 
                                                                | str_detect(test$RecipeName, "Chorizo") | str_detect(test$RecipeName, "chorizo")
                                                                | str_detect(test$FoodName, "BEAN SALAD RETAIL") | test$FoodName=="BEANBURGER RED KIDNEY BEAN WITH BUN + RELISH")), "4",
                           ifelse((test$SubFoodGroupCode=="37I" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade")
                                                                | test$FoodName=="HUMMUS, NOT CANNED" | test$FoodName=="BEANBURGER RED KIDNEY BEAN COOKED NO BUN")), "3",
                           ifelse((test$SubFoodGroupCode=="37I" & test$RecipeName!=""), "3",
                           ifelse((test$SubFoodGroupCode=="37I" & ((str_detect(test$FoodName, "CANNED") & !str_detect(test$FoodName, "NOT CANNED"))
                                                                | str_detect(test$FoodName, "IN SALTED WATER") 
                                                                | str_detect(test$FoodName, "CURRY")
                                                                | (str_detect(test$FoodName, "BUTTER") & ! (str_detect(test$FoodName, "NO BUTTER") | str_detect(test$FoodName, "BUTTER BEAN"))))), "3",
                           ifelse((test$SubFoodGroupCode=="37I" & (test$FoodName=="LENTIL DAHL WITH SUNFLOWER OIL GARLIC AND ONIONS"
                                                                | test$FoodName=="PLAIN DOSA INDIAN PANCAKE LENTILS RICE FLOUR"
                                                                | test$FoodName=="SPICY RED KIDNEY BEANS"
                                                                | test$FoodName=="THREE BEAN SALAD")), "3",
                           ifelse(test$SubFoodGroupCode=="37I", "1", 
                           ifelse(test$SubFoodGroupCode=="37K", "4",
                           ifelse(test$SubFoodGroupCode=="37L" & test$FoodName=="SUSHI, VEGETARIAN", "3",
                           ifelse(test$SubFoodGroupCode=="37L", "4", "NA")))))))))))))))))))))))))))))))))))))))))))))))



gc()
test$NOVA9 <- as.factor(ifelse(test$NOVA8=="NC", "NC",  
                        ifelse(test$NOVA8=="1", "1",
                        ifelse(test$NOVA8=="2", "2",
                        ifelse(test$NOVA8=="3", "3",
                        ifelse(test$NOVA8=="4", "4", 
                           ifelse((test$SubFoodGroupCode=="37M" & ((str_detect(test$FoodName, "ADDED SALT") & !str_detect(test$FoodName, "NO ADDED SALT"))
                                                                | str_detect(test$FoodName, "LOW/REDUCED FAT") | str_detect(test$FoodName, "PURCHASED")
                                                                | str_detect(test$FoodName, "BREADCRUMB") | str_detect(test$FoodName, "MATAR PANEER - PEA AND CHEESE CURRY")
                                                                | str_detect(test$FoodName, "BEETROOT PICKLED IN VINEGAR") | str_detect(test$FoodName, "STUFFED & BREADED")
                                                                | test$FoodName=="VEGETARIAN HAGGIS")), "4",
                           ifelse((test$SubFoodGroupCode=="37M" & test$RecipeName!=""), "3",
                           ifelse((test$SubFoodGroupCode=="37M" & ((str_detect(test$FoodName, "CANNED") & !str_detect(test$FoodName, "NOT CANNED"))
                                                                |  (str_detect(test$FoodName, "PICKLED") & !str_detect(test$FoodName, "NOT PICKLED"))
                                                                | str_detect(test$FoodName, "FRIED") | str_detect(test$FoodName, "FRYING")
                                                                | str_detect(test$FoodName, "ROAST IN") | str_detect(test$FoodName, "ROASTED IN") 
                                                                | str_detect(test$FoodName, "SAUTEED BLENDED OIL") | str_detect(test$FoodName, "SAUTEED IN")
                                                                | (str_detect(test$FoodName, "SALTED") & !str_detect(test$FoodName, "UNSALTED"))
                                                                | str_detect(test$FoodName, "CASSEROLE")  
                                                                | str_detect(test$FoodName, "HOT SWEETENED PICKLED PEPPERS") | str_detect(test$FoodName, "GHERKINS PICKLED")
                                                                | str_detect(test$FoodName, "HOMEMADE") | str_detect(test$FoodName, "TAKEAWAY") 
                                                                | str_detect(test$FoodName, "TOMATO SAUCE WITH COURGETTES AND NO OIL"))), "3",
                          ifelse((test$SubFoodGroupCode=="37M" & (str_detect(test$FoodName, "CURRY") | str_detect(test$FoodName, "CURRIED") 
                                                                | str_detect(test$FoodName,"PAKORA") | str_detect(test$FoodName, "BHAJI") 
                                                                | str_detect(test$FoodName, "BHINDI") | str_detect(test$FoodName, "BIRYANI")  
                                                                | str_detect(test$FoodName, "GOULASH") | str_detect(test$FoodName, "VEGETABLE KIEV") 
                                                                | test$FoodName=="VOL AU VENTS MADE WITH MUSHROOM SAUCE AND PASTRY"
                                                                | test$FoodName=="BOMBAY ALOO" | str_detect(test$FoodName, "LAVERBREAD")   
                                                                | str_detect(test$FoodName, "CHEESE SLICE") | str_detect(test$FoodName, "VINE LEAF STUFFED")
                                                                | str_detect(test$FoodName, "IN A CREAMY TOMATO SAUCE")
                                                                | (str_detect(test$FoodName, "MILK") & !str_detect(test$FoodName, "NO MILK"))
                                                                | str_detect(test$FoodName, "PIE") | str_detect(test$FoodName, "RISOTTO")
                                                                | str_detect(test$FoodName, "TEMPURA") | str_detect(test$FoodName, "SAUERKRAUT")
                                                                | str_detect(test$FoodName, "VEGETABLE CHOW MEIN") | str_detect(test$FoodName, "VEGETABLE STEW")
                                                                | str_detect(test$FoodName, "ONION RINGS"))), "3",
                          ifelse(test$SubFoodGroupCode=="37M", "1",
                          ifelse(test$SubFoodGroupCode=="38A", "4",
                          ifelse(test$SubFoodGroupCode=="38C", "4",
                          ifelse((test$SubFoodGroupCode=="38D" & (str_detect(test$FoodName, "BATTERED") | str_detect(test$FoodName, "BACON")
                                                               | (str_detect(test$FoodName, "MAR") & !str_detect(test$FoodName, "NO MAR"))
                                                               | str_detect(test$FoodName, "TREX") | str_detect(test$FoodName, "REDUCED FAT SPREAD")
                                                               | str_detect(test$FoodName, "FLORA"))), "4",
                                 
                          ifelse((test$SubFoodGroupCode=="38D" & (str_detect(test$FoodName, "FRESH") | str_detect(test$FoodName, "HOMEMADE")
                                                               | str_detect(test$FoodName, "BHAJI TAKE-AWAY"))), "3",       
                          ifelse(test$SubFoodGroupCode=="38D", "3",  
                          ifelse(test$SubFoodGroupCode=="39A" & test$RecipeName=="" & test$FoodName=="POTATOES NEW, CANNED AND  DRAINED, NO ADDED SALT OR SUGAR", "3",
                          ifelse(test$SubFoodGroupCode=="39A" & test$RecipeName!="" & test$FoodName=="POTATOES NEW, CANNED AND  DRAINED, NO ADDED SALT OR SUGAR", "3",
                          ifelse(test$SubFoodGroupCode=="39A", "4",
                          ifelse((test$SubFoodGroupCode=="39B" & ((str_detect(test$FoodName, "MARG") & !str_detect(test$FoodName, "NO MARG"))
                                                                | str_detect(test$FoodName, "LOW FAT") | str_detect(test$FoodName, "REDUCED FAT") | str_detect(test$FoodName, "REDUCE FAT")
                                                                | str_detect(test$FoodName, "LF SPRD P/S") | str_detect(test$FoodName, "LOW OR RED FAT")
                                                                | str_detect(test$FoodName, "CHEESE") | str_detect(test$FoodName, "BACON"))), "4",
                          ifelse((test$SubFoodGroupCode=="39B" & test$RecipeName=="" 
                                                               & (str_detect(test$FoodName, "WITH BUTTER") | str_detect(test$FoodName, "& BUTTER") 
                                                               | str_detect(test$FoodName, "IN BUTTER") | str_detect(test$FoodName, "FRYING")
                                                               | str_detect(test$FoodName, "POTATO WEDGES BAKED") | str_detect(test$FoodName, "HOMEMADE")
                                                               | test$FoodName=="POTATO CURRY" |  test$FoodName=="POTATO CURRY WITH ONIONS AND TOMATOES"                                                          
                                                               | test$FoodName=="POTATO SALAD" | test$FoodName=="POTATO SLICES BATTERED (BLENDED VEG OIL)")), "3",
                          ifelse((test$SubFoodGroupCode=="39B" & test$RecipeName=="" 
                                                               & (str_detect(test$FoodName, "BAKED") | str_detect(test$FoodName, "BOILED") 
                                                               | str_detect(test$FoodName, "MICROWAVED"))), "1",
                          ifelse((test$SubFoodGroupCode=="39B" & test$RecipeName!=""), "3", 
                          ifelse(test$SubFoodGroupCode=="40A" & str_detect(test$RecipeName, "Fresh juice"), "1", 
                          ifelse((test$SubFoodGroupCode=="40A" & test$RecipeName!=""), "3",  
                          ifelse((test$SubFoodGroupCode=="40A" & test$RecipeName=="" & str_detect(test$FoodName, "NAS")), "1",
                          ifelse((test$SubFoodGroupCode=="40A" & test$RecipeName=="" 
                                                               & (str_detect(test$FoodName, "WITH SUGAR") | str_detect(test$FoodName, "APPLE SAUCE NOT CANNED")
                                                               | str_detect(test$FoodName, "HOMEMADE"))), "3",
                          ifelse(test$SubFoodGroupCode=="40A", "1",  
                          ifelse(test$SubFoodGroupCode=="40B" & str_detect(test$RecipeName, "Fresh juice"), "1", 
                          ifelse((test$SubFoodGroupCode=="40B" & test$RecipeName!=""), "3",  
                          ifelse((test$SubFoodGroupCode=="40B" & test$RecipeName=="" & str_detect(test$FoodName, "NAS")), "1",
                          ifelse((test$SubFoodGroupCode=="40B" & test$RecipeName=="" & (str_detect(test$FoodName, "WITH SUGAR") | str_detect(test$FoodName, "HOMEMADE"))), "3",
                          ifelse(test$SubFoodGroupCode=="40B", "1", 
                          ifelse(test$SubFoodGroupCode=="40C" & str_detect(test$RecipeName, "Fresh juice"), "1", 
                          ifelse((test$SubFoodGroupCode=="40C" & test$RecipeName!=""), "3",  
                          ifelse((test$SubFoodGroupCode=="40C" & test$RecipeName=="" & str_detect(test$FoodName, "NAS")), "1",
                          ifelse((test$SubFoodGroupCode=="40C" & test$RecipeName=="" & (str_detect(test$FoodName, "WITH ADDED") | str_detect(test$FoodName, "BANANA COOKED")
                                                               | str_detect(test$FoodName, "HOMEMADE"))), "3",
                          ifelse(test$SubFoodGroupCode=="40C", "1",
                          ifelse((test$SubFoodGroupCode=="40D" & (str_detect(test$FoodName, "ADDED") & !str_detect(test$FoodName, "NO ADDED"))), "4",  
                          ifelse(test$SubFoodGroupCode=="40D", "3","NA"))))))))))))))))))))))))))))))))))))))))


gc()
test$NOVA10 <- as.factor(ifelse(test$NOVA9=="NC", "NC",  
                         ifelse(test$NOVA9=="1", "1",
                         ifelse(test$NOVA9=="2", "2",
                         ifelse(test$NOVA9=="3", "3",
                         ifelse(test$NOVA9=="4", "4", 
                          ifelse((test$SubFoodGroupCode=="40E" & (str_detect(test$FoodName, "ADDED") & !str_detect(test$FoodName, "NO ADDED"))), "4",
                          ifelse(test$SubFoodGroupCode=="40E", "3", 
                          ifelse((test$SubFoodGroupCode=="40R" & (str_detect(test$FoodName, "FRUIT BARS EG. SCHOOL BARS") | test$FoodName=="SUMMERFRUIT COMPOTE (M&S)"
                                                               | str_detect(test$FoodName, "FRUIT CUP JELLY WITH FRUIT") | str_detect(test$FoodName, "FRUIT PIE FILLING"))), "4",
                          ifelse((test$SubFoodGroupCode=="40R" & str_detect(test$RecipeName, "Fresh juice")), "1", 
                          ifelse((test$SubFoodGroupCode=="40R" & test$RecipeName!=""), "3",  
                          ifelse((test$SubFoodGroupCode=="40R" & (str_detect(test$FoodName, "FRUIT COMPOTE PEACH APRICOT PLUM") | str_detect(test$FoodName, "CANNED") 
                                                               | str_detect(test$FoodName, "IN BRINE") | str_detect(test$FoodName, "STEWED WITH SUGAR")
                                                               | str_detect(test$FoodName, "FRUIT SALAD FRESH WITH SUGAR/SYRUP FRUIT & JUICE")
                                                               | str_detect(test$FoodName, "TAPENADE"))), "3",
                          ifelse(test$SubFoodGroupCode=="40R", "1",
                          ifelse((test$SubFoodGroupCode=="41A" & (test$FoodName=="SUGAR / SWEETENER MIXES" | str_detect(test$FoodName, "MALTODEXTRIN") 
                                                               | test$FoodName=="CARBOHYDRATE POWDER  (SUCROSE, MALTOSE, GLUCOSE) E.G. HI FIVE"
                                                               | str_detect(test$FoodName, "GLUCOSE LIQUID") | str_detect(test$FoodName, "GLUCOSE POWDER"))), "4",
                          ifelse((test$SubFoodGroupCode=="41A" & str_detect(test$RecipeName, "Sainsburys Red Cabbage")), "4",
                          ifelse(test$SubFoodGroupCode=="41A", "2",
                          ifelse((test$SubFoodGroupCode=="41B" & (str_detect(test$FoodName, "PURCHASED") | str_detect(test$FoodName, "HONEYCOMB")
                                                               | str_detect(test$FoodName, "REDUCED SUGAR") | str_detect(test$FoodName, "REDUCED-SUGAR"))), "4",
                          ifelse(test$SubFoodGroupCode=="41B" & test$FoodName=="HONEY (IN JARS)", "2",
                          ifelse(test$SubFoodGroupCode=="41B", "3",
                          ifelse(test$SubFoodGroupCode=="41R", "4",
                          ifelse(test$SubFoodGroupCode=="42R" & test$FoodName=="HOMEMADE POPCORN", "3",
                          ifelse(test$SubFoodGroupCode=="42R", "4",
                          ifelse(test$SubFoodGroupCode=="43R", "4",
                          ifelse(test$SubFoodGroupCode=="44R", "4",
                          ifelse((test$SubFoodGroupCode=="45R" & ((str_detect(test$FoodName, "CONCENTRATE") & !str_detect(test$FoodName, "NOT FROM CONCENTRATE"))
                                                               | (str_detect(test$FoodName, "SWEETENED") & !str_detect(test$FoodName, "UNSWEETENED"))
                                                               | str_detect(test$FoodName, "SMOOTHIES RED BOTTLED PURCHASED") 
                                                               | str_detect(test$FoodName, "LEMON JUICE 50% VIT C LOSS") 
                                                               | str_detect(test$FoodName, "VITAFIT MULTIVITAMIN 11 FRUIT JUICE")
                                                               | str_detect(test$FoodName, "GRAPE JUICE CARBONATED GRAPE JUICE NOT CANNED"))), "4", 
                          ifelse((test$SubFoodGroupCode=="45R" & (str_detect(test$FoodName, "FRESH") | str_detect(test$FoodName, "LEMONS JUICE ONLY NO PEEL OR FLESH") 
                                                               | str_detect(test$FoodName, "UNSWEETENED") | str_detect(test$FoodName, "MIXED FRUIT JUICE PASTEURISED")
                                                               | str_detect(test$FoodName, "NOT FROM CONCENTRATE") | str_detect(test$FoodName, "CARROT JUICE CARTONS OR BOTTLES")
                                                               | str_detect(test$FoodName, "FRUIT JUICE FORTIFIED WITH MULTIVITAMINS") 
                                                               | str_detect(test$FoodName, "POMEGRANATE JUICE PURCHASED") 
                                                               | str_detect(test$FoodName, "TOMATO JUICE CARTONS OR BOTTLES")  
                                                               | str_detect(test$FoodName, "VEGETABLE JUICE MIXED"))), "1", 
                          ifelse((test$SubFoodGroupCode=="45R" & str_detect(test$FoodName, "100% JUICE")), "1", 
                          ifelse(test$SubFoodGroupCode=="45R", "3",    
                          ifelse(test$SubFoodGroupCode=="50A", "4",
                          ifelse(test$SubFoodGroupCode=="50C", "4",
                          ifelse((test$SubFoodGroupCode=="50D" & (str_detect(test$FoodName, "WON TON CHINESE SOUP") 
                                                               | str_detect(test$FoodName, "WITH HAM"))), "4", 
                          ifelse(test$SubFoodGroupCode=="50D", "3",
                          ifelse(test$SubFoodGroupCode=="50E", "4",
                          ifelse((test$SubFoodGroupCode=="50R" & str_detect(test$FoodName, "PURCHASED")), "4",
                          ifelse(test$SubFoodGroupCode=="50R" & str_detect(test$FoodName, "HOME"), "3",
                          ifelse((test$SubFoodGroupCode=="50R" & (test$FoodName=="BAKING POWDER" | test$FoodName=="VINEGAR" | test$FoodName=="YEAST COMPRESSED" 
                                                               | test$FoodName=="SALT TABLE" | test$FoodName=="SEA SALT" | test$FoodName=="SODIUM BICARBONATE"
                                                               | test$FoodName=="YEAST DRIED" | test$FoodName=="GELATIN")), "2",    
                          ifelse((test$SubFoodGroupCode=="50R" & (str_detect(test$FoodName, "HOMEMADE") | test$FoodName=="CHILLI PICKLE SWEET" 
                                                               | test$FoodName=="ONION SAUCE WITH SEMI-SKIMMED MILK" | test$FoodName=="TOMATO PUREE (NOT CANNED)" 
                                                               | test$FoodName=="PICKLE SWEET" | test$FoodName=="GARLIC PUREE"
                                                               | test$FoodName=="TOMATO PUREE WITH COOKING LOSSES"
                                                               | test$FoodName=="TOMATO BASED PASTA SAUCE WITH FRESH TOMATOES & ONIONS" 
                                                               | test$FoodName=="WHITE SAUCE SEMI SKIMMED MILK" | test$FoodName=="WHITE SAUCE SKIMMED MILK"
                                                               | test$FoodName=="TOMATO SAUCE MADE WITH OLIVE OIL" | test$FoodName=="TOMATO SAUCE WITH ONIONS")), "3", 
                          ifelse((test$SubFoodGroupCode=="50R" & (str_detect(test$FoodName, "SEEDS") | str_detect(test$FoodName, "DRIED") | str_detect(test$FoodName, "FRESH") 
                                                               | str_detect(test$FoodName, "GROUND") | test$FoodName=="CAYENNE PEPPER" | test$FoodName=="CINNAMON" 
                                                               | test$FoodName=="SEAWEED WAKAME DRIED RAW" | test$FoodName=="PAPRIKA" | test$FoodName=="PEPPER" 
                                                               | test$FoodName=="SAFFRON"| test$FoodName=="MUSTARD POWDER" | test$FoodName=="MEXICAN SPICE MIXES"
                                                               | test$FoodName=="BLACK BEAN" | test$FoodName=="CHILLI POWDER" | test$FoodName=="CURRY POWDER")), "1",               
                          ifelse(test$SubFoodGroupCode=="50R", "4", "NA")))))))))))))))))))))))))))))))))))))))
                                 
gc()                             
test$NOVA11 <- as.factor(ifelse(test$NOVA10=="NC", "NC",  
                         ifelse(test$NOVA10=="1", "1",
                         ifelse(test$NOVA10=="2", "2",
                         ifelse(test$NOVA10=="3", "3",
                         ifelse(test$NOVA10=="4", "4",    
                          ifelse((test$SubFoodGroupCode=="51A" & (str_detect(test$FoodName, "PURCHASED") | str_detect(test$FoodName, "VENDING")
                                                               | str_detect(test$FoodName, "INSTANT, WITH WHITENER")
                                                               | test$FoodName=="COFFEE & CHICORY ESSENCE")), "4", 
                          ifelse((test$SubFoodGroupCode=="51A" & (str_detect(test$FoodName, "TAKEAWAY ONLY") 
                                                               | str_detect(test$FoodName, "CAPPUCCINO MADE WITH ESPRESSO AND SEMI-SKIMMED MILK"))), "3", 
                          ifelse(test$SubFoodGroupCode=="51A", "1", 
                          ifelse((test$SubFoodGroupCode=="51B" & (str_detect(test$FoodName, "PURCHASED") | str_detect(test$FoodName, "VENDING"))), "4", 
                          ifelse((test$SubFoodGroupCode=="51B" & (str_detect(test$FoodName, "MILK") & !str_detect(test$FoodName, "NO MILK"))), "3", 
                          ifelse(test$SubFoodGroupCode=="51B", "1", 
                          ifelse((test$SubFoodGroupCode=="51C" & (str_detect(test$FoodName, "PURCHASED") | str_detect(test$FoodName, "VENDING"))), "4", 
                          ifelse((test$SubFoodGroupCode=="51C" & (str_detect(test$FoodName, "MILK") & !str_detect(test$FoodName, "NO MILK"))), "3", 
                          ifelse(test$SubFoodGroupCode=="51C", "1",
                          ifelse((test$SubFoodGroupCode=="51D" & !str_detect(test$FoodName, "NOT FLAVOURED") 
                                                               & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade"))), "3",
                          ifelse((test$SubFoodGroupCode=="51D" & (str_detect(test$FoodName, "FLAVOURED") & !str_detect(test$FoodName, "NOT FLAVOURED"))
                                                               |  str_detect(test$FoodName, "SWEETENER") | str_detect(test$FoodName, "V WATER")), "4", 
                          ifelse(test$SubFoodGroupCode=="51D", "1",        
                          ifelse(test$SubFoodGroupCode=="51R" & test$FoodName=="WATER AS A DILUENT FOR POWDERED", "4",
                          ifelse(test$SubFoodGroupCode=="51R", "1",
                          ifelse(test$SubFoodGroupCode=="52A" & (str_detect(test$FoodName, "RTD") | str_detect(test$FoodName, "READY TO DRINK")
                                                              | str_detect(test$FoodName, "FRUIT JUICE CONCENTRATE")), "4",       
                          ifelse(test$SubFoodGroupCode=="52A", "NA",
                          ifelse(test$SubFoodGroupCode=="52R", "4",
                          ifelse(test$SubFoodGroupCode=="53R" & str_detect(test$FoodName, "HOMEMADE"), "3",
                          ifelse(test$SubFoodGroupCode=="53R", "4",
                          ifelse(test$SubFoodGroupCode=="55R", "4",  
                          ifelse((test$SubFoodGroupCode=="56R" & (str_detect(test$FoodName, "CHEVDA") | str_detect(test$FoodName, "MILK PURCHASED") 
                                                               | (str_detect(test$FoodName, "SWEETENED") & !str_detect(test$FoodName, "UNSWEETENED")) 
                                                               | str_detect(test$FoodName, "REDUCED FAT")
                                                               | str_detect(test$FoodName, "PEANUT BUTTER CRUNCHY") | str_detect(test$FoodName, "PEANUT BUTTER SMOOTH"))), "4",
                          ifelse((test$SubFoodGroupCode=="56R" & ((str_detect(test$FoodName, "SALT") & !str_detect(test$FoodName, "UNSALT"))
                                                               | str_detect(test$FoodName, "HONEY ROASTED") | str_detect(test$FoodName, "TAHINI")	
                                                               | test$FoodName=="PEANUTS & RAISINS (KP)"
                                                               | test$FoodName=="PEANUT BUTTER WHOLEGRAIN WHOLENUT NO ADDED SUGAR")), "3", 
                          ifelse(test$SubFoodGroupCode=="56R", "1", 
                          ifelse(test$SubFoodGroupCode=="57A", "4",
                          ifelse(test$SubFoodGroupCode=="57B", "4",
                          ifelse(test$SubFoodGroupCode=="57C", "4",   
                          ifelse(test$SubFoodGroupCode=="58A", "4",
                          ifelse(test$SubFoodGroupCode=="58B", "4",
                          ifelse(test$SubFoodGroupCode=="58C", "4",
                          ifelse(test$SubFoodGroupCode=="59R", "4", 
                          ifelse(test$SubFoodGroupCode=="60R", "1",
                          ifelse((test$SubFoodGroupCode=="61R" & (str_detect(test$RecipeName, "homemade") | str_detect(test$RecipeName, "Homemade")
                                                               | (test$RecipeName=="Smoothie") & !str_detect(test$FoodName, "PURCHASED"))), "1",
                          ifelse(test$SubFoodGroupCode=="61R" & test$RecipeName!="", "NA",
                          ifelse((test$SubFoodGroupCode=="61R" & str_detect(test$FoodName, "HOMEMADE")), "1", 
                          ifelse((test$SubFoodGroupCode=="61R" & str_detect(test$FoodName, "PURCHASED")), "4",        
                          ifelse(test$SubFoodGroupCode=="61R", "NA",
                          ifelse(test$FoodName=="DIABETIC JAM" | test$FoodName=="DIABETIC MARMALADE", "4","NA")))))))))))))))))))))))))))))))))))))))))))

#CHECK
#zz <- subset(test, select=c(FoodName, SubFoodGroupCode, RecipeName, NOVA11, NOVA1), test$SubFoodGroupCode=="50R")    
#zzz <- subset(zz, !duplicated(FoodName))
#table(zzz$FoodName)

#Did some item have no group and can be classified? except food item part of a recipe that are normally not coded
zNA1 <- subset(test, NOVA11=="NA")    
zzNA1 <- subset(zNA1, !duplicated(RecipeName))
table(zzNA1$RecipeName)

zzNA2 <- subset(zNA1, !duplicated(FoodName))
table(zzNA2$FoodName)

#Turn the NOVA variable into numeric
require(dplyr)
MonDF <- test

#List of NA found before : If nutrient supplement into a recipe, then this recipe will be 4
MonDF$NOVA12 <- as.factor(ifelse(MonDF$NOVA11=="NC", "-1",  
                           ifelse(MonDF$NOVA11=="1","1",
                           ifelse(MonDF$NOVA11=="2","2",
                           ifelse(MonDF$NOVA11=="3","3",
                           ifelse(MonDF$NOVA11=="4","4",
                           ifelse(MonDF$RecipeName=="Bread" | MonDF$RecipeName=="Casino sauvers d'Ailleurs" | MonDF$RecipeName=="Fish pie"
                                | MonDF$RecipeName=="Creamy mushroom alfredo pasta" | MonDF$RecipeName=="Gnocchi with green beans" 
                                | MonDF$RecipeName=="Joost" | MonDF$RecipeName=="Matcha latte" | MonDF$RecipeName=="Peach and apricot yogurt" 
                                | MonDF$RecipeName=="Smoothie" | MonDF$RecipeName=="Smoothie, D1" | MonDF$RecipeName=="Smoothie, D2 & 3" 
                                | MonDF$RecipeName=="Tofu in spices"
                               & (MonDF$SubFoodGroupCode=="54A" | MonDF$SubFoodGroupCode=="54B" | MonDF$SubFoodGroupCode=="54C" |
                                  MonDF$SubFoodGroupCode=="54D" | MonDF$SubFoodGroupCode=="54E" | MonDF$SubFoodGroupCode=="54F" |
                                  MonDF$SubFoodGroupCode=="54G" | MonDF$SubFoodGroupCode=="54H" | MonDF$SubFoodGroupCode=="54I" |
                                  MonDF$SubFoodGroupCode=="54J" | MonDF$SubFoodGroupCode=="54K" | MonDF$SubFoodGroupCode=="54L" | 
                                  MonDF$SubFoodGroupCode=="54M" | MonDF$SubFoodGroupCode=="54N" | MonDF$SubFoodGroupCode=="54P"), "4","0")))))))


MonDF$NOVA12 <-  as.numeric(as.character(factor(MonDF$NOVA12)))


#Check
#table(MonDF$NOVA11,useNA="a")
#table(MonDF$NOVA12,useNA="a")


#STEP 5 - Deal with the recipe
MonDF2 <- data.table(MonDF)
MonDF1 <- MonDF2[, .(MaxNOVA = max(NOVA12, na.rm = T),  MinNOVA = min(NOVA12, na.rm = T), FoodName,RecipeName,SubFoodGroupDesc,TotalGrams), by=list(seriali, SurveyYear, DayNo, MealTime, RecipeSubFoodGroupDesc)]
#table(MonDF1$MaxNOVA,useNA="a")
#table(MonDF1$MinNOVA,useNA="a")


MonDF1$NOVA12bis <-as.numeric(ifelse(MonDF1$MaxNOVA==-1 & MonDF1$MinNOVA==-1, 12,
                              ifelse(MonDF1$MaxNOVA==1 & MonDF1$MinNOVA==0, 0,
                              ifelse(MonDF1$MaxNOVA==1 & MonDF1$MinNOVA==-1, 4, 
                              ifelse(MonDF1$MaxNOVA==1, 1,
                                                   
                              ifelse(MonDF1$MaxNOVA==2 & MonDF1$MinNOVA==2 & 
                                       (str_detect(MonDF1$RecipeSubFoodGroupDesc, "MANUFACTURED") |
                                        str_detect(MonDF1$RecipeSubFoodGroupDesc, "PURCHASED") |
                                        MonDF1$RecipeSubFoodGroupDesc %in% c("SOFT DRINKS NOT LOW CALORIE CONCENTRATED","CRISPS AND SAVOURY SNACKS")),4,
                              #conservative approach
                              ifelse(MonDF1$MaxNOVA==2 & MonDF1$MinNOVA==2 & MonDF1$RecipeSubFoodGroupDesc %in% c("BISCUITS HOMEMADE", 
                                                                                                                  "BUNS CAKES & PASTRIES HOMEMADE",
                                                                                                 "CEREAL BASED MILK PUDDINGS - HOMEMADE", 
                                                                                                 "DAIRY DESSERTS HOMEMADE", "FRUIT PIES HOMEMADE",
                                                                                                 "OTHER CEREAL BASED PUDDINGS - HOMEMADE",
                                                                                                 "SOUP HOMEMADE","SPONGE PUDDINGS - HOMEMADE"),3,
                                     
                              #some here are not really recipe as only one ingredient listed. 
                              #we then trust the SubFoodGroupDesc
                              ifelse(MonDF1$MaxNOVA==2 & MonDF1$MinNOVA==2, 2,
                              ifelse(MonDF1$MaxNOVA==2 & MonDF1$MinNOVA==0, 0,
                              
                              #something max 2 (so culinary ingredient) and min -1 (add vit etc.) 
                              #surely mean formula
                              ifelse(MonDF1$MaxNOVA==2 & MonDF1$MinNOVA==-1, 4,
                                     
                              ifelse(MonDF1$MaxNOVA==2, 3, 
                               
                              ifelse(MonDF1$MaxNOVA==3 & MonDF1$MinNOVA==0, 0,
                              ifelse(MonDF1$MaxNOVA==3 & MonDF1$MinNOVA==-1, 10,
                                            
                              ifelse(MonDF1$MaxNOVA==3 & MonDF1$MinNOVA==1, 3, 
                              ifelse(MonDF1$MaxNOVA==3 & MonDF1$MinNOVA==2, 3,

                              ifelse(MonDF1$MaxNOVA==3 & (str_detect(MonDF1$RecipeName, "homemade") | str_detect(MonDF1$RecipeName, "Homemade")), 3,
                              #we supposed that "H/M" mean homemade
                              ifelse((str_detect(MonDF1$RecipeName, "H/M")) & MonDF1$MaxNOVA==3, 3, 
                              
                              #if RecipeSubFoodGroupDesc precise that it's homemade (and not including homemade), then 3
                              ifelse((MonDF1$RecipeSubFoodGroupDesc %in% c("OTHER CEREAL BASED PUDDINGS - HOMEMADE",
                                      "BUNS CAKES & PASTRIES HOMEMADE","SOUP HOMEMADE","HOMEMADE MEAT PIES AND PASTRIES","DAIRY DESSERTS HOMEMADE",
                                      "CEREAL BASED MILK PUDDINGS - HOMEMADE","BISCUITS HOMEMADE")) & MonDF1$MaxNOVA==3, 3, 
                              
                              #food 3 or 4 depending on the recipe.... optimistic approach = 3
                              ifelse(MonDF1$MaxNOVA==3 & MonDF1$MinNOVA==3, 3,
                                     
                              ifelse(MonDF1$MaxNOVA==4, 4, 
                              
                              ifelse(MonDF1$MaxNOVA==-1, 12,0)))))))))))))))))))))

# table(MonDF1$NOVA12bis)
# essk <- MonDF1[NOVA12bis %in% c(10)]
# table(essk$RecipeSubFoodGroupDesc)

MonDF1$NOVA13 <- as.numeric(ifelse(MonDF1$NOVA12bis==10 & (MonDF1$RecipeName %in% c("Peaches in brandy","Cranberry & sloegin cream")),4,
                            ifelse(MonDF1$NOVA12bis==0 & 
                            #recipe supposed to be 3 anyway 
                                  (MonDF1$RecipeName=="Cottage cheese" | MonDF1$RecipeName=="Matcha latte"
                                  | str_detect(MonDF1$RecipeName, "actifry") | str_detect(MonDF1$RecipeName, "Actifry")), 3,  #as Actifry is a home utensil...
                            #recipe supposed not "homemade"
                            ifelse(MonDF1$NOVA12bis==0 & 
                                  (MonDF1$RecipeName=="Almond milk" | MonDF1$RecipeName=="Brioche roll" | MonDF1$RecipeName=="Caramel waffle" 
                                  | MonDF1$RecipeName=="Cheese mug shot" | MonDF1$RecipeName=="Lentil crisps" | MonDF1$RecipeName=="4 cheese ravioli"
                                  | MonDF1$RecipeName=="Grenadine syrup"
                                  | MonDF1$RecipeName=="Peach and apricot yogurt" #look at the foods composing this recipe, we can see CORNFLOUR, not usual for a group 1 yogurt
                                  | MonDF1$RecipeName=="Protein mega blitz"), 4, MonDF1$NOVA12bis))))

# table(MonDF1$NOVA13)
# ess <- MonDF1[NOVA13==12]
#everything in 12 should be vitamins etc
# table(ess$RecipeSubFoodGroupDesc)



#STEP 6 - Check that everything is well classified

#Check if some recipe are in 10. If yes, look at the recipe and class them accordingly
z10 <- subset(MonDF1, NOVA13==10)
#zz10 <- subset(z10, !duplicated(RecipeName))
#table(zz10$RecipeName)

#Check if no more recipe in 2. If not class them accordingly
z2 <- subset(MonDF1, NOVA13==2)
zz2 <- subset(z2, !duplicated(RecipeName))
table(zz2$RecipeName)
zz2 <- subset(z2, !duplicated(RecipeSubFoodGroupDesc))
table(zz2$RecipeSubFoodGroupDesc)
#"Dressing (D3)" & "Oil and vinegar" are really just NOVA group 2
#Little issue with this intake. The participant declared "tomato fried" but only add "olive oil". Tomato missing.
# 900611131 / NDNS Year 9 / Day 1 / Hour 07:30:00 / food: OLIVE OIL / recipe: tomato fried
#We delete the recipe name t
MonDF1$RecipeName <- ifelse(MonDF1$seriali==900611131 & MonDF1$DayNo==1 & MonDF1$FoodName=="OLIVE OIL" & MonDF1$RecipeName=="tomato fried","",MonDF1$RecipeName)
zz22 <- subset(z2, !duplicated(FoodName))
table(zz22$FoodName)
zz22 <- subset(z2, !duplicated(RecipeSubFoodGroupDesc))
table(zz22$RecipeSubFoodGroupDesc)


#The 12 recipe are non classed. 
z12 <- subset(MonDF1, NOVA13==12)
zz12 <- subset(z12, !duplicated(RecipeName))
table(zz12$RecipeName)
zz12 <- subset(z12, !duplicated(RecipeSubFoodGroupDesc))
table(zz12$RecipeSubFoodGroupDesc)

#Check if the "1" recipe are really 1. If not class them accordingly
z1 <- subset(MonDF1, NOVA13==1)
zz1 <- subset(z1, !duplicated(RecipeName))
table(zz1$RecipeName)

#Here, the 3 are normally the 2+1 and the "homemade" recipe. Check if no brand remaining
z3 <- subset(MonDF1, NOVA13==3)
zz3 <- subset(z3, !duplicated(RecipeName))
a <- table(zz3$RecipeName)
#write.xlsx(a, file="C:\\Users\\zoe_c\\OneDrive - The University of Liverpool\\ZOE PROJECT 2\\Datas\\BDD\\asupp.xlsx")

#Look at the "0" and classed them if possible
z0 <- subset(MonDF1, NOVA13==0)
zz0 <- subset(z0, !duplicated(RecipeName))
table(zz0$RecipeName)
b <- table(zz0$RecipeName)
#write.xlsx(b, file="C:\\Users\\zoe_c\\OneDrive - The University of Liverpool\\ZOE PROJECT 2\\Datas\\BDD\\asuppb.xlsx")


#Delete all the data create
rm(z10, zz10)
rm(z2, zz2)
rm(z12, zz12)
rm(z1, zz1)
rm(z3, zz3)
rm(z0, zz0)




#We decided that if no info make us thing that the recipe are in the group 4, they probably are in the group 3.
MonDF1$NOVA14 <- as.factor(ifelse(MonDF1$NOVA13=="12", "NC", MonDF1$NOVA13))

#Check
#table(MonDF1$NOVA13)
#table(MonDF1$NOVA14)

#create the final dataset;
MonDF3 <- subset(MonDF1, select = c(seriali, SurveyYear, DayNo, MealTime, FoodName, RecipeSubFoodGroupDesc, RecipeName, TotalGrams, NOVA14))
MonDF3$cc <- paste(MonDF3$seriali, MonDF3$SurveyYear, MonDF3$DayNo, MonDF3$MealTime, MonDF3$FoodName, MonDF3$RecipeSubFoodGroupDesc, MonDF3$RecipeName, MonDF3$TotalGrams)
MonDF3 <- subset(MonDF3, select=-c(seriali, SurveyYear, DayNo, MealTime, FoodName, RecipeSubFoodGroupDesc, RecipeName, TotalGrams))
#Check that the duplicated have the same NOVA group
#z <- subset(MonDF3, duplicated(cc))
#zz <- merge(x=MonDF3, y=z, by="cc", all.y = TRUE)
#zzz <- zz[NOVA14.x!=NOVA14.y,]
MonDF2 <- subset(MonDF3, !duplicated(cc))

test1 <- subset(test, select = -c(NOVA0:NOVA10))
# test1$nul <- "NA"
# test1$cc <- ifelse(test1$RecipeName!="", paste(test1$seriali, test1$SurveyYear, test1$DayNo, test1$MealTime, test1$FoodName, test1$RecipeSubFoodGroupDesc, test1$RecipeName, test1$TotalGrams),
#                                          paste(test1$seriali, test1$SurveyYear, test1$DayNo, test1$MealTime, test1$FoodName,  test1$RecipeSubFoodGroupDesc, test1$nul, test1$TotalGrams))
test1$cc <- paste(test1$seriali, test1$SurveyYear, test1$DayNo, test1$MealTime, test1$FoodName, test1$RecipeSubFoodGroupDesc, test1$RecipeName, test1$TotalGrams)
total2 <- merge(x=test1, y=MonDF2, by="cc", all.x = TRUE)
#Check that number of observation in total2 is equal to the one in test


total <- total2

total$NOVA <- as.factor(ifelse(is.na(total$NOVA14) & total$NOVA11=="NC", "NC",  
                        ifelse(is.na(total$NOVA14) & total$NOVA11=="1", "1",
                        ifelse(is.na(total$NOVA14) & total$NOVA11=="2", "2",
                        ifelse(is.na(total$NOVA14) & total$NOVA11=="3", "3",
                        ifelse(is.na(total$NOVA14) & total$NOVA11=="4", "4", 
                        ifelse(is.na(total$NOVA14) & total$NOVA11=="NA", "NA", 
                        ifelse(total$NOVA14=="NC", "NC",  
                        ifelse(total$NOVA14=="1", "1",
                        ifelse(total$NOVA14=="2", "2",
                        ifelse(total$NOVA14=="3", "3",
                        ifelse(total$NOVA14=="4", "4", "NA"))))))))))))    
#Check
#table(total$NOVA11, useNA="always")
#table(total$NOVA14, useNA="always")
#table(total$NOVA, useNA="always")



#Did some item, not in a recipe have no group?
zNA <- subset(total, NOVA_opti=="NA")    
zzNA <- subset(zNA, !duplicated(FoodName))
table(zzNA$FoodName)

zNA1 <- subset(total, NOVA_pessi=="NA")    
zzNA1 <- subset(zNA1, !duplicated(FoodName))
table(zzNA1$FoodName)


#Complete check
# zy1_8 <- subset(total, SurveyYear=="NDNS Year 1" | SurveyYear=="NDNS Year 2" | SurveyYear=="NDNS Year 3" | SurveyYear=="NDNS Year 4"
#                      | SurveyYear=="NDNS Year 5" | SurveyYear=="NDNS Year 6" | SurveyYear=="NDNS Year 7" | SurveyYear=="NDNS Year 8")    
# zy9_11 <- subset(total, SurveyYear=="NDNS Year 9" | SurveyYear=="NDNS Year 10" | SurveyYear=="NDNS Year 11")   
# 
# zy1_8 <- subset(zy1_8, select=c(FoodName, RecipeName, NOVA_opti, NOVA_pessi))
# zy1_8$aa <- paste(zy1_8$FoodName, zy1_8$RecipeName)
# zy1_8 <- subset(zy1_8, !duplicated(aa))
# zy9_11 <- subset(zy9_11, select=c(FoodName, RecipeName, NOVA_opti, NOVA_pessi))
# zy9_11$aa <- paste(zy9_11$FoodName, zy9_11$RecipeName)
# zy9_11 <- subset(zy9_11, !duplicated(aa))
# 
# write.xlsx(zy1_8, file="C:\\Users\\zoe_c\\OneDrive - The University of Liverpool\\ZOE PROJECT 2\\Datas\\NDNS NOVA\\zy1_8.xlsx")
# write.xlsx(zy9_11, file="C:\\Users\\zoe_c\\OneDrive - The University of Liverpool\\ZOE PROJECT 2\\Datas\\NDNS NOVA\\zy9_11.xlsx")



#Cleaning
total <- subset(total, select=-c(cc, NOVA11:NOVA14))

#write.csv(total, file="C:\\Users\\Zoe\\OneDrive - The University of Liverpool\\ZOE PROJECT 2\\Datas\\BDD\\ndns_rp_yrAll_NOVA.csv")
ndns_rp_yrAll_NOVA.new2023 <- total
archived(ndns_rp_yrAll_NOVA.new2023)

#NOVA CLASSIFICATION DATABASE 
#total <- read.csv(file = "C:\\Users\\Zoe\\OneDrive - The University of Liverpool\\ZOE PROJECT 2\\Datas\\BDD\\ndns_rp_yrAll_NOVA.csv")
total <- import(ndns_rp_yrAll_NOVA.new2023)

NDNS_NOVA_DATABASE.new2023 <- total %>% dplyr::select(FoodNumber,FoodName, SubFoodGroupCode, SubFoodGroupDesc,RecipeName,
                                              RecipeSubFoodGroupCode,RecipeSubFoodGroupDesc,NOVA) %>% distinct()
#write.csv(NDNS_NOVA_DATABASE, file="C:\\Users\\Zoe\\OneDrive - The University of Liverpool\\ZOE PROJECT 2\\Datas\\NDNS NOVA\\NDNS_NOVA_DATABASE.csv")
archived(NDNS_NOVA_DATABASE.new2023)


################################################################################
#                           2. Calculating the means                           #
################################################################################

#Daily intakes estimation
ndns_rp_yrAll_NOVA <- import(ndns_rp_yrAll_NOVA.new2023)
#Check
#table(ndns_rp_yrAll_NOVA$NOVA, useNA="a")


ndns_rp_yrAll_NOVA$AgeGroupRauber <- as.factor(ifelse(ndns_rp_yrAll_NOVA$Age<=18, "E", "A"))
ndns_rp_yrAll_NOVA$AgeGroupAdams <- as.factor(ifelse(ndns_rp_yrAll_NOVA$Age<18, "E", "A"))


weekend <- c("Saturday", "Sunday")
ndns_rp_yrAll_NOVA$rap_sem=1 * !ndns_rp_yrAll_NOVA$DayofWeek %in% weekend #*1 to have 1/0 instead of True/False
ndns_rp_yrAll_NOVA$rap_we=1 * ndns_rp_yrAll_NOVA$DayofWeek %in% weekend
#Check
#table(ndns_rp_yrAll_NOVA$rap_sem, ndns_rp_yrAll_NOVA$DayofWeek)
#table(ndns_rp_yrAll_NOVA$rap_we, ndns_rp_yrAll_NOVA$DayofWeek)
rm(weekend)



#Declaring the survey weight and strata
dw <- svydesign(ids = ~area, weights = ~ wti_UKY1to11, strata=~astrata1, data = ndns_rp_yrAll_NOVA)
#stratified on astrata1, with sampling weights wti_UKY1to11 
#The fpc variable contains the population size for the stratum, we don't have one (it seems) 


#Test
#z <- ndns_rp_yrAll_NOVA
#sum(z$Energykcal)
#svytotal(z$Energykcal, dw)
#mean(z$Energykcal)
#svymean(z$Energykcal, dw)
#freq(z$Sex, total = TRUE)
#tab <- svytable(~z$Sex, dw)
#freq(tab, total = TRUE)

# tapply(~z$Energykcal, ~z$Sex, sum)
# svyby(~z$Energykcal, ~z$Sex, dw, svytotal)


#Sum by year, person and day
essai1 <- ndns_rp_yrAll_NOVA %>% 
  group_by(seriali, SurveyYear, DayNo) %>%
  mutate(
    sumE = sum(Energykcal),
    sumG = sum(TotalGrams)
  ) %>%
  arrange(seriali, SurveyYear, DayNo)

# table(essai1$sumE, essai1$SurveyYear)
# table(essai1$sumE)


#Calculating the amount of Energy or grams bring by each NOVA group 
essai2 <- essai1 %>% 
  mutate(
    ENOVA1 = ifelse(NOVA=="1", Energykcal, 0),
    ENOVA2 = ifelse(NOVA=="2", Energykcal, 0),
    ENOVA3 = ifelse(NOVA=="3", Energykcal, 0),
    ENOVA4 = ifelse(NOVA=="4", Energykcal, 0),
    ENOVANC = ifelse(NOVA=="NC", Energykcal, 0),
    GNOVA1 = ifelse(NOVA=="1", TotalGrams, 0),
    GNOVA2 = ifelse(NOVA=="2", TotalGrams, 0),
    GNOVA3 = ifelse(NOVA=="3", TotalGrams, 0),
    GNOVA4 = ifelse(NOVA=="4", TotalGrams, 0),
    GNOVANC = ifelse(NOVA=="NC", TotalGrams, 0),
  ) 

gc()
essai2ter <- essai2 %>%
  group_by(seriali, SurveyYear) %>%
  mutate(
    moyg_sumE_raw = sum(Energykcal)/DiaryDaysCompleted,
    moyg_sumG_raw = sum(TotalGrams)/DiaryDaysCompleted
  ) %>%
  arrange(seriali, SurveyYear)

gc()
listvar0 <- c("ENOVA1", "ENOVA2", "ENOVA3", "ENOVA4", "ENOVANC", 
              "GNOVA1", "GNOVA2", "GNOVA3", "GNOVA4", "GNOVANC")
essai2qua <- essai2ter
essai2qua$groups <- paste(essai2qua$seriali, essai2qua$SurveyYear)
gc()
for (i in listvar0) {
  aa <- aggregate(essai2qua[[i]], by=list(essai2qua$seriali, essai2qua$SurveyYear), sum)
  aa$groups <- paste(aa$Group.1, aa$Group.2)
  aa <- subset(aa, select=-c(Group.1, Group.2))
  essai2qua <- merge(x=essai2qua, y=aa, by="groups", all.x = TRUE)
  rm(aa)
  essai2qua$x <- essai2qua$x/essai2qua$DiaryDaysCompleted
  essai2qua[[paste("moyg_sum", i, "_raw", sep = "")]] <- essai2qua$x
  essai2qua <- subset(essai2qua, select=-c(x))
}
rm(i)

gc()
#WEIGHT BY WEEK DAY
essai3 <- essai2qua
essai3$groups <- paste(essai3$seriali, essai3$SurveyYear, essai3$DayNo)
for (i in listvar0) {
  bb <- aggregate(essai3[[i]], by=list(essai3$seriali, essai3$SurveyYear, essai3$DayNo), sum)
  bb[[paste("sum", i, sep = "")]] <- bb$x
  bb$groups <- paste(bb$Group.1, bb$Group.2, bb$Group.3)
  bb <- subset(bb, select=-c(Group.1, Group.2, Group.3, x))
  essai3 <- merge(x=essai3, y=bb, by="groups", all.x = TRUE)
  essai3 <- select(essai3,-all_of(i))
  rm(bb)
}

essai3$dd <- paste(essai3$seriali, essai3$SurveyYear, essai3$DayNo)
essai4 <- subset(essai3, !duplicated(dd))
essai4 <- subset(essai4, select=-c(dd, MealTime:SubFoodGroupDesc, TotalGrams:Energykcal, RecipeName:NOVA))

essai5 <- essai4 %>%
  group_by(seriali, SurveyYear, DayNo) %>%
  mutate(
    sumENOVA = sum(sumENOVA1, sumENOVA2, sumENOVA3, sumENOVA4, sumENOVANC),
    sumGNOVA = sum(sumGNOVA1, sumGNOVA2, sumGNOVA3, sumGNOVA4, sumGNOVANC),
  ) %>%
  arrange(seriali, SurveyYear, DayNo)

   
#Check: sumE = sumENOVA / sumG = sumGNOVA
#z <- subset(essai5)
#z$dif0 <- z$sumENOVA - z$sumE
#z$dif2 <- z$sumGNOVA - z$sumG
#z <- subset(z, select=c(sumENOVA, sumGNOVA, sumE, sumG, dif0, dif2))
#zz <- subset(z, -0.1 > z$dif0 | z$dif0 > 0.1)
#zzz <- subset(z, -0.1 > z$dif2 | z$dif2 > 0.1)


essai6 <- essai5 %>% 
  group_by(seriali, SurveyYear) %>%
  mutate(
    nb_sem = sum(rap_sem),
    nb_we = sum(rap_we),
    nb_24 = sum(rap_sem+rap_we)
  ) %>%
  arrange(seriali, SurveyYear)
#Check
#table(essai6$nb_sem, useNA="always")
#table(essai6$nb_we, useNA="always")
#table(essai6$nb_24, useNA="always")

#Taking into account the weighting of the day of the week or the weekend
essai6$Type <- as.numeric(ifelse(essai6$nb_sem!=0 & essai6$nb_we!=0, 1,
                          ifelse(essai6$nb_sem==0 | essai6$nb_we==0, 2, 3)))
#Check no type 3
#table(essai6$Type, useNA="always")


#List of variable you want to use
listdo <- c("sumE", "sumENOVA1", "sumENOVA2", "sumENOVA3", "sumENOVA4", "sumENOVANC", 
            "sumG", "sumGNOVA1", "sumGNOVA2", "sumGNOVA3", "sumGNOVA4", "sumGNOVANC")
           
for (i in listdo) {
  essai6[[paste("pond_", i, sep = "")]] <- as.numeric(ifelse(essai6$Type==1, (essai6[[i]]*essai6$rap_sem*5/essai6$nb_sem) + (essai6[[i]]*essai6$rap_we*2/essai6$nb_we), 
                                                      ifelse(essai6$Type==2, essai6[[i]], NA)))
}

#Check no NA
#test <- subset(essai6, select=listdo)
#for (i in listdo) {
#  test[[paste("na_", i, sep = "")]] <- is.numeric(is.na(test[[paste("pond_", i, sep = "")]]))
#}
# test2 <- subset(test, select=c(na_sumE, 
#                                na_sumENOVA1, na_sumENOVA2, na_sumENOVA3, na_sumENOVA4, na_sumENOVANC, 
#                                na_sumG, 
#                                na_sumGNOVA1, na_sumGNOVA2, na_sumGNOVA3, na_sumGNOVA4, na_sumGNOVANC))
# table(test2)



listdo2 <- c("pond_sumE", 
             "pond_sumENOVA1", "pond_sumENOVA2", "pond_sumENOVA3", "pond_sumENOVA4", "pond_sumENOVANC", 
             "pond_sumG", 
             "pond_sumGNOVA1", "pond_sumGNOVA2", "pond_sumGNOVA3", "pond_sumGNOVA4", "pond_sumGNOVANC")


essai7 <- essai6 
essai7$groups <- paste(essai7$seriali, essai7$SurveyYear)
for (i in listdo2) {
  aa <- aggregate(essai7[[i]], by=list(essai7$seriali, essai7$SurveyYear), sum)
  aa[[paste("sp_", i, sep = "")]] <- aa$x
  aa$groups <- paste(aa$Group.1, aa$Group.2)
  aa <- subset(aa, select=-c(Group.1, Group.2, x))
  bb <- aggregate(essai7[[i]], by=list(essai7$seriali, essai7$SurveyYear), mean)
  bb[[paste("mean_", i, sep = "")]] <- bb$x
  bb$groups <- paste(bb$Group.1, bb$Group.2)
  bb <- subset(bb, select=-c(Group.1, Group.2, x))
  essai7 <- merge(x=essai7, y=aa, by="groups", all.x = TRUE)
  essai7 <- merge(x=essai7, y=bb, by="groups", all.x = TRUE)
  rm(aa, bb)
}

#Check no NA
#test <- subset(essai7, select=listdo3)
#for (i in listdo3) {
#  test[[paste("na_", i, sep = "")]] <- is.numeric(is.na(test[[i]]))
#}
#z <- data.frame(table(test2))


#test <- subset(essai7, select=listdo2)
#for (i in listdo2) {
#  test[[paste("na_mean", i, sep = "")]] <- is.numeric(is.na(test[[i]]))
#}
#listdona <- c("na_mean_pond_sumE", "na_mean_pond_sumENOVA1", "na_mean_pond_sumENOVA2", "na_mean_pond_sumENOVA3", "na_mean_pond_sumENOVA4", "na_mean_pond_sumENOVANC", 
#               "na_mean_pond_sumG", "na_mean_pond_sumGNOVA1", "na_mean_pond_sumGNOVA2", "na_mean_pond_sumGNOVA3", "na_mean_pond_sumGNOVA4", "na_mean_pond_sumGNOVANC")
#test3 <- subset(test, select=listdona)
#table(test3)




#Identifying extreme total dietary energy intake outliers as values above the 99th or below the 1st percentiles, for each survey day and age group 
#define quantiles of interest for Rauber study (see below in this code)
q <- c(.01, .99)

essai7bis <- essai7 %>%
  group_by(DayNo, AgeGroupRauber) %>%
  mutate(
    quant1 = quantile(sumE, probs = q[1]),
    quant99 = quantile(sumE, probs = q[2])
  ) 

essai7bis$Eoutliner_p1_99 <- as.numeric(ifelse(essai7bis$sumE < essai7bis$quant1 | essai7bis$sumE > essai7bis$quant99, 1, 0))

essai7bis <- essai7bis %>%
  group_by(seriali, SurveyYear) %>%
  mutate(
    nb_day_Eoutliner_p1_99 = sum(Eoutliner_p1_99)
  ) 

essai7bis$Eexclu_p1_99 <- as.numeric(ifelse(essai7bis$nb_day_Eoutliner_p1_99 == essai7bis$DiaryDaysCompleted, 1, 0))

#Check
#table(essai7bis$Eexclu_p1_99, essai7bis$SurveyYear)


listdo3 <- c("sp_pond_sumE", 
             "sp_pond_sumENOVA1", "sp_pond_sumENOVA2", "sp_pond_sumENOVA3", "sp_pond_sumENOVA4", "sp_pond_sumENOVANC", 
             "sp_pond_sumG", 
             "sp_pond_sumGNOVA1", "sp_pond_sumGNOVA2", "sp_pond_sumGNOVA3", "sp_pond_sumGNOVA4", "sp_pond_sumGNOVANC")


essai8 <- select(essai7bis,-groups)
for (i in listdo3) {
  j <- which(colnames(essai8) == i)+1
  essai8[[paste("moyg_", i, sep = "")]] <- as.numeric(ifelse(essai8$Type==1, essai8[[i]]/7, 
                                                      ifelse(essai8$Type==2, essai8[[j]], NA)))
  rm(j)
}

essai8$ee <- paste(essai8$seriali, essai8$SurveyYear)
essai9 <- subset(essai8, !duplicated(ee))
essai9 <- subset(essai9, select=-c(DayNo:DayofWeek, rap_sem:mean_pond_sumGNOVANC, ee))


listdo4 <- c("moyg_sp_pond_sumE", 
             "moyg_sp_pond_sumENOVA1", "moyg_sp_pond_sumENOVA2", "moyg_sp_pond_sumENOVA3", "moyg_sp_pond_sumENOVA4", "moyg_sp_pond_sumENOVANC", 
             "moyg_sp_pond_sumG", 
             "moyg_sp_pond_sumGNOVA1", "moyg_sp_pond_sumGNOVA2", "moyg_sp_pond_sumGNOVA3", "moyg_sp_pond_sumGNOVA4", "moyg_sp_pond_sumGNOVANC")

listdo5 <- c("moyg_sumE", 
             "moyg_sumENOVA1", "moyg_sumENOVA2", "moyg_sumENOVA3", "moyg_sumENOVA4", "moyg_sumENOVANC", 
             "moyg_sumG", 
             "moyg_sumGNOVA1", "moyg_sumGNOVA2", "moyg_sumGNOVA3", "moyg_sumGNOVA4", "moyg_sumGNOVANC")
setnames(essai9, old = listdo4, new = listdo5)

#Created the NOVA variables
essai10 <- essai9 %>%
  group_by(seriali, SurveyYear) %>%
  mutate(
    moyg_sumENOVA = sum(moyg_sumENOVA1, moyg_sumENOVA2, moyg_sumENOVA3, moyg_sumENOVA4, moyg_sumENOVANC),
    moyg_sumENOVA_withoutNC = sum(moyg_sumENOVA1, moyg_sumENOVA2, moyg_sumENOVA3, moyg_sumENOVA4),
    moyg_sumGNOVA = sum(moyg_sumGNOVA1, moyg_sumGNOVA2, moyg_sumGNOVA3, moyg_sumGNOVA4, moyg_sumGNOVANC),
    moyg_sumGNOVA_withoutNC = sum(moyg_sumGNOVA1, moyg_sumGNOVA2, moyg_sumGNOVA3, moyg_sumGNOVA4),
  ) %>%
  arrange(seriali, SurveyYear)

essai10$NOVA_Epct_1 <- (essai10$moyg_sumENOVA1/essai10$moyg_sumENOVA)*100
essai10$NOVA_Epct_withoutNC_1 <- (essai10$moyg_sumENOVA1/essai10$moyg_sumENOVA_withoutNC)*100

essai10$NOVA_Epct_2 <- (essai10$moyg_sumENOVA2/essai10$moyg_sumENOVA)*100
essai10$NOVA_Epct_withoutNC_2 <- (essai10$moyg_sumENOVA2/essai10$moyg_sumENOVA_withoutNC)*100

essai10$NOVA_Epct_3 <- (essai10$moyg_sumENOVA3/essai10$moyg_sumENOVA)*100
essai10$NOVA_Epct_withoutNC_3 <- (essai10$moyg_sumENOVA3/essai10$moyg_sumENOVA_withoutNC)*100

essai10$NOVA_Epct_4 <- (essai10$moyg_sumENOVA4/essai10$moyg_sumENOVA)*100
essai10$NOVA_Epct_withoutNC_4 <- (essai10$moyg_sumENOVA4/essai10$moyg_sumENOVA_withoutNC)*100

essai10$NOVA_Epct_NC <- (essai10$moyg_sumENOVANC/essai10$moyg_sumENOVA)*100


essai10$NOVA_Gpct_1 <- (essai10$moyg_sumGNOVA1/essai10$moyg_sumGNOVA)*100
essai10$NOVA_Gpct_withoutNC_1 <- (essai10$moyg_sumGNOVA1/essai10$moyg_sumGNOVA_withoutNC)*100

essai10$NOVA_Gpct_2 <- (essai10$moyg_sumGNOVA2/essai10$moyg_sumGNOVA)*100
essai10$NOVA_Gpct_withoutNC_2 <- (essai10$moyg_sumGNOVA2/essai10$moyg_sumGNOVA_withoutNC)*100

essai10$NOVA_Gpct_3 <- (essai10$moyg_sumGNOVA3/essai10$moyg_sumGNOVA)*100
essai10$NOVA_Gpct_withoutNC_3 <- (essai10$moyg_sumGNOVA3/essai10$moyg_sumGNOVA_withoutNC)*100

essai10$NOVA_Gpct_4 <- (essai10$moyg_sumGNOVA4/essai10$moyg_sumGNOVA)*100
essai10$NOVA_Gpct_withoutNC_4 <- (essai10$moyg_sumGNOVA4/essai10$moyg_sumGNOVA_withoutNC)*100

essai10$NOVA_Gpct_NC <- (essai10$moyg_sumGNOVANC/essai10$moyg_sumGNOVA)*100

#Check everything = 100
# z <- essai10
# z <- z %>%
#   group_by(seriali, SurveyYear) %>%
#   mutate(
#     test1 = sum(NOVA_Epct_1, NOVA_Epct_2, NOVA_Epct_3, NOVA_Epct_4, NOVA_Epct_NC),
#     test3 = sum(NOVA_Epct_withoutNC_1, NOVA_Epct_withoutNC_2, NOVA_Epct_withoutNC_3, NOVA_Epct_withoutNC_4))
#   ) %>%
#   arrange(seriali, SurveyYear)
# 
# zz <- subset(z, round(test1)!=100)
# zzzz <- subset(z, round(test3)!=100)



#Final dataset 
NDNS_final_data.new2023 <- essai10
archived(NDNS_final_data.new2023)

#Cleaning datasets
rm(essai, essai1, essai2, essai3, essai4, essai5, essai6, essai7, essai8, essai10)





