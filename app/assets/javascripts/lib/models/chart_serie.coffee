class @ChartSerie extends Backbone.Model
  initialize : ->
    gquery = gqueries.find_or_create_by_key @get('gquery_key')
    @set {gquery : gquery}

  result: -> @get('gquery').result()

  result_pairs: -> [@present_value(), @future_value()]

  future_value: -> @result()[1][1]

  present_value: -> @result()[0][1]

class @ChartSeries extends Backbone.Collection
  model : ChartSerie

  with_gquery: (gquery) ->
    @find (s) -> s.get('gquery').get('key') == gquery

  gqueries: =>
    @map (s) -> s.get('gquery')
