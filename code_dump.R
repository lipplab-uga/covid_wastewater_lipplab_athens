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



###Smoothing figs
```{r}
#create smothing data frames for loess
#n1
smooth_n1 <- only_n1 %>% select(-c(Facility)) %>% 
  group_by(date, cases_cum_clarke, new_cases_clarke, X10_day_ave_clarke, cases_per_100000_clarke) %>%
  summarize(sum_copy_num_L = sum(mean_copy_num_L)) %>%
  ungroup() %>%
  mutate(log_sum_copies_L = log10(sum_copy_num_L))

#n2
smooth_n2 <- only_n2 %>% select(-c(Facility)) %>% 
  group_by(date, cases_cum_clarke, new_cases_clarke, X10_day_ave_clarke, cases_per_100000_clarke) %>%
  summarize(sum_copy_num_L = sum(mean_copy_num_L)) %>%
  ungroup() %>%
  mutate(log_sum_copies_L = log10(sum_copy_num_L))

sumfit_1 <- loess(log_sum_copies_L ~ new_cases_clarke, data = smooth_n1, span = 0.8)
sumfit_2 <- loess(log_sum_copies_L ~ new_cases_clarke, data = smooth_n2, span = 0.8)

p3 <- plotly::plot_ly() %>%
  plotly::add_trace(x = ~date, y = ~log_sum_copies_L,
                    type = "scatter",
                    mode = "markers",
                    hoverinfo = "text",
                    text = ~paste('</br> Date: ', date,
                                  '</br> Copies/L: ', round(sum_copy_num_L, digits = 2)),
                    data = smooth_n1,
                    marker = list(color = '#1B9E77', size = 8, opacity = 0.65),
                    showlegend = FALSE) %>%
  plotly::add_trace(x = ~date, y = ~log_sum_copies_L,
                    type = "scatter",
                    mode = "markers",
                    hoverinfo = "text",
                    text = ~paste('</br> Date: ', date,
                                  '</br> Copies/L: ', round(sum_copy_num_L, digits = 2)),
                    data = smooth_n2,
                    marker = list(color = '#D95F02', size = 8, opacity = 0.65),
                    showlegend = FALSE) %>%
  plotly::add_lines(x = ~date, y = predict(sumfit_1),
                    data = smooth_n1,
                    hoverinfo = "text",
                    text = NULL,
                    showlegend = FALSE,
                    line = list(color = '#1B9E77')) %>%
  plotly::add_lines(x = ~date, y = predict(sumfit_2),
                    data = smooth_n2,
                    hoverinfo = "text",
                    text = NULL,
                    showlegend = FALSE,
                    line = list(color = '#D95F02'))


p3
```

```{r}
ddd <- smooth_n1 %>% ggplot() + geom_smooth(aes(x = date, y = log_sum_copies_L), span = 0.8)
ddd
```








#fit smoothing to loess function and predict values for standard error
sumfit_1 <- loess(log_sum_copies_L ~ new_cases_clarke, data = smooth_n1, span = 0.95)
sumfit_2 <- loess(log_sum_copies_L ~ new_cases_clarke, data = smooth_n2, span = 0.95)
pred_1 <- predict(sumfit_1, se = TRUE)
pred_2 <- predict(sumfit_2, se = TRUE)

#combine fits/predictions into a dataframe
smooth_df_n1 <- data.frame(x = sumfit_1$x, fit = pred_1$fit, 
                           ymin = pred_1$fit - (1.96 * pred_1$se.fit), 
                           ymax = pred_1$fit + (1.96 * pred_1$se.fit))
#smooth_df_n1 <- smooth_df_n1[order(smooth_df_n1$date)]


p3 <- p3 %>%  plotly::add_ribbons(data = augment(sumfit_1),
                                  x = ~date,
                                  ymin = ~.fitted - 1.96 * .se.fit,
                                  ymax = ~.fitted + 1.96 * .se.fit,
                                  line = list(color = 'rgba(7, 164, 181, 0.05)'),
                                  fillcolor = 'rgba(7, 164, 181, 0.2)',
                                  name = "Standard Error")
