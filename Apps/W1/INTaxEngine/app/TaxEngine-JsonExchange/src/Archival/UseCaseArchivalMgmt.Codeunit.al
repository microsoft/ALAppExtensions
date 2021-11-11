codeunit 20365 "Use Case Archival Mgmt."
{
    procedure ShowConfigurationFile(UseCaseArchivalLogEntry: Record "Use Case Archival Log Entry")
    var
        IStream: InStream;
        FileTextLbl: Label '%1.json', Comment = '%1 = name of use case';
        FileName: Text;
    begin
        FileName := StrSubstNo(FileTextLbl, UseCaseArchivalLogEntry.Description);
        UseCaseArchivalLogEntry.CalcFields("Configuration Data");
        if UseCaseArchivalLogEntry."Configuration Data".HasValue then begin
            UseCaseArchivalLogEntry."Configuration Data".CreateInStream(IStream);
            DownloadFromStream(IStream, '', '', '', FileName);
        end;
    end;

    procedure CopyUseCase(CaseId: Guid)
    var
        UseCase: Record "Tax Use Case";
        TaxJsonSerialization: Codeunit "Tax Json Serialization";
        TaxJsonDeSerialization: Codeunit "Tax Json Deserialization";
        OpenRestoredUseCaseQst: Label 'Use case is copied. Do you want open use case card now ?';
        JArray: JsonArray;
        JsonText: Text;
    begin
        UseCase.SetRange(ID, CaseId);
        TaxJsonSerialization.SetCalledFromCopyUseCase(true);
        TaxJsonSerialization.ExportUseCases(UseCase, JArray);
        JArray.WriteTo(JsonText);

        TaxJsonDeSerialization.ImportUseCases(JsonText);
        UseCase.Reset(); //becuase the record variable has filters on line 26.
        UseCase.Get(TaxJsonDeSerialization.GetCreatedCaseID());
        UseCase.Validate("Major Version", GetNextVersionID(0));
        UseCase.Validate("Minor Version", 0);
        UseCase.Status := UseCase.Status::Draft;
        UseCase.Enable := false;
        UseCase."Changed By" := ChangedByPartnerLbl;
        UseCase.Modify();
        Commit();

        if Confirm(OpenRestoredUseCaseQst) then
            Page.Run(PAGE::"Use Case Card", UseCase);
    end;

    procedure ExportUseCases(var UseCase: Record "Tax Use Case")
    var
        TaxJsonSerialization: Codeunit "Tax Json Serialization";
        TempBlob: Codeunit "Temp Blob";
        OStream: OutStream;
        IStream: InStream;
        JArray: JsonArray;
        JsonText: Text;
        FileText: Text;
    begin
        TaxJsonSerialization.ExportUseCases(UseCase, JArray);
        JArray.WriteTo(JsonText);
        if StrLen(JsonText) = 0 then
            exit;
        TempBlob.CreateOutStream(OStream);
        OStream.WriteText(JsonText);
        FileText := UseCase."Tax Type" + '.json';
        TempBlob.CreateInStream(IStream);
        DownloadFromStream(IStream, '', '', '', FileText);
    end;

    procedure ImportUseCases()
    var
        TaxJsonDeSerializationImport: Codeunit "Tax Json Deserialization";
        TypeHelper: Codeunit "Type Helper";
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        JsonText: Text;
        FileText: Text;
    begin
        TempBlob.CreateInStream(IStream);
        UploadIntoStream('', '', '', FileText, IStream);
        if FileText = '' then
            exit;

        JsonText := TypeHelper.ReadAsTextWithSeparator(IStream, '');
        TaxJsonDeSerializationImport.ImportUseCases(JsonText);
    end;

    procedure ExportTaxTypes(var TaxType: Record "Tax Type")
    var
        EntityJsonSerialization: Codeunit "Tax Json Serialization";
        TempBlob: Codeunit "Temp Blob";
        TaxConfigLbl: Label 'TaxConfig - %1.json', Comment = '%1 = name of company';
        OStream: OutStream;
        IStream: InStream;
        JArray: JsonArray;
        JsonText: Text;
        FileText: Text;
    begin
        EntityJsonSerialization.SetCanExportUseCases(Confirm(ExportUseCaseQst));
        EntityJsonSerialization.ExportTaxTypes(TaxType, JArray);
        JArray.WriteTo(JsonText);
        if StrLen(JsonText) = 0 then
            exit;
        TempBlob.CreateOutStream(OStream);
        OStream.WriteText(JsonText);
        FileText := StrSubstNo(TaxConfigLbl, CompanyName());
        TempBlob.CreateInStream(IStream);
        DownloadFromStream(IStream, '', '', '', FileText);
    end;

    procedure ImportTaxTypes()
    var
        TaxJsonSerializationImport: Codeunit "Tax Json Deserialization";
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
        JsonText: Text;
        FileText: Text;
    begin
        TempBlob.CreateInStream(IStream);
        UploadIntoStream('', '', '', FileText, IStream);
        if FileText = '' then
            exit;

        JsonText := TypeHelper.ReadAsTextWithSeparator(IStream, '');

        TaxJsonSerializationImport.SetCanImportUseCases(Confirm('Do you want to Import Use Cases as well?'));
        TaxJsonSerializationImport.ImportTaxTypes(JsonText);
    end;

    procedure RestoreArchivalToUse(UseCaseArchivalLogEntry: Record "Use Case Archival Log Entry")
    var
        TaxUseCase: Record "Tax Use Case";
        TypeHelper: Codeunit "Type Helper";
        RestoreUseCaseQst: Label 'If you restore this version then current version will be deleted. Do you want continue ?';
        IStream: InStream;
        OldVersion: Decimal;
        JsonText: Text;
    begin
        if not Confirm(RestoreUseCaseQst) then
            exit;

        TaxUseCase.Get(UseCaseArchivalLogEntry."Case ID");
        OldVersion := TaxUseCase."Minor Version";
        if TaxUseCase.Status = TaxUseCase.Status::Draft then
            OldVersion -= 1
        else begin
            TaxUseCase.Validate(Status, TaxUseCase.Status::Draft);
            TaxUseCase.Modify();
        end;

        UseCaseArchivalLogEntry.CalcFields("Configuration Data");
        UseCaseArchivalLogEntry."Configuration Data".CreateInStream(IStream);
        JsonText := TypeHelper.ReadAsTextWithSeparator(IStream, '');
        RestoreUseCase(JsonText, UseCaseArchivalLogEntry."Case ID", OldVersion);
    end;

    procedure SetIfChangedByMicrosoft(NewChangedByMicrosoft: Boolean)
    begin
        ChangedByMicrosoft := NewChangedByMicrosoft;
    end;

    local procedure RestoreUseCase(JsonText: Text; CaseID: Guid; OldVersion: Decimal)
    var
        TaxUseCase: Record "Tax Use Case";
        TaxJsonDeSerializationImport: Codeunit "Tax Json Deserialization";
        OpenRestoredUseCaseQst: Label 'Use case is restored. Do you want open this version now ?';
    begin
        TaxJsonDeSerializationImport.HideDialog(true);
        TaxJsonDeSerializationImport.SetGlobalCaseID(CaseID);
        TaxJsonDeSerializationImport.ImportUseCases(JsonText);

        TaxUseCase.Get(CaseID);
        TaxUseCase.Validate("Minor Version", GetNextVersionID(OldVersion));
        TaxUseCase.Validate(Status, TaxUseCase.Status::Released);
        TaxUseCase.Modify();

        Commit();
        if Confirm(OpenRestoredUseCaseQst) then
            Page.Run(PAGE::"Use Case Card", TaxUseCase);
    end;

    local procedure ExportModifiedUseCases()
    var
        TaxUseCase: Record "Tax Use Case";
    begin
        TaxUseCase.SetFilter("Minor Version", '<>%1', 0);
        if not TaxUseCase.IsEmpty() then
            ExportUseCases(TaxUseCase);
    end;

    local procedure ArchiveUseCase(var TaxUseCase: Record "Tax Use Case")
    begin
        CreateArchivalLog(TaxUseCase);
    end;

    local procedure CreateArchivalLog(var TaxUseCase: Record "Tax Use Case")
    var
        UseCaseArchivalLogEntry: Record "Use Case Archival Log Entry";
        OStream: OutStream;
    begin
        UseCaseArchivalLogEntry.init();
        UseCaseArchivalLogEntry."Case ID" := TaxUseCase.ID;
        UseCaseArchivalLogEntry.Description := TaxUseCase.Description;
        UseCaseArchivalLogEntry."Log Date-Time" := CurrentDateTime;
        UseCaseArchivalLogEntry."Major Version" := TaxUseCase."Major Version";
        UseCaseArchivalLogEntry."Minor Version" := TaxUseCase."Minor Version";
        UseCaseArchivalLogEntry."Configuration Data".CreateOutStream(OStream);
        UseCaseArchivalLogEntry."Changed by" := TaxUseCase."Changed By";
        OStream.WriteText(GetUseCaseJsonText(TaxUseCase.ID));
        UseCaseArchivalLogEntry."User ID" := copystr(UserId(), 1, 50);
        UseCaseArchivalLogEntry.Insert(true);

        UpdateTaxUseCase(TaxUseCase, UseCaseArchivalLogEntry);
    end;

    local procedure UpdateTaxUseCase(
        var TaxUseCase: Record "Tax Use Case";
        UseCaseArchivalLogEntry: Record "Use Case Archival Log Entry")
    begin
        RemoveIsActiveFromLastLog(TaxUseCase.ID, UseCaseArchivalLogEntry."Entry No.");
        TaxUseCase.Validate("Effective From", UseCaseArchivalLogEntry."Log Date-Time");
        TaxUseCase.Validate("Major Version", UseCaseArchivalLogEntry."Major Version");
        TaxUseCase.Validate("Minor Version", GetNextVersionID(UseCaseArchivalLogEntry."Minor Version"));
        TaxUseCase.Validate("Changed By", ChangedByPartnerLbl);
    end;

    local procedure GetUseCaseJsonText(CaseID: Guid) JsonText: Text
    var
        TaxUseCase: Record "Tax Use Case";
        TaxJsonSerialization: Codeunit "Tax Json Serialization";
        UseCaseJArray: JsonArray;
    begin
        TaxUseCase.SetRange(ID, CaseID);
        TaxJsonSerialization.ExportUseCases(TaxUseCase, UseCaseJArray);
        UseCaseJArray.WriteTo(JsonText);
    end;

    local procedure RemoveIsActiveFromLastLog(CaseID: Guid; EntryNo: Integer)
    var
        UseCaseArchivalLogEntry: Record "Use Case Archival Log Entry";
    begin
        UseCaseArchivalLogEntry.SetRange("Case ID", CaseID);
        UseCaseArchivalLogEntry.SetRange("Active Version", true);
        UseCaseArchivalLogEntry.SetFilter("Entry No.", '<>%1', EntryNo);
        if UseCaseArchivalLogEntry.FindFirst() then begin
            UseCaseArchivalLogEntry.Validate("Active Version", false);
            UseCaseArchivalLogEntry.Modify();
        end;
    end;

    local procedure LogStatusTelemetry(CaseId: Guid; VersionTxt: Text; UseCaseStatus: Enum "Use Case Status")
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('CaseID', CaseId);
        Dimensions.Add('Version', VersionTxt);
        Dimensions.Add('Status', Format(UseCaseStatus));

        Session.LogMessage(
            'TE-USECASE-STATUS',
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

    local procedure GetNextVersionID(CurrentVersion: Integer): Integer
    begin
        exit(CurrentVersion + 1);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Engine Setup Wizard", 'OnAfterActionEvent', 'ExportModified', false, false)]
    local procedure OnAfterExportModified()
    begin
        ExportModifiedUseCases();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Use Case", 'OnBeforeValidateEvent', 'Status', false, false)]
    local procedure OnAfterValidateEnableEvent(var Rec: Record "Tax Use Case"; var xRec: Record "Tax Use Case")
    begin
        if xRec.Status = Rec.Status then
            exit;

        if Rec.Status = Rec.Status::Draft then begin
            ArchiveUseCase(Rec);
            Rec.Validate(Enable, false);
        end;

        LogStatusTelemetry(Rec.ID, GetVersionText(Rec."Major Version", Rec."Minor Version"), Rec.Status);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Types", 'OnAfterExportTaxTypes', '', false, false)]
    local procedure OnAfterExportTaxTypes(var TaxType: Record "Tax Type")
    begin
        ExportTaxTypes(TaxType);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Mgmt.", 'OnAfterExportUseCases', '', false, false)]
    local procedure OnAfterActionExportUseCases(var TaxUseCase: Record "Tax Use Case")
    begin
        ExportUseCases(TaxUseCase);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Types", 'OnAfterActionEvent', 'ImportTaxTypes', false, false)]
    local procedure OnAfterActionImportTaxTypes()
    begin
        ImportTaxTypes();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Use Cases", 'OnAfterActionEvent', 'ImportUseCase', false, false)]
    local procedure OnAfterActionImportUseCases()
    begin
        ImportUseCases();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Use Case Card", 'OnAfterActionEvent', 'CopyUseCase', false, false)]
    local procedure OnAfterActionCopyUseCase(var Rec: Record "Tax Use Case")
    begin
        CopyUseCase(Rec.ID);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Use Case Card", 'OnAfterActionEvent', 'ArchivedLogs', false, false)]
    local procedure OnAfterActionArchivedLogsFromUseCaseCard(var Rec: Record "Tax Use Case")
    var
        UseCaseArchivalLogEntry: Record "Use Case Archival Log Entry";
    begin
        UseCaseArchivalLogEntry.SetRange("Case ID", Rec.ID);
        Page.run(Page::"Use Case Archival Log Entries", UseCaseArchivalLogEntry);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Use Cases", 'OnAfterActionEvent', 'ArchivedLogs', false, false)]
    local procedure OnAfterActionArchivedLogsFromUseCaseList(var Rec: Record "Tax Use Case")
    var
        UseCaseArchivalLogEntry: Record "Use Case Archival Log Entry";
    begin
        UseCaseArchivalLogEntry.SetRange("Case ID", Rec.ID);
        Page.run(Page::"Use Case Archival Log Entries", UseCaseArchivalLogEntry);
    end;

    var
        ChangedByMicrosoft: Boolean;
        ChangedByPartnerLbl: Label 'Partner';
        ExportUseCaseQst: Label 'Do you want to Export Use Cases as well?';
        UseCaseStatusTxt: Label 'Use Case Status change.', Locked = true;
        VersionLbl: Label '%1.%2', Comment = '%1 - Major Version, %2 - Minor Version';
}