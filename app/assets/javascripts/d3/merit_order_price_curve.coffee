D3.merit_order_price_curve =
  View: class extends D3YearlyChartView
    initialize: ->
      D3YearlyChartView.prototype.initialize.call(this)

    draw: ->
      @average = new ChartSerie(
        color: "#CC0000",
        label: I18n.t("output_element_series.merit_price_average")
      )

      @legendSeries = @model.non_target_series()
      @legendSeries.push(@average)

      @drawChart()
      @dateSelect.setVal(1)

      @drawLegend(@legendSeries, 1)

    averageData: (data) ->
      color:  @average.attributes.color,
      label:  @average.attributes.label,
      key:    'average',
      values: Array.apply(null, Array(8760)).map(
        Number.prototype.valueOf, d3.mean(data[0].values.slice()))

    dataForChart: ->
      data = @model.non_target_series().map(@getSerie)
      data.push(@averageData(data))
      data

    drawData: (xScale, yScale, line) ->
      @svg.selectAll('path.serie')
        .data(@chartData)
        .enter()
        .append('g')
        .attr('id', (data, index) -> "path_#{ index }")
        .attr('class', 'serie line')
        .append('path')
        .attr('d', (data) -> line(data.values) )
        .attr('stroke', (data) -> data.color )
        .attr('stroke-width', 2)
        .attr('fill', 'none')
        .style("shape-rendering", "crispEdges")
        .style("stroke-dasharray", (d) ->
          if d.key == "average" then "3,3" else ""
        )

    line: (xScale, yScale) ->
      d3.svg.line()
        .x((data) -> xScale(data.x))
        .y((data) -> yScale(data.y))
        .interpolate('step-after')

    refresh: ->
      super

      @chartData = @convertData()

      xScale = @createTimeScale(@dateSelect.getCurrentRange())
      yScale = @createLinearScale()
      line   = @line(xScale, yScale)

      @svg.select(".x_axis").call(@createTimeAxis(xScale))
      @svg.select(".y_axis").call(@createLinearAxis(yScale))

      if @container_node().find("g.serie.line").length > 0
        @svg.selectAll('g.serie.line')
          .data(@chartData)
          .select('path')
          .attr('d', (data) -> line(data.values) )
      else
        @drawData(xScale, yScale, line)

    maxYvalue: ->
      d3.max(@rawChartData[0].values)
