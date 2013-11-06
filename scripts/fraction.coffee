# Class Fraction
class Fraction
  constructor: (@numerateur, @denominateur) ->
    if @denominateur < 0
      @numerateur *= -1
      @denominateur *= -1
  
  irreductible: () ->
    [a, b] = [@numerateur, @denominateur]
    [a, b] = [b, a%b] until b is 0
    @denominateur /= a
    @numerateur /= a
  
  inverse: () ->
    [@numerateur,@denominateur]=[@denominateur,@numerateur]
  
  oppose: () ->
    @numerateur = -@numerateur
    
ajouter_deux_fractions = (f1,f2) ->
  n = f1.numerateur * f2.denominateur + f2.numerateur * f1.denominateur
  d = f1.denominateur * f2.denominateur
  foo = new Fraction n, d

multiplier_deux_fractions = (f1,f2) ->
  n = f1.numerateur * f2.numerateur
  d = f1.denominateur * f2.denominateur
  foo = new Fraction n, d
