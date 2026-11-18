@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Game'
define root view entity ZANVG_R_GAME
  as select from zanvg_t_game
  composition [0..*] of ZANVG_R_GUESS as _Guess
{
  key game_id               as GameId,
      @EndUserText.label: 'Player'
      player                as Player,
      secret_word           as SecretWord,
      @EndUserText.label: 'Solution'
      case
          when status <> 'I' then secret_word
      end                   as Solution,
      @EndUserText.label: 'Status'
      status                as Status,
      @EndUserText.label: 'Status'
      case status
        when 'I' then 'In progress'
        when 'W' then 'Won'
        when 'L' then 'Lost'
      end                   as StatusText,
      case status
        when 'W' then 3
        when 'L' then 1
        else 0
      end                   as StatusCriticality,
      @EndUserText.label: 'Mode'
      game_mode             as GameMode,
      @EndUserText.label: 'Mode'
      case game_mode
        when 'E' then 'Endless'
        else 'Classic'
      end                   as GameModeText,
      @EndUserText.label: 'Attempts'
      attempts              as Attempts,
      @EndUserText.label: 'Lives'
      lives                 as Lives,
      @EndUserText.label: 'Words solved'
      score                 as Score,
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
