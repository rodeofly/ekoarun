ekoarun
=======

// Equation de la Réunion : EkoaRun !
// logiciel libre, sous licence CeCILL:
// http://www.cecill.info/licences/Licence_CeCILL_V2-fr.txt
// Auteurs:
// Alain Busser
// Florian Tobé
//

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