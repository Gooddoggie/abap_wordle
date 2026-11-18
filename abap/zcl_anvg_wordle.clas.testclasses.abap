CLASS ltc_status_after_guess DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA game TYPE REF TO zcl_anvg_wordle.

    METHODS setup.
    METHODS win_before_last_attempt  FOR TESTING.
    METHODS win_on_last_attempt      FOR TESTING.
    METHODS miss_on_last_attempt     FOR TESTING.
    METHODS miss_before_last_attempt FOR TESTING.
ENDCLASS.

CLASS ltc_status_after_guess IMPLEMENTATION.
  METHOD setup.
    game = NEW #( ).
  ENDMETHOD.

  METHOD win_before_last_attempt.
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_anvg_wordle=>game_status-won
      act = game->status_after_guess( pattern = 'GGGGG' attempt_number = 3 ) ).
  ENDMETHOD.

  METHOD win_on_last_attempt.
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_anvg_wordle=>game_status-won
      act = game->status_after_guess( pattern = 'GGGGG' attempt_number = 6 ) ).
  ENDMETHOD.

  METHOD miss_on_last_attempt.
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_anvg_wordle=>game_status-lost
      act = game->status_after_guess( pattern = 'XXYXX' attempt_number = 6 ) ).
  ENDMETHOD.

  METHOD miss_before_last_attempt.
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_anvg_wordle=>game_status-in_progress
      act = game->status_after_guess( pattern = 'XXYXX' attempt_number = 2 ) ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_normalize_guess DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA game TYPE REF TO zcl_anvg_wordle.

    METHODS setup.
    METHODS lowercase_becomes_uppercase FOR TESTING.
    METHODS outer_spaces_are_removed    FOR TESTING.
ENDCLASS.

