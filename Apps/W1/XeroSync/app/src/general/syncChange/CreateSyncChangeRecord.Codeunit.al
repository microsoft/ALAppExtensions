codeunit 2424 "XS Create Sync Change Record"
{
    procedure CreateSyncChangeRecord(var SyncChange: Record "Sync Change"; NAVEntityID: Integer; EntityDataJsonText: Text);
    var
        Handled: Boolean;
    begin
        OnBeforeCreateSyncChangeRecord(SyncChange, Handled);

        DoCreateSyncChangeRecord(SyncChange, NAVEntityID, EntityDataJsonText);

        OnAfterCreateSyncChangeRecord(SyncChange);
    end;

    local procedure DoCreateSyncChangeRecord(var SyncChange: Record "Sync Change"; NAVEntityID: Integer; EntityDataJsonText: Text)
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        JobQueueFunctionLibrary: Codeunit "XS Job Queue Management";
    begin
        SyncChange."Sync Handler" := XeroSyncManagement.GetXeroHandler();
        SyncChange."XS NAV Entity ID" := NAVEntityID;
        if not SyncChange.Insert(true) then
            exit;

        if SyncChange."Change Type" = SyncChange."Change Type"::Delete then
            if SyncChange.Direction = SyncChange.Direction::Incoming then
                exit;

        SaveJsonData(SyncChange, EntityDataJsonText);
        SyncChange.Modify(true);

        if not JobQueueFunctionLibrary.CheckifJobQueueEntryExists() then
            JobQueueFunctionLibrary.CreateJobQueueEntry();
    end;

    local procedure SaveJsonData(var SyncChange: Record "Sync Change"; EntityDataJsonText: Text)
    var
        OutStream: OutStream;
    begin
        case SyncChange.Direction of
            SyncChange.Direction::Incoming:
                SyncChange."XS Xero Json Response".CreateOutStream(OutStream, TextEncoding::UTF8);
            SyncChange.Direction::Outgoing:
                SyncChange."NAV Data".CreateOutStream(OutStream, TextEncoding::UTF8);
        end;

        OutStream.Write(EntityDataJsonText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSyncChangeRecord(SyncChange: Record "Sync Change"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSyncChangeRecord(SyncChange: Record "Sync Change");
    begin
    end;
}