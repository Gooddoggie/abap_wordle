@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Game'
define root view entity ZANVG_C_GAME
  provider contract transactional_query
  as projection on ZANVG_R_GAME
{
  key GameId,
      Player,
      Solution,
      Status,
      Attempts,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _Guess : redirected to composition child ZANVG_C_GUESS
}
