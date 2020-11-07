library(shiny)
library(ggplot2)
library(dplyr)
library(DT)

shinyServer(function(input, output) {
    
    color_graph <- reactiveVal("black")
    df <- reactiveVal(mtcars)
    brush_dt <- reactiveVal("True")
    
    output$grafica_base_r <- renderPlot({
        plot(mtcars$wt, 
             mtcars$mpg, 
             xlab = "Peso del vehículo",
             ylab = "Millas por galón")
    })
    output$grafica_ggplot <- renderPlot({
        diamonds %>%
            sample_n(10000) %>%
            ggplot(aes(x = carat, y = price, color=color)) +
            geom_point() +
            ylab("Precio") +
            xlab("Kilates") +
            ggtitle("Precio de diamantes por kilate")
    })
    
    output$plot_click_options <- renderPlot({
        plot(mtcars$wt,
             mtcars$mpg,
             xlab = "Peso del vehículo",
             ylab = "Millas por galón",
             col = color_graph(),
             pch = 19)
        points(df()$wt, df()$mpg, col="red", pch = 19)
 
    })
    
    output$click_data <- renderPrint({
        clk_msg <- NULL
        dclk_msg <- NULL
        mhover_msg <- NULL
        mbrush <- NULL
        if (!is.null(input$clk$x)){
            clk_msg <- paste0("Click coordenada x = ",
                              round(input$clk$x,2),
                              " Click coordenada y = ",
                              round(input$clk$y,2))
            color_graph("green")
            df(nearPoints(mtcars, input$clk, xvar = "wt", yvar = "mpg"))
        }
        if (!is.null(input$dclk$x)){
            dclk_msg <- paste0("Doble click coordenada x = ",
                               round(input$dclk$x,2),
                               "Doble click coordenada y = ",
                               round(input$dclk$y,2))
            color_graph("black")
        }
        if (!is.null(input$mhover$x)){
            mhover_msg <- paste0("Hover coordenada x = ",
                                 round(input$mhover$x,2),
                                 "Doble click coordenada y = ",
                                 round(input$mhover$y,2))
            color_graph("gray")
        }
        if (!is.null(input$mbrush$xmin)){
            brushx <- paste0("(",
                             input$mbrush$xmin,
                             ",",
                             input$mbrush$xmax)
            brushy <- paste0("(",
                             input$mbrush$ymin,
                             ",",
                             input$mbrush$ymax)
            mbrush_msg <- cat("Rango en x = ",
                              brushx,
                              "\n",
                              "Rango en y = ",
                              brushy,
                              "\n")
            df(brushedPoints(mtcars, input$mbrush, xvar = "wt", yvar = "mpg"))
        }
        cat(clk_msg, dclk_msg, mhover_msg, mbrush, sep = "\n")
        
        output$mtcars_out <- DT::renderDataTable({
            if(nrow(df()) != 0){
                df()
            }else{
                NULL
            }
        })
        
    })
    
})