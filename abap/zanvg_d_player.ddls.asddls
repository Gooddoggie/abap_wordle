@EndUserText.label: 'Player parameter'
define abstract entity ZANVG_D_PLAYER
{
  @EndUserText.label: 'Player'
  Player  : abap.char(30);
  @EndUserText.label: 'Endless mode'
  Endless : abap_boolean;
}
