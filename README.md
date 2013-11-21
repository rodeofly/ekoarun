ekoarun
=======

// Equation de la Réunion : EkoaRun !
// logiciel libre, sous licence CeCILL:
// http://www.cecill.info/licences/Licence_CeCILL_V2-fr.txt
// Auteurs:
// Alain Busser
// Florian Tobé
//

  <h1>Ekoarun</h1>
  <br /><br /><br />
  <div id="equation_panel"> </div>
  	
  <input id="equation_string" type="text" size="100" readonly>
  <span id="effacer_equation_string" class="panel_touch">Effacer</span>
  <span id="generer_equation" class="panel_touch">Générer</span>
  <span id="add_equation" class="panel_touch">Inserer</span>
  <div class="buttons">
    <button class="deleteButton" title="Supprimer cette équation">X</button>
    <button class="selectAllButton" title="Sélectionner tous les termes de cette équation">all</button>
    <button class="sommationMonome" title="Effectuer la somme des termes sélectionnés dans chaque membre">&Sigma;</button>
    <button class="simplifier_les_monomes" title="rendre les fractions des termes sélectionnés irréductibles">&frac12;</button>
    <button class="ajouter" title="Ajouter un terme à chaque membre de cette équation">+</button>
    <button class="retrancher" title="Retrancher un terme à chaque membre de cette équation">-</button>       
    <button class="multiplier" title="Multiplier par un terme chaque membre de cette équation">&#215;</button>        
    <button class="diviser"  title="Diviser par un terme chaque membre de cette équation">&#247;</button>
    <button class="obtenirSolution"  title="Obtenir la solution de cette équation">?</button>
    <button class="copier"  title="Copier cette valeur">&#169;</button>
    <button class="coller"  title="Injecter la valeur">&#8618;</button>
  </div>
  