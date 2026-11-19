@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Endless leaderboard'
@Metadata.allowExtensions: true
define view entity ZANVG_R_ENDLESS_BOARD
  as select from zanvg_t_game
{
      @EndUserText.label: 'Player'
  key player       as Player,
      @EndUserText.label: 'Runs'
      count( * )   as Runs,
      @EndUserText.label: 'Best run'
      max( score ) as BestRun,
      @EndUserText.label: 'Words solved'
      sum( score ) as WordsSolved
}
where game_mode = 'E'
  and status    = 'L'
group by player
