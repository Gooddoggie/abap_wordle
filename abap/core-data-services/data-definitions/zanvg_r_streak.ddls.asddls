@EndUserText.label: 'Classic win streaks'
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZANVG_R_STREAK
returns
{
  key client        : abap.clnt;
  key Player        : abap.char(30);
      CurrentStreak : abap.int4;
      MaxStreak     : abap.int4;
}
implemented by method zcl_anvg_streak=>get_streaks;
