permissionset 18921 "D365 Read Access - IN Charge"
{
    Access = Public;
    Assignable = false;
    Caption = 'D365 Read Access - IN Charge';

    Permissions = tabledata "Charge Group Header" = R,
                    tabledata "Charge Group Line" = R;
}