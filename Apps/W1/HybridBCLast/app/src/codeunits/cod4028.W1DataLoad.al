codeunit 4028 "W1 Data Load"
{
    procedure LoadTableData(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text)
    begin
        // Needed so that AL contract doesn't break
        LoadTableData_15x(HybridReplicationSummary, CountryCode, 15.0);
        LoadTableData_16x(HybridReplicationSummary, CountryCode, 16.0);
        LoadTableData_17x(HybridReplicationSummary, CountryCode, 17.0);
        LoadTableData_18x(HybridReplicationSummary, CountryCode, 18.0);
        LoadTableData_19x(HybridReplicationSummary, CountryCode, 19.0);
        LoadTableData_20x(HybridReplicationSummary, CountryCode, 20.0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnLoadTableDataForVersion', '', false, false)]
    local procedure LoadTableData_15x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        LoadIncomingDocument(HybridReplicationSummary);
        OnAfterW1DataLoadForVersion(HybridReplicationSummary, CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnLoadTableDataForVersion', '', false, false)]
    local procedure LoadTableData_16x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 16.0 then
            exit;

        OnAfterW1DataLoadForVersion(HybridReplicationSummary, CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnLoadTableDataForVersion', '', false, false)]
    local procedure LoadTableData_17x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 17.0 then
            exit;

        OnAfterW1DataLoadForVersion(HybridReplicationSummary, CountryCode, TargetVersion);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnLoadTableDataForVersion', '', false, false)]
    local procedure LoadTableData_18x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        OnAfterW1DataLoadForVersion(HybridReplicationSummary, CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnLoadTableDataForVersion', '', false, false)]
    local procedure LoadTableData_19x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;

        OnAfterW1DataLoadForVersion(HybridReplicationSummary, CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnLoadTableDataForVersion', '', false, false)]
    local procedure LoadTableData_20x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 20.0 then
            exit;

        OnAfterW1DataLoadForVersion(HybridReplicationSummary, CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnLoadNonCompanyTableDataForVersion', '', false, false)]
    local procedure LoadNonCompanyTableData_15x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        OnAfterW1DataLoadNonCompanyForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnLoadNonCompanyTableDataForVersion', '', false, false)]
    local procedure LoadNonCompanyTableData_16x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 16.0 then
            exit;

        OnAfterW1DataLoadNonCompanyForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnLoadNonCompanyTableDataForVersion', '', false, false)]
    local procedure LoadNonCompanyTableData_17x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 17.0 then
            exit;

        OnAfterW1DataLoadNonCompanyForVersion(CountryCode, TargetVersion);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnLoadNonCompanyTableDataForVersion', '', false, false)]
    local procedure LoadNonCompanyTableData_18x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        OnAfterW1DataLoadNonCompanyForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnLoadNonCompanyTableDataForVersion', '', false, false)]
    local procedure LoadNonCompanyTableData_19x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;

        OnAfterW1DataLoadNonCompanyForVersion(CountryCode, TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnLoadNonCompanyTableDataForVersion', '', false, false)]
    local procedure LoadNonCompanyTableData_20x(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 20.0 then
            exit;

        OnAfterW1DataLoadNonCompanyForVersion(CountryCode, TargetVersion);
    end;

    local procedure LoadIncomingDocument(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        IncomingDocument: Record "Incoming Document";
        StgIncomingDocument: Record "Stg Incoming Document";
    begin
        if StgIncomingDocument.FindSet(false, false) then begin
            repeat
                IncomingDocument.SetRange("Entry No.", StgIncomingDocument."Entry No.");
                if IncomingDocument.FindFirst() then begin
                    IncomingDocument.TransferFields(StgIncomingDocument);
                    IncomingDocument.Modify();
                end;
            until StgIncomingDocument.Next() = 0;

            OnAfterCompanyTableLoad(IncomingDocument.RecordId().TableNo(), HybridReplicationSummary."Synced Version");
            StgIncomingDocument.DeleteAll();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterW1DataLoadForVersion(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterW1DataLoadNonCompanyForVersion(CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCompanyTableLoad(TableNo: Integer; SyncedVersion: BigInteger)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterNonCompanyTableLoad(TableNo: Integer; SyncedVersion: BigInteger)
    begin
    end;
}
