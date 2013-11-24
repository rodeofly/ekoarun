debug = false
unique_id = 1
activer_copier_symbole= ""
activer_copier_contenu= {}
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
    foo = new Fraction @numerateur,@denominateur

  inverse: () ->
    if @numerateur isnt 0
      [@numerateur,@denominateur]=[@denominateur,@numerateur]
      foo = new Fraction @numerateur,@denominateur
  
  oppose: () ->
    @numerateur = -@numerateur
    foo = new Fraction @numerateur,@denominateur
     
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
string_to_frac = (value) ->
  alert "string_to_frac(#{value}) starts !" if debug
  foo = value.split("/")
  switch foo.length
    when 2
      [n,d] = [parseInt(foo[0]), parseInt(foo[1])]
      if n? and d? then foo = new Fraction n,d else alert "Erreur : string_to_frac, n is #{n} and d is #{d} !"
    when 1
      n = parseInt(foo[0])
      if n? then foo = new Fraction n,1 else alert "Erreur : string_to_frac, n is #{n} !"
    else
      alert "Erreur : string_to_frac, value is #{value} !"
    
# afficher une fraction en html
frac_to_html = (fraction) ->
  if fraction.denominateur is 1
    if fraction.numerateur < 0
      html = "<span class='moins'>&minus;</span><span class='rationnel'>#{Math.abs(fraction.numerateur)}</span>"
    else
      html = "<span class='plus'>&plus;</span><span class='rationnel'>#{fraction.numerateur}</span>"
  else
    if fraction.numerateur < 0
      html = "<span class='moins'>&minus;</span><span class='fraction'><span class='top'>#{Math.abs(fraction.numerateur)}</span><span class='bottom'>#{fraction.denominateur}</span></span>"
    else
      html = "<span class='plus'>&plus;</span><span class='fraction'><span class='top'>#{fraction.numerateur}</span><span class='bottom'>#{fraction.denominateur}</span></span>"

mettre_a_jour_ce_monome = (monome)->
  try
    id = monome.parent().attr("id").split("_")[1]
    data_type = monome.attr("data-type")
    fraction = string_to_frac monome.attr( "data-value")
    html = "<span id='monome_html_#{id}' class='monome_html'>"
    html += frac_to_html fraction
    switch data_type
      when "symbol"
        symbol = monome.attr("data-symbol")
        if fraction.numerateur*fraction.denominateur in [-1,1]
          if fraction.numerateur/fraction.denominateur is 1
            monome.html( "<span class='droppable'><span class='plus'>+</span><span>#{symbol}</span></span>" )
          else
            monome.html( "<span class='droppable'><span class='moins'>&minus;</span><span>#{symbol}</span></span>" )
        else
          monome.html( "#{html}<span>#{symbol}</span></span>")                   
      when "rationnel"
        monome.html( "#{html}</span>" )
    
    $li_gauche = $( "#membreDeGauche_#{id} > li")
    if $li_gauche.length is 1 and $li_gauche.attr("data-symbol")
      if $li_gauche.attr("data-value") is "1/1" or $li_gauche.attr("data-value") is "1"
        $( "#activer_copier_#{id}" ).show()
      else
        $( "#activer_copier_#{id}" ).hide()
    else
      $( "#activer_copier_#{id}" ).hide()
  catch error
    alert "mettre_a_jour_ce_monome : #{error}"
  finally
  
# Afficher le contenu des termes de l'equation  
mettre_a_jour_les_monomes = ->  
  $(".equation").each ->
    id = $( this ).attr("id").split("_")[1]
    for Side in ["Gauche","Droite"]
      side = if Side is "Gauche" then "gauche" else "Droite"
  $(".monome").each ->
    mettre_a_jour_ce_monome( $( this ) )      
  doSort()
  
#Ajouter un monome à un autre monome s'ils sont de meme type
ajouter_m1_a_m2 = (m1,m2) ->
  if (m1.attr("data-type") is m2.attr("data-type")) and (m1.attr("data-type") is "rationnel" or m1.attr("data-symbol") is m2.attr("data-symbol"))
    v = ajouter_deux_fractions string_to_frac(m1.attr( "data-value")), string_to_frac(m2.attr( "data-value"))
    m1.hide
      duration: "slow", 
      easing: "easeInCirc", 
      complete: -> 
        m1.remove()
        m2.attr("data-value", "#{v.numerateur}/#{v.denominateur}")
        mettre_a_jour_ce_monome m2        
  else
    alert "On ne mélange pas symboles et les chiffres !"
  
