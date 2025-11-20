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
                  codeunit "Migration Validation" = X,
                  page "Company Migration Status" = X,
                  table "Migration Validation Test" = X,
                  page "Migration Validation Results" = X,
                  table "Company Validation Progress" = X,
                  table "Migration Validation Buffer" = X,
                  codeunit "Migration Validator Warning" = X;
}
