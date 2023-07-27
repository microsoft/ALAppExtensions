// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9988 "Word Template Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Word Template" = rim,
                  tabledata "Word Template Field" = rimd,
                  tabledata "Word Templates Table" = ri,
                  tabledata "Word Templates Related Table" = rimd,
                  tabledata AllObj = r,
                  tabledata Field = r;

    procedure DownloadTemplate()
    var
        Output: Text;
        InStream: InStream;
    begin
        if MergeFields.Count() = 0 then begin
            TemplateTempBlob.CreateInStream(InStream, TextEncoding::UTF8);
            Output := GetTemplateName('docx');
            DownloadFromStream(InStream, DownloadDialogTitleLbl, '', '', Output);
            Session.LogMessage('0000ED4', StrSubstNo(DownloadedTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
            exit;
        end;

        PrepareZipFile();
        ZipFileTempBlob.CreateInStream(InStream, TextEncoding::UTF8);

        Output := GetTemplateName('zip');
        DownloadFromStream(InStream, DownloadDialogTitleLbl, '', '', Output);

        Session.LogMessage('0000ECN', StrSubstNo(DownloadedTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    procedure DownloadTemplate(WordTemplateRec: Record "Word Template")
    begin
        Load(WordTemplateRec.Code);
        DownloadTemplate();
    end;

    local procedure PrepareZipFile()
    var
        DataCompression: Codeunit "Data Compression";
        OutStream: OutStream;
        InStream: InStream;
    begin
        Clear(ZipFileTempBlob);

        DataCompression.CreateZipArchive();
        TemplateTempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        if not TrySetDataSource(InStream) then begin
            Session.LogMessage('0000K03', DataSourceNotSetTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
            InStream.Position := 1; // Make sure we are ready to read from the InStream regardless of where we ended up.
        end;
        DataCompression.AddEntry(InStream, GetTemplateName('docx'));
        GenerateSpreadsheetDataSource(DataCompression); // Add data source spreadsheet to zip

        ZipFileTempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        DataCompression.SaveZipArchive(OutStream);
    end;

    /// <summary>
    /// Generates the data source excel spreadsheet with DataSource as sheetname.
    /// </summary>
    /// <param name="DataCompression">Zip to add the worksheet to.</param>
    local procedure GenerateSpreadsheetDataSource(var DataCompression: Codeunit "Data Compression")
    var
        TempBlob: Codeunit "Temp Blob";
        Decorator: DotNet CellDecorator;
        XlWrkBkWriter: DotNet WorkbookWriter;
        XlWrkShtWriter: DotNet WorksheetWriter;
        ColNo: Integer;
        MailMergeField: Text;
        InStream: InStream;
        OutStream: OutStream;
    begin
        if MergeFields.Count() = 0 then
            exit;

        TempBlob.CreateOutStream(OutStream);
        XlWrkBkWriter := XlWrkBkWriter.Create(OutStream);
        XlWrkShtWriter := XlWrkBkWriter.FirstWorksheet();
        XlWrkShtWriter.Name := DataSourceSheetNameTxt;

        Decorator := XlWrkShtWriter.DefaultCellDecorator();

        foreach MailMergeField in MergeFields do begin
            ColNo += 1;
            XlWrkShtWriter.SetCellValueText(1, ConvertColNoToColName(ColNo), MailMergeField, Decorator);
        end;
        XlWrkBkWriter.Close();

        TempBlob.CreateInStream(InStream);
        DataCompression.AddEntry(InStream, DataSourceFileTxt);
    end;

    /// <summary>
    /// Used for getting the proper Column name corresponding to a column number.
    /// Excel columns goes from A..Z AB..AZ etc and not 1..999~
    /// </summary>
    /// <param name="ColumnNo">The column number.</param>
    /// <returns>Column name</returns>
    internal procedure ConvertColNoToColName(ColumnNo: Integer) ColumnName: Text[10]
    var
        RemainingColNo: Integer;
        CurrentCharInt: Integer;
        CurrentChar: Char;
    begin
        RemainingColNo := ColumnNo;
        while RemainingColNo > 0 do begin
            CurrentCharInt := (RemainingColNo - 1) mod 26;
            CurrentChar := 65 + CurrentCharInt;
            ColumnName := CurrentChar + ColumnName;
            RemainingColNo := (RemainingColNo - CurrentCharInt) div 26;
        end;
    end;

    procedure DownloadDocument()
    var
        FileText: Text;
        InStream: InStream;
    begin
        ResultTempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        if MultipleDocuments then
            FileText := 'Output.zip'
        else
            FileText := GetFileName('Output', ChosenFormat);
        DownloadFromStream(InStream, DownloadResultFileDialogTitleLbl, '', '', FileText);
    end;

    internal procedure Upload(var TemplateRecToUpdate: Record "Word Template"; var UploadedFileName: Text): Boolean
    var
        FileContentInStream: InStream;
    begin
        if not UploadIntoStream(UploadDialogTitleLbl, '', '', UploadedFileName, FileContentInStream) then
            exit(false);

        SaveTemplate(FileContentInStream, TemplateRecToUpdate);

        Session.LogMessage('0000ECO', StrSubstNo(UploadedTemplateTxt, TemplateRecToUpdate.SystemId, TemplateRecToUpdate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);

        exit(true);
    end;

    internal procedure Upload(var TemplateRecToUpdate: Record "Word Template")
    var
        TempWordTemplate: Record "Word Template" temporary;
        NewTemplateInStream: InStream;
        DummyFileName: Text;
    begin
        if not Upload(TempWordTemplate, DummyFileName) then
            exit;

        if not Confirm(OverrideTemplateQst, true) then
            exit;

        GetTemplate(NewTemplateInStream);
        Clear(TemplateRecToUpdate.Template);
        TemplateRecToUpdate.Template.ImportStream(NewTemplateInStream, 'Template');

        TemplateRecToUpdate.Modify();
    end;

    local procedure SaveTemplate(TemplateToSave: InStream; var TemplateRecToUpdate: Record "Word Template")
    begin
        Load(TemplateToSave);
        if not TrySetDataSource(TemplateToSave) then begin
            Session.LogMessage('0000K04', DataSourceNotSetTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
            TemplateToSave.Position := 1; // Make sure we are ready to read from the InStream regardless of where we ended up.
        end;

        if not VerifyMailMergeFieldNameLengths() then
            Error(TableNotAllowedMergeFieldsTruncatedErr);

        TemplateRecToUpdate.Template.ImportStream(TemplateToSave, DefaultTemplateLbl);

        if TemplateRecToUpdate.Name = '' then
            if TemplateRecToUpdate."Table ID" <> 0 then
                TemplateRecToUpdate.Name := CopyStr(StrSubstNo(DefaultTemplateNameWithCaptionLbl, TemplateRecToUpdate."Table Caption"), 1, MaxStrLen(TemplateRecToUpdate.Name))
            else
                TemplateRecToUpdate.Name := DefaultTemplateNameLbl;
    end;

    procedure GetTemplate(var TemplateInStream: InStream)
    begin
        TemplateTempBlob.CreateInStream(TemplateInStream, TextEncoding::UTF8);
    end;

    procedure GetDocument(var DocumentInStream: InStream)
    begin
        ResultTempBlob.CreateInStream(DocumentInStream, TextEncoding::UTF8);
    end;

    procedure GetDocumentSize(): Integer
    begin
        exit(ResultTempBlob.Length());
    end;

    procedure Create()
    var
        TempWordTemplateFields: Record "Word Template Field" temporary;
        TableId: Integer;
    begin
        TableId := SelectTable();
        Create(TableId, TempWordTemplateFields);
    end;

    procedure Create(TableId: Integer; var TempWordTemplateFields: Record "Word Template Field" temporary)
    var
        MailMergeFields: List of [Text];
    begin
        WordTemplate."Table ID" := TableId;
        GetMergeFieldsForRecord(TableId, MailMergeFields, TempWordTemplateFields);
        GetUnrelatedCustomMergeFields(MailMergeFields, TempWordTemplateFields);
        Create(MailMergeFields);
    end;

    procedure Create(TableId: Integer; RelatedTableIds: List of [Integer]; RelatedTableCodes: List of [Code[5]]; var TempWordTemplateFields: Record "Word Template Field" temporary)
    var
        MailMergeFields: List of [Text];
        Index: Integer;
    begin
        if RelatedTableIds.Count() <> RelatedTableCodes.Count() then
            Error(RelatedTableIdsLengthErr, RelatedTableIds.Count, RelatedTableCodes.Count);

        WordTemplate."Table ID" := TableId;
        GetMergeFieldsForRecord(TableId, MailMergeFields, TempWordTemplateFields);

        for Index := 1 to RelatedTableIds.Count do
            GetMergeFieldsForRecord(RelatedTableIds.Get(Index), MailMergeFields, RelatedTableCodes.Get(Index), TempWordTemplateFields);
        GetUnrelatedCustomMergeFields(MailMergeFields, TempWordTemplateFields);

        Create(MailMergeFields);
    end;

    procedure Create(MailMergeFields: List of [Text])
    var
        OutStream: OutStream;
    begin
        if MailMergeFields.Count() = 0 then
            Error(NoMergeFieldsWereSpecifiedErr);

        MergeFields := MailMergeFields;

        TemplateTempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        MailMerge := MailMerge.MailMerge();
        MailMerge.CreateDocument(DataSourceFileTxt, OutStream);
    end;

    procedure Load(WordTemplateCode: Code[30])
    var
        TempBlob: Codeunit "Temp Blob";
        TemplateOutStream: OutStream;
        TemplateInStream: InStream;
    begin
        if not WordTemplate.Get(WordTemplateCode) then
            Error(NotAValidTemplateCodeErr);

        TempBlob.CreateOutStream(TemplateOutStream, TextEncoding::UTF8);
        WordTemplate.Template.ExportStream(TemplateOutStream);
        TempBlob.CreateInStream(TemplateInStream, TextEncoding::UTF8);

        LoadDocument(TemplateInStream);
        GetMergeFieldsForRecordAndRelated(WordTemplate, MergeFields);
    end;

    procedure Load(TemplateInStream: InStream)
    begin
        LoadDocument(TemplateInStream);
        GetMergeFieldsForDocument();
    end;

    procedure Load(TemplateInStream: InStream; WordTemplateCode: Code[30])
    begin
        if not WordTemplate.Get(WordTemplateCode) then
            Error(NotAValidTemplateCodeErr);

        LoadDocument(TemplateInStream);
        GetMergeFieldsForRecordAndRelated(WordTemplate, MergeFields);
    end;

    local procedure LoadDocument(TemplateInStream: InStream)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
        OutStream: OutStream;
        Success: Boolean;
    begin
        Clear(MergeFields);

        TemplateTempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        CopyStream(OutStream, TemplateInStream);
        TemplateTempBlob.CreateInStream(TemplateInStream, TextEncoding::UTF8);

        Success := TryMailMergeLoadDocument(TemplateInStream);
        CustomDimensions.Add('TemplateSystemID', WordTemplate.SystemId);
        CustomDimensions.Add('TemplateTableID', Format(WordTemplate."Table ID"));

        if Success then
            FeatureTelemetry.LogUptake('0000ECP', 'Word templates', Enum::"Feature Uptake Status"::"Set up", CustomDimensions)
        else begin
            FeatureTelemetry.LogError('0000ECQ', 'Word templates', 'Loading template', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
            Session.LogMessage('0000ECR', StrSubstNo(FailedToLoadTemplateAllTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', WordTemplatesCategoryTxt);
            Error(FailedToLoadTemplateErr);
        end;
    end;

    [TryFunction]
    local procedure TrySetDataSource(var WordDocumentInStream: InStream)
    var
        SettingsXmlFileContent: Text;
    begin
        // When a word document is saved, the path to the data source is stored as an absolute path.
        // This means if you open the document again, it will refer to the data source in the old location.
        // To avoid this, we replace the path to the data source with a relative path.

        // First extract the settings.xml file from the document which contains the reference to the data source
        SettingsXmlFileContent := GetFileFromZip(SettingsXmlRelsFilePathTxt, WordDocumentInStream);
        if SettingsXmlFileContent = '' then begin
            Session.LogMessage('0000K05', SettingsXmlFileContentDoesNotExistTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', WordTemplatesCategoryTxt);
            exit;
        end;

        // Next update the data source path to be relative
        SetWordDocumentDataSource(SettingsXmlFileContent);

        // Finally replace the settings.xml file in the document and update the document stream
        ReplaceFileInZip(SettingsXmlRelsFilePathTxt, SettingsXmlFileContent, WordDocumentInStream);
    end;

    local procedure GetFileFromZip(FileName: Text; ZipFile: InStream) FileContent: Text
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        Entries: List of [Text];
    begin
        ZipFile.Position := 1;
        DataCompression.OpenZipArchive(ZipFile, false);
        DataCompression.GetEntryList(Entries);
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        DataCompression.ExtractEntry(FileName, OutStream);

        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(FileContent);
    end;

    local procedure SetWordDocumentDataSource(var SettingsXmlFileContent: Text)
    var
        XmlDocument: DotNet XmlDocument;
        TargetXmlNodeList: DotNet XmlNodeList;
        XmlAttribute: DotNet XmlAttribute;
        XmlNamespaceManager: DotNet XmlNamespaceManager;
    begin
        XmlDocument := XmlDocument.XmlDocument();
        XmlDocument.LoadXml(SettingsXmlFileContent);
        XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDocument.NameTable());
        XmlNamespaceManager.AddNamespace('rel', 'http://schemas.openxmlformats.org/package/2006/relationships');
        TargetXmlNodeList := XmlDocument.SelectNodes('//rel:Relationship/@Target', XmlNamespaceManager);
        foreach XmlAttribute in TargetXmlNodeList do
            if XmlAttribute.Value.Contains(DataSourceFileTxt) then
                XmlAttribute.Value := DataSourceFileTxt; // Make sure the data source path is updated to be relative
        SettingsXmlFileContent := XmlDocument.OuterXml;
    end;

    local procedure ReplaceFileInZip(FileName: Text; FileContent: Text; var ZipFile: InStream)
    var
        DataCompression: Codeunit "Data Compression";
        FileContentTempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        ZipFile.Position := 1;
        DataCompression.OpenZipArchive(ZipFile, true);

        // Replace the file
        FileContentTempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(FileContent);
        FileContentTempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        DataCompression.RemoveEntry(FileName);
        DataCompression.AddEntry(InStream, FileName);

        // Update the ZipFile stream to reflect the new zip file
        DataCompression.SaveZipArchive(TemplateTempBlob);
        TemplateTempBlob.CreateInStream(ZipFile, TextEncoding::UTF8);
    end;

    [TryFunction]
    local procedure TryMailMergeLoadDocument(var TemplateInStream: InStream)
    begin
        MailMerge := MailMerge.MailMerge();
        MailMerge.LoadDocument(DataSourceFileTxt, TemplateInStream);
    end;

    procedure Merge(Data: Dictionary of [Text, Text]; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
    begin
        Merge(Data, SplitDocument, SaveFormat, false, Enum::"Doc. Sharing Conflict Behavior"::Ask);
    end;

    procedure Merge(Data: Dictionary of [Text, Text]; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean; DocSharingConflictBehavior: Enum "Doc. Sharing Conflict Behavior")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
        Output: OutStream;
        Success: Boolean;
    begin
        Clear(ResultTempBlob);
        MultipleDocuments := SplitDocument;
        ResultTempBlob.CreateOutStream(Output, TextEncoding::UTF8);
        ChosenFormat := SaveFormat;

        Success := TryMailMergeExecute(Data, SaveFormat, Output);

        if Success and EditDoc then
            EditDocumentAfterMerge(DocSharingConflictBehavior);

        CustomDimensions.Add('TemplateSystemID', WordTemplate.SystemId);
        CustomDimensions.Add('TemplateTableID', Format(WordTemplate."Table ID"));
        FeatureTelemetry.LogUptake('0000FW3', 'Word templates', Enum::"Feature Uptake Status"::Used, CustomDimensions);

        if Success then
            FeatureTelemetry.LogUsage('0000ECS', 'Word templates', 'Template applied', CustomDimensions)
        else begin
            FeatureTelemetry.LogError('0000ECT', 'Word templates', 'Applying template', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
            Session.LogMessage('0000ECU', StrSubstNo(FailedToApplyTemplateAllTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', WordTemplatesCategoryTxt);
            Error(GetLastErrorText());
        end;
    end;

    procedure Merge(SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
    var
        MailMergeFilterPageBuilder: FilterPageBuilder;
        RecordRef: RecordRef;
        FilterView: Text;
    begin
        MultipleDocuments := SplitDocument;
        RecordRef.Open(WordTemplate."Table ID");

        if Confirm(SpecifyFiltersQst) then begin
            MailMergeFilterPageBuilder.AddTable(RecordRef.Caption(), RecordRef.Number());
            MailMergeFilterPageBuilder.PageCaption(StrSubstNo(FilterPageBuilderCaptionLbl, RecordRef.Caption()));
            MailMergeFilterPageBuilder.RunModal();

            FilterView := MailMergeFilterPageBuilder.GetView(RecordRef.Caption(), false);
            RecordRef.SetView(FilterView);
        end;

        Merge(RecordRef, SplitDocument, SaveFormat, false, Enum::"Doc. Sharing Conflict Behavior"::Ask);
        RecordRef.Close();
    end;

    procedure Merge(RecordVariant: Variant; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean)
    begin
        Merge(RecordVariant, SplitDocument, SaveFormat, EditDoc, Enum::"Doc. Sharing Conflict Behavior"::Ask);
    end;

    procedure Merge(RecordVariant: Variant; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean; ConflictBehavior: Enum "Doc. Sharing Conflict Behavior")
    begin
        if not RecordVariant.IsRecord() and not RecordVariant.IsRecordRef() then
            Error(NotARecordErr);
        MultipleDocuments := SplitDocument;
        if SplitDocument then
            MergeSplitDocument(RecordVariant, SaveFormat, EditDoc, ConflictBehavior)
        else
            MergeOneDocument(RecordVariant, SaveFormat, EditDoc, ConflictBehavior);
    end;

    // Merges each record separately into individual documents and puts them into a zip.
    local procedure MergeSplitDocument(RecordVariant: Variant; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean; ConflictBehavior: Enum "Doc. Sharing Conflict Behavior")
    var
        TempWordTemplateCustomField: Record "Word Template Custom Field" temporary;
        DataCompression: Codeunit "Data Compression";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        PrimaryKey: KeyRef;
        InStream: InStream;
        OutStream: OutStream;
        EntryName: Text;
        Index: Integer;
        DataTable: DotNet DataTable;
    begin
        RecordRef.GetTable(RecordVariant);
        DataCompression.CreateZipArchive();

        if RecordRef.FindSet() then
            repeat
                CreateDataTable(DataTable);
                GetCustomTableColumns(RecordRef.Number, TempWordTemplateCustomField);
                FillDataTable(RecordRef, true, DataTable, TempWordTemplateCustomField); // Adding columns
                FillDataTable(RecordRef, false, DataTable, TempWordTemplateCustomField); // Adding rows
                ExecuteMerge(DataTable, true, SaveFormat, EditDoc, ConflictBehavior);
                GetDocument(InStream);
                EntryName := RecordRef.Name();
                PrimaryKey := RecordRef.KeyIndex(1);
                for Index := 1 to PrimaryKey.FieldCount() do begin
                    FieldRef := PrimaryKey.FieldIndex(Index);
                    EntryName := EntryName + '_' + Format(FieldRef.Value);
                end;
                DataCompression.AddEntry(InStream, GetFileName(EntryName, SaveFormat));
                ReloadWordTemplate();
            until RecordRef.Next() = 0;

        Clear(ResultTempBlob);
        ResultTempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        DataCompression.SaveZipArchive(OutStream);
    end;

    local procedure MergeOneDocument(RecordVariant: Variant; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean; ConflictBehavior: Enum "Doc. Sharing Conflict Behavior")
    var
        TempWordTemplateCustomField: Record "Word Template Custom Field" temporary;
        RecordRef: RecordRef;
        DataTable: DotNet DataTable;
    begin
        RecordRef.GetTable(RecordVariant);

        CreateDataTable(DataTable);
        GetCustomTableColumns(RecordRef.Number, TempWordTemplateCustomField);
        FillDataTable(RecordRef, true, DataTable, TempWordTemplateCustomField); // Adding columns
        if RecordRef.FindSet() then
            repeat
                FillDataTable(RecordRef, false, DataTable, TempWordTemplateCustomField); // Adding rows
            until RecordRef.Next() = 0;

        ExecuteMerge(DataTable, false, SaveFormat, EditDoc, ConflictBehavior);
    end;

    local procedure ExecuteMerge(var Data: DotNet DataTable; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean; ConflictBehavior: Enum "Doc. Sharing Conflict Behavior")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
        Output: OutStream;
        Success: Boolean;
    begin
        Clear(ResultTempBlob);
        MultipleDocuments := SplitDocument;
        ResultTempBlob.CreateOutStream(Output, TextEncoding::UTF8);
        ChosenFormat := SaveFormat;

        Success := TryMailMergeExecute(Data, SaveFormat, Output);

        if Success and EditDoc then
            EditDocumentAfterMerge(ConflictBehavior);

        CustomDimensions.Add('TemplateSystemID', WordTemplate.SystemId);
        CustomDimensions.Add('TemplateTableID', Format(WordTemplate."Table ID"));
        FeatureTelemetry.LogUptake('0000FW4', 'Word templates', Enum::"Feature Uptake Status"::Used, CustomDimensions);

        if Success then
            FeatureTelemetry.LogUsage('0000ECV', 'Word templates', 'Template applied', CustomDimensions)
        else begin
            FeatureTelemetry.LogError('0000ECW', 'Word templates', 'Applying template', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
            Session.LogMessage('0000ECX', StrSubstNo(FailedToApplyTemplateAllTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', WordTemplatesCategoryTxt);
            Error(GetLastErrorText());
        end;
    end;

    [TryFunction]
    local procedure TryMailMergeExecute(var Data: DotNet DataTable; SaveFormat: Enum "Word Templates Save Format"; var Output: OutStream)
    begin
        MailMerge.Execute(Data, SaveFormat.AsInteger(), Output);
    end;

    [TryFunction]
    local procedure TryMailMergeExecute(var DataDictionary: Dictionary of [Text, Text]; SaveFormat: Enum "Word Templates Save Format"; var Output: OutStream)
    var
        GenericDictionary: DotNet GenericDictionary2;
        MergeField: Text;
    begin
        GenericDictionary := GenericDictionary.Dictionary();
        foreach MergeField in DataDictionary.Keys do
            GenericDictionary.Add(MergeField, DataDictionary.Get(MergeField));

        MailMerge.Execute(GenericDictionary, SaveFormat.AsInteger(), Output);
    end;

    local procedure EditDocumentAfterMerge(DocShareConflictBehavior: Enum "Doc. Sharing Conflict Behavior"): Boolean
    var
        TempDocumentSharing: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if not DocumentSharing.ShareEnabled(Enum::"Document Sharing Source"::System) then
            exit;
        TempDocumentSharing.Name := TempDocLbl;
        TempDocumentSharing.Extension := CopyStr('.docx', 1, MaxStrLen(TempDocumentSharing.Extension));
        TempDocumentSharing.Source := Enum::"Document Sharing Source"::System;
        TempDocumentSharing."Document Sharing Intent" := Enum::"Document Sharing Intent"::Edit;
        TempDocumentSharing."Conflict Behavior" := DocShareConflictBehavior;

        ResultTempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        TempDocumentSharing.Data.CreateOutStream(OutStream, TextEncoding::UTF8);
        CopyStream(OutStream, InStream);
        TempDocumentSharing.Insert();

        DocumentSharing.Share(TempDocumentSharing);
        ResultTempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        TempDocumentSharing.Data.CreateInStream(InStream, TextEncoding::UTF8);
        CopyStream(OutStream, InStream);
    end;

    local procedure GetFileName(Name: Text; SaveFormat: Enum "Word Templates Save Format"): Text
    begin
        case SaveFormat of
            SaveFormat::Doc:
                exit(StrSubstNo(FilenamePatternTxt, Name, 'doc'));
            SaveFormat::Docx:
                exit(StrSubstNo(FilenamePatternTxt, Name, 'docx'));
            SaveFormat::Html:
                exit(StrSubstNo(FilenamePatternTxt, Name, 'html'));
            SaveFormat::PDF:
                exit(StrSubstNo(FilenamePatternTxt, Name, 'pdf'));
            SaveFormat::Text:
                exit(StrSubstNo(FilenamePatternTxt, Name, 'txt'));
            else
                Error(NotAValidSaveFormatErr);
        end;
    end;

    procedure SetFiltersOnRecord(var RecordRef: RecordRef)
    var
        MailMergeFilterPageBuilder: FilterPageBuilder;
        FilterView: Text;
    begin
        MailMergeFilterPageBuilder.AddTable(RecordRef.Caption(), RecordRef.Number());
        MailMergeFilterPageBuilder.SetView(RecordRef.Caption(), RecordRef.GetView());
        MailMergeFilterPageBuilder.PageCaption(StrSubstNo(FilterPageBuilderCaptionLbl, RecordRef.Caption()));
        MailMergeFilterPageBuilder.RunModal();

        FilterView := MailMergeFilterPageBuilder.GetView(RecordRef.Caption(), false);
        RecordRef.SetView(FilterView);
    end;

    procedure AddTable(TableId: Integer)
    var
        AllowedWordTemplatesTable: Record "Word Templates Table";
        TableMetadata: Record "Table Metadata";
    begin
        if not TableMetadata.Get(TableId) then
            exit;
        AllowedWordTemplatesTable."Table ID" := TableId;
        if AllowedWordTemplatesTable.Insert() then;
    end;

    procedure AllowedTableExist(TableId: Integer): Boolean
    var
        AllowedWordTemplatesTable: Record "Word Templates Table";
    begin
        exit(AllowedWordTemplatesTable.Get(TableId));
    end;

    internal procedure GetTableId(): Integer
    begin
        exit(WordTemplate."Table ID");
    end;

    internal procedure AddTable(): Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Objects: Page Objects;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);

        Objects.SetTableView(AllObjWithCaption);
        Objects.Caption(AddNewEntityCaptionLbl);
        Objects.LookupMode(true);

        if Objects.RunModal() = Action::LookupOK then begin
            Objects.GetRecord(AllObjWithCaption);
            AddTable(AllObjWithCaption."Object ID");
            exit(AllObjWithCaption."Object ID");
        end;

        exit(0);
    end;

    internal procedure GetTable(Caption: Text; var AllObjWithCaption: Record AllObjWithCaption; FilterExpression: Text): Boolean
    var
        Objects: Page Objects;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);

        if FilterExpression <> '' then
            AllObjWithCaption.SetFilter("Object ID", FilterExpression);

        Objects.SetTableView(AllObjWithCaption);
        Objects.Caption(Caption);
        Objects.LookupMode(true);

        if Objects.RunModal() = Action::LookupOK then begin
            Objects.GetRecord(AllObjWithCaption);
            exit(true);
        end;

        exit(false);
    end;

    internal procedure RunModalWordTemplatesRelated(TableId: Integer; RelatedCode: Code[30]; var WordTemplatesRelatedTable: Record "Word Templates Related Table"; FilterExpression: Text; EditOnly: Boolean; var TempWordTemplateField: Record "Word Template Field" temporary): Boolean
    var
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
        WordTemplatesRelatedCard: Page "Word Templates Related Card";
    begin
        WordTemplatesRelatedCard.SetEditOnly(EditOnly);
        WordTemplatesRelatedCard.SetRelatedTable(WordTemplatesRelatedTable);
        WordTemplatesRelatedCard.SetTableNo(TableId);
        WordTemplatesRelatedCard.SetFilterExpression(FilterExpression);
        WordTemplatesRelatedCard.LookupMode(true);

        if WordTemplatesRelatedCard.RunModal() = Action::LookupOK then begin
            WordTemplatesRelatedCard.GetRelatedTable(WordTemplatesRelatedTable);
            WordTemplatesRelatedTable.Code := RelatedCode;
            WordTemplateFieldSelection.SelectDefaultFieldsForTable('', WordTemplatesRelatedTable."Related Table ID", TempWordTemplateField);
            exit(true);
        end;

        exit(false);
    end;

    internal procedure GetField(Caption: Text; TableId: Integer; FilterExpression: Text): Integer
    var
        Field: Record Field;
        FieldsLookup: Page "Fields Lookup";
    begin
        Field.SetRange(TableNo, TableId);

        if FilterExpression <> '' then
            Field.SetFilter("No.", FilterExpression)
        else
            Field.SetFilter(Type,
                            '%1|%2|%3|%4|%5',
                            Field.Type::BigInteger,
                            Field.Type::Integer,
                            Field.Type::Code,
                            Field.Type::GUID,
                            Field.Type::RecordID);

        FieldsLookup.SetTableView(Field);
        FieldsLookup.Caption(Caption);
        FieldsLookup.LookupMode(true);

        if FieldsLookup.RunModal() = Action::LookupOK then begin
            FieldsLookup.GetRecord(Field);
            exit(Field."No.");
        end;

        exit(0);
    end;

    internal procedure GetTemplateName(FileExtension: Text): Text
    var
        Regex: Codeunit Regex;
        TemplateName: Text;
    begin
        if not (WordTemplate.Code = '') then
            TemplateName := WordTemplate.Code
        else begin
            WordTemplate.CalcFields("Table Caption");

            if WordTemplate."Table Caption" = '' then
                exit(StrSubstNo(EmptyTemplateNamePatternTxt, DefaultTemplateLbl, FileExtension));

            TemplateName := WordTemplate."Table Caption";
        end;

        TemplateName := Regex.Replace(TemplateName, ReservedCharsTok, '_'); // Replace reserved characters with _

        exit(StrSubstNo(TemplateNamePatternTxt, TemplateName, DefaultTemplateLbl, FileExtension))
    end;

    procedure SelectTable(): Integer
    var
        AllowedTables: Record "Word Templates Table";
        TableLookup: Page "Word Templates Table Lookup";
    begin
        TableLookup.LookupMode(true);
        if TableLookup.RunModal() = Action::LookupOK then begin
            TableLookup.GetRecord(AllowedTables);
            exit(AllowedTables."Table ID");
        end;
    end;

    internal procedure RefreshTreeView(SourceTableId: Integer; var WordTemplatesRelatedBuffer: Record "Word Templates Related Buffer")
    var
        TempWordTemplatesRelatedBuffer: Record "Word Templates Related Buffer" temporary;
        NullGuid: Guid;
        Position: Integer;
    begin
        // Update source record
        if not WordTemplatesRelatedBuffer.Get('', SourceTableId) then begin
            WordTemplatesRelatedBuffer.Init();
            WordTemplatesRelatedBuffer."Related Table ID" := SourceTableId;
            WordTemplatesRelatedBuffer."Table ID" := 0;
            WordTemplatesRelatedBuffer.Position := 0;
            WordTemplatesRelatedBuffer.Depth := 0;
            WordTemplatesRelatedBuffer.Insert();
        end;

        // Update related records
        Position := 1;
        RefreshTreeViewRecursively(WordTemplatesRelatedBuffer, Position, 1, SourceTableId);

        // Update unrelated records
        WordTemplatesRelatedBuffer.Reset();
        WordTemplatesRelatedBuffer.SetFilter("Source Record ID", '<>%1', NullGuid);
        if WordTemplatesRelatedBuffer.FindSet() then
            repeat
                WordTemplatesRelatedBuffer.Position := Position;
                WordTemplatesRelatedBuffer.Modify();
                Position += 1;
                TempWordTemplatesRelatedBuffer.Copy(WordTemplatesRelatedBuffer, true);
                TempWordTemplatesRelatedBuffer.Reset();
                RefreshTreeViewRecursively(TempWordTemplatesRelatedBuffer, Position, 1, WordTemplatesRelatedBuffer."Related Table ID");
            until WordTemplatesRelatedBuffer.Next() = 0;

        WordTemplatesRelatedBuffer.Reset();
    end;

    internal procedure RefreshTreeViewRecursively(var WordTemplatesRelatedBuffer: Record "Word Templates Related Buffer"; var Position: Integer; Depth: Integer; TableId: Integer)
    var
        TempWordTemplatesRelatedBuffer: Record "Word Templates Related Buffer" temporary;
    begin
        WordTemplatesRelatedBuffer.SetRange("Table ID", TableId);
        if WordTemplatesRelatedBuffer.FindSet() then
            repeat
                WordTemplatesRelatedBuffer.Depth := Depth;
                WordTemplatesRelatedBuffer.Position := Position;
                WordTemplatesRelatedBuffer.Modify();
                Position += 1;
                TempWordTemplatesRelatedBuffer.Copy(WordTemplatesRelatedBuffer, true);
                RefreshTreeViewRecursively(TempWordTemplatesRelatedBuffer, Position, Depth + 1, WordTemplatesRelatedBuffer."Related Table ID");
            until WordTemplatesRelatedBuffer.Next() = 0;
    end;

    internal procedure AddSelectedTable(var WordTemplatesRelatedBuffer: Record "Word Templates Related Buffer"; WordTemplateCode: Code[30]; var TempWordTemplateField: Record "Word Template Field" temporary): Boolean
    var
        RecordSelectionBuffer: Record "Record Selection Buffer";
        AllObjWithCaption: Record AllObjWithCaption;
        RecordSelection: Codeunit "Record Selection";
        RelatedCode: Code[5];
    begin
        if not GetTable(SelectEntityLbl, AllObjWithCaption, '') then
            exit(false);

        VerifyRelatedTableIdIsUnused(WordTemplatesRelatedBuffer.Code, AllObjWithCaption."Object ID", WordTemplatesRelatedBuffer);

        if not RecordSelection.Open(AllObjWithCaption."Object ID", GetMaximumNumberOfRecords(), RecordSelectionBuffer) then
            exit(false);

        RelatedCode := GenerateCode(AllObjWithCaption."Object Caption", GetExistingCodes(WordTemplatesRelatedBuffer));
        exit(AddTable(WordTemplatesRelatedBuffer, WordTemplateCode, AllObjWithCaption."Object ID", RecordSelectionBuffer."Record System Id", RelatedCode, TempWordTemplateField));
    end;

    internal procedure AddTable(var WordTemplatesRelatedBuffer: Record "Word Templates Related Buffer"; WordTemplateCode: Code[30]; SourceTableId: Integer; RecordSystemId: Guid; RelatedCode: Code[5]; var TempWordTemplateField: Record "Word Template Field" temporary): Boolean;
    var
        AllObjWithCaption: Record AllObjWithCaption;
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", SourceTableId);
        if AllObjWithCaption.IsEmpty() then
            Error(TableIdDoesNotExistErr);

        VerifyRelatedTableCodeIsUnique(WordTemplateCode, RelatedCode, SourceTableId, WordTemplatesRelatedBuffer);

        WordTemplatesRelatedBuffer.Init();
        WordTemplatesRelatedBuffer."Source Record ID" := RecordSystemId;
        WordTemplatesRelatedBuffer."Related Table ID" := SourceTableId;
        WordTemplatesRelatedBuffer."Related Table Code" := RelatedCode;
        WordTemplatesRelatedBuffer.Insert();
        WordTemplateFieldSelection.SelectDefaultFieldsForTable('', WordTemplatesRelatedBuffer."Related Table ID", TempWordTemplateField);
        exit(true);
    end;

    internal procedure EditRelatedTable(var WordTemplatesRelatedBuffer: Record "Word Templates Related Buffer"; var TempWordTemplateField: Record "Word Template Field" temporary): Boolean
    var
        TempWordTemplatesRelatedTableRec: Record "Word Templates Related Table" temporary;
        FilterExpression: Text;
    begin
        FilterExpression := GetRelatedTablesFilterExpression(WordTemplatesRelatedBuffer."Table ID");
        TempWordTemplatesRelatedTableRec.TransferFields(WordTemplatesRelatedBuffer);

        if RunModalWordTemplatesRelated(TempWordTemplatesRelatedTableRec."Table ID", '', TempWordTemplatesRelatedTableRec, FilterExpression, true, TempWordTemplateField) then begin

            WordTemplatesRelatedBuffer."Field No." := TempWordTemplatesRelatedTableRec."Field No.";
            WordTemplatesRelatedBuffer.Modify();
        end else
            exit(false);

        exit(true);
    end;

    procedure IsRelatedTableCodeAndIdUnique(WordTemplateCode: Code[30]; TableCode: Code[5]; TableId: Integer): Boolean
    var
        WordTemplatesRelatedTable: Record "Word Templates Related Table";
    begin
        WordTemplatesRelatedTable.SetRange(Code, WordTemplateCode);
        WordTemplatesRelatedTable.SetRange("Related Table Code", TableCode);

        if not WordTemplatesRelatedTable.IsEmpty() then begin
            Message(RelatedTableCodeAlreadyUsedMsg);
            exit(false);
        end;

        WordTemplatesRelatedTable.Reset();
        WordTemplatesRelatedTable.SetRange(Code, WordTemplateCode);
        WordTemplatesRelatedTable.SetRange("Related Table ID", TableId);

        if not WordTemplatesRelatedTable.IsEmpty() then begin
            Message(RelatedTableIdAlreadyUsedMsg);
            exit(false);
        end;
        exit(true);
    end;

    procedure AddUnrelatedTable(WordTemplateCode: Code[30]; PrefixCode: Code[5]; UnrelatedTableId: Integer; RecordSystemId: Guid) Added: Boolean
    var
        WordTemplatesRelatedTable: Record "Word Templates Related Table";
        WordTemplateField: Record "Word Template Field";
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
    begin
        if not IsRelatedTableCodeAndIdUnique(WordTemplateCode, PrefixCode, UnrelatedTableId) then
            exit(false);

        WordTemplatesRelatedTable.Init();
        WordTemplatesRelatedTable."Source Record ID" := RecordSystemId;
        WordTemplatesRelatedTable."Related Table ID" := UnrelatedTableId;
        WordTemplatesRelatedTable."Related Table Code" := PrefixCode;
        Added := WordTemplatesRelatedTable.Insert();
        if Added then
            WordTemplateFieldSelection.SelectDefaultFieldsForTable('', WordTemplatesRelatedTable."Related Table ID", WordTemplateField);
    end;

    internal procedure AddRelatedTable(var WordTemplatesRelatedBuffer: Record "Word Templates Related Buffer"; SourceTableId: Integer; FilterRelatedTables: Boolean; var TempWordTemplateField: Record "Word Template Field" temporary): Boolean
    var
        TempWordTemplatesRelatedTableRec: Record "Word Templates Related Table" temporary;
        FilterExpression: Text;
        InsertFailed: Boolean;
    begin
        if FilterRelatedTables then
            FilterExpression := GetRelatedTablesFilterExpression(SourceTableId);

        repeat
            InsertFailed := false;
            if RunModalWordTemplatesRelated(SourceTableId, '', TempWordTemplatesRelatedTableRec, FilterExpression, false, TempWordTemplateField) then
                InsertFailed := not AddRelatedTableToBuffer(WordTemplatesRelatedBuffer, TempWordTemplatesRelatedTableRec)
            else
                exit(false);
        until not InsertFailed;

        exit(true);
    end;

    internal procedure AddRelatedTableToBuffer(var WordTemplatesRelatedBuffer: Record "Word Templates Related Buffer"; TempWordTemplatesRelatedTable: Record "Word Templates Related Table" temporary) Added: Boolean
    begin
        Added := TryAddRelatedTableToBuffer(WordTemplatesRelatedBuffer, TempWordTemplatesRelatedTable);

        if not Added then
            Message(GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryAddRelatedTableToBuffer(var WordTemplatesRelatedBuffer: Record "Word Templates Related Buffer"; TempWordTemplatesRelatedTable: Record "Word Templates Related Table" temporary)
    begin
        VerifyRelatedTableCodeIsUnique(TempWordTemplatesRelatedTable.Code, TempWordTemplatesRelatedTable."Related Table Code", TempWordTemplatesRelatedTable."Related Table ID", WordTemplatesRelatedBuffer);
        VerifyRelatedTableIdIsUnused(TempWordTemplatesRelatedTable.Code, TempWordTemplatesRelatedTable."Related Table ID", WordTemplatesRelatedBuffer);

        WordTemplatesRelatedBuffer.Init();
        WordTemplatesRelatedBuffer.TransferFields(TempWordTemplatesRelatedTable);
        WordTemplatesRelatedBuffer.Insert();
    end;

    internal procedure VerifyRelatedTableCodeIsUnique(WordTemplateCode: Code[30]; RelatedTableCode: Code[5]; RelatedTableId: Integer; var TempWordTemplatesRelatedBuffer: Record "Word Templates Related Buffer" temporary)
    var
        TempWordTemplatesRelatedBufferCopy: Record "Word Templates Related Buffer" temporary;
    begin
        TempWordTemplatesRelatedBufferCopy.Copy(TempWordTemplatesRelatedBuffer, true);
        TempWordTemplatesRelatedBufferCopy.SetRange(Code, WordTemplateCode);
        TempWordTemplatesRelatedBufferCopy.SetRange("Related Table Code", RelatedTableCode);
        TempWordTemplatesRelatedBufferCopy.SetFilter("Related Table ID", '<>%1', RelatedTableId);

        if not TempWordTemplatesRelatedBufferCopy.IsEmpty() then
            Error(RelatedTableCodeAlreadyUsedMsg);
    end;

    internal procedure VerifyRelatedTableIdIsUnused(WordTemplateCode: Code[30]; RelatedTableId: Integer; var TempWordTemplatesRelatedBuffer: Record "Word Templates Related Buffer" temporary)
    var
        TempWordTemplatesRelatedBufferCopy: Record "Word Templates Related Buffer" temporary;
    begin
        TempWordTemplatesRelatedBufferCopy.Copy(TempWordTemplatesRelatedBuffer, true);
        TempWordTemplatesRelatedBufferCopy.SetRange(Code, WordTemplateCode);
        TempWordTemplatesRelatedBufferCopy.SetRange("Related Table ID", RelatedTableId);

        if not TempWordTemplatesRelatedBufferCopy.IsEmpty() then
            Error(RelatedTableIdAlreadyUsedMsg);
    end;

    internal procedure AddRelatedTable(WordTemplateCode: Code[30]; RelatedCode: Code[5]; TableId: Integer; RelatedTableId: Integer; FieldNo: Integer): Boolean
    var
        DummyWordTemplatesRelatedTable: Record "Word Templates Related Table";
        TempWordTemplatesRelatedTable: Record "Word Templates Related Table" temporary;
    begin
        TempWordTemplatesRelatedTable.Code := WordTemplateCode;
        TempWordTemplatesRelatedTable."Related Table Code" := RelatedCode;
        TempWordTemplatesRelatedTable."Table ID" := TableId;
        TempWordTemplatesRelatedTable."Related Table ID" := RelatedTableId;
        TempWordTemplatesRelatedTable."Field No." := FieldNo;
        exit(AddRelatedTable(DummyWordTemplatesRelatedTable, TempWordTemplatesRelatedTable));
    end;

    /// <summary>
    /// Attempts to a add a related table. If the related table code or related table id already exists, the table is not added and a message is shown.
    /// </summary>
    /// <param name="WordTemplatesRelatedTable">The related table to insert the record into.</param>
    /// <param name="TempWordTemplatesRelatedTable">The temporary related table that holds the values used for inserting.</param>
    /// <returns>True if the related table was added, false otherwise.</returns>
    internal procedure AddRelatedTable(var WordTemplatesRelatedTable: Record "Word Templates Related Table"; TempWordTemplatesRelatedTable: Record "Word Templates Related Table" temporary) Added: Boolean
    begin
        if not IsRelatedTableCodeAndIdUnique(TempWordTemplatesRelatedTable.Code, TempWordTemplatesRelatedTable."Related Table Code", TempWordTemplatesRelatedTable."Related Table ID") then
            exit(false);

        WordTemplatesRelatedTable.Init();
        WordTemplatesRelatedTable.Copy(TempWordTemplatesRelatedTable);
        Added := WordTemplatesRelatedTable.Insert();
        WordTemplatesRelatedTable.SetRange(Code, WordTemplatesRelatedTable.Code);
    end;

    procedure GetChildren(WordTemplateCode: Code[30]; TableId: Integer) Children: List of [Integer]
    var
        WordTemplatesRelatedTable: Record "Word Templates Related Table";
    begin
        WordTemplatesRelatedTable.SetRange(Code, WordTemplateCode);
        WordTemplatesRelatedTable.SetRange("Table ID", TableId);
        if WordTemplatesRelatedTable.FindSet() then
            repeat
                Children.Add(WordTemplatesRelatedTable."Related Table ID");
            until WordTemplatesRelatedTable.Next() = 0;
    end;

    internal procedure RemoveTable(WordTemplateCode: Code[30]; TableId: Integer): Boolean
    var
        WordTemplatesRelatedTable: Record "Word Templates Related Table";
    begin
        WordTemplatesRelatedTable.SetRange(Code, WordTemplateCode);
        WordTemplatesRelatedTable.SetRange("Table ID", TableId);
        if not WordTemplatesRelatedTable.IsEmpty() then
            Error(CannotRemoveTableWithRelationsErr);

        WordTemplatesRelatedTable.Get(WordTemplateCode, TableId);
        exit(WordTemplatesRelatedTable.Delete());
    end;

    internal procedure UpdateRelatedEntity(WordTemplatesRelatedTable: Record "Word Templates Related Table"; TableId: Integer)
    var
        TempWordTemplatesRelatedTable: Record "Word Templates Related Table" temporary;
        WordTemplatesRelatedCard: Page "Word Templates Related Card";
    begin
        WordTemplatesRelatedCard.SetTableNo(TableId);
        WordTemplatesRelatedCard.SetRelatedTable(WordTemplatesRelatedTable);
        WordTemplatesRelatedCard.LookupMode(true);
        if WordTemplatesRelatedCard.RunModal() = Action::LookupOK then begin
            WordTemplatesRelatedCard.GetRelatedTable(TempWordTemplatesRelatedTable);

            // Rename record if Related Table ID changed, otherwise it'd have inserted a new one and kept the old
            if (WordTemplatesRelatedTable.Code <> '') and (WordTemplatesRelatedTable."Related Table ID" <> TempWordTemplatesRelatedTable."Related Table ID") then begin
                // The code should never change as it is linked to the Word Template
                WordTemplatesRelatedTable.Rename(WordTemplatesRelatedTable.Code, TempWordTemplatesRelatedTable."Related Table ID");
                WordTemplatesRelatedTable.CalcFields(WordTemplatesRelatedTable."Related Table Caption");
            end;

            WordTemplatesRelatedTable."Field No." := TempWordTemplatesRelatedTable."Field No.";
            WordTemplatesRelatedTable."Related Table Code" := TempWordTemplatesRelatedTable."Related Table Code";
            if not WordTemplatesRelatedTable.Insert() then
                WordTemplatesRelatedTable.Modify();
        end;
    end;

    local procedure ReloadWordTemplate()
    var
        InStream: InStream;
    begin
        TemplateTempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        MailMerge := MailMerge.MailMerge();
        MailMerge.LoadDocument(InStream);
    end;

    internal procedure InsertWordTemplate(var WordTemplateRec: Record "Word Template")
    begin
        WordTemplateRec.Insert();
    end;

    local procedure GetMergeFieldsForDocument()
    var
        MailMergeField: Text;
    begin
        foreach MailMergeField in MailMerge.GetMergeFields() do
            MergeFields.Add(MailMergeField);
    end;

    local procedure GetMergeFieldsForRecordAndRelated(WordTemplateRec: Record "Word Template"; var MailMergeFields: List of [Text])
    var
        WordTemplatesRelatedTable: Record "Word Templates Related Table";
        WordTemplateField: Record "Word Template Field";
    begin
        GetMergeFieldsForRecord(WordTemplateRec."Table ID", MailMergeFields, WordTemplateField);

        WordTemplatesRelatedTable.SetRange(Code, WordTemplateRec.Code);
        if WordTemplatesRelatedTable.FindSet() then
            repeat
                GetMergeFieldsForRecord(WordTemplatesRelatedTable."Related Table ID", MailMergeFields, WordTemplatesRelatedTable."Related Table Code", WordTemplateField);
            until WordTemplatesRelatedTable.Next() = 0;
        GetUnrelatedCustomMergeFields(MailMergeFields, WordTemplateField);
    end;

    local procedure GetMergeFieldsForRecord(TableId: Integer; var MailMergeFields: List of [Text]; var WordTemplateField: Record "Word Template Field")
    begin
        GetMergeFieldsForRecord(TableId, MailMergeFields, '', WordTemplateField);
    end;

    local procedure GetUnrelatedCustomMergeFields(var MailMergeFields: List of [Text]; var TempWordTemplateField: Record "Word Template Field" temporary)
    begin
        GetCustomMergeFields(0, OtherRecordRelatedTableTxt, MailMergeFields, TempWordTemplateField);
    end;

    local procedure GetMergeFieldsForRecord(TableId: Integer; var MailMergeFields: List of [Text]; RelatedTableCode: Code[5]; var WordTemplateField: Record "Word Template Field")
    var
        FieldRec: Record Field;
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
        MailMergeFieldsCount: Dictionary of [Text, Integer];
        Counter: Integer;
        AppendValue: Text;
        UseDefaultFields: Boolean;
        IncludeField: Boolean;
    begin
        UseDefaultFields := WordTemplateFieldSelection.TableUsesDefaultFields(WordTemplate.Code, TableId, WordTemplateField);

        // Use default fields
        FieldRec.SetRange(TableNo, TableId);
        if UseDefaultFields then begin
            FieldRec.SetFilter(Class, '<>%1', FieldRec.Class::FlowFilter);
            FieldRec.SetFilter(Type, '<>%1&<>%2&<>%3&<>%4&<>%5', FieldRec.Type::BLOB,
                                                                FieldRec.Type::Media,
                                                                FieldRec.Type::MediaSet,
                                                                FieldRec.Type::RecordID,
                                                                FieldRec.Type::TableFilter);
        end;
        if FieldRec.FindSet() then
            repeat
                IncludeField := true;
                if (not UseDefaultFields) and WordTemplateField.Get(WordTemplate.Code, TableId, FieldRec.FieldName) and WordTemplateField.Exclude then
                    IncludeField := false;

                if IncludeField then begin
                    AppendValue := GetAppendValue(FieldRec."Field Caption", Counter, MailMergeFieldsCount);
                    MailMergeFields.Add(GetFieldName(FieldRec."Field Caption", RelatedTableCode, AppendValue));
                end;
            until FieldRec.Next() = 0;

        GetCustomMergeFields(TableId, RelatedTableCode, MailMergeFields, WordTemplateField);
    end;

    local procedure GetCustomFieldName(FieldName: Text; RelatedTableCode: Code[5]): Text
    begin
        if RelatedTableCode = '' then
            exit(StrSubstNo(CustomMergeFieldTok, FieldName));
        exit(StrSubstNo(CustomMergeFieldWithRelatedTableTok, RelatedTableCode, FieldName));
    end;

    local procedure GetFieldName(FieldName: Text; RelatedTableCode: Code[5]; AppendValue: Text): Text
    begin
        if RelatedTableCode = '' then
            exit(StrSubstNo(MergeFieldTok, RelatedTableCode, FieldName, AppendValue));
        exit(StrSubstNo(MergeFieldTok, StrSubstNo(RelatedTablePatternTxt, RelatedTableCode), FieldName, AppendValue));
    end;

    internal procedure GetCustomMergeFields(TableId: Integer; RelatedTableCode: Code[5]; var MailMergeFields: List of [Text]; var WordTemplateField: Record "Word Template Field")
    var
        WordTemplateCustomFieldRecord: Record "Word Template Custom Field";
        WordTemplateCodeunit: Codeunit "Word Template";
        WordTemplateCustomField: Codeunit "Word Template Custom Field";
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
    begin
        WordTemplateCustomField.SetCurrentTableId(TableId, RelatedTableCode);
        WordTemplateCodeunit.OnGetCustomFieldNames(WordTemplateCustomField);
        WordTemplateCustomField.GetCustomFields(WordTemplateCustomFieldRecord);
        WordTemplateCustomFieldRecord.Reset();
        WordTemplateCustomFieldRecord.SetRange("Related Table Code", RelatedTableCode);
        if WordTemplateCustomFieldRecord.FindSet() then
            repeat
                if WordTemplateFieldSelection.IsCustomFieldSelected(WordTemplate.Code, TableId, StrSubstNo(CustomMergeFieldTok, WordTemplateCustomFieldRecord.Name), WordTemplateField) then
                    MailMergeFields.Add(GetCustomFieldName(WordTemplateCustomFieldRecord.Name, WordTemplateCustomFieldRecord."Related Table Code"));
            until WordTemplateCustomFieldRecord.Next() = 0;
    end;

    local procedure CreateDataTable(var DataTable: DotNet DataTable)
    var
        DotNetCultureInfo: DotNet CultureInfo;
    begin
        DataTable := DataTable.DataTable('DataTable');
        DotNetCultureInfo := DotNetCultureInfo.CultureInfo(WindowsLanguage);
        DataTable.Locale := DotNetCultureInfo.CurrentCulture;
    end;

    local procedure GetCustomTableColumns(MainTableId: Integer; var TempWordTemplateCustomField: Record "Word Template Custom Field" temporary);
    var
        RelatedTable: Record "Word Templates Related Table";
        WordTemplateCustomField: Codeunit "Word Template Custom Field";
        WordTemplateCodeunit: Codeunit "Word Template";
    begin
        WordTemplateCustomField.SetCurrentTableId(MainTableId);
        WordTemplateCodeunit.OnGetCustomFieldNames(WordTemplateCustomField);

        RelatedTable.SetRange(Code, WordTemplate.Code);
        if RelatedTable.FindSet() then
            repeat
                WordTemplateCustomField.SetCurrentTableId(RelatedTable."Related Table ID", RelatedTable."Related Table Code");
                WordTemplateCodeunit.OnGetCustomFieldNames(WordTemplateCustomField);
            until RelatedTable.Next() = 0;

        WordTemplateCustomField.SetCurrentTableId(0, OtherRecordRelatedTableTxt);
        WordTemplateCodeunit.OnGetCustomFieldNames(WordTemplateCustomField);
        WordTemplateCustomField.GetCustomFields(TempWordTemplateCustomField);
    end;

    local procedure AddCustomValuesToDataTable(RecordRef: RecordRef; RelatedTableCode: Code[5]; WriteColumns: Boolean; var DataTable: DotNet DataTable; var RowsArrayList: DotNet ArrayList; var TempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    var
        WordTemplateField: Record "Word Template Field";
        WordTemplateFieldValue: Codeunit "Word Template Field Value";
        WordTemplateCodeunit: Codeunit "Word Template";
        IncludeField: Boolean;
    begin
        TempWordTemplateCustomField.Reset();
        if not WriteColumns then begin
            WordTemplateFieldValue.Initialize(TempWordTemplateCustomField);
            WordTemplateFieldValue.SetCurrentRecord(RecordRef, RelatedTableCode);
            WordTemplateCodeunit.OnGetCustomRecordValues(WordTemplateFieldValue);

        end;
        TempWordTemplateCustomField.SetRange("Related Table Code", RelatedTableCode);

        if TempWordTemplateCustomField.FindSet() then
            repeat
                IncludeField := true;
                if WordTemplateField.Get(WordTemplate.Code, RecordRef.Number, TempWordTemplateCustomField.Name) and WordTemplateField.Exclude then
                    IncludeField := false;

                if IncludeField then
                    if not WriteColumns then
                        RowsArrayList.Add(TempWordTemplateCustomField.Value)
                    else
                        DataTable.Columns.Add(GetCustomFieldName(TempWordTemplateCustomField.Name, TempWordTemplateCustomField."Related Table Code"));
            until TempWordTemplateCustomField.Next() = 0;
    end;

    local procedure FillDataTable(RecordRef: RecordRef; WriteColumns: Boolean; var DataTable: DotNet DataTable; var TempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    var
        RowsArrayList: DotNet ArrayList;
    begin
        RowsArrayList := RowsArrayList.ArrayList();
        AddRecordRefToDataTable(RecordRef, true, WriteColumns, '', DataTable, RowsArrayList, TempWordTemplateCustomField);
        FillDataTableRelatedRecords(RecordRef, true, WriteColumns, WordTemplate."Table ID", DataTable, RowsArrayList, TempWordTemplateCustomField);
        FillDataTableUnrelatedRecords(WriteColumns, DataTable, RowsArrayList, TempWordTemplateCustomField);

        if not WriteColumns then
            DataTable.Rows.Add(RowsArrayList.ToArray());
    end;

    local procedure FillDataTableRelatedRecords(RecordRef: RecordRef; ParentRecordExist: Boolean; WriteColumns: Boolean; TableId: Integer; var DataTable: DotNet DataTable; var RowsArrayList: DotNet ArrayList; var TempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    var
        RelatedTable: Record "Word Templates Related Table";
        RecordRefRelated: RecordRef;
        NullGuid: Guid;
        RelatedRecordExist: Boolean;
    begin
        RelatedTable.SetRange("Table ID", TableId);
        RelatedTable.SetRange(Code, WordTemplate.Code);
        RelatedTable.SetRange("Source Record ID", NullGuid);
        if RelatedTable.FindSet() then
            repeat
                RecordRefRelated.Open(RelatedTable."Related Table ID");

                RelatedRecordExist := ParentRecordExist and GetRelatedRecord(RecordRefRelated, RecordRef.Field(RelatedTable."Field No.").Value());
                AddRecordRefToDataTable(RecordRefRelated, RelatedRecordExist, WriteColumns, RelatedTable."Related Table Code", DataTable, RowsArrayList, TempWordTemplateCustomField);
                FillDataTableRelatedRecords(RecordRefRelated, RelatedRecordExist, WriteColumns, RelatedTable."Related Table ID", DataTable, RowsArrayList, TempWordTemplateCustomField);

                Clear(RecordRefRelated);
            until RelatedTable.Next() = 0;

    end;

    local procedure FillDataTableUnrelatedRecords(WriteColumns: Boolean; var DataTable: DotNet DataTable; var RowsArrayList: DotNet ArrayList; var TempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    var
        RelatedTable: Record "Word Templates Related Table";
        RecordRefRelated: RecordRef;
        NullGuid: Guid;
        RecordExist: Boolean;
    begin
        RelatedTable.SetRange(Code, WordTemplate.Code);
        RelatedTable.SetFilter("Source Record ID", '<>%1', NullGuid);
        if RelatedTable.FindSet() then
            repeat
                RecordRefRelated.Open(RelatedTable."Related Table ID");

                RecordExist := RecordRefRelated.GetBySystemId(RelatedTable."Source Record ID");
                AddRecordRefToDataTable(RecordRefRelated, RecordExist, WriteColumns, RelatedTable."Related Table Code", DataTable, RowsArrayList, TempWordTemplateCustomField);
                FillDataTableRelatedRecords(RecordRefRelated, RecordExist, WriteColumns, RelatedTable."Related Table ID", DataTable, RowsArrayList, TempWordTemplateCustomField);

                Clear(RecordRefRelated);
            until RelatedTable.Next() = 0;

    end;

    local procedure AddRecordRefToDataTable(RecordRef: RecordRef; RecordExist: Boolean; WriteColumns: Boolean; RelatedTableCode: Code[5]; var DataTable: DotNet DataTable; var RowsArrayList: DotNet ArrayList; var TempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    var
        WordTemplateField: Record "Word Template Field";
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
        FieldRef: FieldRef;
        MailMergeFieldsCount: Dictionary of [Text, Integer];
        Field: Integer;
        Counter: Integer;
        UseDefaultFields: Boolean;
        IncludeField: Boolean;
    begin
        UseDefaultFields := WordTemplateFieldSelection.TableUsesDefaultFields(WordTemplate.Code, RecordRef.Number, WordTemplateField);
        for Field := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(Field);
            IncludeField := true;

            if UseDefaultFields and (FieldRef.Class = FieldClass::FlowFilter) then
                IncludeField := false;
            if UseDefaultFields and (FieldRef.Type in [FieldRef.Type::Blob,
                                                       FieldRef.Type::MediaSet,
                                                       FieldRef.Type::TableFilter,
                                                       FieldRef.Type::Media,
                                                       FieldRef.Type::RecordId]) then
                IncludeField := false;
            if (not UseDefaultFields) and WordTemplateField.Get(WordTemplate.Code, RecordRef.Number, CopyStr(FieldRef.Name, 1, 30)) and WordTemplateField.Exclude then
                IncludeField := false;

            if IncludeField then
                AddFieldRefToDataTable(FieldRef, RecordExist, WriteColumns, RelatedTableCode, Counter, MailMergeFieldsCount, DataTable, RowsArrayList, TempWordTemplateCustomField);
        end;
        AddCustomValuesToDataTable(RecordRef, RelatedTableCode, WriteColumns, DataTable, RowsArrayList, TempWordTemplateCustomField);
    end;

    internal procedure AddFieldRefToDataTable(var FieldRef: FieldRef; RecordExist: Boolean; WriteColumns: Boolean; RelatedTableCode: Code[5]; var Counter: Integer; var MailMergeFieldsCount: Dictionary of [Text, Integer]; var DataTable: DotNet DataTable; var RowsArrayList: DotNet ArrayList; var TempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    var
        AppendValue: Text;
    begin
        if RecordExist and (FieldRef.Class = FieldClass::FlowField) then
            FieldRef.CalcField();
        if WriteColumns then begin
            AppendValue := GetAppendValue(FieldRef.Caption(), Counter, MailMergeFieldsCount);
            DataTable.Columns.Add(GetFieldName(FieldRef.Caption(), RelatedTableCode, AppendValue));
        end else
            if RecordExist then
                RowsArrayList.Add(Format(FieldRef.Value()))
            else
                RowsArrayList.Add(Format(''))
    end;

    internal procedure GetRelatedRecord(var RelatedRecord: RecordRef; Reference: Variant) Found: Boolean
    begin
        Found := GetByPrimaryKey(RelatedRecord, Reference);

        if not Found then
            if Reference.IsGuid() then
                Found := RelatedRecord.GetBySystemId(Reference)
            else
                if Reference.IsRecordId() then
                    Found := RelatedRecord.Get(Reference);
    end;

    internal procedure GetByPrimaryKey(var RecordRef: RecordRef; ReferenceVariant: Variant): Boolean
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
    begin
        KeyRef := RecordRef.KeyIndex(1);
        if KeyRef.FieldCount() > 1 then
            exit(false);

        FieldRef := KeyRef.FieldIndex(1);
        case FieldRef.Type of
            FieldRef.Type::BigInteger:
                if not ReferenceVariant.IsBigInteger() then
                    exit(false);
            FieldRef.Type::Code:
                if not ReferenceVariant.IsCode() then
                    exit(false);
            FieldRef.Type::Integer:
                if not ReferenceVariant.IsInteger() then
                    exit(false);
            FieldRef.Type::Guid:
                if not ReferenceVariant.IsGuid() then
                    exit(false);
            else
                exit(false);
        end;

        FieldRef.SetRange(ReferenceVariant);
        exit(RecordRef.FindFirst());
    end;

    procedure GetMergeFields(var Value: List of [Text])
    begin
        Value := MergeFields;
    end;

    /// Due to truncation of long names in Microsoft Word, we have to limit the the name length to less than 40.
    /// Word automatically truncates and remove/replace special characters.
    local procedure VerifyMailMergeFieldNameLengths(): Boolean
    var
        MailMergeField: Text;
    begin
        foreach MailMergeField in MailMerge.GetMergeFields() do
            if not (StrLen(MailMergeField) < GetMaximumFieldLength()) then
                exit(false);
        exit(true);
    end;

    internal procedure GetFieldNo(var FilterExpression: Text; ParentTableNo: Integer; RelatedTableNo: Integer) FieldNo: Integer
    var
        Field: Record Field;
        ExpressionBuilder: TextBuilder;
        Found: Boolean;
        MultipleMatches: Boolean;
    begin
        Field.SetRange(TableNo, ParentTableNo);
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No, Field.ObsoleteState::Pending);
        Field.SetRange(Class, Field.Class::Normal);

        if Field.FindSet() then
            repeat
                if (Field.RelationTableNo = RelatedTableNo) and (Field.RelationFieldNo in [0, 1]) then begin
                    ExpressionBuilder.Append(StrSubstNo(ExpressionFilterTok, Field."No."));
                    if not Found then begin
                        FieldNo := Field."No.";
                        Found := true;
                    end else
                        MultipleMatches := true;
                end;
            until Field.Next() = 0;

        if Found then
            if MultipleMatches then
                FilterExpression := ExpressionBuilder.ToText(1, ExpressionBuilder.Length() - 1)
            else
                FilterExpression := Format(FieldNo)
        else
            FilterExpression := '';

        exit(FieldNo);
    end;

    internal procedure GetRelatedTablesFilterExpression(TableNo: Integer): Text
    var
        Field: Record Field;
        ExpressionBuilder: TextBuilder;
    begin
        Field.SetRange(TableNo, TableNo);
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No, Field.ObsoleteState::Pending);
        Field.SetRange(Class, Field.Class::Normal);

        if Field.FindSet() then
            repeat
                if (Field.RelationTableNo <> 0) and (Field.RelationFieldNo in [0, 1]) then
                    ExpressionBuilder.Append(StrSubstNo(ExpressionFilterTok, Field.RelationTableNo));
            until Field.Next() = 0;

        exit(ExpressionBuilder.ToText(1, ExpressionBuilder.Length() - 1));
    end;

    internal procedure GenerateCode(ObjectCaption: Text[249]; ExistingCodes: Dictionary of [Code[5], Boolean]) EntityCode: Code[5]
    var
        Position: Integer;
        Length: Integer;
        No: Integer;
        Character: Char;
    begin
        Length := 1;
        Position := 1;
        ObjectCaption := ObjectCaption.ToUpper();

        repeat
            Character := ObjectCaption[Position];

            // If first character, it can only be alphabetic
            // Subsequent characters can have numbers
            if ((Length = 1) and IsAlphabetic(Character)) or ((Length > 1) and IsAlphanumeric(Character)) then begin
                EntityCode += Character;
                Length += 1;
            end;

            Position += 1;
        until (Length > 5) or (StrLen(ObjectCaption) < Position);

        No := 1;

        // If code already exist, replace last character with a number
        while ExistingCodes.ContainsKey(EntityCode) and (No < 10) do begin
            EntityCode[Length - 1] := Format(No) [1];
            No += 1;
        end;
    end;

    internal procedure GetExistingCodes(var TempWordTemplatesRelatedTable: Record "Word Templates Related Table" temporary) ExistingCodes: Dictionary of [Code[5], Boolean]
    var
        TempWordTemplatesRelatedTableCopy: Record "Word Templates Related Table" temporary;
    begin
        TempWordTemplatesRelatedTableCopy.Copy(TempWordTemplatesRelatedTable, true);
        TempWordTemplatesRelatedTableCopy.Reset();

        if TempWordTemplatesRelatedTableCopy.FindSet() then
            repeat
                ExistingCodes.Add(TempWordTemplatesRelatedTableCopy."Related Table Code", true);
            until TempWordTemplatesRelatedTableCopy.Next() = 0;
    end;

    internal procedure GetExistingCodes(var TempWordTemplatesRelatedBuffer: Record "Word Templates Related Buffer" temporary) ExistingCodes: Dictionary of [Code[5], Boolean]
    var
        TempWordTemplatesRelatedBufferCopy: Record "Word Templates Related Buffer" temporary;
    begin
        TempWordTemplatesRelatedBufferCopy.Copy(TempWordTemplatesRelatedBuffer, true);
        TempWordTemplatesRelatedBufferCopy.Reset();

        if TempWordTemplatesRelatedBufferCopy.FindSet() then
            repeat
                ExistingCodes.Add(TempWordTemplatesRelatedBufferCopy."Related Table Code", true);
            until TempWordTemplatesRelatedBufferCopy.Next() = 0;
    end;

    local procedure GetAppendValue(Caption: Text; var Counter: Integer; var MailMergeFieldsCount: Dictionary of [Text, Integer]): Text
    begin
        if MailMergeFieldsCount.Get(Caption, Counter) then begin
            Counter += 1;
            MailMergeFieldsCount.Set(Caption, Counter);
            exit(StrSubstNo(AppendPatternTxt, Counter));
        end else begin
            MailMergeFieldsCount.Set(Caption, 1);
            exit('');
        end;
    end;

    local procedure IsAlphabetic(Character: Char): Boolean
    begin
        exit(Character in ['A' .. 'Z']);
    end;

    local procedure IsAlphanumeric(Character: Char): Boolean
    begin
        exit((Character in ['0' .. '9']) or IsAlphabetic(Character));
    end;

    local procedure GetMaximumFieldLength(): Integer
    begin
        exit(40);
    end;

    local procedure GetMaximumNumberOfRecords(): Integer
    begin
        exit(1000);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Word Template Creation Wizard", OnSetTableNo, '', false, false)]
    local procedure OnSetTableNo(Value: Integer)
    begin
        Session.LogMessage('0000ECY', StrSubstNo(TableNoSetExternallyTxt, Value), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Word Template", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertWordTemplate(var Rec: Record "Word Template")
    begin
        if Rec.IsTemporary() then
            exit;

        Session.LogMessage('0000ECZ', StrSubstNo(CreatedTemplateTxt, Rec.SystemId, Rec."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Word Template", OnBeforeDeleteEvent, '', false, false)]
    local procedure OnBeforeDeleteWordTemplate(var Rec: Record "Word Template")
    var
        RelatedTables: Record "Word Templates Related Table";
        WordTemplateFields: Record "Word Template Field";
    begin
        if Rec.IsTemporary() then
            exit;

        RelatedTables.SetRange(Code, Rec.Code);
        RelatedTables.DeleteAll();
        WordTemplateFields.SetRange("Word Template Code", Rec.Code);
        WordTemplateFields.DeleteAll();
        Session.LogMessage('0000ED0', StrSubstNo(DeletedTemplateTxt, Rec.SystemId, Rec."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    var
        WordTemplate: Record "Word Template";
        ResultTempBlob: Codeunit "Temp Blob";
        TemplateTempBlob: Codeunit "Temp Blob";
        ZipFileTempBlob: Codeunit "Temp Blob";
        MailMerge: DotNet MailMerge;
        MergeFields: List of [Text];
        ChosenFormat: Enum "Word Templates Save Format";
        MultipleDocuments: Boolean;
        TableNotAllowedMergeFieldsTruncatedErr: Label 'Cannot upload the template because it contains one or more merge fields with names that are 40 characters or more.';
        NotARecordErr: Label 'The RecordVariant parameter is not a Record.';
        NotAValidSaveFormatErr: Label 'The specified save format is not supported.';
        NotAValidTemplateCodeErr: Label 'The specified Word Template Code was not found.';
        NoMergeFieldsWereSpecifiedErr: Label 'No Merge fields were specified.';
        FailedToLoadTemplateErr: Label 'The Word Template could not be loaded. Make sure you''re using a valid Word Template.';
        UploadDialogTitleLbl: Label 'Upload template.';
        DownloadDialogTitleLbl: Label 'Download template and data source as zip.';
        DownloadResultFileDialogTitleLbl: Label 'Download document.';
        FilterPageBuilderCaptionLbl: Label '%1 Filters', comment = '%1 = Table Caption';
        SpecifyFiltersQst: Label 'Do you want to specify any filters on the template entity?';
        DataSourceFileTxt: Label 'DataSource.xlsx', Locked = true;
        DataSourceSheetNameTxt: Label 'DataSource', Locked = true;
        DefaultTemplateLbl: Label 'Template', Locked = true;
        DefaultTemplateNameWithCaptionLbl: Label '%1 Template', Comment = '%1 = Table caption';
        DefaultTemplateNameLbl: Label 'Template';
        SelectEntityLbl: Label 'Select entity';
        OverrideTemplateQst: Label 'Do you want to override the existing template?';
        AddNewEntityCaptionLbl: Label 'Add new entity for which to create template';
        RelatedTableCodeAlreadyUsedMsg: Label 'The field prefix for the related entity already exists.';
        RelatedTableIdAlreadyUsedMsg: Label 'The related entity already exists.';
        RelatedTableIdsLengthErr: Label 'The length of the related table IDs (%1), does not match the length of the related table codes (%2).', Comment = '%1 - Length of related table IDs list, %2 Length of related table codes list';
        FilenamePatternTxt: Label '%1.%2', Locked = true;
        RelatedTablePatternTxt: Label '%1_', Locked = true;
        AppendPatternTxt: Label '_%1', Locked = true;
        EmptyTemplateNamePatternTxt: Label '%1.%2', Locked = true;
        TemplateNamePatternTxt: Label '%1_%2.%3', Locked = true;
        ExpressionFilterTok: Label '%1|', Locked = true;
        MergeFieldTok: Label '%1%2%3', Locked = true;
        CustomMergeFieldWithRelatedTableTok: Label '%1_CALC_%2', Locked = true;
        CustomMergeFieldTok: Label 'CALC_%1', Locked = true;
        ReservedCharsTok: Label '<|>|:|\/|\\|\||\?|\*|\"', Locked = true;
        WordTemplatesCategoryTxt: Label 'AL Word Templates', Locked = true;
        DownloadedTemplateTxt: Label 'Template downloaded: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        UploadedTemplateTxt: Label 'Template uploaded: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        CreatedTemplateTxt: Label 'Template created: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        DeletedTemplateTxt: Label 'Template deleted: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        TableNoSetExternallyTxt: Label 'Table no. of Word Template Creation Wizard set externally: %1.', Comment = '%1 - Table ID', Locked = true;
        FailedToApplyTemplateAllTxt: Label 'Failed to apply template: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID, %3 - Error', Locked = true;
        FailedToLoadTemplateAllTxt: Label 'Failed to load template: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        TableIdDoesNotExistErr: Label 'Table ID %1 does not exist.', Comment = '%1 - Table ID';
        OtherRecordRelatedTableTxt: Label 'OTHER', Locked = true;
        TempDocLbl: Label 'Temp doc.docx', Locked = true;
        CannotRemoveTableWithRelationsErr: Label 'You cannot remove a table while there are still tables related to it.';
        SettingsXmlFileContentDoesNotExistTxt: Label 'Settings.xml file content does not exist in the Word Document.', Locked = true;
        SettingsXmlRelsFilePathTxt: label 'word/_rels/settings.xml.rels', Locked = true;
        DataSourceNotSetTxt: Label 'Data source not set.', Locked = true;
}
