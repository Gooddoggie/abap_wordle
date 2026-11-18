CLASS zcl_anvg_wordle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF game_status,
        in_progress TYPE zanvg_t_game-status VALUE 'I',
        won         TYPE zanvg_t_game-status VALUE 'W',
        lost        TYPE zanvg_t_game-status VALUE 'L',
      END OF game_status.

    CONSTANTS:
      BEGIN OF game_mode,
        classic TYPE zanvg_t_game-game_mode VALUE 'C',
        endless TYPE zanvg_t_game-game_mode VALUE 'E',
      END OF game_mode.

    CONSTANTS start_lives TYPE zanvg_t_game-lives VALUE 6.

    TYPES:
      BEGIN OF game_state,
        mode        TYPE zanvg_t_game-game_mode,
        secret_word TYPE zanvg_t_game-secret_word,
        status      TYPE zanvg_t_game-status,
        attempts    TYPE zanvg_t_game-attempts,
        lives       TYPE zanvg_t_game-lives,
        score       TYPE zanvg_t_game-score,
      END OF game_state.

    METHODS state_after_guess
      IMPORTING before        TYPE game_state
                pattern       TYPE zanvg_t_guess-result_pattern
      RETURNING VALUE(result) TYPE game_state.

    METHODS status_after_guess
      IMPORTING pattern        TYPE zanvg_t_guess-result_pattern
                attempt_number TYPE zanvg_t_game-attempts
      RETURNING VALUE(result)  TYPE zanvg_t_game-status.

    METHODS normalize_guess
      IMPORTING raw_guess     TYPE string
      RETURNING VALUE(result) TYPE zanvg_t_word-word.

    METHODS evaluate_guess
      IMPORTING guess         TYPE zanvg_t_guess-guess
                secret        TYPE zanvg_t_game-secret_word
      RETURNING VALUE(result) TYPE zanvg_t_guess-result_pattern.

    METHODS is_valid_word
      IMPORTING guess_word    TYPE zanvg_t_word-word
      RETURNING VALUE(result) TYPE abap_boolean.

    METHODS pick_secret_word
      RETURNING VALUE(result) TYPE zanvg_t_game-secret_word.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS word_length TYPE i VALUE 5.
    CONSTANTS max_attempts TYPE i VALUE 6.
    CONSTANTS crossed_off TYPE c LENGTH 1 VALUE '-'.
    CONSTANTS:
      BEGIN OF mark,
        correct   TYPE c LENGTH 1 VALUE 'G',
        misplaced TYPE c LENGTH 1 VALUE 'Y',
      END OF mark.
    CONSTANTS all_correct TYPE zanvg_t_guess-result_pattern VALUE 'GGGGG'.
    CONSTANTS all_absent TYPE zanvg_t_guess-result_pattern VALUE 'XXXXX'.
    CONSTANTS solve_bonus TYPE zanvg_t_game-lives VALUE 4.

    METHODS is_won
      IMPORTING pattern       TYPE zanvg_t_guess-result_pattern
      RETURNING VALUE(result) TYPE abap_boolean.

    METHODS next_endless_round
      IMPORTING state         TYPE game_state
                pattern       TYPE zanvg_t_guess-result_pattern
      RETURNING VALUE(result) TYPE game_state.
ENDCLASS.

CLASS zcl_anvg_wordle IMPLEMENTATION.

  METHOD is_won.
    result = xsdbool( pattern = all_correct ).
  ENDMETHOD.

  METHOD state_after_guess.
    result = VALUE #( BASE before
                      attempts = before-attempts + 1
                      lives    = before-lives - 1
                      score    = before-score + COND i( WHEN is_won( pattern ) THEN 1 ) ).

    IF before-mode = game_mode-endless.
      result = next_endless_round( state = result pattern = pattern ).
    ELSE.
      result-status = status_after_guess( pattern = pattern attempt_number = result-attempts ).
    ENDIF.
  ENDMETHOD.

  METHOD next_endless_round.
    result = state.

    IF is_won( pattern ).
      result-lives       = state-lives + solve_bonus.
      result-secret_word = pick_secret_word( ).
    ENDIF.

    result-status = COND #( WHEN result-lives > 0 THEN game_status-in_progress
                            ELSE game_status-lost ).
  ENDMETHOD.

  METHOD status_after_guess.
    IF is_won( pattern ).
      result = game_status-won.
    ELSEIF attempt_number >= max_attempts.
      result = game_status-lost.
    ELSE.
      result = game_status-in_progress.
    ENDIF.
  ENDMETHOD.

  METHOD normalize_guess.
    result = to_upper( condense( raw_guess ) ).
  ENDMETHOD.

  METHOD evaluate_guess.
    result = all_absent.
    DATA(unused) = secret.
    DATA pos TYPE i.

    DO word_length TIMES.
      pos = sy-index - 1.
      IF guess+pos(1) = secret+pos(1).
        result+pos(1) = mark-correct.
        unused+pos(1) = crossed_off.
      ENDIF.
    ENDDO.

    DO word_length TIMES.
      pos = sy-index - 1.
      IF result+pos(1) = mark-correct.
        CONTINUE.
      ENDIF.
      DATA(offset) = find( val = unused sub = guess+pos(1) ).
      IF offset >= 0.
        result+pos(1) = mark-misplaced.
        unused+offset(1) = crossed_off.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD is_valid_word.
    SELECT SINGLE @abap_true
      FROM zanvg_t_word
      WHERE word = @guess_word
      INTO @result.
  ENDMETHOD.

  METHOD pick_secret_word.
    SELECT *
      FROM zanvg_t_word
      WHERE is_answer = @abap_true
      INTO TABLE @DATA(answers).

    IF answers IS INITIAL.
      RETURN.
    ENDIF.

    DATA(row_picker) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )
                                                   min  = 1
                                                   max  = lines( answers ) ).
    DATA(index) = row_picker->get_next( ).
    result = answers[ index ]-word.
  ENDMETHOD.

ENDCLASS.
