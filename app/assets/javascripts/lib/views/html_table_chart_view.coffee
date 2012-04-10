class @HtmlTableChartView extends BaseChartView
  initialize : ->
    @initialize_defaults()

  render : =>
    @clear_container()
    @container_node().html(@table_html())
    @fill_cells()
    # sort rows on merit order chart
    @merit_order_sort() if @model.get("id") == 116

  # The table HTML is provided by the rails app. It is stored in the
  # window.charts object, a hash that contains the markup of the table.
  # Being stored in a hash, we can save the markup of multiple tables
  # and eventually show multiple tables at the same time
  #
  table_html: ->
    charts.html[@model.get("id")]

  # normal charts have their series added when the /output_element/X.js
  # action is called. Tables have the gqueries defined in the markup instead.
  # This method will parse the HTML and create the gqueries as needed.
  # See charts#load to see this method in action.
  #
  build_gqueries: =>
    html = $(@table_html())
    for cell in html.find("td[data-gquery]")
      gquery = $(cell).data('gquery')
      @model.series.add({gquery_key: gquery})

  # The table is already in the DOM; let's find the cells whose content
  # is the result of a gquery and write the output
  #
  fill_cells: ->
    for cell in @dynamic_cells()
      gqid = $(cell).data('gquery')
      serie = @model.series.with_gquery(gqid)
      if !serie
        console.warn "Missing gquery: #{gqid}"
        return
      raw_value = serie.future_value()
      value = Metric.round_number(raw_value, 1)
      $(cell).html(value)

  # returns a jQuery collection of cells to be dynamically filled
  dynamic_cells: ->
    @container_node().find("td[data-gquery]")

  can_be_shown_as_table: -> false

  merit_order_sort: =>
    rows = _.sortBy $("##{@container_id()} tbody tr"), @merit_order_position
    # get rid of rows with merit order of 1000. See ETE#193.
    # Ugly solution until we use better gqueries
    rows = _.reject rows, (item) => @merit_order_position(item) == 1000
    @container_node().find("tbody").html(rows)

  # custom method to sort merit order table
  # DEBT: this should be resolved at gquery level
  merit_order_position: (item) ->
    parseInt($(item).find("td:first").text())