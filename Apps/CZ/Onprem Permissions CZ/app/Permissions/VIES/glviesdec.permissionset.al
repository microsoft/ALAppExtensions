permissionset 11710 "GL-VIES DEC."
{
    Access = Public;
    Assignable = true;
    Caption = 'GL-Vies declaration read';

    Permissions = tabledata "VIES Declaration Header" = R,
                  tabledata "VIES Declaration Line" = R;
}
