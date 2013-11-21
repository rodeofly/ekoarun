debug = false
id = 1
copier_symbole= ""
copier_contenu= {}
changementSens = { '=': '=', '<': '>', '>': '<', '≤': '≥', '≥': '≤' }
liste_des_operateurs = ['+','-']
liste_des_chiffres =   ['1','2','3','4','5','6','7','8','9','0']  
liste_des_variables =  ['x','y','z','t']
liste_des_signes =     ['=','<','>','≤','≥']


# Class Fraction
class Fraction
  constructor: (@numerateur, @denominateur) ->    
  
  irreductible: () ->
    [a, b] = [@numerateur, @denominateur]
    [a, b] = [b, a%b] until b is 0
    @denominateur /= a
    @numerateur /= a
    if @denominateur < 0 then [@numerateur , @denominateur] = [-@numerateur;-@denominateur]

  inverse: () ->
    [@numerateur,@denominateur]=[@denominateur,@numerateur]
  
  oppose: () ->
    @numerateur = -@numerateur
     
ajouter_deux_fractions = (f1,f2) ->
  if f1.denominateur isnt f2.denominateur
    n = f1.numerateur * f2.denominateur + f2.numerateur * f1.denominateur
    d = f1.denominateur * f2.denominateur
  else
    n = f1.numerateur + f2.numerateur
    d = f1.denominateur
  foo = new Fraction n, d
  
multiplier_deux_fractions = (f1,f2) ->
  n = f1.numerateur * f2.numerateur
  d = f1.denominateur * f2.denominateur
  foo = new Fraction n, d

# Evaluer value comme fraction
valeur_comme_fraction = (value) ->
  alert "valeur_comme_fraction(#{value}) starts !" if debug
  foo = value.split("/")
  if foo.length>1
    fraction = new Fraction parseInt(foo[0]), parseInt(foo[1])
  else
    fraction = new Fraction parseInt(foo[0]), 1

# afficher une fraction en html
fraction_as_html = (fraction) ->
  if fraction.denominateur is 1
    if fraction.numerateur < 0
      html = "<span class='moins'>&minus;</span><span class='rationnel'>#{Math.abs(fraction.numerateur)}</span>"
    else
      html = "<span class='plus'>+</span><span class='rationnel'>#{fraction.numerateur}</span>"
  else
    if fraction.numerateur < 0
      html = "<span class='moins'>&minus;</span><span class='fraction'><span class='top'>#{Math.abs(fraction.numerateur)}</span><span class='bottom'>#{fraction.denominateur}</span></span>"
    else
      html = "<span class='plus'>+</span><span class='fraction'><span class='top'>#{fraction.numerateur}</span><span class='bottom'>#{fraction.denominateur}</span></span>"

# Rendre sortable et connectable les equations
doSort = () ->    
  $( ".membreDeGauche" ).each ->
    id = $( this ).attr("id").split("_")[1]
    $( "#membreDeGauche_#{id}" ).sortable
      connectWith: "#membreDeDroite_#{id}",
      placeholder: "monome placeholder",
      update : (event, ui) ->
        mettre_a_jour_les_monomes(id)
      receive : (event, ui) ->
        changer_de_membre(event, ui,id)
     
  $( ".membreDeDroite" ).each ->
    id = $( this ).attr("id").split("_")[1]
    $( "#membreDeDroite_#{id}" ).sortable
      connectWith: "#membreDeGauche_#{id}",
      placeholder: "monome placeholder",
      update : (event, ui) ->
        mettre_a_jour_les_monomes(id)
      receive : (event, ui) ->
        changer_de_membre(event, ui,id)
          
