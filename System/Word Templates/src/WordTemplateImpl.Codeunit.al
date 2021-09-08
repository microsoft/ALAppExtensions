// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9988 "Word Template Impl."
{
    Access = Internal;
    Permissions = tabledata "Word Template" = rim,
                  tabledata "Word Templates Table" = ri,
                  tabledata AllObj = r,
                  tabledata Field = r;

    procedure DownloadTemplate()
    var
        Output: Text;
        InStream: InStream;
    begin
        if MergeFields.Count() = 0 then begin
            Template.CreateInStream(InStream, TextEncoding::UTF8);
            Output := GetTemplateName('docx');
            DownloadFromStream(InStream, DownloadDialogTitleLbl, '', '', Output);
            Session.LogMessage('0000ED4', StrSubstNo(DownloadedTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
            exit;
        end;

        PrepareZipFile();
        ZipFile.CreateInStream(InStream, TextEncoding::UTF8);

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
        Clear(ZipFile);

        DataCompression.CreateZipArchive();
        Template.CreateInStream(InStream, TextEncoding::UTF8);
        DataCompression.AddEntry(InStream, GetTemplateName('docx'));
        GenerateSpreadsheetDataSource(DataCompression); // Add data source spreadsheet to zip

        ZipFile.CreateOutStream(OutStream, TextEncoding::UTF8);
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
        Result.CreateInStream(InStream, TextEncoding::UTF8);
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
        Template.CreateInStream(TemplateInStream, TextEncoding::UTF8);
    end;

    procedure GetDocument(var DocumentInStream: InStream)
    begin
        Result.CreateInStream(DocumentInStream, TextEncoding::UTF8);
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

    procedure Create(MailMergeFields: List of [Text])
    var
        OutStream: OutStream;
    begin
        if MailMergeFields.Count() = 0 then
            Error(NoMergeFieldsWereSpecifiedErr);

        MergeFields := MailMergeFields;

        Template.CreateOutStream(OutStream, TextEncoding::UTF8);
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
        Load(TemplateInStream);
    end;

    procedure Load(TemplateInStream: InStream)
    var
        OutStream: OutStream;
        Success: Boolean;
    begin
        Clear(MergeFields);

        Template.CreateOutStream(OutStream, TextEncoding::UTF8);
        CopyStream(OutStream, TemplateInStream);
        Template.CreateInStream(TemplateInStream, TextEncoding::UTF8);

        Success := TryMailMergeLoadDocument(TemplateInStream);

        if Success then
            Session.LogMessage('0000ECP', StrSubstNo(LoadedTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt)
        else begin
            Session.LogMessage('0000ECQ', StrSubstNo(FailedToLoadTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID", GetLastErrorText(true)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
            Session.LogMessage('0000ECR', StrSubstNo(FailedToLoadTemplateAllTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', WordTemplatesCategoryTxt);
            Error(FailedToLoadTemplateErr);
        end;
    end;

    [TryFunction]
    local procedure TryMailMergeLoadDocument(var TemplateInstream: InStream)
    var
        MailMergeField: Text;
    begin
        MailMerge := MailMerge.MailMerge();
        MailMerge.LoadDocument(TemplateInStream);

        foreach MailMergeField in MailMerge.GetMergeFields() do
            MergeFields.Add(MailMergeField);
    end;

    procedure Merge(Data: Dictionary of [Text, Text]; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
    var
        Output: OutStream;
        Success: Boolean;
    begin
        Clear(Result);
        MultipleDocuments := SplitDocument;
        Result.CreateOutStream(Output, TextEncoding::UTF8);
        ChosenFormat := SaveFormat;

        Success := TryMailMergeExecute(Data, SaveFormat, Output);

        if Success then
            Session.LogMessage('0000ECS', StrSubstNo(AppliedTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt)
        else begin
            Session.LogMessage('0000ECT', StrSubstNo(FailedToApplyTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID", GetLastErrorText(true)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
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
        Output: OutStream;
        Success: Boolean;
    begin
        Clear(Result);
        MultipleDocuments := SplitDocument;
        Result.CreateOutStream(Output, TextEncoding::UTF8);
        ChosenFormat := SaveFormat;

        Success := TryMailMergeExecute(Data, SaveFormat, Output);

        if Success then
            Session.LogMessage('0000ECV', StrSubstNo(AppliedTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt)
        else begin
            Session.LogMessage('0000ECW', StrSubstNo(FailedToApplyTemplateTxt, WordTemplate.SystemId, WordTemplate."Table ID", GetLastErrorText(true)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
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

        Clear(Result);
        Result.CreateOutStream(OutStream, TextEncoding::UTF8);
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
        AllowedTable: Record "Word Templates Table";
        TableMetadata: Record "Table Metadata";
    begin
        if not TableMetadata.Get(TableId) then
            exit;
        AllowedTable."Table ID" := TableId;
        if AllowedTable.Insert() then;
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

    local procedure ReloadWordTemplate()
    var
        Instream: Instream;
    begin
        Template.CreateInStream(Instream, TextEncoding::UTF8);
        MailMerge := MailMerge.MailMerge();
        MailMerge.LoadDocument(Instream);
    end;

    internal procedure InsertWordTemplate(var WordTemplate: Record "Word Template")
    begin
        WordTemplate.Insert();
    end;

    local procedure GetMergeFieldsForRecord(TableId: Integer; var MailMergeFields: List of [Text])
    var
        FieldRec: Record Field;
    begin
        Clear(MailMergeFields);
        FieldRec.SetRange(TableNo, TableId);
        FieldRec.SetFilter(Class, '<>%1', FieldRec.Class::FlowFilter);
        FieldRec.SetFilter(Type, '<>%1&<>%2&<>%3&<>%4&<>%5', FieldRec.Type::BLOB,
                                                             FieldRec.Type::Media,
                                                             FieldRec.Type::MediaSet,
                                                             FieldRec.Type::RecordID,
                                                             FieldRec.Type::TableFilter);
        if FieldRec.FindSet() then
            repeat
                MailMergeFields.Add(FieldRec."Field Caption");
            until FieldRec.Next() = 0;
    end;

    local procedure WriteDataStream(RecordRef: RecordRef; OutStream: OutStream; WriteNames: Boolean)
    var
        FieldRef: FieldRef;
        Field: Integer;
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
                if WriteNames then
                    OutStream.WriteText(FieldRef.Caption())
                else
                    OutStream.WriteText(Format(FieldRef.Value()));
                if Field < RecordRef.FieldCount() then
                    OutStream.WriteText('|');
            end;
        end;
        OutStream.WriteText();
    end;

    local procedure WriteDataDict(RecordRef: RecordRef; var Data: Dictionary of [Text, Text])
    var
        FieldRef: FieldRef;
        Field: Integer;
    begin
        Clear(Data);
        for Field := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(Field);
            if (FieldRef.Class <> FieldClass::FlowFilter) and not (FieldRef.Type in [FieldRef.Type::Blob,
                                                                                     FieldRef.Type::MediaSet,
                                                                                     FieldRef.Type::TableFilter,
                                                                                     FieldRef.Type::Media,
                                                                                     FieldRef.Type::RecordId]) then begin
                if FieldRef.Class = FieldClass::FlowField then
                    FieldRef.CalcField();
                Data.Set(FieldRef.Caption(), Format(FieldRef.Value()));
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

    [EventSubscriber(ObjectType::Page, Page::"Word Template Creation Wizard", 'OnSetTableNo', '', false, false)]
    local procedure OnSetTableNo(Value: Integer)
    begin
        Session.LogMessage('0000ECY', StrSubstNo(TableNoSetExternallyTxt, Value), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Word Template", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertWordTemplate(var Rec: Record "Word Template")
    begin
        Session.LogMessage('0000ECZ', StrSubstNo(CreatedTemplateTxt, Rec.SystemId, Rec."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Word Template", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteWordTemplate(var Rec: Record "Word Template")
    begin
        Session.LogMessage('0000ED0', StrSubstNo(DeletedTemplateTxt, Rec.SystemId, Rec."Table ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WordTemplatesCategoryTxt);
    end;

    var
        WordTemplate: Record "Word Template";
        Result: Codeunit "Temp Blob";
        Template: Codeunit "Temp Blob";
        ZipFile: Codeunit "Temp Blob";
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
        FilenamePatternTxt: Label '%1.%2', Locked = true;
        EmptyTemplateNamePatternTxt: Label '%1.%2', Locked = true;
        TemplateNamePatternTxt: Label '%1_%2.%3', Locked = true;
        ReservedCharsTok: Label '<|>|:|\/|\\|\||\?|\*|\"', Locked = true;
        WordTemplatesCategoryTxt: Label 'AL Word Templates', Locked = true;
        DownloadedTemplateTxt: Label 'Template downloaded: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        UploadedTemplateTxt: Label 'Template uploaded: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        CreatedTemplateTxt: Label 'Template created: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        DeletedTemplateTxt: Label 'Template deleted: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        LoadedTemplateTxt: Label 'Template loaded: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        AppliedTemplateTxt: Label 'Template applied: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
        TableNoSetExternallyTxt: Label 'Table no. of Word Template Creation Wizard set externally: %1.', Comment = '%1 - Table ID', Locked = true;
        FailedToApplyTemplateTxt: Label 'Failed to apply template %1 (%2) with error: %3.', Comment = '%1 - System ID, %2 - Table ID, %3 - Error', Locked = true;
        FailedToApplyTemplateAllTxt: Label 'Failed to apply template: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID, %3 - Error', Locked = true;
        FailedToLoadTemplateTxt: Label 'Failed to load template: %1 (%2) with error: %3.', Comment = '%1 - System ID, %2 - Table ID, %3 - Error', Locked = true;
        FailedToLoadTemplateAllTxt: Label 'Failed to load template: %1 (%2).', Comment = '%1 - System ID, %2 - Table ID', Locked = true;
}