codeunit 139516 "XS Sync Wizard Test"
{
    // [FEATURE] [Synchronization]
    Subtype = Test;

    var

    local procedure Initialize()
    var
        SyncSetup: Record "Sync Setup";
    begin
        SyncSetup."XS Enabled" := true;
    end;

    [ConfirmHandler]
    procedure AcceptStopSynchronization(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}