doSortSide = (Side) ->
  oppositeSide = if Side is "Gauche" then "Droite" else "Gauche"
  side = if Side is "Gauche" then "gauche" else "Droite"
  $("#equations_div").sortable  
  $( ".membreDe#{Side}" ).each ->
    id = $( this ).attr("id").split("_")[1]
    $( "#membreDe#{Side}_#{id} > li" ).droppable
      accept: "#membreDe#{Side}_#{id} > li"
      hover: -> $(this).css('cursor','crosshair')
      hoverClass: "ui-state-hover"
      cursor: 'crosshair'
      tolerance : "pointer"
      drop: (event, ui) ->
        ajouter_m1_a_m2(ui.draggable, $( this ) )
        mettre_a_jour_ce_monome $( this )    
    $( "#membreDe#{Side}_#{id}" ).sortable
      connectWith: "#membreDe#{oppositeSide}_#{id}",
      update : -> mettre_a_jour_les_monomes(id),
      receive : (event, ui) ->
        changer_de_membre(event, ui,id)
# Rendre sortable et connectable les equations
doSort = () -> 
  doSortSide("Gauche") 
  doSortSide("Droite")
  $("#equations_div" ).sortable()
        
#Afficher la solution d'une équation
obtenir_la_solution = (id) ->
  if $( "#equation_#{id} > ul.membreDeGauche > li").length is 1 and $( "#equation_#{id} > ul.membreDeDroite > li").length is 1
    $li_gauche = $( "#equation_#{id} > ul.membreDeGauche > li")
    $li_droite = $( "#equation_#{id} > ul.membreDeDroite > li")
    if $li_gauche.attr("data-symbol") and not $li_droite.attr("data-symbol")
      if $li_gauche.attr("data-value") is "1/1" or $li_gauche.attr("data-value") is "1"
        signe = $( "#signe_#{id}" ).text()
        frac = string_to_frac($li_droite.attr( "data-value"))
        frac.irreductible()
        s = frac_to_html frac 
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

###############################################################################   unique_id++ 
# effectuer la somme, par membre, des termes selectionnés
sommation_par_membre = (side,id) ->    
  Side = if side is "gauche" then "Gauche" else "Droite"
  membre = "#membreDe#{Side}_#{id}"
  selected = "#{membre} > .#{side}.selected"
  alert "#{Side} + #{membre} + #{selected} +#{$( selected ).length}" if debug
  symbols = {}
  values = new Fraction 0, 1
  $( selected ).each ->
    data_type = $( this ).attr("data-type")
    value = string_to_frac $( this ).attr( "data-value")
    switch data_type
      when "symbol"
        symbol = $( this ).attr("data-symbol")   
        symbols[ symbol ] ?= new Fraction 0, 1
        symbols[ symbol ] = ajouter_deux_fractions(symbols[ symbol ], value)
      when "rationnel"
        values =  ajouter_deux_fractions(values, value)        
  for symbol, value of symbols
    $( membre ).append(insert_monome side, "#{value.numerateur}/#{value.denominateur}", "#{symbol}")  
  $( membre ).append(insert_monome side, "#{values.numerateur}/#{values.denominateur}")
  $( selected ).remove()
  mettre_a_jour_les_monomes()
  

#simplifier les fractions sélectionnées d'une équation
simplifier_ce_monome = (monome) ->
  try
    value = string_to_frac monome.attr( "data-value")
    value.irreductible()
    monome.attr( "data-value", "#{value.numerateur}/#{value.denominateur}")
    mettre_a_jour_ce_monome(monome)
  catch error
    alert error
  finally
    
  
#simplifier les fractions sélectionnées d'une équation
simplifier_les_monomes = (id) ->
  try
    $( "#equation_#{id} > ul > li.selected" ).each ->
      simplifier_ce_monome( $(this) )
  catch error
    print "simplifier_les_monomes: #{error}"
  finally

insert_monome = (side,fraction_string,symbol) ->
  try
    unique_id++
    if not symbol?
      foo = "<li id='monome_#{unique_id}' class='monome #{side}' data-value='#{fraction_string}' data-type='rationnel'></li>"
    else
      foo = "<li id='monome_#{unique_id}' class='monome #{side}' data-value='#{fraction_string}' data-type='symbol' data-symbol='#{symbol}'></li>"  
  catch error
      print "insert_monome: #{error}"
  finally
  