#Afficher la solution d'une équation
obtenir_la_solution = (id) ->
  if $( "#equation_#{id} > ul.membreDeGauche > li").length is 1 and $( "#equation_#{id} > ul.membreDeDroite > li").length is 1
    $li_gauche = $( "#equation_#{id} > ul.membreDeGauche > li")
    $li_droite = $( "#equation_#{id} > ul.membreDeDroite > li")
    if $li_gauche.attr("data-symbol") and not $li_droite.attr("data-symbol")
      if $li_gauche.attr("data-value") is "1/1" or $li_gauche.attr("data-value") is "1"
        signe = $( "#signe_#{id}" ).text()
        value = valeur_comme_fraction($li_droite.attr( "data-value"))
        value.irreductible()
        s = fraction_as_html value 
        switch signe
          when "="
            solution = "S = {#{s}}"
          when ">"
            solution = "S = ]#{s} ; +∞ ["
          when "≥"
            solution = "S = [#{s} ; +∞ ["
          when "<"
            solution = "S = ] -∞ ; #{s}]"
          when "≤"
            solution = "S = ] -∞ ; #{s}]"                
        $("#solution_#{id}").html solution
      else alert "On ne peut pas encore lire la solution ! il faut que le coefficient de l'inconnue soit 1."
    else alert "On ne peut pas encore lire la solution ! il faut une l'inconnue à gauche et une valeur à droite." 
  else alert "On ne peut pas encore lire la solution ! il faut un seul terme à gauche et un seul terme à droite." 

mettre_a_jour_ce_monome = (monome)->
  typeOf = monome.attr("data-type")  
  fraction = valeur_comme_fraction monome.attr( "data-value")
  html = fraction_as_html(fraction, typeOf)
  id = monome.parent().attr("id").split("_")[1]
  switch typeOf
    when "symbol"
      symbol = monome.attr("data-symbol")
      if fraction.numerateur*fraction.denominateur in [-1,1]
        if fraction.numerateur/fraction.denominateur is 1
          monome.html( "<span class='plus'>+</span><span>#{symbol}</span>" )
        else
          monome.html( "<span class='moins'>&minus;</span><span>#{symbol}</span>" )
      else
        monome.html( "#{html}<span>#{symbol}</span>")                      
    when "rationnel"
      monome.html( html )
  $li_gauche = $( "#membreDeGauche_#{id} > li")
  if $li_gauche.length is 1 and $li_gauche.attr("data-symbol")
    if $li_gauche.attr("data-value") is "1/1" or $li_gauche.attr("data-value") is "1"
      $( "#copier_#{id}" ).show()
    else
      $( "#copier_#{id}" ).hide()
  else
    $( "#copier_#{id}" ).hide()
    
# Afficher le contenu des termes de l'equation  
mettre_a_jour_les_monomes = ->
  $(".monome").each ->
    mettre_a_jour_ce_monome( $( this ) )
  
# effectuer la somme, par membre, des termes selectionnés
sommation_par_membre = (side,id) ->    
    Side = if side is "gauche" then "Gauche" else "Droite"
    membre = "#membreDe#{Side}_#{id}"
    selected = "#{membre} > .#{side}.selected"
    alert "#{Side} + #{membre} + #{selected} +#{$( selected ).length}" if debug
    symbols = {}
    values = new Fraction 0, 1
    $( selected ).each ->
      typeOf = $( this ).attr("data-type")
      value = valeur_comme_fraction $( this ).attr( "data-value")
      symbol = $( this ).attr("data-symbol")   
      switch typeOf
        when "symbol"
          symbols[ symbol ] ?= new Fraction 0, 1
          symbols[ symbol ] = ajouter_deux_fractions(symbols[ symbol ], value)
        when "rationnel"
          values =  ajouter_deux_fractions(values, value)
          
    for symbol, value of symbols
      if value.numerateur isnt 0
        $( membre ).append("<li class='monome #{side}' data-value='#{value.numerateur}/#{value.denominateur}' data-type='symbol' data-symbol='#{symbol}'></li>")  
    if values.numerateur isnt 0
      $( membre ).append("<li class='monome #{side}' data-value='#{values.numerateur}/#{values.denominateur}' data-type='rationnel'></li>")
    $( selected ).remove()
    if $( "#{membre} > li.#{side}" ).length is 0
      $( membre ).append("<li class='monome #{side}' data-value='0' data-type='rationnel'></li>")
    
    mettre_a_jour_les_monomes()

#simplifier les fractions sélectionnées d'une équation
simplifier_ce_monome = (monome) ->
  value = valeur_comme_fraction monome.attr( "data-value")
  value.irreductible()
  monome.attr( "data-value", "#{value.numerateur}/#{value.denominateur}")
  mettre_a_jour_ce_monome(monome)
  
