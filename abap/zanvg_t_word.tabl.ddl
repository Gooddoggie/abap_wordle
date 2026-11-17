@EndUserText.label : 'Wordle: word list'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zanvg_t_word {

  key client : abap.clnt not null;
  key word   : abap.char(5) not null;
  is_answer  : abap_boolean;

}