#Modifier un terme lors de son passage d'un membre a l'autre de l'équation   
changer_de_membre = (event, ui,id) ->
  try
    value = string_to_frac(ui.item.attr("data-value"))
    value.oppose()
    ui.item.attr("data-value", "#{value.numerateur}/#{value.denominateur}").toggleClass("gauche droite")
    if $( "#membreDeDroite_#{id} > li" ).length is 0
      $( "#membreDeDroite_#{id}" ).append(insert_monome "droite", "0")
    if $( "#membreDeGauche_#{id}  > li" ).length is 0
      $( "#membreDeGauche_#{id}" ).append(insert_monome "gauche", "0")
  catch error
      print "changer_de_membre: #{error}"
  finally

#Obtenir le code html d'un membre d'une equation    
membre_as_html = (membre,side,id) ->
  if side is "gauche"
    Side = "Gauche" 
  else
    Side = "Droite"
  html = "<ul id='membreDe#{Side}_#{id}' class='membreDe#{Side}'>"
  for monome in membre
    m = monome.split(")")
    if m[1]
      html += insert_monome side, m[0][1..], m[1]
    else
      unique_id++
      html += insert_monome side, m[0][1..]
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

#craignos !
monome_string_comme_array = (s) ->
  try
    pattern_terme = /\([\+\-]*\d+[/\d+]*\)(\w+²{0,1})*/g
    foo = s.match(pattern_terme)
    if foo and foo[0] is s
      alert "#{s} match regex:#{pattern_terme}" if debug
      foo = s.split(")")
      if foo[1] 
        foo = [foo[0][1..], foo[1]]
      else
        foo = [foo[0][1..]]
    else
      alert "Poids mal formé"
      foo = []
  catch error
    alert "monome_string_comme_array : #{error}"
  finally

monome_comme_array = (monome) ->
  if monome.attr( "data-type" ) is "rationnel"
    s = "(#{monome.attr( "data-value" )})"
  else
    s = "(#{monome.attr( "data-value" )})#{monome.attr( "data-symbol" )}"
  monome_string_comme_array(s)

add_panel_touch = (sign) ->
  try
    sign = if sign is "+" then 1 else -1
    if $( ".focus" )? then id = $( ".focus" ).attr("id").split("_")[1] else alert "Choisir une équation !"   
    array = monome_string_comme_array $( "#equation_string" ).val()
    value = string_to_frac array[0]
    value = multiplier_deux_fractions(value, string_to_frac "#{sign}")
    switch array.length
      when 1
        s = insert_monome "gauche", "#{value.numerateur}/#{value.denominateur}"
        $( "#membreDeGauche_#{id}" ).append(s)
        s = insert_monome "droite", "#{value.numerateur}/#{value.denominateur}"
        $( "#membreDeDroite_#{id}" ).append(s)
      when 2      
        symbol = array[1]
        s = insert_monome "gauche", "#{value.numerateur}/#{value.denominateur}", "#{symbol}"
        $( "#membreDeGauche_#{id}" ).append(s)
        s = insert_monome "droite", "#{value.numerateur}/#{value.denominateur}", "#{symbol}"
        $( "#membreDeDroite_#{id}" ).append(s)
      else
        alert "il manque quelque chose !"
  catch error
    alert "add_panel_touch : #{error} ;id=#{id}, array=#{array}"
  finally
    mettre_a_jour_les_monomes()
    $( "#equation_string" ).val("")

ajouter_un_terme_a_chaque_membre = (monome,id) ->
  try
    array = monome_comme_array monome
    value = string_to_frac array[0]
    switch array.length
      when 1
        s = insert_monome "gauche", "#{value.numerateur}/#{value.denominateur}"
        $( "#membreDeGauche_#{id}" ).append(s)
        s = insert_monome "droite", "#{value.numerateur}/#{value.denominateur}"
        $( "#membreDeDroite_#{id}" ).append(s)
      when 2      
        symbol = array[1]
        s = insert_monome "gauche", "#{value.numerateur}/#{value.denominateur}", "#{symbol}"
        $( "#membreDeGauche_#{id}" ).append(s)
        s = insert_monome "droite", "#{value.numerateur}/#{value.denominateur}", "#{symbol}"
        $( "#membreDeDroite_#{id}" ).append(s)
      else
        alert "il manque quelque chose !"
  catch error
    alert "ajouter_un_terme_a_chaque_membre : #{error} ;id=#{id}, array=#{array}"
  finally
    mettre_a_jour_les_monomes()
    $( "#equation_string" ).val("")  
  