#simplifier les fractions sélectionnées d'une équation
simplifier_les_monomes = (id) ->
  $( "#equation_#{id} > ul > li.selected" ).each ->
    simplifier_ce_monome( $(this) )

#Modifier un terme lors de son passage d'un membre a l'autre de l'équation   
changer_de_membre = (event, ui,id) ->
  value = valeur_comme_fraction(ui.item.attr("data-value"))
  value = multiplier_deux_fractions(value, new Fraction(-1, 1))
  ui.item.attr("data-value", "#{value.numerateur}/#{value.denominateur}").toggleClass("gauche droite")
  if $( "#membreDeDroite_#{id} > li" ).length is 0
    $( "#membreDeDroite_#{id}" ).append("<li class='monome droite' data-value='0' data-type='rationnel'></li>")
  if $( "#membreDeGauche_#{id}  > li" ).length is 0
    $( "#membreDeGauche_#{id}" ).append("<li class='monome gauche' data-value='0' data-type='rationnel'></li>")

#Obtenir le code html d'un membre d'une equation    
membre_as_html = (membre,side,id) ->
  if side is "gauche"
    Side = "Gauche" 
  else
    Side = "Droite"
  html = "<ul class='membreDe#{Side}' id='membreDe#{Side}_#{id}'>"
  for monome in membre
    m = monome.split(")")
    if m[1]
      html += "<li class='monome #{side}' data-value='#{m[0][1..]}' data-type='symbol' data-symbol='#{m[1]}'></li>"
    else
      html += "<li class='monome #{side}' data-value='#{m[0][1..]}' data-type='rationnel'></li>"
  html += "</ul>"    

n_termes_string = (n) ->
  str = ""
  for [1..n]
    plusOrMinus = if Math.random() < 0.5 then -1 else 1
    coeff = plusOrMinus*(Math.floor(10*Math.random())+1)
    toss = Math.floor 2*Math.random()
    if toss is 0 
      str += "+(#{coeff}) "
    else
      str += "+(#{coeff})x "
  str[1..]

monome_comme_array = (s) ->
  alert "monome_comme_array(#{s}) starts !" if debug
  pattern_terme = /\([\+\-]*\d+[/\d+]*\)(\w+²{0,1})*/g
  foo = s.match(pattern_terme)
  if foo
    if foo[0] is s
      alert "#{s} match regex:#{pattern_terme}" if debug
      foo = s.split(")")
      if foo[1] 
        foo = [foo[0][1..], foo[1]]
      else
        foo = [foo[0][1..]]
    else
      alert "Poids mal formé"
      foo = []
  else
    alert "Poids mal formé"
    foo = []

ajouter_un_terme_a_chaque_membre = (array,id,factor) ->
  if array.length then value = valeur_comme_fraction array[0]
  value = multiplier_deux_fractions(value, valeur_comme_fraction "#{factor}")
  switch array.length
    when 1
      $( "#membreDeGauche_#{id}" ).append("<li class='monome gauche' data-type='rationnel' data-value='#{value.numerateur}/#{value.denominateur}'><span></span></li>")
      $( "#membreDeDroite_#{id}" ).append("<li class='monome droite' data-type='rationnel' data-value='#{value.numerateur}/#{value.denominateur}'><span></span></li>")
    when 2
      symbol = array[1]
      $( "#membreDeGauche_#{id}" ).append("<li class='monome gauche' data-value='#{value.numerateur}/#{value.denominateur}' data-type='symbol' data-symbol='#{symbol}'></li>")
      $( "#membreDeDroite_#{id}" ).append("<li class='monome droite' data-value='#{value.numerateur}/#{value.denominateur}' data-type='symbol' data-symbol='#{symbol}'></li>")
    else
      alert "il manque quelque chose !"
  mettre_a_jour_les_monomes()

multiplier_chaque_membre_par = (facteur,id) ->
  if facteur.numerateur
    if facteur.numerateur/facteur.denominateur < 0 then $("#signe_#{id}").text changementSens[$("#signe_#{id}").text()]
    $( "#equation_#{id} > ul > li.monome").each ->
      value = valeur_comme_fraction $( this ).attr( "data-value")
      value = multiplier_deux_fractions(value,facteur)
      $( this ).attr( "data-value","#{value.numerateur}/#{value.denominateur}")
  mettre_a_jour_les_monomes()
  
