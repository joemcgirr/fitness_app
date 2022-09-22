library(shiny)
library(tidyverse)
library(googlesheets4)
library(shinydashboard)
library(DT)

googlesheets4::gs4_deauth()
ex_sheet <- read_sheet("https://docs.google.com/spreadsheets/d/1fKO_bNNdNoGZTVXRqa_QVI2Y7HNzSPpPRMUaKKcfsTg/edit#gid=0", sheet = "Exercises") %>% as.data.frame()

muscle_groups <- c(
	"Upper Body" = "upper body",
	"Lower Body" = "lower body",
	"Core"       = "core"
)

power_couple <- c(
	"Dr. Kimiko McGirr" = "kimiko",
	"Dr. Joe McGirr"    = "joe"
)

training_types <- c(
	"Endurance"                        = "endurance",
	"Gains (sarcoplasmic hypertrophy)" = "gains",
	"Power (myofibril hypertrophy)"    = "power"
)

ui <- dashboardPage(
	
  dashboardHeader(title = "Exercise Routines"),
  dashboardSidebar(),
	
  dashboardBody(
  	
  	
  	fluidPage(
  		
  		#sidebarPanel(
      #selectInput("selectedCrag", h4("Crag"), choices = as.list(sort(locations$crag)), selected = "Mickey's Beach"),
      #width = 4)
  		
  		radioButtons("selected_person",
            label = "Which member of the power couple are you?",
            choices = power_couple,
  					selected = c("kimiko")),
  		
  		radioButtons("selected_training",
            label = "What type of training do you want to do?",
            choices = training_types,
  					selected = c("endurance")),
  		
  		sliderInput("selected_number_of_excersies",
            label = "How many exercises do you want in each set?",
            min = 1,
  					max = 15,
  					value = 2,
  					step = 1,
  					width = "100%"),
  		
  	  checkboxGroupInput("selected_muscle_group",
                  label = "Which muscle groups do you want to target? (select all that apply)", 
                  choices = muscle_groups,
  	  						selected = c("upper body"))
  		
     ),
  	

  	
  	fluidRow(

  		mainPanel(DTOutput(outputId = "routine_table"))
  		#mainPanel(tableOutput('routine_table'))


  	)
  	
  	
  )	
)
