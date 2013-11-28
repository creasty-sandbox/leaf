describe 'Routines', ->

  el = input = trueRadioInput = falseRadioInput = checkboxInput = null

  createInputElement = (type, value) ->
    elem = document.createElement 'input'
    elem.setAttribute 'type', type
    elem.setAttribute 'value', value if value?
    document.body.appendChild elem
    elem

  beforeEach ->
    rivets.configure
      adapter:
        subscribe: ->
        unsubscribe: ->
        read: ->
        publish: ->

    el = document.createElement 'div'
    document.body.appendChild el

    input = createInputElement 'text'

    # to test the radio input scenario when its value is "true"
    trueRadioInput = createInputElement 'radio', 'true'

    # to test the radio input scenario when its value is "false"
    falseRadioInput = createInputElement 'radio', 'false'

    # to test the checkbox input scenario
    checkboxInput = createInputElement 'checkbox'

  afterEach ->
    el.parentNode.removeChild el
    input.parentNode.removeChild input
    trueRadioInput.parentNode.removeChild trueRadioInput
    falseRadioInput.parentNode.removeChild falseRadioInput
    checkboxInput.parentNode.removeChild checkboxInput


  describe 'text', ->

    it 'sets the element\'s text content', ->
      rivets.binders.text el, '<em>gluten-free</em>'

      expect(el.textContent || el.innerText).toBe '<em>gluten-free</em>'
      expect(el.innerHTML).toBe '&lt;em&gt;gluten-free&lt;/em&gt;'

    it 'sets the element\'s text content to zero when a numeric zero is passed', ->
        rivets.binders.text el, 0

        expect(el.textContent || el.innerText).toBe '0'
        expect(el.innerHTML).toBe '0'


  describe 'html', ->

    it 'sets the element\'s HTML content', ->
      rivets.binders.html el, '<strong>fixie</strong>'

      expect(el.textContent || el.innerText).toBe 'fixie'
      expect(el.innerHTML).toBe '<strong>fixie</strong>'

    it 'sets the element\'s HTML content to zero when a zero value is passed', ->
      rivets.binders.html el, 0

      expect(el.textContent || el.innerText).toBe '0'
      expect(el.innerHTML).toBe '0'


  describe 'value', ->

    it 'sets the element\'s value', ->
      rivets.binders.value.routine input, 'pitchfork'

      expect(input.value).toBe 'pitchfork'

    it 'applies a default value to the element when the model doesn\'t contain it', ->
      rivets.binders.value.routine input, undefined

      expect(input.value).toBe ''

    it 'sets the element\'s value to zero when a zero value is passed', ->
      rivets.binders.value.routine input, 0

      expect(input.value).toBe '0'


  describe 'show', ->

    describe 'with a truthy value', ->

      it 'shows the element', ->
        rivets.binders.show el, true

        expect(el.style.display).toBe ''


    describe 'with a falsey value', ->

      it 'hides the element', ->
        rivets.binders.show el, false

        expect(el.style.display).toBe 'none'


  describe 'hide', ->

    describe 'with a truthy value', ->

      it 'hides the element', ->
        rivets.binders.hide el, true

        expect(el.style.display).toBe 'none'


    describe 'with a falsey value', ->

      it 'shows the element', ->
        rivets.binders.hide el, false

        expect(el.style.display).toBe ''


  describe 'enabled', ->

    describe 'with a truthy value', ->

      it 'enables the element', ->
        rivets.binders.enabled el, true

        expect(el.disabled).toBe false


    describe 'with a falsey value', ->

      it 'disables the element', ->
        rivets.binders.enabled el, false

        expect(el.disabled).toBe true


  describe 'disabled', ->

    describe 'with a truthy value', ->

      it 'disables the element', ->
        rivets.binders.disabled el, true

        expect(el.disabled).toBe true


    describe 'with a falsey value', ->

      it 'enables the element', ->
        rivets.binders.disabled el, false

        expect(el.disabled).toBe nfalse


  describe 'checked', ->

    describe 'with a checkbox input', ->

      describe 'and a truthy value', ->

        it 'checks the checkbox input', ->
          rivets.binders.checked.routine checkboxInput, true

          expect(checkboxInput.checked).toBe true

      describe 'with a falsey value', ->

        it 'unchecks the checkbox input', ->
          rivets.binders.checked.routine checkboxInput, false

          expect(checkboxInput.checked).toBe false


    describe 'with a radio input with value="true"', ->

      describe 'and a truthy value', ->

        it 'checks the radio input', ->
          rivets.binders.checked.routine trueRadioInput, true

          expect(trueRadioInput.checked).toBe true


      describe 'with a falsey value', ->

        it 'unchecks the radio input', ->
          rivets.binders.checked.routine trueRadioInput, false

          expect(trueRadioInput.checked).toBe false


    describe 'with a radio input with value="false"', ->

      describe 'and a truthy value', ->

        it 'checks the radio input', ->
          rivets.binders.checked.routine falseRadioInput, true

          expect(falseRadioInput.checked).toBe false


      describe 'with a falsey value', ->

        it 'unchecks the radio input', ->
          rivets.binders.checked.routine falseRadioInput, false

          expect(falseRadioInput.checked).toBe true


  describe 'unchecked', ->

    describe 'and a truthy value', ->

      describe 'and a truthy value', ->

        it 'checks the checkbox input', ->
          rivets.binders.unchecked.routine checkboxInput, true

          expect(checkboxInput.checked).toBe false


      describe 'with a falsey value', ->

        it 'unchecks the checkbox input', ->
          rivets.binders.unchecked.routine checkboxInput, false

          expect(checkboxInput.checked).toBe true


    describe 'with a radio input with value="true"', ->

      describe 'and a truthy value', ->

        it 'checks the radio input', ->
          rivets.binders.unchecked.routine trueRadioInput, true

          expect(trueRadioInput.checked).toBe false


      describe 'with a falsey value', ->

        it 'unchecks the radio input', ->
          rivets.binders.unchecked.routine trueRadioInput, false

          expect(trueRadioInput.checked).toBe true


    describe 'with a radio input with value="false"', ->

      describe 'and a truthy value', ->

        it 'checks the radio input', ->
          rivets.binders.unchecked.routine falseRadioInput, true

          expect(falseRadioInput.checked).toBe true


      describe 'with a falsey value', ->

        it 'unchecks the radio input', ->
          rivets.binders.unchecked.routine falseRadioInput, false

          expect(falseRadioInput.checked).toBe false


