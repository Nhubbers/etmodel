@Metric =
  parsed_unit : (value, unit) ->

    if (unit == "MT")
      start_scale = 2
    else if (unit == "euro")
      # quick ugly fix
      unit == "EUR"
      start_scale = 0
    else
      start_scale = 3

    scale = Metric.scaled_scale(value, start_scale);

    if (unit == 'PJ')
      if (scale >= 3 && scale < 5) then scale = 3
      return Metric.scaling_in_words(scale, 'joules')
    else if (unit == 'MT')
      return Metric.scaling_in_words(scale, 'ton')
    else if (unit == 'EUR')
      return Metric.scaling_in_words(scale, 'currency')
    else if (unit == 'MW')
      return Metric.scaling_in_words(scale, 'watt')
    else if (unit == '%')
      return '%'
    else
      return Metric.scaling_in_words(scale, unit)

  scaled: (value, start_scale, target_scale, max_scale) ->
    scale = start_scale || 0
    target = target_scale || null
    min_scale = 0
    max_scale = max_scale || 100;

    if (!target)
      while (value >= 0 && scale < max_scale)
        value = value / 1000
        scale = scale + 1
      while (value < 1 && scale > min_scale)
        value = value * 1000
        scale = scale - 1
    else
      diff = target - scale
      i = Math.abs(diff)
      while i > 0
        if (diff < 0)
          value = value * 1000
          scale = scale - 1
        else
          value = value / 1000
          scale = scale + 1
        i--
    return [parseInt(scale), value]

  scaled_scale: (value, start_scale, target_scale, max_scale) ->
    return this.scaled(value, start_scale, target_scale, max_scale)[0]

  scaled_value: (value, start_scale, target_scale, max_scale) ->
    return this.scaled(value, start_scale, target_scale, max_scale)[1]

  # Translates a scale to a words:
  #  1000 ^ 1 = thousands
  #  1000 ^ 2 = millions
  #  etc.
  #
  # @param scale [Float] The scale that must be translated into a word
  # @param unit [String] The unit - currently {currency|joules|nounit|ton}
  # Add other units on config/locales/{en|nl}.yml
  scaling_in_words: (scale, unit) ->
    scale_symbols =
      "0" : 'unit'
      "1" : 'thousands'
      "2" : 'millions'
      "3" : 'billions'
      "4" : 'trillions'
      "5" : 'quadrillions'
      "6" : 'quintillions'
    symbol = scale_symbols["" + scale]
    return I18n.t("units." + unit + "." + symbol)

  # Doesn't add trailing zeros. Let's use sprintf.js in case
  round_number : (value, precision) ->
    rounded = Math.pow(10, precision)
    Math.round(value * rounded) / rounded

  calculate_performance : (now, fut) ->
    return null if now == null || fut == null || fut == 0
    return fut / now - 1

  #  given a value and a unit, returns a translated string
  # uses i18n.js, so be sure the required translation keys
  # are available.
  # The available units are:
  #
  # av(20, '%') => 20%
  # av(1234)    => 1234
  autoscale_value: (x, unit, precision) ->
    precision  = precision || 0
    pow    = Metric.power_of_thousand(x)
    value  = x / Math.pow(1000, pow)
    value = Metric.round_number(value, precision)
    scale_string = Metric.power_of_thousand_to_string(pow)

    prefix = ''
    out    = ''
    suffix = ''

    switch unit
      when '%'
        out = Metric.percentage_to_string(x)
      when 'MJ'
        out = x / Math.pow(1000, pow)
        suffix = I18n.t('units.joules.' + scale_string)
      when 'MW'
        out = x / Math.pow(1000, pow)
        suffix = I18n.t('units.watt.' + scale_string)
      when 'euro'
        out = value
        prefix = "&euro;"
      else
        out = x

    output = prefix + out + suffix
    return output

  # formatters

  # x: the value - no transformations on it
  # prefix: if true, add a leading + on positive values
  #  precision: default = 1, the number of decimal points
  # pts(10) => 10%
  # pts(10, true) => +10%
  # pts(10, true, 2) => 10.00%
  percentage_to_string: (x, prefix, precision) ->
    precision = precision || 1
    prefix = prefix || false
    value = Metric.round_number(x, precision)
    value = "+" + value if prefix && value > 0.0
    return '' + value + '%'

  # as format_percentage, but multiplying the value * 100
  ratio_as_percentage: (x, prefix, precision)->
    return Metric.percentage_to_string(x * 100, prefix, precision)

  #   very specific I'm keeping it separated from autoscale_value.
  #   1_000_000     => &euro;1mln
  #   -1_000_000    => -&euro;1mln
  #   1_000_000_000 => &euro;1bln
  #   The unit_suffix parameters adds a translated mln/bln suffix
  euros_to_string: (x, unit_suffix) ->
    prefix = if x < 0 then "-" else ""
    abs_value = Math.abs(x)
    scale     = Metric.power_of_thousand(x)
    value     = abs_value / Math.pow(1000, scale)
    suffix    = ''

    if unit_suffix
     suffix = I18n.t('units.currency.' + Metric.power_of_thousand_to_string(scale))

    rounded = Metric.round_number(value, 1).toString()

    # If the number is < 1000, and has decimal places, make sure that the
    # number isn't truncated to something like 5.4, but instead returns 5.40.
    if (abs_value < 1000 && _.indexOf(rounded, '.') != -1)
      rounded = rounded.split('.')
      if (rounded[1] && rounded[1].length == 1)
        rounded[1] += '0'
      rounded = rounded.join('.')

    return "#{prefix}&euro;#{rounded}#{suffix}"


  # utility methods

  # 0-999: 0, 1000-999999: 1, ...
  power_of_thousand: (x) ->
    return parseInt(Math.log(Math.abs(x)) / Math.log(1000))

  # Returns the string currently used on the i18n file
  power_of_thousand_to_string: (x)->
    switch x
      when 0 then return 'unit'
      when 1 then return 'thousands'
      when 2 then return 'millions'
      when 3 then return 'billions'
      when 4 then return 'trillions'
      when 5 then return 'quadrillions'
      when 6 then return 'quintillions'
      else return null
