permissionset 11708 "GL-CREDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'GL - Credit read';

    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Compensation Localization Pack for Czech.';
    ObsoleteTag = '18.0';

    Permissions = tabledata "Credit Header" = RIMD,
                  tabledata "Credit Line" = RIMD,
                  tabledata "Credit Report Selections" = R,
                  tabledata "Credits Setup" = R,
                  tabledata "Posted Credit Header" = R,
                  tabledata "Posted Credit Line" = R;
}
