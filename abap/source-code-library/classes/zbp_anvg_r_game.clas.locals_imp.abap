CLASS lhc_Game DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Game RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Game RESULT result.
    METHODS setDefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Game~setDefaults.
    METHODS SubmitGuess FOR MODIFY
      IMPORTING keys FOR ACTION Game~SubmitGuess RESULT result.
    METHODS StartGame FOR MODIFY
      IMPORTING keys FOR ACTION Game~StartGame.

ENDCLASS.

CLASS lhc_Game IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zanvg_r_game IN LOCAL MODE
      ENTITY Game
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(games).

    result = VALUE #( FOR game IN games
                      ( %tky                = game-%tky
                        %action-SubmitGuess = COND #( WHEN game-Status = zcl_anvg_wordle=>game_status-in_progress
                                                      THEN if_abap_behv=>fc-o-enabled
                                                      ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD setDefaults.
    DATA(wordle) = NEW zcl_anvg_wordle( ).

    MODIFY ENTITIES OF zanvg_r_game IN LOCAL MODE
      ENTITY Game
        UPDATE FIELDS ( SecretWord Status Lives )
        WITH VALUE #( FOR key IN keys ( %tky       = key-%tky
                                        SecretWord = wordle->pick_secret_word( )
                                        Status     = zcl_anvg_wordle=>game_status-in_progress
                                        Lives      = zcl_anvg_wordle=>start_lives ) ).
  ENDMETHOD.

  METHOD SubmitGuess.
    DATA(wordle) = NEW zcl_anvg_wordle( ).

    READ ENTITIES OF zanvg_r_game IN LOCAL MODE
      ENTITY Game
        FIELDS ( GameMode SecretWord Status Attempts Lives Score )
        WITH CORRESPONDING #( keys )
      RESULT DATA(games).

    LOOP AT keys INTO DATA(key).
      DATA(game) = games[ GameId = key-GameId ].
      DATA(guess) = wordle->normalize_guess( CONV #( key-%param-Guess ) ).

      DATA(error) = COND string( WHEN game-Status <> zcl_anvg_wordle=>game_status-in_progress THEN `Game is over`
                                 WHEN NOT wordle->is_valid_word( guess )                       THEN `Not in word list` ).
      IF error IS NOT INITIAL.
        APPEND VALUE #( %tky = game-%tky ) TO failed-game.
        APPEND VALUE #( %tky = game-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = error ) ) TO reported-game.
        CONTINUE.
      ENDIF.

      DATA(pattern) = wordle->evaluate_guess( guess = guess secret = game-SecretWord ).
      DATA(after) = wordle->state_after_guess( before  = CORRESPONDING #( game MAPPING mode = GameMode secret_word = SecretWord )
                                               pattern = pattern ).

      MODIFY ENTITIES OF zanvg_r_game IN LOCAL MODE
        ENTITY Game
          UPDATE FIELDS ( SecretWord Status Attempts Lives Score )
          WITH VALUE #( ( %tky       = game-%tky
                          SecretWord = after-secret_word
                          Status     = after-status
                          Attempts   = after-attempts
                          Lives      = after-lives
                          Score      = after-score ) )
        ENTITY Game
          CREATE BY \_Guess
          FIELDS ( AttemptNo Guess ResultPattern )
          WITH VALUE #( ( %tky    = game-%tky
                          %target = VALUE #( ( %cid          = 'GUESS'
                                               AttemptNo     = after-attempts
                                               Guess         = guess
                                               ResultPattern = pattern ) ) ) ).
    ENDLOOP.

    READ ENTITIES OF zanvg_r_game IN LOCAL MODE
      ENTITY Game
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(updated_games).

    result = VALUE #( FOR updated IN updated_games ( %tky   = updated-%tky
                                                     %param = updated ) ).
  ENDMETHOD.

  METHOD StartGame.
    MODIFY ENTITIES OF zanvg_r_game IN LOCAL MODE
      ENTITY Game
        CREATE FIELDS ( Player GameMode )
        WITH VALUE #( FOR key IN keys ( %cid     = key-%cid
                                        Player   = key-%param-Player
                                        GameMode = COND #( WHEN key-%param-Endless = abap_true
                                                           THEN zcl_anvg_wordle=>game_mode-endless
                                                           ELSE zcl_anvg_wordle=>game_mode-classic ) ) )
      MAPPED mapped.
  ENDMETHOD.

ENDCLASS.
