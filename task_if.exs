if_else = fn
  check, _if_true, if_false when check in [false, nil] -> if_false
  _check, if_true, _if_false -> if_true
end

if_else_lazy = fn
  check, _if_true, if_false when check in [false, nil] and is_function(if_false, 0) ->
    if_false.()

  _check, if_true, _if_false when is_function(if_true, 0) ->
    if_true.()
end
