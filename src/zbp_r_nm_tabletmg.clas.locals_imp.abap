CLASS LHC_ZR_NM_TABLETMG DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.

  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
           request requested_authorizations FOR Student
        RESULT result,

      is_update_allowed
        RETURNING VALUE(rv_update_allowed) TYPE abap_bool,

      get_instance_authorizations FOR INSTANCE AUTHORIZATION
        IMPORTING keys REQUEST requested_authorizations FOR Student RESULT result,

      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Student RESULT result,

      setAdmitted FOR MODIFY
        IMPORTING keys FOR ACTION Student~setAdmitted RESULT result,
      copyStudent FOR MODIFY
            IMPORTING keys FOR ACTION Student~copyStudent,
      createInstance FOR MODIFY
            IMPORTING keys FOR ACTION Student~createInstance.
ENDCLASS.

CLASS LHC_ZR_NM_TABLETMG IMPLEMENTATION.

  METHOD get_global_authorizations.

    IF requested_authorizations-%update = if_abap_behv=>mk-on OR
       requested_authorizations-%action-edit = if_abap_behv=>mk-on.

      IF is_update_allowed( ) = abap_true.
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update = if_abap_behv=>auth-unauthorized.
        result-%action-edit = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

  ENDMETHOD.

 METHOD is_update_allowed.

  DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
  rv_update_allowed = abap_false.

  " Allow only specific users
  IF
 lv_user = 'CB9980004208'
 or lv_user = 'CB9980000123'
 or lv_user = 'CB9980000280' .

    rv_update_allowed = abap_true.
  ENDIF.

ENDMETHOD.

 METHOD get_instance_authorizations.

  DATA: update_requested TYPE abap_bool,
        update_granted   TYPE abap_bool.

  READ ENTITIES OF zr_nm_tabletmg IN LOCAL MODE
    ENTITY Student
    FIELDS ( status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(studentadmitted)
    FAILED failed.

  CHECK studentadmitted IS NOT INITIAL.

  update_requested = COND #(
    WHEN requested_authorizations-%update = if_abap_behv=>mk-on OR
         requested_authorizations-%action-edit = if_abap_behv=>mk-on
    THEN abap_true ELSE abap_false ).

  LOOP AT studentadmitted ASSIGNING FIELD-SYMBOL(<lfs_studentadmitted>).

    IF <lfs_studentadmitted>-status = abap_false AND update_requested = abap_true.

      update_granted = is_update_allowed( ).

      IF update_granted = abap_false.  " ❌ Unauthorized

        APPEND VALUE #( %tky = <lfs_studentadmitted>-%tky ) TO failed-student.

        APPEND VALUE #(
          %tky = <lfs_studentadmitted>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'No Authorization to update status!!!' )
        ) TO reported-student.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDMETHOD.


  METHOD get_instance_features.

    READ ENTITIES OF zr_nm_tabletmg IN LOCAL MODE
      ENTITY Student
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(studentadmitted)
      FAILED failed.

    result = VALUE #(
      FOR student IN studentadmitted
      LET status_flag = COND #(
                    WHEN student-Status = abap_false
                    THEN if_abap_behv=>fc-o-enabled
                    ELSE if_abap_behv=>fc-o-disabled )

      IN ( %tky = student-%tky
           %action-setAdmitted = status_flag ) ).

  ENDMETHOD.



  METHOD setAdmitted.

    MODIFY ENTITIES OF zr_nm_tabletmg IN LOCAL MODE
      ENTITY Student
      UPDATE FIELDS ( Status )
      WITH VALUE #(
        FOR key IN keys
        ( %tky = key-%tky Status = abap_true )
      )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zr_nm_tabletmg IN LOCAL MODE
      ENTITY Student
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(studentdata).

    result = VALUE #(
      FOR studentrec IN studentdata
      ( %tky = studentrec-%tky %param = studentrec )
    ).

  ENDMETHOD.

  METHOD copyStudent.

 DATA: lt_student TYPE TABLE FOR CREATE zr_nm_tabletmg.

  " Reading selected data from frontend
  READ ENTITIES OF zr_nm_tabletmg IN LOCAL MODE
    ENTITY Student
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(students)
    FAILED failed.

  LOOP AT students ASSIGNING FIELD-SYMBOL(<lfs_students>).

    APPEND VALUE #(
      %cid     = keys[ KEY entity %key = <lfs_students>-%key ]-%cid
      %is_draft = keys[ KEY entity %key = <lfs_students>-%key ]-%param-%is_draft
      %data    = CORRESPONDING #( <lfs_students> except  Studentid )
    ) TO lt_student ASSIGNING FIELD-SYMBOL(<lfs_newStudent>).

  ENDLOOP.

  modify ENTITIES OF zr_nm_tabletmg in LOCAL MODE
  entity Student
  create fields ( Firstname Lastname Age Course Courseduration Status Gender )
  with lt_student
  mapped data(mapped_create).
  mapped-student = mapped_create-student.

  ENDMETHOD.

  METHOD createInstance.

  MODIFY ENTITIES OF zr_nm_tabletmg IN LOCAL MODE
  ENTITY Student
     CREATE FROM VALUE #( FOR <instance> IN keys (
  %cid            = <instance>-%cid
  Age             = 23
  Course          = 'E'
  Courseduration  = 5
  Firstname       = 'FNM'
  Lastname        = 'LNM'
  Dob             = sy-datum
  %control =
    VALUE #(
      Age             = if_abap_behv=>mk-on
      Course          = if_abap_behv=>mk-on
      Courseduration  = if_abap_behv=>mk-on
      Firstname       = if_abap_behv=>mk-on
      Lastname        = if_abap_behv=>mk-off
      Dob             = if_abap_behv=>mk-on
    )
) )

MAPPED   mapped
FAILED   failed
REPORTED reported.
  ENDMETHOD.

ENDCLASS.
