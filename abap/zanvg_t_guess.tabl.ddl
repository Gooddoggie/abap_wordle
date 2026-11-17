@EndUserText.label : 'Wordle: guesses'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zanvg_t_guess {

  key client     : abap.clnt not null;
  key game_id    : sysuuid_x16 not null;
  key attempt_no : abap.int1 not null;
  guess          : abap.char(5);
  result_pattern : abap.char(5);

}
