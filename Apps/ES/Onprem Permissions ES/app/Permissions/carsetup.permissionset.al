permissionset 10707 "CAR-SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cartera - Setup';

    Permissions = tabledata "Cartera Setup" = RIMD,
                  tabledata "Operation Fee" = RIMD;
}
