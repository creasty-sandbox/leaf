
describe 'Rivets.TextTemplateParser', ->

  Rivets = rivets._

  describe 'parse()', ->

    it 'tokenizes a text template', ->
      template = 'Hello {{ user.name }}, you have {{ user.messages.unread | length }} unread messages.'

      expected = [
        { type: 0, value: 'Hello ' }
        { type: 1, value: 'user.name' }
        { type: 0, value: ', you have ' }
        { type: 1, value: 'user.messages.unread | length' }
        { type: 0, value: ' unread messages.' }
      ]

      results = Rivets.TextTemplateParser.parse template, ['{{', '}}']
      expect(results.length).toBe 5

      for i in [0...results.length] by 1
        expect(results[i].type).toBe expected[i].type
        expect(results[i].value).toBe expected[i].value


    describe 'with no binding fragments', ->

      it "should return a single text token", ->
        template = 'Hello World!'
        expected = [{ type: 0, value: 'Hello World!' }]

        results = Rivets.TextTemplateParser.parse template, ['{{', '}}']
        expect(results.length).toBe 1

        for i in [0...results.length] by 1
          expect(results[i].type).toBe expected[i].type
          expect(results[i].value).toBe expected[i].value


    describe 'with only a binding fragment', ->

      it 'should return a single binding token', ->
        template = '{{ user.name }}'
        expected = [{ type: 1, value: 'user.name' }]

        results = Rivets.TextTemplateParser.parse template, ['{{', '}}']
        expect(results.length).toBe 1

        for i in [0...results.length] by 1
          expect(results[i].type).toBe expected[i].type
          expect(results[i].value).toBe expected[i].value

