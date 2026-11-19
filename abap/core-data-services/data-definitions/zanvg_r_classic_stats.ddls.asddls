@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Classic stats'
@Metadata.allowExtensions: true
define view entity ZANVG_R_CLASSIC_STATS
  as select from zanvg_t_game
{
      @EndUserText.label: 'User'
  key created_by                                                                     as CreatedBy,
      @EndUserText.label: 'Played'
      count( * )                                                                     as Games,
      @EndUserText.label: 'Wins'
      sum( case status when 'W' then 1 else 0 end )                                  as Wins,
      @EndUserText.label: 'Win %'
      division( sum( case status when 'W' then 1 else 0 end ) * 100, count( * ), 1 ) as WinRate
}
where game_mode <> 'E'
  and status    <> 'I'
group by created_by
