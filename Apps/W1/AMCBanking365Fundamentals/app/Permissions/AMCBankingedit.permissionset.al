permissionset 20111 "AMC Banking - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'AMC Banking - Edit';

    IncludedPermissionSets = "AMC Banking - Read";
    
    Permissions = tabledata "AMC Bank Banks" = IMD,
                  tabledata "AMC Bank Pmt. Type" = IMD,
                  tabledata "AMC Banking Setup" = IMD;
}