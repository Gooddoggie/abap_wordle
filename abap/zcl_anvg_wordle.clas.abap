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

    METHODS status_after_guess
      IMPORTING pattern        TYPE zanvg_t_guess-result_pattern
                attempt_number TYPE i
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
    METHODS is_won
      IMPORTING pattern       TYPE zanvg_t_guess-result_pattern
      RETURNING VALUE(result) TYPE abap_boolean.
ENDCLASS.

CLASS zcl_anvg_wordle IMPLEMENTATION.

  METHOD is_won.
    IF pattern = 'GGGGG'.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD status_after_guess.
    IF is_won( pattern ).
      result = game_status-won.
    ELSEIF attempt_number >= 6.
      result = game_status-lost.
    ELSE.
      result = game_status-in_progress.
    ENDIF.
  ENDMETHOD.

  METHOD normalize_guess.
    result = to_upper( condense( raw_guess ) ).
  ENDMETHOD.

  METHOD evaluate_guess.
    result = 'XXXXX'.
    DATA(unused) = secret.
    DATA pos TYPE i.

    DO 5 TIMES.
      pos = sy-index - 1.
      IF guess+pos(1) = secret+pos(1).
        result+pos(1) = 'G'.
        unused+pos(1) = '-'.
      ENDIF.
    ENDDO.

    DO 5 TIMES.
      pos = sy-index - 1.
      IF result+pos(1) = 'G'.
        CONTINUE.
      ENDIF.
      DATA(offset) = find( val = unused sub = guess+pos(1) ).
      IF offset >= 0.
        result+pos(1) = 'Y'.
        unused+offset(1) = '-'.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD is_valid_word.
    SELECT SINGLE word
        FROM zanvg_t_word
        WHERE word = @guess_word
        INTO @DATA(found_word).
    IF sy-subrc = 0.
      result = abap_true.
    ENDIF.
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