multiplier_chaque_membre_par = (facteur,id) ->
  if facteur.numerateur
    if facteur.numerateur/facteur.denominateur < 0 then $("#signe_#{id}").text changementSens[$("#signe_#{id}").text()]
    $( "#equation_#{id} > ul > li.monome").each ->
      value = string_to_frac $( this ).attr( "data-value")
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
  
  #Saisie 'intelligente' de l'equation   
  $('body').on "click", ".panel_touch", () ->
    char = $( this ).attr( "id" ).split("_")[1]    
    saisie = $( "#equation_string" ).val()
    caractere_precedent = if saisie.length then saisie.slice(-1) else ''      
    
    if char is '←'
      if saisie.length < 2
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

# effacer la zone de saisie  
  $('body').on "click", "#effacer_equation_string", () ->
    $( "#equation_string" ).val( '' ) 
      
# effacer une equation
  $('body').on "click", ".deleteButton", () ->
    if $( ".focus" ).attr("id")
      id = $( ".focus" ).attr("id").split("_")[1]
      $( "#equation_#{id}.focus" ).hide 'easeInElastic', () -> 
        $( "#equation_#{id}.focus" ).remove()
  
  # additionner les termes selectionnés d'un membre par double click
  $('body').on "dblclick", ".selected", (event) ->
    event.stopImmediatePropagation()
    id = if $( ".focus" ).attr("id") then $( ".focus" ).attr("id").split("_")[1] else alert "Selectionner une équation !"
    if id
      if $( this ).hasClass( "gauche" ) and $("#equation_#{id} ul > .gauche.selected").length>1
        sommation_par_membre("gauche",id)
      else
        if $( this ).hasClass( "droite" ) and $("#equation_#{id} ul > .droite.selected").length>1
          sommation_par_membre("droite",id)
  
  $( "body" ).on "click", ".ajouterChoixMonome", () ->
    id = $( this ).attr("id").split("_")[1]
    data_type = $( this ).attr( "data-type" )
    data_value = $( this ).attr( "data-value" )
    if data_type is "symbol"
      symbol = $( this ).attr( "data-symbol" )
      html = """
        <li data-type='symbol' data-value='#{data_value}' data-symbol='#{symbol}'</li>'
             """
    else
      html = """
        <li data-type='rationnel' data-value='#{data_value}'></li>'
             """
    monome = $($.parseHTML(html))
    ajouter_un_terme_a_chaque_membre monome, id
   
   # multiplier par une fraction chaque membre de lequation 
  $( "body" ).on "click", ".multiplierChoixMonome", () ->
    $( "#choixMonome_#{id}" ).empty()
    id = $( this ).attr("id").split("_")[1]
    data_value = $( this ).attr( "data-value" )
    facteur = string_to_frac data_value
    multiplier_chaque_membre_par(facteur,id)
    

   # multiplier par une fraction chaque membre de lequation 
  $( "body" ).on "click", ".supprimerChoixMonome", () ->
    id = $( this ).attr("id").split("_")[1]
    $( "#choixMonome_#{id}" ).empty()
          
  # selectionner un terme
  $('body').on "click", "li", (event) ->
    event.stopImmediatePropagation()
    frac = string_to_frac $(this).attr( "data-value" )
    foo = new Fraction frac.numerateur, frac.denominateur
    if frac.numerateur is 0
      if $(this).siblings().length > 0
        $( this ).remove()
      else
        $( this ).attr( "data-type", "rationnel" )
        $( this ).attr( "data-value", "0" )
        mettre_a_jour_ce_monome $( this )
    else
      id = $( this ).parent().attr("id").split("_")[1]
      $( "#choixMonome_#{id}" ).empty()
      inv_frac = foo.inverse()
      foo.inverse()
      opp_frac = foo.oppose()
      foo.oppose()
      irr_frac = new Fraction foo.numerateur, foo.denominateur
      irr_frac.irreductible()
      $(this).toggleClass("selected")
      $( "#equation_string").val("(#{$(this).attr( "data-value" )})")
      data_type = $(this).attr( "data-type" )
      switch data_type
        when "symbol"
          symbol =  $(this).attr( "data-symbol" )
          html = """
            <button class="simplifier_les_monomes" title="rendre les fractions des termes sélectionnés irréductibles">#{frac_to_html frac} = #{frac_to_html irr_frac}</button>
            <button id='multiplierChoixMonome_#{id}' class='multiplierChoixMonome' data-type='rationnel' data-value='#{frac.numerateur}/#{frac.denominateur}'>*(#{frac_to_html frac})</button>
            <button id='diviserChoixMonome_#{id}'    class='multiplierChoixMonome' data-type='rationnel' data-value='#{inv_frac.numerateur}/#{inv_frac.denominateur}'>*(#{frac_to_html inv_frac})</button>
            <button id='ajouter_#{id}'               class='ajouterChoixMonome' data-type='symbol' data-value='#{frac.numerateur}/#{frac.denominateur}' data-symbol='#{symbol}'>#{frac_to_html frac}#{symbol}</button>
            <button id='retrancher_#{id}'            class='ajouterChoixMonome' data-type='symbol' data-value='#{opp_frac.numerateur}/#{opp_frac.denominateur}' data-symbol='#{symbol}'>#{frac_to_html opp_frac}#{symbol}</button>
            <button id='supprimerChoixMonome_#{id}'  class='supprimerChoixMonome' >x</button>
                  """
          $( "#choixMonome_#{id}" ).append(html)
        when "rationnel"
          html = """
            <button class="simplifier_les_monomes" title="rendre les fractions des termes sélectionnés irréductibles">#{frac_to_html frac} = #{frac_to_html irr_frac}</button>
            <button id='multiplierChoixMonome_#{id}' class='multiplierChoixMonome' data-type='rationnel' data-value='#{frac.numerateur}/#{frac.denominateur}'>*(#{frac_to_html frac})</button>
            <button id='diviserChoixMonome_#{id}' class='multiplierChoixMonome' data-type='rationnel' data-value='#{inv_frac.numerateur}/#{inv_frac.denominateur}'>*(#{frac_to_html inv_frac})</button>
            <button id='ajouterChoixMonome_#{id}' class='ajouterChoixMonome' data-type='rationnel' data-value='#{frac.numerateur}/#{frac.denominateur}'>#{frac_to_html frac}</button>
            <button id='retrancherChoixMonome_#{id}' class='ajouterChoixMonome' data-type='rationnel' data-value='#{opp_frac.numerateur}/#{opp_frac.denominateur}'>#{frac_to_html opp_frac}</button>
            <button id='supprimerChoixMonome_#{id}'  class='supprimerChoixMonome' >x</button>
                 """
          $( "#choixMonome_#{id}" ).append(html)
        else
          alert "aie"
      
      
      
      
  
  #Focus sur une équation et/ou désélectionner les termes d'une équation en cliquant à coté
  $('body').on "click", ".equation", () ->
    $( ".focus" ).toggleClass("focus")
    $( this ).toggleClass("focus")
    focus_id = parseInt $( this ).attr("id").split("_")[1]
    $( ".selected" ).toggleClass( "selected" )
  
  #focus sur une équation par le signe
  $('body').on "click", ".signe", () ->
    $( ".focus" ).toggleClass("focus")
    id = $( this ).attr("id").split("_")[1]
    $("#equation_#{id}").toggleClass("focus")
    $( ".selected" ).toggleClass( "selected" )

    
  # selectionner tous les termes d'une equation
  $( "body" ).on "click", ".selectAllButton", (event) ->
    event.stopImmediatePropagation()
    if $( ".focus" ).attr("id")
      id = $( ".focus" ).attr("id").split("_")[1]
      $("#equation_#{id}.focus ul > .monome").addClass( "selected" )
    else alert "Selectionner une équation !"
    
  # simplifier un terme
  $('body').on "dblclick", ".monome", () ->
    monome = $(this)
    simplifier_ce_monome(monome)
   
  #Simplifier les fractions selectionnées d'une équation
  $( "body" ).on "click", ".simplifier_les_monomes", () ->
    if $( ".focus" ).attr("id")
      id = $( ".focus" ).attr("id").split("_")[1]
      simplifier_les_monomes(id)
    else alert "Selectionner une équation !"
    
  #Obtenir la solution de l'equation s'il ne reste plus qu'un symbole à gauche
  $( "body" ).on "click", ".obtenirSolution", () ->
    if $( ".focus" ).attr("id")
      id = $( ".focus" ).attr("id").split("_")[1]
      obtenir_la_solution(id)
    else alert "Selectionner une équation !"
    
  # Ajouter un terme a chaque membre de l'equation
  $( "body" ).on "click", ".ajouter", () ->
    if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
    add_panel_touch 1
  # Retrancher un terme a chaque membre de lequation
  $( "body" ).on "click", ".retrancher", () ->
    if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
    add_panel_touch -1
        
  # multiplier par une fraction chaque membre de lequation
  $( "body" ).on "click", ".multiplier", () ->
    id = if $( ".focus" ).attr("id") then $( ".focus" ).attr("id").split("_")[1] else alert "Selectionner une équation !"
    if id
      if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
      array = monome_string_comme_array $( "#equation_string" ).val()
      if array.length is 1
        facteur = string_to_frac array[0]
        multiplier_chaque_membre_par(facteur,id)
        $( "#equation_string" ).val("")
      else
        alert "Il faut un coefficient seul"  
 
  # diviser par une fraction chaque membre de lequation
  $( "body" ).on "click", ".diviser", () ->
    id = if $( ".focus" ).attr("id") then $( ".focus" ).attr("id").split("_")[1] else alert "Selectionner une équation !"
    if id
      if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
      array = monome_string_comme_array $( "#equation_string" ).val()
      if array.length is 1
        facteur = string_to_frac array[0]
        facteur.inverse()
        multiplier_chaque_membre_par(facteur,id)
      else
        alert "Il faut un coefficient seul"
       
  # effectuer la somme, par membre, des termes selectionnés
  $( "body" ).on "click", ".sommationMonome", () ->
    id = if $( ".focus" ).attr("id") then $( ".focus" ).attr("id").split("_")[1] else alert "Selectionner une équation !"
    if id
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
    activer_copier_symbole = $( "#equation_#{id} > ul.membreDeGauche > li").attr("data-symbol")
    activer_copier_contenu = $( "#equation_#{id} > ul.membreDeDroite > li")
    alert "symbole copié : #{activer_copier_symbole}"
    
  check_substitute = (side,id) ->
    Side = if side is "gauche" then "Gauche" else "Droite"
    #alert "#membreDe#{Side}_#{id} > li"
    #alert $( "#membreDe#{Side}_#{id} > li").length
    $( "#membreDe#{Side}_#{id} > li").each ->
      #alert activer_copier_symbole + " vs " + $( this ).attr( "data-symbol")
      if $( this ).attr( "data-symbol") is activer_copier_symbole
        html = ""
        fraction1 = string_to_frac $( this ).attr( "data-value") 
        activer_copier_contenu.each ->
          fraction2 = string_to_frac $( this ).attr("data-value")
          value = multiplier_deux_fractions fraction1, fraction2
          symbol = $( this ).attr("data-symbol")
          if symbol
            html += "<li class='monome #{side}' data-value='#{value.numerateur}/#{value.denominateur}' data-type='symbol' data-symbol='#{symbol}'></li>"
          else
            html += "<li class='monome #{side}' data-value='#{value.numerateur}/#{value.denominateur}' data-type='rationnel'></li>"  
        $( this ).hide "easeInElastic", () -> 
          $( this ).remove()
          $( "#membreDe#{Side}_#{id}" ).append(html)
          mettre_a_jour_les_monomes()       
   
  $( "body" ).on "click", ".coller", () ->
    id = parseInt $( ".focus" ).attr("id").split("_")[1]
    check_substitute("gauche", id)
    check_substitute("droite", id)
          
  $( "body" ).on "click", "#add_equation", () ->
    unique_id++
    id = unique_id
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
                    <button id='deleteButton_#{id}' class='deleteButton' title='Supprimer cette équation'>X</button>
                    <div id='choixMonome_#{id}' class='choixMonome'></div>           
                """
        html += membre_as_html(mdg,"gauche",id)
        html += "<span id='signe_#{id}' class='signe'>#{signe}</span>"
        html += membre_as_html(mdd,"droite",id)
        html += "<p id='solution_#{id}'></p></div>"
        $( "#equations_div" ).append(html)
        mettre_a_jour_les_monomes()
      else
        alert "Vérifier que l'équation est correctement formatée"
      