ekoarun
=======

// Equation de la Réunion : EkoaRun !
// logiciel libre, sous licence CeCILL:
// http://www.cecill.info/licences/Licence_CeCILL_V2-fr.txt
// Auteurs:
// Alain Busser
// Florian Tobé
//

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
      $( "#activer_copier_#{id}" ).show()
    else
      $( "#activer_copier_#{id}" ).hide()
  else
    $( "#activer_copier_#{id}" ).hide()