
describe 'Rivets.Binding', ->

  model = el = view = binding = opts = null

  beforeEach ->
    rivets.config.prefix = 'data'
    adapter = rivets.adapters['.']

    el = document.createElement 'div'
    el.setAttribute 'data-text', 'obj.name'

    view = rivets.bind el, obj: {}
    binding = view.bindings[0]
    model = binding.model


  it 'gets assigned the proper binder routine matching the identifier', ->
    expect(binding.binder.routine).toBe rivets.binders.text


  describe 'bind()', ->

    it 'subscribes to the model for changes via the adapter', ->
      spyOn adapter, 'subscribe'
      binding.bind()

      expect(adapter.subscribe).toHaveBeenCalledWith model, 'name', binding.sync

    it 'calls the binder\'s bind method if one exists', ->
      expect(-> binding.bind()).not.toThrow new Error()

      binding.binder.bind = (->)
      spyOn binding.binder, 'bind'
      binding.bind()

      expect(binding.binder.bind).toHaveBeenCalled()


    describe 'with preloadData set to true', ->

      beforeEach ->
        rivets.config.preloadData = true

      it 'sets the initial value via the adapter', ->
        spyOn binding, 'set'
        spyOn adapter, 'read'
        binding.bind()

        expect(adapter.read).toHaveBeenCalledWith model, 'name'
        expect(binding.set).toHaveBeenCalled()


    describe 'with dependencies', ->

      beforeEach ->
        binding.options.dependencies = ['.fname', '.lname']

      it 'sets up observers on the dependant attributes', ->
        spyOn adapter, 'subscribe'
        binding.bind()

        expect(adapter.subscribe).toHaveBeenCalledWith model, 'fname', binding.sync
        expect(adapter.subscribe).toHaveBeenCalledWith model, 'lname', binding.sync


  describe 'unbind()', ->

    it 'calls the binder\'s unbind method if one exists', ->
      expect(-> binding.unbind()).not.toThrow new Error()

      binding.binder.unbind = (->)
      spyOn binding.binder, 'unbind'
      binding.unbind()

      expect(binding.binder.unbind).toHaveBeenCalled()


  describe 'set()', ->

    it 'performs the binding routine with the supplied value', ->
      spyOn binding.binder, 'routine'
      binding.set 'sweater'

      expect(binding.binder.routine).toHaveBeenCalledWith el, 'sweater'

    it 'applies any formatters to the value before performing the routine', ->
      view.formatters.awesome = (value) -> 'awesome ' + value
      binding.formatters.push 'awesome'
      spyOn binding.binder, 'routine'
      binding.set 'sweater'

      expect(binding.binder.routine).toHaveBeenCalledWith el, 'awesome sweater'

    it 'calls methods with the object as context', ->
      binding.model = foo: 'bar'
      spyOn binding.binder, 'routine'
      binding.set -> @foo
      expect(binding.binder.routine).toHaveBeenCalledWith el, binding.model.foo

  describe 'publish()', ->
    it 'should publish the value of a number input', ->
      numberInput = document.createElement 'input'
      numberInput.setAttribute 'type', 'number'
      numberInput.setAttribute 'data-value', 'obj.num'

      view = rivets.bind numberInput, obj: num: 42
      binding = view.bindings[0]
      model = binding.model

      numberInput.value = 42

      spyOn adapter, 'publish'
      binding.publish target: numberInput

      expect(adapter.publish).toHaveBeenCalledWith model, 'num', '42'


  describe 'publishTwoWay()', ->

    it 'applies a two-way read formatter to function same as a single-way', ->
      view.formatters.awesome =
        read: (value) -> 'awesome ' + value

      binding.formatters.push 'awesome'
      spyOn binding.binder, 'routine'
      binding.set 'sweater'
      expect(binding.binder.routine).toHaveBeenCalledWith el, 'awesome sweater'

    it 'should publish the value of a number input', ->
      rivets.formatters.awesome =
        publish: (value) -> 'awesome ' + value

      numberInput = document.createElement 'input'
      numberInput.setAttribute 'type', 'number'
      numberInput.setAttribute 'data-value', 'obj.num | awesome'

      view = rivets.bind numberInput, obj: num: 42
      binding = view.bindings[0]
      model = binding.model

      numberInput.value = 42

      spyOn adapter, 'publish'
      binding.publish target: numberInput
      expect(adapter.publish).toHaveBeenCalledWith model, 'num', 'awesome 42'

    it 'should format a value in both directions', ->
      rivets.formatters.awesome =
        publish: (value) -> 'awesome ' + value
        read: (value) -> value + ' is awesome'

      valueInput = document.createElement 'input'
      valueInput.setAttribute 'type','text'
      valueInput.setAttribute 'data-value', 'obj.name | awesome'

      view = rivets.bind valueInput, obj: name: 'nothing'
      binding = view.bindings[0]
      model = binding.model

      spyOn adapter, 'publish'
      valueInput.value = 'charles'
      binding.publish target: valueInput
      expect(adapter.publish).toHaveBeenCalledWith model, 'name', 'awesome charles'

      spyOn binding.binder, 'routine'
      binding.set 'fred'
      expect(binding.binder.routine).toHaveBeenCalledWith valueInput, 'fred is awesome'

    it 'should not fail or format if the specified binding function doesn\'t exist', ->
      rivets.formatters.awesome = {}
      valueInput = document.createElement 'input'
      valueInput.setAttribute 'type','text'
      valueInput.setAttribute 'data-value', 'obj.name | awesome'

      view = rivets.bind valueInput, obj:name: 'nothing'
      binding = view.bindings[0]
      model = binding.model

      spyOn adapter, 'publish'
      valueInput.value = 'charles'
      binding.publish target: valueInput
      expect(adapter.publish).toHaveBeenCalledWith model, 'name', 'charles'

      spyOn binding.binder, 'routine'
      binding.set 'fred'
      expect(binding.binder.routine).toHaveBeenCalledWith valueInput, 'fred'

    it 'should apply read binders left to right, and write binders right to left', ->
      rivets.formatters.totally =
        publish: (value) -> value + ' totally'
        read: (value) -> value + ' totally'

      rivets.formatters.awesome =
        publish: (value) -> value + ' is awesome'
        read: (value) -> value + ' is awesome'

      valueInput = document.createElement 'input'
      valueInput.setAttribute 'type','text'
      valueInput.setAttribute 'data-value', 'obj.name | awesome | totally'

      view = rivets.bind valueInput, obj: name: 'nothing'
      binding = view.bindings[0]
      model = binding.model

      spyOn binding.binder, 'routine'
      binding.set 'fred'
      expect(binding.binder.routine).toHaveBeenCalledWith valueInput, 'fred is awesome totally'

      spyOn adapter, 'publish'
      valueInput.value = 'fred'
      binding.publish target: valueInput
      expect(adapter.publish).toHaveBeenCalledWith model, 'name', 'fred totally is awesome'

     it 'binders in a chain should be skipped if they\'re not there', ->
      rivets.formatters.totally =
        publish: (value) -> value + ' totally'
        read: (value) -> value + ' totally'

      rivets.formatters.radical =
        publish: (value) -> value + ' is radical'

      rivets.formatters.awesome = (value) -> value + ' is awesome'

      valueInput = document.createElement 'input'
      valueInput.setAttribute 'type','text'
      valueInput.setAttribute 'data-value', 'obj.name | awesome | radical | totally'

      view = rivets.bind valueInput, obj: name: 'nothing'
      binding = view.bindings[0]
      model = binding.model

      spyOn binding.binder, 'routine'
      binding.set 'fred'
      expect(binding.binder.routine).toHaveBeenCalledWith valueInput, 'fred is awesome totally'

      spyOn adapter, 'publish'
      valueInput.value = 'fred'
      binding.publish target: valueInput
      expect(adapter.publish).toHaveBeenCalledWith model, 'name', 'fred totally is radical'


  describe 'formattedValue()', ->

    it 'applies the current formatters on the supplied value', ->
      view.formatters.awesome = (value) -> 'awesome ' + value
      binding.formatters.push 'awesome'
      expect(binding.formattedValue('hat')).toBe 'awesome hat'


    describe 'with a multi-argument formatter string', ->

      beforeEach ->
        view.formatters.awesome = (value, prefix) -> prefix + ' awesome ' + value

        binding.formatters.push 'awesome super'

      it 'applies the formatter with arguments', ->
        expect(binding.formattedValue('jacket')).toBe 'super awesome jacket'


