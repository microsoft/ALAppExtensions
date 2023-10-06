namespace Microsoft.DataMigration;

permissionset 4006 "HBD - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'HybridBaseDeployment- Objects';

    Permissions = page "Hybrid DA Approval" = X,
                  page "Add Migration Table Mappings" = X,
                  table "Hybrid Company Status" = X,
                  table "Hybrid DA Approval" = X;
}
