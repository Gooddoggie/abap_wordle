@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Guess'
@Metadata.allowExtensions: true
define view entity ZANVG_C_GUESS
  as projection on ZANVG_R_GUESS
{
  key GameId,
  key AttemptNo,
      Guess,
      ResultPattern,
      _Game : redirected to parent ZANVG_C_GAME
}
