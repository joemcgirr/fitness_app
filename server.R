library(shiny)
library(tidyverse)
library(googlesheets4)
library(shinydashboard)
library(DT)


googlesheets4::gs4_deauth()
ex_sheet <- read_sheet("https://docs.google.com/spreadsheets/d/1fKO_bNNdNoGZTVXRqa_QVI2Y7HNzSPpPRMUaKKcfsTg/edit#gid=0", sheet = "Exercises") %>% as.data.frame()

no.duplicate.exercises <- function(selected_muscle_group, selected_number_of_excersies, all_excersises) {
	
	mg_routine <- filter(all_excersises, muscle_group == selected_muscle_group) |>
		            sample_n(selected_number_of_excersies)
	
	while(any(duplicated(mg_routine$name))){
		
		mg_routine <- filter(all_excersises, muscle_group == selected_muscle_group) |>
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

		# get correct person for three_rep_max
		three_rep_max_person <- paste0('three_rep_max_', selected_person)
		all_excersises <- select(ex_sheet, c(name,	weight_type, three_rep_max_person, muscle_group,	video_link))
		
		# get the correct number of exercises for each muscle group
		if(length(selected_muscle_group) == 1){
		tab <- no.duplicate.exercises(selected_muscle_group[[1]], selected_number_of_excersies, all_excersises)
		}
		if(length(selected_muscle_group) == 2){
		tab1 <- no.duplicate.exercises(selected_muscle_group[[1]], selected_number_of_excersies, all_excersises)
		tab2 <- no.duplicate.exercises(selected_muscle_group[[2]], selected_number_of_excersies, all_excersises)
		tab <- rbind(tab1, tab2)
		}
		
		if(length(selected_muscle_group) == 3){
		tab1 <- no.duplicate.exercises(selected_muscle_group[[1]], selected_number_of_excersies, all_excersises)
		tab2 <- no.duplicate.exercises(selected_muscle_group[[2]], selected_number_of_excersies, all_excersises)
		tab3 <- no.duplicate.exercises(selected_muscle_group[[3]], selected_number_of_excersies, all_excersises)
		tab <- rbind(tab1, tab2, tab3)
		}
		
		# get correct weight, reps, and rest times for training type
		one_rep_max <- tab[[three_rep_max_person]] / 0.93

		if(selected_training == "power"){
			tab$weight <- round(one_rep_max * 0.87)
			tab$reps <- 5
			tab$rest_time <- "4 minutes"
		}
		
		if(selected_training == "gains"){
			tab$weight <- round(one_rep_max * 0.8)
			tab$reps <- 8
			tab$rest_time <- "1 minute"
		}
		
		if(selected_training == "endurance"){
			tab$weight <- round(one_rep_max * 0.70)
			tab$reps <- 12
			tab$rest_time <- "45 seconds"
		}

		# make links clickable
		tab$video_link <- paste0("<a href='",tab$video_link,"' target='_blank'>",tab$video_link,"</a>")
		
		tab <- select(tab, c(name, weight_type, weight, reps, rest_time, muscle_group, video_link)) |>
			     arrange(muscle_group)
		
		datatable(tab, escape = FALSE, options = list(dom = 't')) 
	
	})
	
}
	

# https://shiny.rstudio.com/tutorial/written-tutorial/lesson7/
# https://mastering-shiny.org/basic-ui.html#inputs

# library(shiny)
# runApp()
# library(rsconnect)
# deployApp()



