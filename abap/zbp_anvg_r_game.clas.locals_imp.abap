CLASS lhc_Game DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Game RESULT result.
    METHODS setDefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Game~setDefaults.
    METHODS SubmitGuess FOR MODIFY
       keys FOR ACTION Game~SubmitGuess RESULT result.

ENDCLASS.

CLASS lhc_Game IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setDefaults.
    DATA(wordle) = NEW zcl_anvg_wordle( ).

    MODIFY ENTITIES OF zanvg_r_game IN LOCAL MODE
      ENTITY Game
        UPDATE FIELDS ( SecretWord Status )
        WITH VALUE #( FOR key IN keys ( %tky       = key-%tky
                                        SecretWord = wordle->pick_secret_word( )
                                        Status     = zcl_anvg_wordle=>game_status-in_progress ) ).
  ENDMETHOD.

  METHOD SubmitGuess.
    DATA(wordle) = NEW zcl_anvg_wordle( ).

    READ ENTITIES OF zanvg_r_game IN LOCAL MODE
      ENTITY Game
        FIELDS ( SecretWord Status Attempts )
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

      DATA(attempt_no) = game-Attempts + 1.
      DATA(pattern) = wordle->evaluate_guess( guess = guess secret = game-SecretWord ).
      DATA(status) = wordle->status_after_guess( pattern = pattern attempt_number = attempt_no ).

      MODIFY ENTITIES OF zanvg_r_game IN LOCAL MODE
        ENTITY Game
          UPDATE FIELDS ( Status Attempts )
          WITH VALUE #( ( %tky     = game-%tky
                          Status   = status
                          Attempts = attempt_no ) )
        ENTITY Game
          CREATE BY \_Guess
          FIELDS ( AttemptNo Guess ResultPattern )
          WITH VALUE #( ( %tky    = game-%tky
                          %target = VALUE #( ( %cid          = 'GUESS'
                                               AttemptNo     = attempt_no
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

ENDCLASS.
