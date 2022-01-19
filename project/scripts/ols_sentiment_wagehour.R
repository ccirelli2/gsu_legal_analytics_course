# Clear Name space
rm(list=ls())

# Load Libraries
library(car)
library('fastDummies')
library("MASS")
library('ranger')


# Load Data
data <- read.csv('C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\project\\data\\ols_transformed_data.csv')
#View(data)

# Data Transformations
data$sent_score <- data$negative_wnh_txt + data$positive_wnh_txt
#View(data)
colnames(data)

# Plot Relationship Sentiment Score ~ AverageNetWorth



################################################################################
# Fit OLS - No Data Transformation
################################################################################

# Plot Relationship
scatterplot(data$sent_score ~ data$AverageNetWorth, data=data,
            main='Sentiment ~ Average Net Worth')

# Fit Model
model.ols<- lm(data$sent_score ~ data$AverageNetWorth)

summary(model.ols)


################################################################################
# Fit OLS - Log Avg NetWorth
################################################################################

# Transform Avg Net Worth - Get Log(x)
data.pos <- subset(data, data$AverageNetWorth > 0)
data.pos$LogAvgNetWorth <- log(data.pos$AverageNetWorth)
data.pos$sent_score_scaled <- scale(data.pos$sent_score)
data.pos$ScaleAvgNetWorth <- scale(data.pos$AverageNetWorth)

# Generate Plot Relationship - Sent ~ Log x
scatterplot(data.pos$sent_score ~ data.pos$LogAvgNetWorth, data=data.pos,
            main='Sentiment ~ Log Average Net Worth')

# Generate Plot Relationship - Sent_Scaled ~ Log x
scatterplot(data.pos$sent_score_scaled ~ data.pos$LogAvgNetWorth, data=data,
            main='Scaled Sentiment ~ Log Average Net Worth')

# Fit Model
model.ols.log<-lm(data.pos$sent_score ~ data.pos$LogAvgNetWorth)
summary(model.ols.log)


################################################################################
# Fit OLS - Log Avg NetWorth & Polynomials
################################################################################

# Create Variable
degree <- 2
data.pos$PolyAvgNetWorth <- data.pos$AverageNetWorth ^ degree

# Plot
plot(data.pos$sent_score, data.pos$PolyAvgNetWorth)

# Fit Model
model.ols.poly <- lm(data.pos$sent_score ~ data.pos$LogAvgNetWorth + I(data.pos$LogAvgNetWorth^degree), data=data.pos)
summary(model.ols.poly)



################################################################################
# Fit OSL - All Features
################################################################################

vars.ind <- c(colnames(data.pos)[5:65], 'LogAvgNetWorth')
y <- data.pos$sent_score
x <- data.pos[, vars.ind]


model.ols.allfeatures <- lm(y ~ ., data=x)
summary(model.ols.allfeatures)

################################################################################
# Fit OSL - All Features - Ridge
################################################################################
model.ols.allfeatures.ridge <- lm.ridge(data.pos$sent_score ~ data.pos$LogAvgNetWorth + data.pos$chamber_H + data.pos$chamber_S)









