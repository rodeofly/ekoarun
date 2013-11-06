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

# Enlever le plus en première position
enlever_le_plus = -> $( "ul > li:first-child > span.plus").remove()
# Evaluer value comme fraction
value_comme_fraction = (value) ->
  foo = value.split("/")
  if foo.length>1
    fraction = new Fraction parseInt(foo[0]), parseInt(foo[1])
  else
    fraction = new Fraction parseInt(foo[0]), 1

# afficher une fraction en html
fraction_as_html = (fraction) ->
  if fraction.denominateur is 1
    if fraction.numerateur < 0
      html = "<span class='moins'>&#8210;</span><span class='integer'>" +Math.abs(fraction.numerateur)+ "</span>"
    else
      html = "<span class='plus'>+</span><span class='integer'>" +fraction.numerateur+ "</span>"
  else
    if fraction.numerateur < 0
      html = "<span class='moins'>&#8210;</span><span class='fraction'><span class='top'>" +Math.abs(fraction.numerateur)+ "</span><span class='bottom'>" + fraction.denominateur+ "</span></span>"
    else
      html = "<span class='plus'>+</span><span class='fraction'><span class='top'>" +fraction.numerateur+ "</span><span class='bottom'>" + fraction.denominateur+ "</span></span>"
  
#Afficher les données contenus dans les monomes
obtenir_la_solution = (id) ->
  
  if $( "#equation_#{id} > ul.membreDeGauche > li").length is 1 and $( "#equation_#{id} > ul.membreDeDroite > li").length is 1
    $li_gauche = $( "#equation_#{id} > ul.membreDeGauche > li")
    $li_droite = $( "#equation_#{id} > ul.membreDeDroite > li")
    if $li_gauche.attr("data-symbol") and not $li_droite.attr("data-symbol")
      if $li_gauche.attr("data-value") is "1/1"
        signe = $( "#signe_" + id ).text()
        value = value_comme_fraction($li_droite.attr( "data-value"))
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
        $("#solution_" + id).html solution
      else alert "On ne peut pas encore lire la solution ! il faut que le coefficient de l'inconnue soit 1."
    else alert "On ne peut pas encore lire la solution ! il faut une l'inconnue à gauche et une valeur à droite." 
  else alert "On ne peut pas encore lire la solution ! il faut un seul terme à gauche et un seul terme à droite." 
mettre_a_jour_les_monomes = ->
  $(".monome").each ->
    typeOf = $( this ).attr("data-type")  
    fraction = value_comme_fraction $( this ).attr( "data-value")
    html = fraction_as_html(fraction)  
    switch typeOf
      when "symbol"
        symbol = $( this ).attr("data-symbol")
        if $( this ).attr("data-value") in ["-1/1","1/1"]
          if fraction.numerateur is 1
            $( this ).html( "<span class='plus'>+</span>" + "<span>" + symbol + "</span>" )
          else
            $( this ).html( "<span class='moins'>&#8210;</span>" + "<span>" + symbol + "</span>" )

        else
          $( this ).html( html + "<span>" + symbol + "</span>" )                      
      when "rationnel"
        $( this ).html( html )
  enlever_le_plus()
  

sommation_par_membre = (side,id) ->    
    Side = if side is "gauche" then "Gauche" else "Droite"
    selected = "#membreDe" + Side + "_" + id + " > " + "li.monome." + side + ".selected"
    symbols = {}
    values = new Fraction 0, 1
    $( selected ).each ->
      typeOf = $( this ).attr("data-type")
      value = value_comme_fraction $( this ).attr( "data-value")
      symbol = $( this ).attr("data-symbol")   
      switch typeOf
        when "symbol"
          symbols[ symbol ] ?= new Fraction 0, 1
          symbols[ symbol ] = ajouter_deux_fractions(symbols[ symbol ], value)
        when "rationnel"
          values =  ajouter_deux_fractions(values, value)
    membre = "#membreDe#{Side}_#{id}"
    for symbol, value of symbols
      if value.numerateur isnt 0
        $( membre ).append("<li class='monome #{side}' data-value='#{value.numerateur}/#{value.denominateur}' data-type='symbol' data-symbol='#{symbol}'></li>")  
    if values.numerateur isnt 0
      $( membre ).append("<li class='monome #{side}' data-value='#{values.numerateur}/#{values.denominateur}' data-type='rationnel'></li>")
    $( selected ).hide 1000, () -> 
      $( selected ).remove()
      if $( membre + " li" ).length is 0
        $( membre ).append("<li class='monome #{side}' data-value='0' data-type='rationnel'></li>")
      mettre_a_jour_les_monomes()

reduceOne = (id) ->
  $( "#equation_#{id} > ul > li.selected" ).each ->
    value = value_comme_fraction $( this ).attr( "data-value")
    value.irreductible()
    $( this ).attr( "data-value", "#{value.numerateur}/#{value.denominateur}")
  mettre_a_jour_les_monomes()
  