CLASS ltc_normalize_guess IMPLEMENTATION.
  METHOD setup.
    game = NEW #( ).
  ENDMETHOD.

  METHOD lowercase_becomes_uppercase.
    cl_abap_unit_assert=>assert_equals(
      exp = 'CRANE'
      act = game->normalize_guess( `crane` ) ).
  ENDMETHOD.

  METHOD outer_spaces_are_removed.
    cl_abap_unit_assert=>assert_equals(
      exp = 'CRANE'
      act = game->normalize_guess( ` cRaNe ` ) ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_evaluate_guess DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA game TYPE REF TO zcl_anvg_wordle.

    METHODS setup.
    METHODS exact_match_all_green       FOR TESTING.
    METHODS no_shared_letters_all_gray  FOR TESTING.
    METHODS mixed_green_yellow_gray     FOR TESTING.
    METHODS extra_copy_of_green_is_gray FOR TESTING.
    METHODS repeated_letter_once_yellow FOR TESTING.

    METHODS assert_pattern
      IMPORTING guess    TYPE zanvg_t_guess-guess
                secret   TYPE zanvg_t_game-secret_word
                expected TYPE zanvg_t_guess-result_pattern.
ENDCLASS.

CLASS ltc_evaluate_guess IMPLEMENTATION.
  METHOD setup.
    game = NEW #( ).
  ENDMETHOD.

  METHOD exact_match_all_green.
    assert_pattern( guess = 'CRANE' secret = 'CRANE' expected = 'GGGGG' ).
  ENDMETHOD.

  METHOD no_shared_letters_all_gray.
    assert_pattern( guess = 'BOOST' secret = 'CRANE' expected = 'XXXXX' ).
  ENDMETHOD.

  METHOD mixed_green_yellow_gray.
    assert_pattern( guess = 'CRANE' secret = 'REACT' expected = 'YYGXY' ).
  ENDMETHOD.

  METHOD extra_copy_of_green_is_gray.
    assert_pattern( guess = 'SPEED' secret = 'HOTEL' expected = 'XXXGX' ).
  ENDMETHOD.

  METHOD repeated_letter_once_yellow.
    assert_pattern( guess = 'SPEED' secret = 'LEMON' expected = 'XXYXX' ).
  ENDMETHOD.

  METHOD assert_pattern.
    cl_abap_unit_assert=>assert_equals( exp = expected
                                        act = game->evaluate_guess( guess = guess secret = secret )
                                        msg = |{ guess } against { secret }| ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_is_valid_word DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA sql_environment TYPE REF TO if_osql_test_environment.
    DATA game TYPE REF TO zcl_anvg_wordle.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS word_in_list_is_valid       FOR TESTING.
    METHODS word_not_in_list_is_invalid FOR TESTING.
ENDCLASS.

CLASS ltc_is_valid_word IMPLEMENTATION.
  METHOD class_setup.
    sql_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'ZANVG_T_WORD' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    sql_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    DATA words TYPE STANDARD TABLE OF zanvg_t_word WITH EMPTY KEY.
    words = VALUE #( ( word = 'CRANE' is_answer = abap_true ) ).
    sql_environment->clear_doubles( ).
    sql_environment->insert_test_data( words ).
    game = NEW #( ).
  ENDMETHOD.

  METHOD word_in_list_is_valid.
    cl_abap_unit_assert=>assert_true( act = game->is_valid_word( 'CRANE' ) ).
  ENDMETHOD.

  METHOD word_not_in_list_is_invalid.
    cl_abap_unit_assert=>assert_false( act = game->is_valid_word( 'QWXYZ' ) ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_pick_secret_word DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA sql_environment TYPE REF TO if_osql_test_environment.
    DATA game TYPE REF TO zcl_anvg_wordle.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS only_answer_is_picked  FOR TESTING.
    METHODS no_answers_gives_blank FOR TESTING.
ENDCLASS.

CLASS ltc_pick_secret_word IMPLEMENTATION.
  METHOD class_setup.
    sql_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'ZANVG_T_WORD' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    sql_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    sql_environment->clear_doubles( ).
    game = NEW #( ).
  ENDMETHOD.

  METHOD only_answer_is_picked.
    DATA words TYPE STANDARD TABLE OF zanvg_t_word WITH EMPTY KEY.
    words = VALUE #( ( word = 'CRANE' is_answer = abap_true )
                     ( word = 'HOTEL' is_answer = abap_false ) ).
    sql_environment->insert_test_data( words ).
    cl_abap_unit_assert=>assert_equals( exp = 'CRANE' act = game->pick_secret_word( ) ).
  ENDMETHOD.

  METHOD no_answers_gives_blank.
    cl_abap_unit_assert=>assert_initial( act = game->pick_secret_word( ) ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_state_after_guess DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA sql_environment TYPE REF TO if_osql_test_environment.
    DATA game TYPE REF TO zcl_anvg_wordle.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS classic_miss_costs_a_life        FOR TESTING.
    METHODS classic_win_ends_with_score      FOR TESTING.
    METHODS endless_miss_costs_a_life        FOR TESTING.
    METHODS endless_miss_on_last_life_lost   FOR TESTING.
    METHODS endless_win_bonus_and_new_word FOR TESTING.

    METHODS running_game
      IMPORTING mode          TYPE zanvg_t_game-game_mode
                lives         TYPE zanvg_t_game-lives
      RETURNING VALUE(result) TYPE zcl_anvg_wordle=>game_state.
ENDCLASS.

CLASS ltc_state_after_guess IMPLEMENTATION.
  METHOD class_setup.
    sql_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'ZANVG_T_WORD' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    sql_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    DATA words TYPE STANDARD TABLE OF zanvg_t_word WITH EMPTY KEY.
    words = VALUE #( ( word = 'HOTEL' is_answer = abap_true ) ).
    sql_environment->clear_doubles( ).
    sql_environment->insert_test_data( words ).
    game = NEW #( ).
  ENDMETHOD.

  METHOD running_game.
    result = VALUE #( mode        = mode
                      secret_word = 'CRANE'
                      status      = zcl_anvg_wordle=>game_status-in_progress
                      attempts    = 2
                      lives       = lives
                      score       = 1 ).
  ENDMETHOD.

  METHOD classic_miss_costs_a_life.
    DATA(after) = game->state_after_guess( before  = running_game( mode  = zcl_anvg_wordle=>game_mode-classic
                                                                   lives = 4 )
                                           pattern = 'XXYXX' ).

    cl_abap_unit_assert=>assert_equals( exp = 3 act = after-lives ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = after-attempts ).
    cl_abap_unit_assert=>assert_equals( exp = zcl_anvg_wordle=>game_status-in_progress act = after-status ).
  ENDMETHOD.

  METHOD classic_win_ends_with_score.
    DATA(after) = game->state_after_guess( before  = running_game( mode  = zcl_anvg_wordle=>game_mode-classic
                                                                   lives = 4 )
                                           pattern = 'GGGGG' ).

    cl_abap_unit_assert=>assert_equals( exp = zcl_anvg_wordle=>game_status-won act = after-status ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = after-score ).
    cl_abap_unit_assert=>assert_equals( exp = 'CRANE' act = after-secret_word ).
  ENDMETHOD.

  METHOD endless_miss_costs_a_life.
    DATA(after) = game->state_after_guess( before  = running_game( mode  = zcl_anvg_wordle=>game_mode-endless
                                                                   lives = 3 )
                                           pattern = 'XXYXX' ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = after-lives ).
    cl_abap_unit_assert=>assert_equals( exp = zcl_anvg_wordle=>game_status-in_progress act = after-status ).
    cl_abap_unit_assert=>assert_equals( exp = 'CRANE' act = after-secret_word ).
  ENDMETHOD.

  METHOD endless_miss_on_last_life_lost.
    DATA(after) = game->state_after_guess( before  = running_game( mode  = zcl_anvg_wordle=>game_mode-endless
                                                                   lives = 1 )
                                           pattern = 'XXYXX' ).

    cl_abap_unit_assert=>assert_equals( exp = 0 act = after-lives ).
    cl_abap_unit_assert=>assert_equals( exp = zcl_anvg_wordle=>game_status-lost act = after-status ).
  ENDMETHOD.

  METHOD endless_win_bonus_and_new_word.
    DATA(after) = game->state_after_guess( before  = running_game( mode  = zcl_anvg_wordle=>game_mode-endless
                                                                   lives = 1 )
                                           pattern = 'GGGGG' ).

    cl_abap_unit_assert=>assert_equals( exp = 4 act = after-lives ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = after-score ).
    cl_abap_unit_assert=>assert_equals( exp = 'HOTEL' act = after-secret_word ).
    cl_abap_unit_assert=>assert_equals( exp = zcl_anvg_wordle=>game_status-in_progress act = after-status ).
  ENDMETHOD.
ENDCLASS.
