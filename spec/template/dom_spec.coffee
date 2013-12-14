
###

buffer = '<p>{{{ name.toUpperCase() + 234 }}}</p>'
psr = new Leaf.Template.Parser buffer
tree = psr.getTree()

obj = new Leaf.Observable name: 'John'

dom = new Leaf.Template.DOM tree, obj
dom.getDOM()

###


