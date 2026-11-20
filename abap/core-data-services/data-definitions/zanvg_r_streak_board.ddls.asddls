@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Streak leaderboard'
@Metadata.allowExtensions: true
define view entity ZANVG_R_STREAK_BOARD
  as select from ZANVG_R_STREAK
{
      @EndUserText.label: 'Player'
  key Player,
      @EndUserText.label: 'Max streak'
      MaxStreak,
      @EndUserText.label: 'Current streak'
      CurrentStreak
}
