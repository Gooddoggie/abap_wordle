CLASS zcl_anvg_setup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES word_list TYPE STANDARD TABLE OF zanvg_t_word WITH EMPTY KEY.

    CONSTANTS answers_url TYPE string VALUE `https://gist.githubusercontent.com/cfreshman/a03ef2cba789d8cf00c08f767e0fad7b/raw/wordle-answers-alphabetical.txt`.
    CONSTANTS guesses_url TYPE string VALUE `https://raw.githubusercontent.com/tabatkins/wordle-list/main/words`.
    CONSTANTS word_length TYPE i VALUE 5.

    METHODS download
      IMPORTING url           TYPE string
      RETURNING VALUE(result) TYPE string
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error
                cx_web_message_error.

    METHODS five_letter_words
      IMPORTING text          TYPE string
      RETURNING VALUE(result) TYPE word_list.

    METHODS merge
      IMPORTING answers       TYPE word_list
                guesses       TYPE word_list
      RETURNING VALUE(result) TYPE word_list.

    METHODS reload_words
      IMPORTING words TYPE word_list.

ENDCLASS.

CLASS zcl_anvg_setup IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        DATA(answers) = five_letter_words( download( answers_url ) ).
        DATA(guesses) = five_letter_words( download( guesses_url ) ).
      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error INTO DATA(error).
        out->write( error->get_text( ) ).
        RETURN.
    ENDTRY.

    DATA(words) = merge( answers = answers
                         guesses = guesses ).
    reload_words( words ).
    out->write( |{ lines( answers ) } answers, { lines( words ) } words loaded into ZANVG_T_WORD| ).
  ENDMETHOD.

  METHOD download.
    DATA(destination) = cl_http_destination_provider=>create_by_url( url ).
    DATA(client) = cl_web_http_client_manager=>create_by_http_destination( destination ).
    result = client->execute( if_web_http_client=>get )->get_text( ).
    client->close( ).
  ENDMETHOD.

  METHOD five_letter_words.
    SPLIT text AT cl_abap_char_utilities=>newline INTO TABLE DATA(text_lines).

    LOOP AT text_lines INTO DATA(line).
      IF strlen( line ) = word_length.
        APPEND VALUE #( word = to_upper( line ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD merge.
    result = VALUE #( FOR answer IN answers ( word      = answer-word
                                              is_answer = abap_true ) ).
    APPEND LINES OF guesses TO result.

    SORT result BY word is_answer DESCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING word.
  ENDMETHOD.

  METHOD reload_words.
    DELETE FROM zanvg_t_word.
    INSERT zanvg_t_word FROM TABLE @words.
    COMMIT WORK.
  ENDMETHOD.

ENDCLASS.
