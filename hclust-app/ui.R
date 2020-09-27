
ui1_wrapper = function() {
    fluidRow(
        column(3
               ,wellPanel(
                   checkboxGroupInput("variables", "Select variables to use", VARIABLES
                                      ,selected=VARIABLES)
                   ,radioButtons("normalization", "Select normalization type", NORMALIZATIONS)
                   ,radioButtons("distance", "Select distance metric", DISTANCES)
                   ,radioButtons("linkage", "Select linkage method", LINKAGES)
               )
        )
        ,column(1
                ,actionButton("run", "Run")
        )
        ,column(8
                ,h4("Cophenetic Distance")
                ,tableOutput("cophenetic")
                ,h4("Optimal K")
                ,mainPanel(
                    tabsetPanel(
                        tabPanel("Elbow", br(), plotOutput("elbow"))
                        ,tabPanel("Gap", br(), plotOutput("gap"))
                        ,tabPanel("Avg. Silhouette", br(), plotOutput("avg_silhouette"))
                    )
                )
        )
    )
} 

ui2_wrapper = function() {
    fluidRow(
        column(3
               ,wellPanel(
                   numericInput("k", "Number of clusters", value=2, min=1, max=30)
               )
        )
        ,column(1
                ,actionButton("run_k", "Run")
        )
        ,column(8
                ,mainPanel(
                    tabsetPanel(
                        tabPanel("Silhouette", br(), plotlyOutput("silhouette"))
                        ,tabPanel("Details", br(), dataTableOutput("cluster_details"))
                        ,tabPanel("Distributions", br(), plotOutput("densities"))
                    )
                )
        )
    )
} 


ui = fluidPage(
    theme = shinytheme("flatly")
    ,navbarPage("Hierarchical Clustering"
                ,tabPanel("Overview", ui1_wrapper()
                )
                ,tabPanel("Choosing K", ui2_wrapper()
                )
                ,tabPanel("About"
                          ,includeMarkdown("about.md")
                          ,hr()
                          ,dataTableOutput("metadata")
                )
    ))
