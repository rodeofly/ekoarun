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
      html = "<span class='moins'>&#8210;</span><span class='rationnel'>" +Math.abs(fraction.numerateur)+ "</span>"
    else
      html = "<span class='plus'>+</span><span class='rationnel'>" +fraction.numerateur+ "</span>"
  else
    if fraction.numerateur < 0
      html = "<span class='moins'>&#8210;</span><span class='fraction'><span class='top'>" +Math.abs(fraction.numerateur)+ "</span><span class='bottom'>" + fraction.denominateur+ "</span></span>"
    else
      html = "<span class='plus'>+</span><span class='fraction'><span class='top'>" +fraction.numerateur+ "</span><span class='bottom'>" + fraction.denominateur+ "</span></span>"
  
#Afficher la solution d'une équation
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

# Afficher le contenu des termes de l'equation  
mettre_a_jour_les_monomes = ->
  $(".monome").each ->
    typeOf = $( this ).attr("data-type")  
    fraction = value_comme_fraction $( this ).attr( "data-value")
    html = fraction_as_html(fraction, typeOf)  
    switch typeOf
      when "symbol"
        symbol = $( this ).attr("data-symbol")
        if fraction.numerateur*fraction.denominateur in [-1,1]
          if fraction.numerateur/fraction.denominateur is 1
            $( this ).html( "<span class='plus'>+</span>" + "<span>" + symbol + "</span>" )
          else
            $( this ).html( "<span class='moins'>&#8210;</span>" + "<span>" + symbol + "</span>" )
        else
          $( this ).html( html + "<span>" + symbol + "</span>" )                      
      when "rationnel"
        $( this ).html( html )
  $(".equation").each ->
    id = $( this ).attr("id").split("_")[1]
    $li_gauche = $( "#equation_#{id} > ul.membreDeGauche > li")
    if $li_gauche.length is 1 and $li_gauche.attr("data-symbol")
      if $li_gauche.attr("data-value") is "1/1" or $li_gauche.attr("data-value") is "1"
        $( "#copier_#{id}" ).show()
      else
        $( "#copier_#{id}" ).hide()
    else
      $( "#copier_#{id}" ).hide()
  
# effectuer la somme, par membre, des termes selectionnés
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

#simplifier les fractions sélectionnées d'une équation
simplifier_les_fractions = (id) ->
  $( "#equation_#{id} > ul > li.selected" ).each ->
    value = value_comme_fraction $( this ).attr( "data-value")
    value.irreductible()
    $( this ).attr( "data-value", "#{value.numerateur}/#{value.denominateur}")
  mettre_a_jour_les_monomes()

#Modifier un terme lors de son passage d'un membre a l'autre de l'équation   
changer_de_membre = (event, ui,id) ->
  value = value_comme_fraction(ui.item.attr("data-value"))
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
      connectWith: "#membreDeGauche_" + id,
      placeholder: "monome placeholder",
      update : (event, ui) ->
        mettre_a_jour_les_monomes(id)
      receive : (event, ui) ->
        changer_de_membre(event, ui,id)
  
