
class Leaf.Navigator

  constructor: (@ns) ->

  run: (controller, action) ->
    ctrl = new @ns[controller]
    ctrl.render action

