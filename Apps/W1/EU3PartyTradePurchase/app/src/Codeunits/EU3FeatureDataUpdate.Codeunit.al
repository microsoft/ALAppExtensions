#if not CLEAN23
/// <summary>
/// EU 3-Party Trade Purchase feature will be moved to a separate app.
/// </summary>
codeunit 4886 "EU3 Feature Data Update" implements "Feature Data Update"
{
    Access = Internal;
    Permissions = TableData "Feature Data Update Status" = rm,
                  TableData "Purchase Header" = rm,
                  TableData "Purch. Inv. Header" = rm,
                  TableData "Purch. Cr. Memo Hdr." = rm,
                  TableData "VAT Setup" = rim;

    procedure IsDataUpdateRequired(): Boolean;
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        VATStatementLine: Record "VAT Statement Line";
    begin
        CountRecords(Database::"Purchase Header", PurchaseHeader.TableCaption, 11200); //PurchaseHeader.FieldNo("EU 3-Party Trade"));
        CountRecords(Database::"Purch. Inv. Header", PurchInvHeader.TableCaption, 11200); //PurchInvHeader.FieldNo("EU 3-Party Trade"));
        CountRecords(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.TableCaption, 11200); //PurchCrMemoHdr.FieldNo("EU 3-Party Trade"));
        CountRecords(Database::"VAT Statement Line", VATStatementLine.TableCaption, 11200); //VATStatementLine.FieldNo("EU 3-Party Trade"));
        exit(not TempDocumentEntry.IsEmpty());
    end;

    procedure ReviewData();
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Commit();
        Clear(DataUpgradeOverview);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    var
        StartDateTime: DateTime;
        EndDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'UpgradeEU3PartyTradePurchase', StartDateTime);
        UpgradeEU3PartyTradePurchase();
        EndDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'UpgradeEU3PartyTradePurchase', EndDateTime);
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := GetListOfTables();
    end;

    local procedure GetListOfTables() Result: Text;
    begin
        Result := StrSubstNo(DescriptionTxt, PurchaseHdrTxt, PurchaseInvHdrTxt, PurchaseCrMemoHdrTxt, VATStatementLineTxt);
        OnAfterGetListOfTables(Result);
    end;

    local procedure UpgradeEU3PartyTradePurchase()
    var
        Company: Record Company;
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        VATStatementLine: Record "VAT Statement Line";
    begin
        if Company.FindSet() then
            repeat
                UpdateRecords(Database::"Purchase Header", 11200, PurchaseHeader.FieldNo("EU 3 Party Trade"), Company);
                UpdateRecords(Database::"Purch. Inv. Header", 11200, PurchInvHeader.FieldNo("EU 3 Party Trade"), Company);
                UpdateRecords(Database::"Purch. Cr. Memo Hdr.", 11200, PurchCrMemoHdr.FieldNo("EU 3 Party Trade"), Company);
                UpdateRecords(Database::"VAT Statement Line", 11200, VATStatementLine.FieldNo("EU 3 Party Trade"), Company);
            until Company.Next() = 0;
    end;

    local procedure CountRecords(SourceTableId: Integer; SourceTableName: Text[30]; SourceFieldId: Integer)
    var
        Company: Record Company;
        SourceRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        RecordCount: Integer;
    begin
        if Company.FindSet() then
            repeat
                SourceRecRef.Open(SourceTableId, false, Company.Name);
                if SourceRecRef.FieldExist(SourceFieldId) then begin
                    SourceFieldRef := SourceRecRef.Field(SourceFieldId);

                    if SourceTableId <> Database::"VAT Statement Line" then
                        SourceFieldRef.SetFilter('=%1', true);
                    if SourceRecRef.FindSet() then
                        RecordCount += SourceRecRef.Count;
                end;
                SourceRecRef.Close();
            until Company.Next() = 0;

        InsertDocumentEntry(SourceTableId, SourceTableName, RecordCount);
    end;

    local procedure InsertDocumentEntry(TableID: Integer; TableName: Text; RecordCount: Integer)
    begin
        if RecordCount = 0 then
            exit;

        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." += 1;
        TempDocumentEntry."Table ID" := TableID;
        TempDocumentEntry."Table Name" := CopyStr(TableName, 1, MaxStrLen(TempDocumentEntry."Table Name"));
        TempDocumentEntry."No. of Records" := RecordCount;
        TempDocumentEntry.Insert();
    end;

    local procedure UpdateRecords(SourceTableId: Integer; SourceFieldId: Integer; TargetFieldId: Integer; var Company: Record Company)
    var
        SourceRecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
        EU3PartyTradeFilter: Enum "EU3 Party Trade Filter";
    begin
        SourceRecRef.Open(SourceTableId, false, Company.Name);
        if SourceRecRef.FieldExist(SourceFieldId) then begin
            SourceRecRef.SetLoadFields(SourceFieldId, TargetFieldId);
            SourceFieldRef := SourceRecRef.Field(SourceFieldId);
            if SourceTableId <> Database::"VAT Statement Line" then
                SourceFieldRef.SetFilter('=%1', true);

            if SourceRecRef.FindSet() then
                repeat
                    SourceFieldRef := SourceRecRef.Field(SourceFieldId);
                    TargetFieldRef := SourceRecRef.Field(TargetFieldId);
                    if SourceFieldRef.Value then
                        TargetFieldRef.Value := EU3PartyTradeFilter::EU3
                    else
                        TargetFieldRef.Value := EU3PartyTradeFilter::"non-EU3";
                    SourceRecRef.Modify();
                until SourceRecRef.Next() = 0;
        end;
        SourceRecRef.Close();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterUpdateData', '', false, false)]
    local procedure HandleOnOnAfterUpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        VATSetup: Record "VAT Setup";
        EU3PartyTradeFeatureMgt: Codeunit "EU3 Party Trade Feature Mgt.";
    begin
        if FeatureDataUpdateStatus."Feature Key" <> EU3PartyTradeFeatureMgt.GetFeatureKeyId() then
            exit;
        if not VATSetup.Get() then
            VATSetup.Insert();
        VATSetup."Enable EU 3-Party Purchase" := true;
        VATSetup.Modify(true);
        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Enabled;
        FeatureDataUpdateStatus.Modify();
    end;

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        DescriptionTxt: Label 'Records in the %1, %2, %3 and %4 tables will be updated. Please review affected data as the data update can take longer in case of large amount of records. ', Comment = '%1, %2, %3, %4 - table captions';
        PurchaseHdrTxt: Label 'Purchase Header', Locked = true;
        PurchaseInvHdrTxt: Label 'Purch. Inv. Header', Locked = true;
        PurchaseCrMemoHdrTxt: Label 'Purch. Cr. Memo Hdr.', Locked = true;
        VATStatementLineTxt: Label 'VAT Statement Line', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetListOfTables(var Result: Text)
    begin
    end;
}
#endif