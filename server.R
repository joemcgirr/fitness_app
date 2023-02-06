library(shiny)
library(tidyverse)
library(googlesheets4)
library(shinydashboard)
library(DT)
library(plyr)

googlesheets4::gs4_deauth()
ex_sheet <- read_sheet("https://docs.google.com/spreadsheets/d/1fKO_bNNdNoGZTVXRqa_QVI2Y7HNzSPpPRMUaKKcfsTg/edit#gid=0", sheet = "Exercises") %>% as.data.frame()

no.duplicate.exercises <- function(selected_muscle_group, selected_number_of_excersies, all_exercises) {
	
	mg_routine <- filter(all_exercises, muscle_group == selected_muscle_group) |>
		            sample_n(selected_number_of_excersies)
	
	while(any(duplicated(mg_routine$name))){
		
		mg_routine <- filter(all_exercises, muscle_group == selected_muscle_group) |>
		            sample_n(selected_number_of_excersies)	
		
	}
	return(mg_routine)
}




server <- function(input, output, session) {
	
	output$routine_table <- renderDataTable({
		
		selected_person              <- input$selected_person
		selected_training            <- input$selected_training
		selected_number_of_excersies <- input$selected_number_of_excersies
		selected_muscle_group        <- input$selected_muscle_group
		
		# selected_person              <- "joe"
		# selected_training            <- "endurance"
		# selected_number_of_excersies <- 5
		# selected_muscle_group        <- "lower body"

		# get correct person for three_rep_max and exclude undesired exercises
		three_rep_max_person <- paste0('three_rep_max_', selected_person)
		exclude_column <- paste0('exclude_', selected_person)
		#all_exercises <- #select(ex_sheet, c(name,	weight_type, three_rep_max_person, muscle_group,	video_link)) |>
		all_exercises <- filter(ex_sheet, !!as.symbol(exclude_column) != "TRUE")
		
		# get the correct number of exercises for each muscle group
		if(length(selected_muscle_group) == 1){
		tab <- no.duplicate.exercises(selected_muscle_group[[1]], selected_number_of_excersies, all_exercises)
		}
		if(length(selected_muscle_group) == 2){
		tab1 <- no.duplicate.exercises(selected_muscle_group[[1]], selected_number_of_excersies, all_exercises)
		tab2 <- no.duplicate.exercises(selected_muscle_group[[2]], selected_number_of_excersies, all_exercises)
		tab <- rbind(tab1, tab2)
		}
		
		if(length(selected_muscle_group) == 3){
		tab1 <- no.duplicate.exercises(selected_muscle_group[[1]], selected_number_of_excersies, all_exercises)
		tab2 <- no.duplicate.exercises(selected_muscle_group[[2]], selected_number_of_excersies, all_exercises)
		tab3 <- no.duplicate.exercises(selected_muscle_group[[3]], selected_number_of_excersies, all_exercises)
		tab <- rbind(tab1, tab2, tab3)
		}
		
		# get correct weight, reps, and rest times for training type
		one_rep_max <- tab[[three_rep_max_person]] / 0.93

		if(selected_training == "power"){
			tab$total_weight <- round(one_rep_max * 0.87)
			tab$reps <- 5
			tab$rest_time <- "4 minutes"
		}
		
		if(selected_training == "gains"){
			tab$total_weight <- round(one_rep_max * 0.8)
			tab$reps <- 8
			tab$rest_time <- "1 minute"
		}
		
		if(selected_training == "endurance"){
			tab$total_weight <- round(one_rep_max * 0.70)
			tab$reps <- 12
			tab$rest_time <- "45 seconds"
		}

		# make links clickable
		tab$video_link <- paste0("<a href='",tab$video_link,"' target='_blank'>",tab$video_link,"</a>")
		
		#add date
		tab$date <- Sys.Date()
		
		# create plate weight column
		tab <- mutate(tab, rounded_plate_weight = case_when(weight_type == 'barbell' ~ round_any((total_weight - 45)/2,5), 
																												weight_type == 'dumbbell' ~ round_any(total_weight/2,5)))
		# create final table	
		tab <- select(tab, c(muscle_group, name, total_weight, rounded_plate_weight, weight_type, video_link, reps, rest_time, date)) |>
			     arrange(muscle_group, weight_type) |>
			     mutate(total_weight = ifelse(weight_type %in% c("barbell","dumbbell"), total_weight, weight_type))
		
		datatable(tab, escape = FALSE, 
							extensions = c("Buttons"),
							options = list(
              "dom" = 'tB',
              buttons = list(list(extend = 'copy', title = NULL)),
              pageLength = 50),
							rownames = FALSE)
	
	})
	


	output$reps_box <- renderInfoBox({
		
		selected_training <- input$selected_training
		if(selected_training == "power"){reps <- 5}
		if(selected_training == "gains"){reps <- 8}
		if(selected_training == "endurance"){reps <- 12}

		infoBox("Reps", 
						reps, 
						icon = icon("dumbbell"),
            color = "blue"
    )
  })
	
	output$rest_box <- renderInfoBox({
		
		selected_training <- input$selected_training
		if(selected_training == "power"){rest_time <- "4 minutes"}
		if(selected_training == "gains"){rest_time <- "1 minute"}
		if(selected_training == "endurance"){rest_time <- "45 seconds"}

		infoBox("Rest time", 
						rest_time, 
						icon = icon("bed"),
            color = "blue"
    )
  })
	
}
	

# https://shiny.rstudio.com/tutorial/written-tutorial/lesson7/
# https://mastering-shiny.org/basic-ui.html#inputs
# https://rstudio.github.io/shinydashboard/structure.html#infobox

# library(shiny)
# runApp()
# library(rsconnect)
# deployApp()



