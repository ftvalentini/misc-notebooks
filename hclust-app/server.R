
server = function(input, output, session) {

    dat_normalized = eventReactive(input$run, {
        dat_filtered = select_vars(dat, input$variables)
        normalize_data(dat_filtered, input$normalization)
    },ignoreNULL=F)
    
    diss_data = eventReactive(input$run, {
        diss_matrix(dat_normalized(), input$distance)
    },ignoreNULL=F)
    
    output$cophenetic = renderTable({
        cophenetic_distances(diss_data())
    })
    
    output$elbow = renderPlot({
        elbow_plot(dat_normalized(), diss_data()
                   , isolate(input$distance), isolate(input$linkage))
    })
    
    output$gap = renderPlot({
        gap_plot(dat_normalized(), diss_data()
                   , isolate(input$distance), isolate(input$linkage))
    })
    
    output$avg_silhouette = renderPlot({
        avg_silhouette_plot(dat_normalized(), diss_data()
                   , isolate(input$distance), isolate(input$linkage))
    })
    
    hc = eventReactive(input$run_k, {
        hc_cut(dat_normalized(), input$k, input$distance, input$linkage)
    },ignoreNULL=T)
    
    cluster_details = eventReactive(input$run_k, {
        hc_details(hc())
    })
    
    output$cluster_details = renderDataTable({
       tabla = cluster_details()
       tabla
       # DT::datatable(tabla, options=list(pageLength=20))
    })
    
    output$silhouette = renderPlotly({
        plt = silhouette_plot(hc())
        ggplotly(plt)
    })
    # output$boxplots = renderPlot({
    #     cluster_boxplots(dat_normalized(), cluster_details())
    # })
    
    output$densities = renderPlot({
        plt = cluster_densities(dat_normalized(), cluster_details())
        plt
    })
    
    output$metadata = renderDataTable({
        tabla = read_csv("data/worldbank_metadata.csv")
        tabla = bind_cols(variable=VARIABLES, tabla)
        tabla
    })
    
}



    
        
