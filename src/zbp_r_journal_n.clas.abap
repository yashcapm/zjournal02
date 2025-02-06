CLASS zbp_r_journal_n DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zr_journal_n.

PUBLIC SECTION.
    CLASS-DATA mapped_journalentrytp TYPE RESPONSE FOR MAPPED i_journalentrytp.

    CLASS-DATA : lt_Journal  type table of ztmapp_journal_n,
                 lt_Dtl      type table of ztmapp_journal_n.


ENDCLASS.



CLASS ZBP_R_JOURNAL_N IMPLEMENTATION.
ENDCLASS.
