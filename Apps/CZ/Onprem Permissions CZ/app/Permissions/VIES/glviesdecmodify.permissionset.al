permissionset 11711 "GL-VIES DEC. MODIFY"
{
    Access = Public;
    Assignable = true;
    Caption = 'GL-Vies declaration modify';

    Permissions = tabledata "VIES Declaration Header" = RIMD,
                  tabledata "VIES Declaration Line" = RIMD;
}
