@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Guess'
define view entity ZANVG_R_GUESS
  as select from zanvg_t_guess
  association to parent ZANVG_R_GAME as _Game on $projection.GameId = _Game.GameId
{
  key game_id        as GameId,
  key attempt_no     as AttemptNo,
      guess          as Guess,
      result_pattern as ResultPattern,
      _Game
}