# On Dom Ready !
$ ->
  mettre_a_jour_les_monomes()
  
  id = 25
  copier_symbole= ""
  copier_contenu= {}
  changementSens = { '=': '=', '<': '>', '>': '<', '≤': '≥', '≥': '≤' }
 
  # inserer un signe dans le champs de saisie des équations
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
      
  # selectionner un terme
  $('body').on "click", "li", () ->
    $(this).toggleClass("selected")
  
  #Simplifier les fractions selectionnées d'une équation
  $( "body" ).on "click", ".simplifier_les_fractions", () ->
    id = $( this ).attr("id").split("_")[1]
    simplifier_les_fractions(id)
    
  #Obtenir la solution de l'equation s'il ne reste plus qu'un symbole à gauche
  #Simplifier les fractions selectionnées d'une équation
  $( "body" ).on "click", ".obtenirSolution", () ->
    id = $( this ).attr("id").split("_")[1]
    obtenir_la_solution(id)
    
  # Ajouter un terme a chaque membre de lequation
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
  
  # Retrancher un terme a chaque membre de lequation
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
      
  # multiplier par une fraction chaque membre de lequation
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
  
  # effectuer la somme, par membre, des termes selectionnés
  $( "body" ).on "click", ".sommationMonome", () ->
    id = parseInt $( this ).attr("id").split("_")[1]
    if $( "#equation_#{id} .selected" ).length>0
        sommation_par_membre("gauche",id) 
        sommation_par_membre("droite",id)
    else alert("Selectionner des monomes en cliquant dessus !")

  # selectionner tous les termes d'une equation
  $( "body" ).on "click", ".selectAllButton", () ->
    id = parseInt $( this ).attr("id").split("_")[1]
    $("#equation_" + id + " ul > .monome").addClass( "selected" )
  
  # Déselectionner tous les termes d'une equation      
  $( "body" ).on "click", ".unselectAllButton", () ->
    id = parseInt $( this ).attr("id").split("_")[1]
    switch id
      when 0
        $(".monome.selected").toggleClass( "selected" )
      else
        $("#equation_" + id + " ul > .monome.selected").toggleClass( "selected" )
  
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
    id = parseInt $( this ).attr("id").split("_")[1]
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
         fraction1 = value_comme_fraction $( this ).attr( "data-value") 
         copier_contenu.each ->
           fraction2 = value_comme_fraction $( this ).attr("data-value")
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
    id = parseInt $( this ).attr("id").split("_")[1]
    check_substitute("gauche", id)
    check_substitute("droite", id)
          
  $( "body" ).on "click", "#add_equation", () ->
    id++
    # On récupère l'equation et on enlève tous les whitespaces \s+
    s = $( "#equation_string" ).val().replace(/\s+/g, '')
    # regex digest !
    pattern_equation = /(\([\+\-]*\d+[/\d+]*\)(\w²{0,1})*)(\+(\([\+\-]*\d+[/\d+]*\)(\w²{0,1})*))*[<≤=≥>](\([\+\-]*\d+[/\d+]*\)(\w²{0,1})*)(\+(\([\+\-]*\d+[/\d+]*\)(\w²{0,1})*))*/g
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
                  <button id='selectAllButton_#{id}' class='selectAllButton' title='Sélectionner tous les termes de cette équation'>&#9745;</button>
                  <button id='unselectAllButton_#{id}' class='unselectAllButton' title='Désélectionner tous les termes de cette équation'>&#9744;</button>
                  <button id='sommationMonome_#{id}' class='sommationMonome' title='Effectuer la somme des termes sélectionnés dans chaque membre'>&Sigma;</button>
                  <button id='simplifier_#{id}' class='simplifier_les_fractions' title='rendre les fractions des termes sélectionnés irréductibles'>&frac12;</button>
                  <button id='ajouter_#{id}' class='ajouter' title='Ajouter un terme à chaque membre de cette équation'>+</button>
                  <button id='retrancher_#{id}' class='retrancher' title='Retrancher un terme à chaque membre de cette équation'>-</button>       
                  <button id='multiplier_#{id}' class='multiplier' title='Multiplier par un terme chaque membre de cette équation'>&#215;</button>        
                  <button id='diviser_#{id}' class='diviser'  title='Diviser par un terme chaque membre de cette équation'>&#247;</button>
                  <input id='poids_#{id}'  class='poids' type='text' size='5'>
                  <button id='obtenirSolution_#{id}' class='obtenirSolution'  title='Obtenir la solution de cette équation'>?</button>
                  <button id='copier_#{id}' class='copier'  title='Copier cette valeur'>&#169;</button>
                  <button id='coller_#{id}' class='coller'  title='Injecter la valeur'>&#8618;</button>
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
       
    doSort()
    
  