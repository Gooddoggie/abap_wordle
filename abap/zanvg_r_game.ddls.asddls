@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Game'
define root view entity ZANVG_R_GAME
  as select from zanvg_t_game
  composition [0..*] of ZANVG_R_GUESS as _Guess
{
  key game_id               as GameId,
      player                as Player,
      secret_word           as SecretWord,
      case
          when status <> 'I' then secret_word
      end                   as Solution,
      status                as Status,
      attempts              as Attempts,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Guess
}
