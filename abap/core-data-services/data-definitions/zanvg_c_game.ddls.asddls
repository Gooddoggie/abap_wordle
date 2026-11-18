@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Game'
@Metadata.allowExtensions: true
define root view entity ZANVG_C_GAME
  provider contract transactional_query
  as projection on ZANVG_R_GAME
{
  key GameId,
      Player,
      Solution,
      @ObjectModel.text.element: [ 'StatusText' ]
      Status,
      StatusText,
      StatusCriticality,
      @ObjectModel.text.element: [ 'GameModeText' ]
      GameMode,
      GameModeText,
      Attempts,
      Lives,
      Score,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _Guess : redirected to composition child ZANVG_C_GUESS
}