# On Dom Ready !
$ ->  
  $('*:not(:input)').disableSelection()
  $( "#equation_panel").draggable()
  
  #Le petit panel tactile
  for char in liste_des_variables.concat liste_des_operateurs.concat ["/"].concat liste_des_signes
    $("#equation_panel").append("<span id='var_#{char}' class='panel_touch'>#{char}</span>")
  $("#equation_panel").append("<br />")
  for char in liste_des_chiffres.concat ['&leftarrow;']
    $("#equation_panel").append("<span id='var_#{char}' class='panel_touch'>#{char}</span>")
  
  
  $('body').on "click", "#effacer_equation_string", () ->
    $( "#equation_string" ).val( '' ) 
    
  #Saisie 'intelligente' de l'equation   
  $('body').on "click", ".panel_touch", () ->
    char = $( this ).attr( "id" ).split("_")[1]    
    saisie = $( "#equation_string" ).val()
    caractere_precedent = if saisie.length then saisie[saisie.length-1] else ''      
    
    if char is '←'
      if saisie.length is 1
        saisie = ""
      else
        saisie = saisie[0..(saisie.length-2)]
    else
      if caractere_precedent is ''
        if char in liste_des_operateurs 
          if char is '-' then saisie += "(-"  else saisie += "("
        else if char in liste_des_chiffres  then saisie += "(#{char}"
        else if char in liste_des_variables then saisie += "(1)#{char}"
        else if char in liste_des_signes    then alert "il faut un membre à gauche !"
        else if char is '/'                 then alert "Impossible de commencer par ça !"
      
      else if caractere_precedent in liste_des_operateurs or caractere_precedent is '('
        if char in liste_des_operateurs
          if caractere_precedent isnt '-'
            if char is '-' then saisie += "#{char}" else alert "Deux opérateurs d'affilés ?"
          else alert "Deux fois le même opérateur ?"
        else if char in liste_des_chiffres  then saisie += "#{char}"
        else if char in liste_des_variables then saisie += "1)#{char}"
        else if char in liste_des_signes    then alert "Effacer le dernier signe !"
        else if char is '/'                 then alert "Impossible d'enchainer avec ça par ça !"
      
      else if caractere_precedent in liste_des_chiffres
        if char in liste_des_operateurs 
          if char is '-' then saisie += ")+(-"  else saisie += ")#{char}("
        else if char in liste_des_chiffres  then saisie += "#{char}"
        else if char in liste_des_variables then saisie += ")#{char}"
        else if char in liste_des_signes    then saisie += ")#{char}"
        else if char is '/' then saisie += "#{char}"
      
      else if caractere_precedent in liste_des_variables
        if char in liste_des_operateurs
          if char is '-' then saisie += "+(-"  else saisie += "#{char}("
        else if char in liste_des_chiffres  then alert "Les coefficients se placent devant les variables !"
        else if char in liste_des_variables then saisie += "#{char}"
        else if char in liste_des_signes    then saisie += "#{char}"
        else if char is '/'                 then alert "Impossible d'enchainer avec ça par ça !"
      
      else if caractere_precedent in liste_des_signes
        if char in liste_des_operateurs
          if char is '-'                    then saisie += "(-"  else saisie += "("
        else if char in liste_des_chiffres  then saisie += "(#{char}"
        else if char in liste_des_variables then saisie += "(1)#{char}"
        else if char in liste_des_signes    then alert "Deux signes d'affilés"
        else if char is '/'                 then alert "Impossible d'enchainer avec ça par ça !"  
      
      else if caractere_precedent is '/'
        if char in liste_des_operateurs     then alert "Impossible d'enchainer avec ça par ça !"  
        else if char in liste_des_chiffres  then saisie += "#{char}"
        else if char in liste_des_variables then alert "Et la fraction ?" 
        else if char in liste_des_signes    then alert "Et la fraction ?"
        else if char is '/'                 then alert "Ca y est déjà !"
      else
        saisie += "#{char}"
        
    $( "#equation_string" ).val(saisie)
  
  
  # effacer une equation
  $('body').on "click", ".deleteButton", () ->
    id = $( this ).parent().attr("id").split("_")[1]
    $( "#equation_#{id}.focus" ).hide 'slow', () -> 
      $( "#equation_#{id}.focus" ).remove()
  
   # additionner les termes selectionnés d'un membre par double click
  $('body').on "dblclick", ".selected", (event) ->
    event.stopImmediatePropagation()
    id = $( this ).parent().attr("id").split("_")[1]
    if $( this ).hasClass( "gauche" ) and $("#equation_#{id} ul > .gauche.selected").length>1
      sommation_par_membre("gauche",id)
    else
      if $( this ).hasClass( "droite" ) and $("#equation_#{id} ul > .droite.selected").length>1
        sommation_par_membre("droite",id)
      
  # selectionner un terme
  $('body').on "click", "li", (event) ->
    event.stopImmediatePropagation()
    $(this).toggleClass("selected")
  
  #Focus sur une équation et/ou désélectionner les termes d'une équation en cliquant à coté
  $('body').on "click", ".equation", () ->
    $( ".focus" ).toggleClass("focus")
    $( this ).toggleClass("focus")
    focus_id = parseInt $( this ).attr("id").split("_")[1]
    $( this ).find( ".monome" ).removeClass( "selected" )
  
  #focus sur une équation par le signe
  $('body').on "click", ".signe", () ->
    $( ".focus" ).toggleClass("focus")
    id = $( this ).attr("id").split("_")[1]
    $("#equation_#{id}").toggleClass("focus")
    
  # selectionner tous les termes d'une equation
  $( "body" ).on "click", ".selectAllButton", (event) ->
    event.stopImmediatePropagation()
    id = $( ".focus" ).attr("id").split("_")[1]
    $("#equation_#{id}.focus ul > .monome").addClass( "selected" )
    
  # simplifier un terme
  $('body').on "dblclick", ".monome", () ->
    monome = $(this)
    simplifier_ce_monome(monome)
   
  #Simplifier les fractions selectionnées d'une équation
  $( "body" ).on "click", ".simplifier_les_monomes", () ->
    id = $( ".focus" ).attr("id").split("_")[1]
    simplifier_les_monomes(id)
    
  #Obtenir la solution de l'equation s'il ne reste plus qu'un symbole à gauche
  $( "body" ).on "click", ".obtenirSolution", () ->
    id = $( ".focus" ).attr("id").split("_")[1]
    obtenir_la_solution(id)
      
  # Ajouter un terme a chaque membre de l'equation
  $( "body" ).on "click", ".ajouter", () ->
    id = $( ".focus" ).attr("id").split("_")[1]
    if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
    array = monome_comme_array $( "#equation_string" ).val()
    ajouter_un_terme_a_chaque_membre(array,id,1)
   
  # Retrancher un terme a chaque membre de lequation
  $( "body" ).on "click", ".retrancher", () ->
    id = $( ".focus" ).attr("id").split("_")[1]
    if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
    array = monome_comme_array $( "#equation_string" ).val()
    ajouter_un_terme_a_chaque_membre(array,id,-1)
        
  # multiplier par une fraction chaque membre de lequation
  $( "body" ).on "click", ".multiplier", () ->
    id = $( ".focus" ).attr("id").split("_")[1]
    if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
    array = monome_comme_array $( "#equation_string" ).val()
    if array.length is 1
      facteur = valeur_comme_fraction array[0]
      multiplier_chaque_membre_par(facteur,id)
    else
      alert "Il faut un coefficient seul"  
 
  # diviser par une fraction chaque membre de lequation
  $( "body" ).on "click", ".diviser", () ->
    id = $( ".focus" ).attr("id").split("_")[1]
    if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
    array = monome_comme_array $( "#equation_string" ).val()
    if array.length is 1
      facteur = valeur_comme_fraction array[0]
      facteur.inverse()
      multiplier_chaque_membre_par(facteur,id)
    else
      alert "Il faut un coefficient seul"
       
  # effectuer la somme, par membre, des termes selectionnés
  $( "body" ).on "click", ".sommationMonome", () ->
    id = parseInt $( ".focus" ).attr("id").split("_")[1]
    if $( "#equation_#{id} ul > .droite.selected" ).length>0
      sommation_par_membre("droite",id)
    if $( "#equation_#{id} ul > .gauche.selected" ).length>0
      sommation_par_membre("gauche",id)
    
   
  $( "body" ).on "click", "#generer_equation", () ->
    signes =  ['≤', '≤', '≥', '>', '<', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=']
    randomIndex = Math.floor Math.random() * signes.length
    randomSigne = signes[randomIndex]
    n = Math.floor(10*Math.random())+1
    mdg = n_termes_string(n)
    mdd = n_termes_string(n)
    equation = "#{mdg} #{randomSigne} #{mdd}"
    $( "#equation_string" ).val(equation)
  
  $( "body" ).on "click", ".copier", () ->
    id = parseInt $( ".focus" ).attr("id").split("_")[1]
    copier_symbole = $( "#equation_#{id} > ul.membreDeGauche > li").attr("data-symbol")
    copier_contenu = $( "#equation_#{id} > ul.membreDeDroite > li")
    alert "symbole copié : #{copier_symbole}"
    
  check_substitute = (side,id) ->
    Side = if side is "gauche" then "Gauche" else "Droite"
    #alert "#membreDe#{Side}_#{id} > li"
    #alert $( "#membreDe#{Side}_#{id} > li").length
    $( "#membreDe#{Side}_#{id} > li").each ->
      #alert copier_symbole + " vs " + $( this ).attr( "data-symbol")
      if $( this ).attr( "data-symbol") is copier_symbole
        html = ""
        fraction1 = valeur_comme_fraction $( this ).attr( "data-value") 
        copier_contenu.each ->
          fraction2 = valeur_comme_fraction $( this ).attr("data-value")
          value = multiplier_deux_fractions fraction1, fraction2
          symbol = $( this ).attr("data-symbol")
          if symbol
            html += "<li class='monome #{side}' data-value='#{value.numerateur}/#{value.denominateur}' data-type='symbol' data-symbol='#{symbol}'></li>"
          else
            html += "<li class='monome #{side}' data-value='#{value.numerateur}/#{value.denominateur}' data-type='rationnel'></li>"  
        $( this ).hide 1000, () -> 
          $( this ).remove()
          $( "#membreDe#{Side}_#{id}" ).append(html)
          mettre_a_jour_les_monomes()       
   
  $( "body" ).on "click", ".coller", () ->
    id = parseInt $( ".focus" ).attr("id").split("_")[1]
    check_substitute("gauche", id)
    check_substitute("droite", id)
          
  $( "body" ).on "click", "#add_equation", () ->
    id++
    if s = $( "#equation_string" ).val()
      if s.slice(-1) in liste_des_chiffres
        $( "#equation_string" ).val(s + ')')
      # On récupère l'equation et on enlève tous les whitespaces \s+
      s = $( "#equation_string" ).val().replace(/\s+/g, '')
      # regex digest !
      pattern_equation = /(\([\+\-]*\d+[/\d+]*\)(\w{1,}²{0,1})*)(\+(\([\+\-]*\d+[/\d+]*\)(\w{1,}²{0,1})*))*[<≤=≥>](\([\+\-]*\d+[/\d+]*\)(\w{1,}²{0,1})*)(\+(\([\+\-]*\d+[/\d+]*\)(\w{1,}²{0,1})*))*/g
      foo = s.match(pattern_equation)
      if foo[0].length is s.length
        signe = s.match(/[<≤=≥>]/g)[0]
        s = s.split(signe)
        mdg = s[0].split("+")
        mdd = s[1].split("+")   
        html =  """
                <div id='equation_#{id}' class='equation' >
                    <button id='deleteButton_{id}' class='deleteButton' title='Supprimer cette équation'>X</button>                  
                """
        html += membre_as_html(mdg,"gauche",id)
        html += "<span id='signe_#{id}' class='signe'>#{signe}</span>"
        html += membre_as_html(mdd,"droite",id)
        html += "<p id='solution_#{id}'></p></div>"
        $( "body" ).append(html)
        mettre_a_jour_les_monomes()
        doSort()
      else
        alert "Vérifier que l'équation est correctement formatée"
    doSort()
      