// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9988 "Word Template Impl."
{
    Access = Internal;
    Permissions = tabledata "Word Template" = rim,
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

    internal procedure DownloadTemplate(WordTemplate: Record "Word Template")
    begin
        Load(WordTemplate.Code);
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

    internal procedure Upload(var WordTemplate: Record "Word Template"; var UploadedFileName: Text): Boolean
    var
        FileContentInstream: Instream;
    begin
        if not UploadIntoStream(UploadDialogTitleLbl, '', '', UploadedFileName, FileContentInstream) then
            exit(false);

        SaveTemplate(FileContentInstream, WordTemplate);

        Session.LogMessage('0000ECO', StrSubstNo(UploadedTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);

        exit(true);
    end;

    internal procedure Upload(var WordTemplate: Record "Word Template")
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
        Clear(WordTemplate.Template);
        WordTemplate.Template.ImportStream(NewTemplateInStream, 'Template');

        WordTemplate.Modify();
    end;

    local procedure SaveTemplate(TemplateInStream: Instream; var WordTemplate: Record "Word Template")
    begin
        Load(TemplateInStream);

        if not VerifyMailMergeFieldNameLengths() then
            Error(TableNotAllowedMergeFieldsTruncatedErr);

        WordTemplate.Template.ImportStream(TemplateInStream, DefaultTemplateLbl);

        if WordTemplate.Name = '' then
            if WordTemplate."Table ID" <> 0 then
                WordTemplate.Name := CopyStr(StrSubstNo(DefaultTemplateNameWithCaptionLbl, WordTemplate."Table Caption"), 1, MaxStrLen(WordTemplate.Name))
            else
                WordTemplate.Name := DefaultTemplateNameLbl;
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
        TableId: Integer;
    begin
        TableId := SelectTable();
        Create(TableId);
    end;

    procedure Create(TableId: Integer)
    var
        MailMergeFields: List of [Text];
    begin
        WordTemplate."Table ID" := TableId;
        GetMergeFieldsForRecord(TableId, MailMergeFields);
        Create(MailMergeFields);
    end;

    procedure Create(TableId: Integer; RelatedTableIds: List of [Integer]; RelatedTableCodes: List of [Code[5]])
    var
        MailMergeFields: List of [Text];
        Index: Integer;
    begin
        if RelatedTableIds.Count() <> RelatedTableCodes.Count() then
            Error(RelatedTableIdsLengthErr, RelatedTableIds.Count, RelatedTableCodes.Count);

        WordTemplate."Table ID" := TableId;
        GetMergeFieldsForRecord(TableId, MailMergeFields);

        for Index := 1 to RelatedTableIds.Count do
            GetMergeFieldsForRecord(RelatedTableIds.Get(Index), MailMergeFields, StrSubstNo(PrependPatternTxt, RelatedTableCodes.Get(Index)));

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
            FeatureTelemetry.LogUptake('0000ECP', 'Word templates', Enum::"Feature Uptake Status"::"Set up", false, CustomDimensions)
        else begin
            FeatureTelemetry.LogError('0000ECQ', 'Word templates', 'Loading template', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
            Session.LogMessage('0000ECR', StrSubstNo(FailedToLoadTemplateAllTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', WordTemplatesCategoryTxt);
            Error(FailedToLoadTemplateErr);
        end;
    end;

    [TryFunction]
    local procedure TryMailMergeLoadDocument(var TemplateInstream: InStream)
    begin
        MailMerge := MailMerge.MailMerge();
        MailMerge.LoadDocument(DataSourceFileTxt, TemplateInStream);
    end;

    procedure Merge(Data: Dictionary of [Text, Text]; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
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

        CustomDimensions.Add('TemplateSystemID', WordTemplate.SystemId);
        CustomDimensions.Add('TemplateTableID', Format(WordTemplate."Table ID"));
        FeatureTelemetry.LogUptake('0000FW3', 'Word templates', Enum::"Feature Uptake Status"::Used, false, CustomDimensions);

        if Success then
            FeatureTelemetry.LogUsage('0000ECS', 'Word templates', 'Template applied', CustomDimensions)
        else begin
            FeatureTelemetry.LogError('0000ECT', 'Word templates', 'Applying template', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
            Session.LogMessage('0000ECU', StrSubstNo(FailedToApplyTemplateAllTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', WordTemplatesCategoryTxt);
            Error(GetLastErrorText());
        end;
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

    procedure Merge(Data: InStream; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
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

        CustomDimensions.Add('TemplateSystemID', WordTemplate.SystemId);
        CustomDimensions.Add('TemplateTableID', Format(WordTemplate."Table ID"));
        FeatureTelemetry.LogUptake('0000FW4', 'Word templates', Enum::"Feature Uptake Status"::Used, false, CustomDimensions);

        if Success then
            FeatureTelemetry.LogUsage('0000ECV', 'Word templates', 'Template applied', CustomDimensions)
        else begin
            FeatureTelemetry.LogError('0000ECW', 'Word templates', 'Applying template', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
            Session.LogMessage('0000ECX', StrSubstNo(FailedToApplyTemplateAllTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', WordTemplatesCategoryTxt);
            Error(GetLastErrorText());
        end;
    end;

    [TryFunction]
    local procedure TryMailMergeExecute(Data: InStream; SaveFormat: Enum "Word Templates Save Format"; var Output: OutStream)
    begin
        MailMerge.Execute(Data, SaveFormat.AsInteger(), Output);
    end;

    procedure Merge(RecordVariant: Variant; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
    begin
        if not RecordVariant.IsRecord() and not RecordVariant.IsRecordRef() then
            Error(NotARecordErr);
        MultipleDocuments := SplitDocument;
        if SplitDocument then
            MergeSplitDocument(RecordVariant, SaveFormat)
        else
            MergeOneDocument(RecordVariant, SaveFormat);
    end;

    // Merges each record separately into individual documents and puts them into a zip.
    local procedure MergeSplitDocument(RecordVariant: Variant; SaveFormat: Enum "Word Templates Save Format")
    var
        DataCompression: Codeunit "Data Compression";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        PrimaryKey: KeyRef;
        InStream: InStream;
        OutStream: OutStream;
        EntryName: Text;
        Index: Integer;
        Data: Dictionary of [Text, Text];
    begin
        RecordRef.GetTable(RecordVariant);
        DataCompression.CreateZipArchive();

        if RecordRef.FindSet() then
            repeat
                WriteDataDict(RecordRef, Data);
                Merge(Data, true, SaveFormat);
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

    local procedure MergeOneDocument(RecordVariant: Variant; SaveFormat: Enum "Word Templates Save Format")
    var
        Data: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        Reader: InStream;
        Writer: OutStream;
    begin
        RecordRef.GetTable(RecordVariant);
        Data.CreateOutStream(Writer, TextEncoding::UTF8);

        WriteDataStream(RecordRef, Writer, true);
        if RecordRef.FindSet() then
            repeat
                WriteDataStream(RecordRef, Writer, false);
            until RecordRef.Next() = 0;

        Data.CreateInStream(Reader, TextEncoding::UTF8);
        Merge(Reader, false, SaveFormat);
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

        Merge(RecordRef, SplitDocument, SaveFormat);
        RecordRef.Close();
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
        AllObjWithCaption.FilterGroup(2);
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);

        if FilterExpression <> '' then
            AllObjWithCaption.SetFilter("Object ID", FilterExpression);

        AllObjWithCaption.FilterGroup(0);

        Objects.SetTableView(AllObjWithCaption);
        Objects.Caption(Caption);
        Objects.LookupMode(true);

        if Objects.RunModal() = Action::LookupOK then
            Objects.GetRecord(AllObjWithCaption);
    end;

    internal procedure AddRelatedEntity(TableId: Integer; RelatedCode: Code[30]; var WordTemplateRelatedTable: Record "Word Templates Related Table"; FilterExpression: Text): Boolean
    var
        WordTemplateRelatedCard: Page "Word Templates Related Card";
    begin
        WordTemplateRelatedCard.SetRelatedTable(WordTemplateRelatedTable);
        WordTemplateRelatedCard.SetTableNo(TableId);
        WordTemplateRelatedCard.SetFilterExpression(FilterExpression);
        WordTemplateRelatedCard.LookupMode(true);

        if WordTemplateRelatedCard.RunModal() = Action::LookupOK then begin
            WordTemplateRelatedCard.GetRelatedTable(WordTemplateRelatedTable);
            WordTemplateRelatedTable.Code := RelatedCode;
            exit(true);
        end;

        exit(false);
    end;

    internal procedure GetField(Caption: Text; TableId: Integer; FilterExpression: Text): Integer
    var
        Field: Record Field;
        Fields: Page "Fields Lookup";
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

        Fields.SetTableView(Field);
        Fields.Caption(Caption);
        Fields.LookupMode(true);

        if Fields.RunModal() = Action::LookupOK then begin
            Fields.GetRecord(Field);
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

    internal procedure AddRelatedTable(var WordTemplatesRelatedTable: Record "Word Templates Related Table"; TableId: Integer; FilterRelatedTables: Boolean)
    var
        TempWordTemplatesRelatedTable: Record "Word Templates Related Table" temporary;
        FilterExpression: Text;
        InsertFailed: Boolean;
    begin
        if FilterRelatedTables then
            FilterExpression := GetRelatedTablesFilterExpression(TableId);

        repeat
            InsertFailed := false;
            if AddRelatedEntity(TableId, WordTemplatesRelatedTable.Code, TempWordTemplatesRelatedTable, FilterExpression) then
                InsertFailed := not AddRelatedTable(WordTemplatesRelatedTable, TempWordTemplatesRelatedTable);
        until not InsertFailed;
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
    /// <param name="WordTemplateRelatedTable">The related table to insert the record into.</param>
    /// <param name="TempWordTemplateRelatedTable">The temporary related table that holds the values used for inserting.</param>
    /// <returns>True if the related table was added, false otherwise.</returns>
    internal procedure AddRelatedTable(var WordTemplateRelatedTable: Record "Word Templates Related Table"; TempWordTemplateRelatedTable: Record "Word Templates Related Table" temporary) Added: Boolean
    begin
        WordTemplateRelatedTable.SetRange(Code, TempWordTemplateRelatedTable.Code);
        WordTemplateRelatedTable.SetRange("Related Table Code", TempWordTemplateRelatedTable."Related Table Code");

        if not WordTemplateRelatedTable.IsEmpty() then begin
            Message(RelatedTableCodeAlreadyUsedMsg);
            exit(false);
        end;

        WordTemplateRelatedTable.Reset();
        WordTemplateRelatedTable.SetRange(Code, TempWordTemplateRelatedTable.Code);
        WordTemplateRelatedTable.SetRange("Related Table ID", TempWordTemplateRelatedTable."Related Table ID");

        if not WordTemplateRelatedTable.IsEmpty() then begin
            Message(RelatedTableIdAlreadyUsedMsg);
            exit(false);
        end;

        WordTemplateRelatedTable.Init();
        WordTemplateRelatedTable.Copy(TempWordTemplateRelatedTable);
        Added := WordTemplateRelatedTable.Insert();
        WordTemplateRelatedTable.SetRange(Code, WordTemplateRelatedTable.Code);
    end;

    internal procedure RemoveRelatedTable(WordTemplateCode: Code[30]; RelatedTableId: Integer): Boolean
    var
        WordTemplatesRelatedTable: Record "Word Templates Related Table";
    begin
        WordTemplatesRelatedTable.Get(WordTemplateCode, RelatedTableId);
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
        Instream: Instream;
    begin
        TemplateTempBlob.CreateInStream(Instream, TextEncoding::UTF8);
        MailMerge := MailMerge.MailMerge();
        MailMerge.LoadDocument(Instream);
    end;

    internal procedure InsertWordTemplate(var WordTemplate: Record "Word Template")
    begin
        WordTemplate.Insert();
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
    begin
        GetMergeFieldsForRecord(WordTemplateRec."Table ID", MailMergeFields);

        WordTemplatesRelatedTable.SetRange(Code, WordTemplateRec.Code);
        if WordTemplatesRelatedTable.FindSet() then
            repeat
                GetMergeFieldsForRecord(WordTemplatesRelatedTable."Related Table ID", MailMergeFields, StrSubstNo(PrependPatternTxt, WordTemplatesRelatedTable."Related Table Code"));
            until WordTemplatesRelatedTable.Next() = 0;
    end;

    local procedure GetMergeFieldsForRecord(TableId: Integer; var MailMergeFields: List of [Text])
    begin
        GetMergeFieldsForRecord(TableId, MailMergeFields, '');
    end;

    local procedure GetMergeFieldsForRecord(TableId: Integer; var MailMergeFields: List of [Text]; PrependValue: Text)
    var
        FieldRec: Record Field;
        MailMergeFieldsCount: Dictionary of [Text, Integer];
        Counter: Integer;
        AppendValue: Text;
    begin
        FieldRec.SetRange(TableNo, TableId);
        FieldRec.SetFilter(Class, '<>%1', FieldRec.Class::FlowFilter);
        FieldRec.SetFilter(Type, '<>%1&<>%2&<>%3&<>%4&<>%5', FieldRec.Type::BLOB,
                                                             FieldRec.Type::Media,
                                                             FieldRec.Type::MediaSet,
                                                             FieldRec.Type::RecordID,
                                                             FieldRec.Type::TableFilter);
        if FieldRec.FindSet() then
            repeat
                AppendValue := GetAppendValue(FieldRec."Field Caption", Counter, MailMergeFieldsCount);
                MailMergeFields.Add(StrSubstNo(MergeFieldTok, PrependValue, FieldRec."Field Caption", AppendValue));
            until FieldRec.Next() = 0;
    end;


    local procedure WriteDataStream(RecordRef: RecordRef; OutStream: OutStream; WriteNames: Boolean)
    var
        RelatedTable: Record "Word Templates Related Table";
        RecordRefRelated: RecordRef;
    begin
        WriteDataStream(RecordRef, OutStream, WriteNames, '');

        RelatedTable.SetRange(Code, WordTemplate.Code);
        if RelatedTable.FindSet() then
            repeat
                Clear(RecordRefRelated);
                RecordRefRelated.Open(RelatedTable."Related Table ID");

                if WriteNames then begin
                    OutStream.WriteText('|');
                    WriteDataStream(RecordRefRelated, Outstream, WriteNames, StrSubstNo(PrependPatternTxt, RelatedTable."Related Table Code"));
                end else
                    if GetRelatedRecord(RecordRefRelated, RecordRef.Field(RelatedTable."Field No.").Value()) then begin
                        OutStream.WriteText('|');
                        WriteDataStream(RecordRefRelated, Outstream, WriteNames, '')
                    end

            until RelatedTable.Next() = 0;
        OutStream.WriteText();
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

    local procedure WriteDataStream(RecordRef: RecordRef; OutStream: OutStream; WriteNames: Boolean; PrependValue: Text)
    var
        FieldRef: FieldRef;
        MailMergeFieldsCount: Dictionary of [Text, Integer];
        Field: Integer;
        Counter: Integer;
        AppendValue: Text;
    begin
        for Field := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(Field);
            if (FieldRef.Class <> FieldClass::FlowFilter) and not (FieldRef.Type in [FieldRef.Type::Blob,
                                                                                     FieldRef.Type::MediaSet,
                                                                                     FieldRef.Type::TableFilter,
                                                                                     FieldRef.Type::Media,
                                                                                     FieldRef.Type::RecordId]) then begin
                if FieldRef.Class = FieldClass::FlowField then
                    FieldRef.CalcField();
                if WriteNames then begin
                    AppendValue := GetAppendValue(FieldRef.Caption(), Counter, MailMergeFieldsCount);
                    OutStream.WriteText(StrSubstNo(MergeFieldTok, PrependValue, FieldRef.Caption(), AppendValue));
                end else
                    OutStream.WriteText(Format(FieldRef.Value()));
                if Field < RecordRef.FieldCount() then
                    OutStream.WriteText('|');
            end;
        end;
    end;

    local procedure WriteDataDict(RecordRef: RecordRef; var Data: Dictionary of [Text, Text])
    var
        RelatedTable: Record "Word Templates Related Table";
        RecordRefRelated: RecordRef;
    begin
        WriteDataDict(RecordRef, Data, '');

        RelatedTable.SetRange(Code, WordTemplate.Code);
        if RelatedTable.FindSet() then
            repeat
                RecordRefRelated.Open(RelatedTable."Related Table ID");
                if GetRelatedRecord(RecordRefRelated, RecordRef.Field(RelatedTable."Field No.").Value()) then
                    WriteDataDict(RecordRefRelated, Data, StrSubstNo(PrependPatternTxt, RelatedTable."Related Table Code"));
                RecordRefRelated.Close();
            until RelatedTable.Next() = 0;
    end;

    local procedure WriteDataDict(RecordRef: RecordRef; var Data: Dictionary of [Text, Text]; PrependValue: Text)
    var
        FieldRef: FieldRef;
        MailMergeFieldsCount: Dictionary of [Text, Integer];
        Field: Integer;
        Counter: Integer;
        AppendValue: Text;
    begin
        for Field := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(Field);
            if (FieldRef.Class <> FieldClass::FlowFilter) and not (FieldRef.Type in [FieldRef.Type::Blob,
                                                                                     FieldRef.Type::MediaSet,
                                                                                     FieldRef.Type::TableFilter,
                                                                                     FieldRef.Type::Media,
                                                                                     FieldRef.Type::RecordId]) then begin
                if FieldRef.Class = FieldClass::FlowField then
                    FieldRef.CalcField();
                AppendValue := GetAppendValue(FieldRef.Caption(), Counter, MailMergeFieldsCount);
                Data.Set(StrSubstNo(MergeFieldTok, PrependValue, FieldRef.Caption(), AppendValue), Format(FieldRef.Value()));
            end;
        end;
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
            if not (StrLen(MailMergeField) < 40) then
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

        if MultipleMatches then
            FilterExpression := ExpressionBuilder.ToText(1, ExpressionBuilder.Length() - 1)
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

        if Field.FindSet() then
            repeat
                if (Field.RelationTableNo <> 0) and (Field.RelationFieldNo in [0, 1]) then
                    ExpressionBuilder.Append(StrSubstNo(ExpressionFilterTok, Field.RelationTableNo));
            until Field.Next() = 0;

        exit(ExpressionBuilder.ToText(1, ExpressionBuilder.Length() - 1));
    end;

    internal procedure GenerateCode(ObjectCaption: Text[249]) EntityCode: Code[5]
    var
        Position: Integer;
        Length: Integer;
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

    [EventSubscriber(ObjectType::Page, Page::"Word Template Creation Wizard", 'OnSetTableNo', '', false, false)]
    local procedure OnSetTableNo(Value: Integer)
    begin
        Session.LogMessage('0000ECY', StrSubstNo(TableNoSetExternallyTxt, Value), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Word Template", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertWordTemplate(var Rec: Record "Word Template")
    begin
        if Rec.IsTemporary() then
            exit;

        Session.LogMessage('0000ECZ', StrSubstNo(CreatedTemplateTxt, Rec.SystemId, Rec."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Word Template", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteWordTemplate(var Rec: Record "Word Template")
    var
        RelatedTables: Record "Word Templates Related Table";
    begin
        if Rec.IsTemporary() then
            exit;

        RelatedTables.SetRange(Code, Rec.Code);
        RelatedTables.DeleteAll();
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
        NotARecordErr: Label 'The RecordVariant paramenter is not a Record.';
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
        OverrideTemplateQst: Label 'Do you want to override the existing template?';
        AddNewEntityCaptionLbl: Label 'Add new entity for which to create template';
        RelatedTableCodeAlreadyUsedMsg: Label 'The field prefix for the related entity already exists.';
        RelatedTableIdAlreadyUsedMsg: Label 'The related entity already exists.';
        RelatedTableIdsLengthErr: Label 'The length of the related table IDs (%1), does not match the length of the related table codes (%2).', Comment = '%1 - Length of related table IDs list, %2 Length of related table codes list';
        FilenamePatternTxt: Label '%1.%2', Locked = true;
        PrependPatternTxt: Label '%1_', Locked = true;
        AppendPatternTxt: Label '_%1', Locked = true;
        EmptyTemplateNamePatternTxt: Label '%1.%2', Locked = true;
        TemplateNamePatternTxt: Label '%1_%2.%3', Locked = true;
        ExpressionFilterTok: Label '%1|', Locked = true;
        MergeFieldTok: Label '%1%2%3', Locked = true;
        ReservedCharsTok: Label '<|>|:|\/|\\|\||\?|\*|\"', Locked = true;
        WordTemplatesCategoryTxt: Label 'AL Word Templates', Locked = true;
        DownloadedTemplateTxt: Label 'Template downloaded: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        UploadedTemplateTxt: Label 'Template uploaded: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        CreatedTemplateTxt: Label 'Template created: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        DeletedTemplateTxt: Label 'Template deleted: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        TableNoSetExternallyTxt: Label 'Table no. of Word Template Creation Wizard set externally: %1.', Comment = '%1 - Table ID', Locked = true;
        FailedToApplyTemplateAllTxt: Label 'Failed to apply template: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID, %3 - Error', Locked = true;
        FailedToLoadTemplateAllTxt: Label 'Failed to load template: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
}
