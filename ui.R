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
  dashboardSidebar(
  	
  	titlePanel("Workout options:"),

  	fluidPage(

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
  					max = 20,
  					value = 5,
  					step = 1,
  					width = "100%"),

  	  checkboxGroupInput("selected_muscle_group",
                  label = "Which muscle groups do you want to target? (select all that apply)",
                  choices = muscle_groups,
  	  						selected = c("upper body"))

     )

  	
  ),
	
  dashboardBody(
  	
 	
  	#titlePanel("Your workout:"),
  	
  	fluidRow(
  		
  		box(title = "Training Suggestion", status = "primary", solidHeader = TRUE, width = 12,

  		
				infoBoxOutput("reps_box"),
				infoBoxOutput("rest_box")
  		)
    ),


  	fluidRow(
  		
  		#titlePanel("Your workout:"),
		
  			mainPanel(DTOutput(outputId = "routine_table"))
  			
  	),
		
		
		fluidRow(

  		box(title = "Archive Completed Workout", status = "primary", solidHeader = TRUE, width = 12,

  			a(h4("Google sheets link", class = "btn btn-default action-button" , 
    			style = "fontweight:600"), target = "_blank",
    			href = paste0("https://docs.google.com/spreadsheets/d/1fKO_bNNdNoGZTVXRqa_QVI2Y7HNzSPpPRMUaKKcfsTg/edit#gid=0"))
  			
  			)
  		
  	)
		


  	
  )	
)
