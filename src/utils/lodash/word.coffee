
_.mixin do ->
  word = (str) -> str.split /\s+/
  { word, w: word }

