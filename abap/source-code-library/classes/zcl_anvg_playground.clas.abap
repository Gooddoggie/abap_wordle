CLASS zcl_anvg_playground DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_anvg_playground IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA(wordle) = NEW zcl_anvg_wordle( ).

    DATA(game) = VALUE zanvg_t_game( game_id     = '00000000000000000000000000000001'
                                     player      = 'Tester'
                                     secret_word = 'CRANE'
                                     status      = zcl_anvg_wordle=>game_status-in_progress
                                     attempts    = 2 ).
    INSERT zanvg_t_game FROM @game.
    out->write( |game: { sy-subrc }| ).

    DATA(first_guess) = VALUE zanvg_t_guess( game_id        = game-game_id
                                             attempt_no     = 1
                                             guess          = 'HOTEL'
                                             result_pattern = wordle->evaluate_guess( guess  = 'HOTEL'
                                                                                      secret = game-secret_word ) ).
    INSERT zanvg_t_guess FROM @first_guess.
    out->write( |first guess: { sy-subrc }| ).

    DATA(second_guess) = VALUE zanvg_t_guess( game_id        = game-game_id
                                              attempt_no     = 2
                                              guess          = 'SLATE'
                                              result_pattern = wordle->evaluate_guess( guess  = 'SLATE'
                                                                                       secret = game-secret_word ) ).
    INSERT zanvg_t_guess FROM @second_guess.
    out->write( |second guess: { sy-subrc }| ).
  ENDMETHOD.

ENDCLASS.
