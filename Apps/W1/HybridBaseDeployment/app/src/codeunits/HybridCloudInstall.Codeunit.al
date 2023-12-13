namespace Microsoft.DataMigration;

codeunit 4000 "Hybrid Cloud Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany();
    var
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        HybridCueSetupManagement.InsertDataForReplicationSuccessRateCue();
    end;
}