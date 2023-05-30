#if not CLEAN22
/// <summary>
/// Automatic Acc. feature will be moved to a separate app.
/// </summary>
codeunit 4851 "Feature Auto. Acc. Codes" implements "Feature Data Update"
{
    Access = Internal;
    Permissions = TableData "Feature Data Update Status" = rm;

    procedure IsDataUpdateRequired(): Boolean;
    begin
        CountRecords();
        exit(not TempDocumentEntry.IsEmpty);
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
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'UpgradeAutomaticAccountCodes', StartDateTime);
        UpgradeAutomaticAccountCodes();
        EndDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'UpgradeAutomaticAccountCodes', EndDateTime);
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := StrSubstNo(DescrTok, GetListOfTables(), Description2Txt);
    end;

    local procedure GetListOfTables() Result: Text;
    var

    begin
        Result := StrSubstNo(Description1Txt, AutomaticAccHdrTxt, AutomaticAccLnTxt);
        OnAfterGetListOfTables(Result);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureEnableConfirmed', '', false, false)]
    local procedure HandleOnAfterFeatureEnableConfirmed(var FeatureKey: Record "Feature Key")
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterUpdateData', '', false, false)]
    local procedure HandleOnOnAfterUpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
    begin
        if FeatureDataUpdateStatus."Feature Key" <> AutoAccCodesFeatureMgt.GetFeatureKeyId() then
            exit;
        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Enabled;
        FeatureDataUpdateStatus.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnBeforeSetFeatureStatusForOtherCompanies', '', false, false)]
    local procedure OnBeforeSetFeatureStatusForOtherCompanies(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; var IsHandled: Boolean)
    var
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
    begin
        if IsHandled then
            exit;
        if FeatureDataUpdateStatus.GetFilter("Feature Key") <> AutoAccCodesFeatureMgt.GetFeatureKeyId() then
            exit;
        FeatureDataUpdateStatus.SetFilter("Company Name", '<>%1', CompanyName());
        FeatureDataUpdateStatus.ModifyAll("Feature Status", FeatureDataUpdateStatus."Feature Status"::Enabled);
        IsHandled := true;
    end;


    local procedure UpgradeAutomaticAccountCodes()
    var
        Company: Record Company;
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
        AutomaticAccHeaderTableId: Integer;
        AutomaticAccLineTableId: Integer;
    begin
        AutoAccCodesFeatureMgt.OnBeforeUpgradeToAutomaticAccountCodes(AutomaticAccHeaderTableId, AutomaticAccLineTableId);
        if AutomaticAccHeaderTableId = 0 then
            exit;

        if Company.FindSet() then
            repeat
                TransferRecords(AutomaticAccHeaderTableId, Database::"Automatic Account Header", Company);
                TransferRecords(AutomaticAccLineTableId, Database::"Automatic Account Line", Company);

                RemoveAutomaticAccountCodes(AutomaticAccHeaderTableId, Company);
                RemoveAutomaticAccountCodes(AutomaticAccLineTableId, Company);

                SetSetupKey(Company);
            until Company.Next() = 0;
    end;

    local procedure CountRecords()
    var
        Company: Record Company;
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
        AutomaticAccHeaderRecRef: RecordRef;
        AutomaticAccLineRecRef: RecordRef;
        AutomaticAccHeaderTableId: Integer;
        AutomaticAccLineTableId: Integer;
        HeaderCount, LineCount : Integer;
    begin
        TempDocumentEntry.Reset();
        TempDocumentEntry.DeleteAll();

        AutoAccCodesFeatureMgt.OnBeforeUpgradeToAutomaticAccountCodes(AutomaticAccHeaderTableId, AutomaticAccLineTableId);

        if Company.FindSet() then
            repeat
                // Automatic Account Codes
                AutomaticAccHeaderRecRef.Open(AutomaticAccHeaderTableId, false, Company.Name);
                AutomaticAccLineRecRef.Open(AutomaticAccLineTableId, false, Company.Name);
                if AutomaticAccHeaderRecRef.FindSet() then
                    HeaderCount += AutomaticAccHeaderRecRef.Count;
                if AutomaticAccLineRecRef.FindSet() then
                    LineCount += AutomaticAccLineRecRef.Count;
                AutomaticAccHeaderRecRef.Close();
                AutomaticAccLineRecRef.Close();

            until Company.Next() = 0;

        InsertDocumentEntry(AutomaticAccHeaderTableId, 'Automatic Acc. Header', HeaderCount);
        InsertDocumentEntry(AutomaticAccHeaderTableId, 'Automatic Acc. Line', LineCount);

    end;

    procedure SetSetupKey(Company: Record Company)
    var
        AutoAccPageSetupCardRecRef: RecordRef;
        AutoAccPageSetupListRecRef: RecordRef;
        AutoAccCodesIdFieldRef: FieldRef;
        AutoAccCodesObjectIdFieldRef: FieldRef;
    begin
        // Set up Card page to be used
        AutoAccPageSetupCardRecRef.Open(Database::"Auto. Acc. Page Setup", false, Company.Name);

        AutoAccCodesIdFieldRef := AutoAccPageSetupCardRecRef.FieldIndex(1);
        AutoAccCodesIdFieldRef.VALUE := Enum::"AAC Page Setup Key"::"Automatic Acc. Groups Card";

        AutoAccCodesObjectIdFieldRef := AutoAccPageSetupCardRecRef.FieldIndex(2);
        AutoAccCodesObjectIdFieldRef.VALUE := Page::"Automatic Account Header";

        AutoAccPageSetupCardRecRef.Insert();
        AutoAccPageSetupCardRecRef.Close();

        // Set up List page to be used
        AutoAccPageSetupListRecRef.Open(Database::"Auto. Acc. Page Setup", false, Company.Name);

        AutoAccCodesIdFieldRef := AutoAccPageSetupListRecRef.Field(1);
        AutoAccCodesIdFieldRef.VALUE := Enum::"AAC Page Setup Key"::"Automatic Acc. Groups List";

        AutoAccCodesObjectIdFieldRef := AutoAccPageSetupListRecRef.Field(2);
        AutoAccCodesObjectIdFieldRef.VALUE := Page::"Automatic Account List";
        AutoAccPageSetupListRecRef.Insert();

        AutoAccPageSetupListRecRef.Close();
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

    local procedure RemoveAutomaticAccountCodes(TableId: Integer; var Company: Record Company)
    var
        RecordRef: RecordRef;
    begin
        if TableId = 0 then
            exit;
        RecordRef.Open(TableId, false, Company.Name);
        RecordRef.DeleteAll();
        RecordRef.Close();
    end;

    local procedure TransferRecords(SourceTableId: Integer; TargetTableId: Integer; var Company: Record Company)
    var
        SourceField: Record Field;
        SourceRecRef: RecordRef;
        TargetRecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
        SourceFieldRefNo: Integer;
    begin
        SourceRecRef.Open(SourceTableId, false, Company.Name);
        TargetRecRef.Open(TargetTableId, false, Company.Name);

        if SourceRecRef.IsEmpty() then
            exit;

        SourceRecRef.FindSet();

        Repeat
            Clear(SourceField);
            SourceField.SetRange(TableNo, SourceTableId);
            SourceField.SetRange(Class, SourceField.Class::Normal);
            SourceField.SetRange(Enabled, true);
            if SourceField.Findset() then
                repeat
                    SourceFieldRefNo := SourceField."No.";
                    SourceFieldRef := SourceRecRef.Field(SourceFieldRefNo);
                    TargetFieldRef := TargetRecRef.Field(SourceFieldRefNo);
                    TargetFieldRef.VALUE := SourceFieldRef.VALUE;
                until SourceField.Next() = 0;
            TargetRecRef.Insert();
        Until SourceRecRef.Next() = 0;
        SourceRecRef.Close();
        TargetRecRef.Close();
    end;

    local procedure SyncFeatureStatusState(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
    begin
        if FeatureDataUpdateStatus."Feature Key" <> AutoAccCodesFeatureMgt.GetFeatureKeyId() then
            exit;
        if FeatureDataUpdateStatus."Feature Status" = FeatureDataUpdateStatus."Feature Status"::Enabled then
            EnableFeature();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Feature Data Update Status", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterFeatureDataUpdateStatusModify(var Rec: Record "Feature Data Update Status")
    begin
        SyncFeatureStatusState(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Feature Data Update Status", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterFeatureDataUpdateStatusInsert(var Rec: Record "Feature Data Update Status")
    begin
        SyncFeatureStatusState(Rec);
    end;

    procedure EnableFeature()
    var
        AutoAccCodesPageMgt: Codeunit "Auto. Acc. Codes Page Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        Country: Text;
    begin
        Country := EnvironmentInformation.GetApplicationFamily();
        if (Country = 'SE') or (Country = 'FI') then begin
            AutoAccCodesPageMgt.SetSetupKey(Enum::"AAC Page Setup Key"::"Automatic Acc. Groups Card", Page::"Automatic Account Header");
            AutoAccCodesPageMgt.SetSetupKey(Enum::"AAC Page Setup Key"::"Automatic Acc. Groups List", Page::"Automatic Account List");
            Commit();
        end;
    end;

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        Description1Txt: Label 'Records from %1, %2 tables', Comment = '%1, %2 - table captions';
        Description2Txt: Label 'will be copied to the Automatic Account Header and Automatic Account Line tables.';
        AutomaticAccHdrTxt: Label 'Automatic Acc. Header', Locked = true;
        AutomaticAccLnTxt: Label 'Automatic Acc. Line', Locked = true;
        DescrTok: Label '%1 %2', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetListOfTables(var Result: Text)
    begin
    end;
}
#endif