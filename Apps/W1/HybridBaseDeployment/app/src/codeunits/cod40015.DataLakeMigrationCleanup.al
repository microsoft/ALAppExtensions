codeunit 40015 "Data Lake Migration Cleanup"
{
    Access = Internal;
    trigger OnRun()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.DisableDataLakeMigration();
    end;
}