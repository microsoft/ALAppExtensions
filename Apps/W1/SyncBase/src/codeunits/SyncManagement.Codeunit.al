codeunit 2401 "Sync Management"
{
    SingleInstance = true;

    procedure MergeSyncChanges()
    var
        IncomingSyncChange: Record "Sync Change";
        OutgoingSyncChange: Record "Sync Change";
        SyncMapping: Record "Sync Mapping";
    begin
        IncomingSyncChange.Init();
        IncomingSyncChange.SetRange(Direction, IncomingSyncChange.Direction::Incoming);
        if IncomingSyncChange.FindSet() then
            repeat
                OutgoingSyncChange.Init();
                OutgoingSyncChange.SetRange(Direction, OutgoingSyncChange.Direction::Outgoing);
                if OutgoingSyncChange.FindSet() then
                    repeat
                        SyncMapping.SetRange("Internal ID", OutgoingSyncChange."Internal ID");
                        SyncMapping.SetRange("External Id", IncomingSyncChange."External ID");
                        if SyncMapping.FindFirst() then begin
                            if IncomingSyncChange."Change Type" <> IncomingSyncChange."Change Type"::Delete then begin
                                IncomingSyncChange.Direction := IncomingSyncChange.Direction::Bidirectional;
                                if OutgoingSyncChange."Change Type" = OutgoingSyncChange."Change Type"::Create then
                                    IncomingSyncChange."Change Type" := IncomingSyncChange."Change Type"::Update
                                else
                                    IncomingSyncChange."Change Type" := OutgoingSyncChange."Change Type";
                                IncomingSyncChange."Internal ID" := OutgoingSyncChange."Internal ID";
                                if OutgoingSyncChange."NAV Data".HasValue() then begin
                                    OutgoingSyncChange.CalcFields("NAV Data");
                                    IncomingSyncChange."NAV Data" := OutgoingSyncChange."NAV Data";
                                end;
                                IncomingSyncChange.Modify(true);
                            end else
                                if OutgoingSyncChange."Change Type" = OutgoingSyncChange."Change Type"::Delete then begin
                                    IncomingSyncChange.Delete(true);
                                    SyncMapping.Delete(true);
                                end;
                            OutgoingSyncChange.Delete(true);
                        end;
                    until OutgoingSyncChange.Next() = 0;
            until IncomingSyncChange.Next() = 0;
    end;
}

