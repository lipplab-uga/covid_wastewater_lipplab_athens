#Not used Code Dump


##From plot script
```{r}
plotly_p <- ggplotly(clean_plot)

marker_colors <- c("#1B9E77", "#D95F02")


plotly_p <- plotly_p %>% plotly::add_trace(x = ~date, y = ~log_copy_per_L,
                                           type = "scatter",
                                           mode = "markers",
                                           shape = ~Facility,
                                           yaxis = "y2", 
                                           colors = marker_colors,
                                           data = final_data, 
                                           showlegend = FALSE) %>%
  layout(yaxis2 = list(overlaying = "y", 
                       side = "right",
                       automargin = TRUE,
                       showticklabels = TRUE,
                       showgrid = TRUE,
                       showline = TRUE,
                       tickfont = list(size=11.7),
                       titlefont=list(size=14.6),
                       title="SARS CoV-2 Log Copies Per L", 
                       range = c(0,8)))%>%
  layout(legend = list(orientation = "h", x = 0.2, y = -0.3))

plotly_p
```

```{r}
save(plotly_p, file = "./plotly_fig.rda")
```
## from index
<div style="margin-bottom:50px;">
  </div>
  
  Testing out a plotly also, need a bit more work if we like it

```{r out.height = "100%", out.width = "100%", echo=FALSE, message=FALSE, warning=FALSE}
load(file = "./plotly_fig.rda")
plotly_p
```


###results section

### Results

Main Figure (again)

Total Viral Load 

Number of Assays positive/week



### For trendlines with mean values
plotly::add_trace(x = ~date, y = ~mean_copy_num_L,
                  type = "scatter",
                  mode = "lines",
                  data = trend1,
                  showlegend = FALSE,
                  opacity = 0.5,
                  line = list(color = '#1B9E77')) %>%
  
  plotly::add_trace(x = ~date, y = ~mean_copy_num_L,
                    type = "scatter",
                    mode = "lines",
                    data = trend2,
                    showlegend = FALSE,
                    opacity = 0.5,
                    line = list(color = '#D95F02'))



### to move start date up

```{r}
only_background_2 <- subset(only_background, date > as.Date("2020-05-20"))
```


```{r}
p2 <- only_background_2 %>%
  plotly::plot_ly() %>%
  plotly::add_trace(x = ~date, y = ~new_cases_clarke, 
                    type = "bar", 
                    alpha = 0.5,
                    name = "Daily Reported Cases",
                    color = background_color,
                    colors = background_color) %>%
  layout(yaxis = list(title = "Clarke County Daily Cases", range = c(0,80), showline=TRUE)) %>%
  layout(legend = list(orientation = "h", x = 0.2, y = -0.3))

#renders the main plot layer two as ten day moving average
p2 <- p2 %>% plotly::add_trace(x = ~date, y = ~X10_day_ave_clarke, 
                               type = "scatter",
                               mode = "lines",
                               name = "Ten Day Moving Average Athens",
                               colors = ten_day_ave_color)

#renders the main plot layer three as positive target hits
p2 <- p2 %>% plotly::add_trace(x = ~date, y = ~log_copy_per_L,
                               type = "scatter",
                               mode = "markers",
                               data = only_positives,
                               colors = marker_colors,
                               symbol = ~Facility,
                               yaxis = "y2") %>%
  layout(yaxis2 = list(overlaying = "y", side = "right", title = "SARS CoV-2 Log Copies Per L", range = c(0, 8), showline = TRUE)) %>%
  layout(legend = list(orientation = "h", x = 0.2, y = -0.3))

p2
```

```{r}
save(p2, file = "./plotly_fig_2.rda")
```
