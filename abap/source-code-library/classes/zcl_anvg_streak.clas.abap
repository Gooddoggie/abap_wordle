CLASS zcl_anvg_streak DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    CLASS-METHODS get_streaks FOR TABLE FUNCTION zanvg_r_streak.

ENDCLASS.

CLASS zcl_anvg_streak IMPLEMENTATION.

  METHOD get_streaks BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
                     OPTIONS READ-ONLY
                     USING zanvg_t_game.

    finished = SELECT player,
                      status,
                      ROW_NUMBER() OVER (PARTITION BY player ORDER BY last_changed_at, game_id) AS game_no,
                      COUNT(*)     OVER (PARTITION BY player)                                   AS games
                 FROM zanvg_t_game
                WHERE client     = SESSION_CONTEXT('CDS_CLIENT')
                  AND game_mode <> 'E'
                  AND status    <> 'I';

    players = SELECT DISTINCT player
                FROM :finished;

    wins = SELECT player,
                  game_no,
                  games,
                  game_no - ROW_NUMBER() OVER (PARTITION BY player ORDER BY game_no) AS island
             FROM :finished
            WHERE status = 'W';

    streaks = SELECT player,
                     COUNT(*)                                              AS streak,
                     CASE WHEN MAX(game_no) = MAX(games) THEN 1 ELSE 0 END AS is_current
                FROM :wins
               GROUP BY player, island;

    RETURN SELECT SESSION_CONTEXT('CDS_CLIENT')                                                       AS client,
                  players.player                                                                     AS Player,
                  CAST(MAX(CASE WHEN streaks.is_current = 1 THEN streaks.streak ELSE 0 END) AS INTEGER) AS CurrentStreak,
                  CAST(COALESCE(MAX(streaks.streak), 0) AS INTEGER)                                   AS MaxStreak
             FROM :players AS players
             LEFT OUTER JOIN :streaks AS streaks
               ON streaks.player = players.player
            GROUP BY players.player;

  ENDMETHOD.

ENDCLASS.
