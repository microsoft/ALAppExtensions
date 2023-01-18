permissionset 18919 "D365 Common Access - IN Charge"
{
    Access = Public;
    Assignable = false;
    Caption = 'D365 Common Access - IN Charge';

    Permissions = tabledata "Charge Group Header" = RIMD,
                    tabledata "Charge Group Line" = RIMD;
}