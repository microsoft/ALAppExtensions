namespace Microsoft.DataMigration;

permissionset 4006 "HBD - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'HybridBaseDeployment- Objects';

    Permissions = page "Hybrid DA Approval" = X,
                  page "Add Migration Table Mappings" = X,
                  table "Hybrid Company Status" = X,
                  table "Hybrid DA Approval" = X,
                  table "Migration Validation Error" = X,
                  page "Migration Validation Errors" = X,
                  codeunit "Migration Validation Assert" = X,
                  codeunit "Migration Validation" = X,
                  table "Migration Validation Test" = X,
                  page "Migration Validation Results" = X,
                  table "Validation Progress" = X,
                  codeunit "Migration Validator Warning" = X;
}
