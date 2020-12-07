codeunit 4000 "Hybrid Cloud Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany();
    var
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        HybridCueSetupManagement.InsertDataForReplicationSuccessRateCue();
    end;

    [Obsolete('No longer needed since the underlying field is removed.', '17.0')]
    procedure UpdateHybridReplicationDetailRecords()
    begin
    end;
}