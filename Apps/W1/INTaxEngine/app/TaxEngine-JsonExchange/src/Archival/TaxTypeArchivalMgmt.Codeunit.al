codeunit 20368 "Tax Type Archival Mgmt."
{
    procedure ShowConfigurationFile(TaxTypeArchivalLogEntry: Record "Tax Type Archival Log Entry")
    var
        IStream: InStream;
        FileTextLbl: Label '%1.json', Comment = '%1 = name of Tax Type';
        FileName: Text;
    begin
        FileName := StrSubstNo(FileTextLbl, TaxTypeArchivalLogEntry.Description);
        TaxTypeArchivalLogEntry.CalcFields("Configuration Data");
        if TaxTypeArchivalLogEntry."Configuration Data".HasValue then begin
            TaxTypeArchivalLogEntry."Configuration Data".CreateInStream(IStream);
            DownloadFromStream(IStream, '', '', '', FileName);
        end;
    end;

    procedure RestoreArchivalToUse(TaxTypeArchivalLogEntry: Record "Tax Type Archival Log Entry")
    var
        TaxType: Record "Tax Type";
        TypeHelper: Codeunit "Type Helper";
        RestoreTaxTypeQst: Label 'If you restore this version then current version will be deleted and might make your existing use cases inconsistent. Do you want continue ?';
        IStream: InStream;
        OldVersion: Decimal;
        JsonText: Text;
    begin
        TaxTypeArchivalLogEntry.TestField("Tax Type");

        if not Confirm(RestoreTaxTypeQst) then
            exit;

        TaxType.Get(TaxTypeArchivalLogEntry."Tax Type");
        OldVersion := TaxType."Minor Version";
        if TaxType.Status = TaxType.Status::Draft then
            OldVersion -= 1
        else begin
            TaxType.Validate(Status, TaxType.Status::Draft);
            TaxType.Modify();
        end;

        ClearTaxEngineSetup(TaxTypeArchivalLogEntry."Tax Type");
        TaxTypeArchivalLogEntry.CalcFields("Configuration Data");
        TaxTypeArchivalLogEntry."Configuration Data".CreateInStream(IStream);
        JsonText := TypeHelper.ReadAsTextWithSeparator(IStream, '');
        RestoreTaxType(JsonText, TaxTypeArchivalLogEntry."Tax Type", OldVersion);
    end;

    procedure SetIfChangedByMicrosoft(NewChangedByMicrosoft: Boolean)
    begin
        ChangedByMicrosoft := NewChangedByMicrosoft;
    end;

    local procedure RestoreTaxType(JsonText: Text; TaxTypeCode: Code[20]; OldVersion: Decimal)
    var
        TaxType: Record "Tax Type";
        TaxJsonDeSerializationImport: Codeunit "Tax Json Deserialization";
        OpenRestoredTaxTypeQst: Label 'Tax type is restored. Do you want open this version now ?';
    begin
        TaxJsonDeSerializationImport.HideDialog(true);
        TaxJsonDeSerializationImport.ImportTaxTypes(JsonText);

        TaxType.Get(TaxTypeCode);
        TaxType.Validate("Minor Version", GetNextVersionID(OldVersion));
        TaxType.Validate(Status, TaxType.Status::Released);
        TaxType.Modify();

        Commit();
        if Confirm(OpenRestoredTaxTypeQst) then
            Page.Run(PAGE::"Tax Type", TaxType);
    end;

    local procedure ExportModifiedTaxTypes()
    var
        TaxType: Record "Tax Type";
        UseCaseArchivalMgmt: Codeunit "Use Case Archival Mgmt.";
    begin
        TaxType.SetFilter("Minor Version", '<>%1', 0);
        if not TaxType.IsEmpty() then
            UseCaseArchivalMgmt.ExportTaxTypes(TaxType);
    end;

    local procedure ArchiveTaxType(var TaxType: Record "Tax Type")
    begin
        CreateArchivalLog(TaxType);
    end;

    local procedure CreateArchivalLog(var TaxType: Record "Tax Type")
    var
        TaxTypeArchivalLogEntry: Record "Tax Type Archival Log Entry";
        OStream: OutStream;
    begin
        TaxTypeArchivalLogEntry.init();
        TaxTypeArchivalLogEntry."Tax Type" := TaxType.Code;
        TaxTypeArchivalLogEntry.Description := TaxType.Description;
        TaxTypeArchivalLogEntry."Log Date-Time" := CurrentDateTime;
        TaxTypeArchivalLogEntry."Major Version" := TaxType."Major Version";
        TaxTypeArchivalLogEntry."Minor Version" := TaxType."Minor Version";
        TaxTypeArchivalLogEntry."Configuration Data".CreateOutStream(OStream);
        TaxTypeArchivalLogEntry."Changed by" := TaxType."Changed By";
        OStream.WriteText(GetTaxTypeJsonText(TaxType.Code));
        TaxTypeArchivalLogEntry."User ID" := copystr(UserId(), 1, 50);
        TaxTypeArchivalLogEntry.Insert(true);

        UpdateTaxType(TaxType, TaxTypeArchivalLogEntry);
    end;

    local procedure UpdateTaxType(
        var TaxType: Record "Tax Type";
        TaxTypeArchivalLogEntry: Record "Tax Type Archival Log Entry")
    begin
        RemoveIsActiveFromLastLog(TaxType.Code, TaxTypeArchivalLogEntry."Entry No.");
        TaxType.Validate("Effective From", TaxTypeArchivalLogEntry."Log Date-Time");
        TaxType.Validate("Major Version", TaxTypeArchivalLogEntry."Major Version");
        TaxType.Validate("Minor Version", GetNextVersionID(TaxTypeArchivalLogEntry."Minor Version"));
        TaxType.Validate("Changed By", ChangedByPartnerLbl);
    end;

    local procedure GetTaxTypeJsonText(TaxTypeCode: Code[20]) JsonText: Text
    var
        TaxType: Record "Tax Type";
        TaxJsonSerialization: Codeunit "Tax Json Serialization";
        TaxTypeJArray: JsonArray;
    begin
        TaxType.SetRange(Code, TaxTypeCode);
        TaxJsonSerialization.ExportTaxTypes(TaxType, TaxTypeJArray);
        TaxTypeJArray.WriteTo(JsonText);
    end;

    local procedure RemoveIsActiveFromLastLog(TaxTypeCode: Code[20]; EntryNo: Integer)
    var
        TaxTypeArchivalLogEntry: Record "Tax Type Archival Log Entry";
    begin
        TaxTypeArchivalLogEntry.SetRange("Tax Type", TaxTypeCode);
        TaxTypeArchivalLogEntry.SetRange("Active Version", true);
        TaxTypeArchivalLogEntry.SetFilter("Entry No.", '<>%1', EntryNo);
        if TaxTypeArchivalLogEntry.FindFirst() then begin
            TaxTypeArchivalLogEntry.Validate("Active Version", false);
            TaxTypeArchivalLogEntry.Modify();
        end;
    end;

    local procedure GetNextVersionID(CurrentVersion: Integer): Integer
    begin
        exit(CurrentVersion + 1);
    end;

    local procedure ClearTaxEngineSetup(TaxTypeCode: Code[20])
    var
        TaxType: Record "Tax Type";
    begin
        TaxType.SetHideDialog(true);
        TaxType.SetSkipUseCaseDeletion(true);
        TaxType.Get(TaxTypeCode);
        TaxType.Delete(true);
    end;

    local procedure LogStatusTelemetry(TaxType: Code[20]; VersionTxt: Text; TaxTypeStatus: Enum "Tax Type Status")
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('TaxType', TaxType);
        Dimensions.Add('Version', VersionTxt);
        Dimensions.Add('Status', Format(TaxTypeStatus));

        Session.LogMessage(
            'TE-TAXTYPE-STATUS',
            UseCaseStatusTxt,
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            Dimensions);
    end;

    local procedure GetVersionText(Major: Integer; Minor: Integer): Text
    begin
        exit(StrSubstNo(VersionLbl, Major, Minor));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Engine Setup Wizard", 'OnAfterActionEvent', 'ExportModified', false, false)]
    local procedure OnAfterExportModified()
    begin
        ExportModifiedTaxTypes();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Type", 'OnBeforeValidateEvent', 'Status', false, false)]
    local procedure OnAfterValidateEnableEvent(var Rec: Record "Tax Type"; var xRec: Record "Tax Type")
    begin
        if xRec.Status = Rec.Status then
            exit;

        if Rec.Status = Rec.Status::Draft then begin
            ArchiveTaxType(Rec);
            Rec.Validate(Enabled, false);
        end;

        LogStatusTelemetry(Rec.Code, GetVersionText(Rec."Major Version", Rec."Minor Version"), Rec.Status);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Type", 'OnAfterActionEvent', 'ArchivedLogs', false, false)]
    local procedure OnAfterActionArchivedLogsFromTaxTypeCard(var Rec: Record "Tax Type")
    var
        TaxTypeArchivalLogEntry: Record "Tax Type Archival Log Entry";
    begin
        TaxTypeArchivalLogEntry.SetRange("Tax Type", Rec.Code);
        Page.run(Page::"Tax Type Archival Log Entries", TaxTypeArchivalLogEntry);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Types", 'OnAfterActionEvent', 'ArchivedLogs', false, false)]
    local procedure OnAfterActionArchivedLogsFromTaxTypeList(var Rec: Record "Tax Type")
    var
        TaxTypeArchivalLogEntry: Record "Tax Type Archival Log Entry";
    begin
        TaxTypeArchivalLogEntry.SetRange("Tax Type", Rec.Code);
        Page.run(Page::"Tax Type Archival Log Entries", TaxTypeArchivalLogEntry);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Type", 'OnAfterExportTaxTypes', '', false, false)]
    local procedure OnAfterExportTaxTypes(var TaxType: Record "Tax Type")
    var
        UseCaseArchivalMgmt: Codeunit "Use Case Archival Mgmt.";
    begin
        UseCaseArchivalMgmt.ExportTaxTypes(TaxType);
    end;

    var
        ChangedByMicrosoft: Boolean;
        ChangedByPartnerLbl: Label 'Partner';
        UseCaseStatusTxt: Label 'Tax Type Status change.', Locked = true;
        VersionLbl: Label '%1.%2', Comment = '%1 - Major Version, %2 - Minor Version';
}