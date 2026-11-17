@EndUserText.label : 'Wordle: games'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zanvg_t_game {

  key client            : abap.clnt not null;
  key game_id           : sysuuid_x16 not null;
  player                : abap.char(30);
  secret_word           : abap.char(5);
  status                : abap.char(1);
  attempts              : abap.int1;
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_lastchange_user;
  last_changed_at       : abp_lastchange_tstmpl;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;

}