reduce = () ->
  $( ".selected" ).each ->
    value = value_comme_fraction $( this ).attr( "data-value")
    value.irreductible()
    $( this ).attr( "data-value", "#{value.numerateur}/#{value.denominateur}")
  mettre_a_jour_les_monomes()

changer_de_membre = (event, ui,id) ->
  value = value_comme_fraction(ui.item.attr("data-value"))
  value = multiplier_deux_fractions(value, new Fraction(-1, 1))
  ui.item.attr("data-value", "#{value.numerateur}/#{value.denominateur}").toggleClass("gauche droite")
  if $( "#membreDeDroite_#{id} > li" ).length is 0
    $( "#membreDeDroite_#{id}" ).append("<li class='monome droite' data-value='0' data-type='rationnel'></li>")
  if $( "#membreDeGauche_#{id}  > li" ).length is 0
    $( "#membreDeGauche_#{id}" ).append("<li class='monome gauche' data-value='0' data-type='rationnel'></li>")
      
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
      connectWith: "#membreDeGauche_" + id,
      placeholder: "monome placeholder",
      update : (event, ui) ->
        mettre_a_jour_les_monomes(id)
      receive : (event, ui) ->
        changer_de_membre(event, ui,id)
  
# On Dom Ready !
$ ->
    
  $( "#helper_strictement_inferieur" ).click () ->
    $( "#equation_string" ).val($( "#equation_string" ).val()+"<")
    
  $( "#helper_inferieur_ou_egal" ).click () ->
    $( "#equation_string" ).val($( "#equation_string" ).val()+"≤")
  
  $( "#helper_egal" ).click () ->
    $( "#equation_string" ).val($( "#equation_string" ).val()+"=")
    
  $( "#helper_superieur_ou_egal" ).click () ->
    $( "#equation_string" ).val($( "#equation_string" ).val()+"≥")
  
  $( "#helper_strictement_superieur" ).click () ->
    $( "#equation_string" ).val($( "#equation_string" ).val()+">")
  
  # effacer une equation
  $('body').on "click", ".deleteButton", () ->
    id = $( this ).attr("id").split("_")[1]
    $( "#equation_#{id}" ).hide 'slow', () -> 
      $( "#equation_#{id}" ).remove()
      
  # selectionner un monome
  $('body').on "click", "li", () ->
    $(this).toggleClass("selected")
  
  #Obtenir la solution de l'equation s'il ne reste plus qu'un symbol à gauche
  $( "body" ).on "click", ".reduceOne", () ->
    id = $( this ).attr("id").split("_")[1]
    reduceOne(id)
    
  #Obtenir la solution de l'equation s'il ne reste plus qu'un symbol à gauche
  $( "body" ).on "click", ".obtenirSolution", () ->
    id = $( this ).attr("id").split("_")[1]
    obtenir_la_solution(id)
    
  # Ajouter un monome a chaque membre de lequation
  $( "body" ).on "click", ".ajouter", () ->
    id = $( this ).attr("id").split("_")[1]
    if $( "#poids_" + id ).val()
      value = value_comme_fraction $( "#poids_" + id ).val()
    else
      alert "il manque quelque chose !"
    if value.numerateur
      $( "#membreDeGauche_" + id ).append("<li class='monome gauche' data-type='rationnel' data-value='#{value.numerateur}/#{value.denominateur}'><span></span></li>")
      $( "#membreDeDroite_" + id ).append("<li class='monome droite' data-type='rationnel' data-value='#{value.numerateur}/#{value.denominateur}'><span></span></li>")
      mettre_a_jour_les_monomes()
  
  # Retrancher un monome a chaque membre de lequation
  $( "body" ).on "click", ".retrancher", () ->
    id = $( this ).attr("id").split("_")[1]
    if $( "#poids_" + id ).val()
      value = value_comme_fraction $( "#poids_" + id ).val()
      value.oppose()
    else
      alert "il manque quelque chose !"
    if value.numerateur
      $( "#membreDeGauche_" + id).append("<li class='monome gauche' data-type='rationnel' data-value='#{value.numerateur}/#{value.denominateur}'><span></span></li>")
      $( "#membreDeDroite_" + id ).append("<li class='monome droite' data-type='rationnel' data-value='#{value.numerateur}/#{value.denominateur}'><span></span></li>")
      mettre_a_jour_les_monomes()
      
  # multiplier par une fraction a chaque membre de lequation
  $( "body" ).on "click", ".multiplier", () ->
    id = $( this ).attr("id").split("_")[1]
    if $( "#poids_" + id ).val()
      facteur = value_comme_fraction $( "#poids_" + id ).val()
      if $( "#poids_" + id ).val() < 0
        $("#signe_" + id).text changementSens[$("#signe_" + id).text()]
    else
      alert "il manque quelque chose !"
    $( "#equation_" + id + " > ul > li.monome").each ->
      value = value_comme_fraction $( this ).attr( "data-value")
      value = multiplier_deux_fractions(value,facteur)
      $( this ).attr( "data-value","#{value.numerateur}/#{value.denominateur}")
    mettre_a_jour_les_monomes()

  # diviser par une fraction a chaque membre de lequation
  $( "body" ).on "click", ".diviser", () ->
    id = $( this ).attr("id").split("_")[1]
    if $( "#poids_" + id ).val()
      facteur = value_comme_fraction $( "#poids_" + id ).val()
      if $( "#poids_" + id ).val() < 0
        $("#signe_" + id).text changementSens[$("#signe_" + id).text()]
    else
      alert "il manque quelque chose !" 
    facteur.inverse()
    $("#equation_" + id + " > ul > li.monome").each ->
      value = value_comme_fraction $( this ).attr( "data-value")
      value = multiplier_deux_fractions(value,facteur)
      $( this ).attr( "data-value","#{value.numerateur}/#{value.denominateur}")
    mettre_a_jour_les_monomes()    
  
  $( "body" ).on "click", ".sommationMonome", () ->
    id = parseInt $( this ).attr("id").split("_")[1]
    if $( "#equation_#{id} .selected" ).length>0
        sommation_par_membre("gauche",id) 
        sommation_par_membre("droite",id)
    else alert("Selectionner des monomes en cliquant dessus !")

   
  
  $( "#reduce" ).click () -> if $( ".selected" ).length>0 then reduce() else alert("Selectionner des monomes en cliquant dessus !")
  
  $( "body" ).on "click", ".selectButton", () ->
    id = parseInt $( this ).attr("id").split("_")[1]
    switch id
      when 0
        $(".monome").addClass( "selected" )
      else
        $("#equation_" + id + " ul > .monome").addClass( "selected" )
  $( ".unselectButton" ).click () ->
    id = parseInt $( this ).attr("id").split("_")[1]
    switch id
      when 0
        $(".monome.selected").toggleClass( "selected" )
      else
        $("#equation_" + id + " ul > .monome.selected").toggleClass( "selected" )
     
  $( "#add_equation" ).on "click", ->
    id++
    # On récupère l'equation et on enlève tous les whitespaces \s+
    s = $( "#equation_string" ).val().replace(/\s+/g, '')
    # regex digest !
    pattern_equation = /(\([\+\-]*\d+[/\d+]*\)\w*)(\+(\([\+\-]*\d+[/\d+]*\)\w*))*[<≤=≥>](\([\+\-]*\d+[/\d+]*\)\w*)(\+(\([\+\-]*\d+[/\d+]*\)\w*))*/g
    foo = s.match(pattern_equation)
    if foo[0].length is s.length
      signe = s.match(/[<≤=≥>]/g)[0]
      s = s.split(signe)
      mdg = s[0].split("+")
      mdd = s[1].split("+")   
      html =  """
              <br />
              <div id='equation_#{id}' class='equation' >
                <div id='panel_#{id}' class='buttons'>
                  <button id='deleteButton_#{id}' class='deleteButton' title='Supprimer cette équation'>X</button>
                  <button id='selectButton_#{id}' class='selectButton' title='Sélectionner tous les termes de cette équation'>&#9745;</button>
                  <button id='unselectButton_#{id}' class='unselectButton' title='Désélectionner tous les termes de cette équation'>&#9744;</button>
                  <button id='sommationMonome_#{id}' class='sommationMonome' title='Effectuer la somme des termes sélectionnés dans chaque membre'>&Sigma;</button>
                  <button id='reduce_#{id}' class='reduceOne' title='rendre les fractions des termes sélectionnés irréductibles'>&frac12;</button>
                  <button id='ajouter_#{id}' class='ajouter' title='Ajouter un terme à chaque membre de cette équation'>+</button>
                  <button id='retrancher_#{id}' class='retrancher' title='Retrancher un terme à chaque membre de cette équation'>-</button>       
                  <button id='multiplier_#{id}' class='multiplier' title='Multiplier par un terme chaque membre de cette équation'>&#215;</button>        
                  <button id='diviser_#{id}' class='diviser'  title='Diviser par un terme chaque membre de cette équation'>&#247;</button>
                  <input id='poids_#{id}'  class='poids' type='text' size='5'>
                  <button id='obtenirSolution_#{id}' class='obtenirSolution'  title='Obtenir la solution de cette équation'>?</button>
                  <p id="solution_#{id}"></p>  
                </div>
              """
      html += membre_as_html(mdg,"gauche",id)
      html += "<span id='signe_#{id}' class='signe'>#{signe}</span>"
      html += membre_as_html(mdd,"droite",id)
      html += "</div>"
      $( "body" ).append(html)
      mettre_a_jour_les_monomes()
      doSort()
    else
      alert "Vérifier que l'équation est correctement formaté"
       
   
   mettre_a_jour_les_monomes()
   doSort()
   id = 25
   changementSens = { '=': '=', '<': '>', '>': '<', '≤': '≥', '≥': '≤' }
   
      
    
  