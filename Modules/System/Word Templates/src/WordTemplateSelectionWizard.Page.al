// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

using System.Integration;
using System.Utilities;

/// <summary>
/// A wizard to select a Word template and apply it for a record.
/// </summary>
page 9996 "Word Template Selection Wizard"
{
    PageType = NavigatePage;
    Caption = 'Apply Word Template';
    SourceTable = "Word Template";
    Permissions = tabledata "Word Template" = rm;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(WordTemplatesDontExist)
            {
                Visible = not WordTemplatesExist;
                Caption = 'We could not find any Word templates.';
                InstructionalText = 'Before you can continue you must first create at least one Word template.';
            }

            group(SelectTemplate)
            {
                Visible = (Step = Step::Template) and WordTemplatesExist;

                repeater(Templates)
                {
                    Editable = false;

                    field(Code; Rec.Code)
                    {
                        ApplicationArea = All;
                        Caption = 'Code';
                        ToolTip = 'Specifies the code of the template.';
                        Editable = false;
                    }

                    field(Name; Rec.Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of the template.';
                        Editable = false;
                    }
                    field(TableName; Rec."Table Caption")
                    {
                        ApplicationArea = All;
                        Caption = 'Entity';
                        ToolTip = 'Specifies the entity the template is asscociated with.';
                        Editable = false;
                    }
                }
            }

            group(SelectOutput)
            {
                Visible = Step = Step::Output;

                group(FinalInput)
                {
                    Caption = 'Select setting for the output';
                    InstructionalText = ' ';
                }

                field(Output; SaveFormat)
                {
                    ApplicationArea = All;
                    Caption = 'Output format';
                    ToolTip = 'Specifies the format of the final document.';
                }

                field(SplitDocuments; SplitDocuments)
                {
                    ApplicationArea = All;
                    Visible = not SingleRecordSelected;
                    Caption = 'Split documents';
                    ToolTip = 'Specifies whether one document per record should be created or one document for all Records.';
                }

                group(Edit)
                {
                    ShowCaption = false;
                    Visible = ShowEditDocument;

                    field(EditHelp; EditLbl)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Tooltip for editing..';
                        MultiLine = true;
                    }

                    field(EditDocument; EditDocumentTxt)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Caption = ' ';
                        Editable = false;
                        ToolTip = 'Open Word for editing merged document.';

                        trigger OnDrillDown()
                        var
                            WordTemplates: Codeunit "Word Template";
                            InStream: InStream;
                            KeepChanges: Boolean;
                        begin
                            if DocumentDataTempBlob.HasValue() then
                                KeepChanges := Dialog.Confirm(EditEditedDocumentTxt, true);

                            if KeepChanges then begin
                                DocumentDataTempBlob.CreateInStream(InStream);
                                WordTemplates.Load(InStream);
                            end else
                                WordTemplates.Load(Rec.Code);
                            WordTemplates.Merge(DataVariant, SplitDocuments, Enum::"Word Templates Save Format"::Docx, true);

                            DocumentDataTempBlob.CreateOutStream(DocumentOutStream);
                            WordTemplates.GetDocument(InStream);
                            CopyStream(DocumentOutStream, InStream);

                            if DocumentDataTempBlob.HasValue() then
                                EditDocumentTxt := EditedDocumentLbl;
                        end;
                    }
                }

                group(Filters)
                {
                    ShowCaption = false;
                    Visible = not FiltersSet;

                    field(FilterHelp; FilterHelpLbl)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Tooltip for filter..';
                        MultiLine = true;
                    }

                    field(SetFilters; SetFiltersLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Caption = ' ';
                        ToolTip = 'Select filters on the entity';

                        trigger OnDrillDown()
                        var
                            WordTemplatesImpl: Codeunit "Word Template Impl.";
                            RecordRef: RecordRef;
                        begin
                            RecordRef.GetTable(DataVariant);
                            WordTemplatesImpl.SetFiltersOnRecord(RecordRef);
                            DataVariant := RecordRef;

                            Filters := RecordRef.GetFilters().Replace(', ', '\');
                            CurrPage.Update();
                        end;
                    }

                    group(FilterDetails)
                    {
                        Visible = Filters <> '';
                        ShowCaption = false;

                        field(FiltersDetails; Filters)
                        {
                            ApplicationArea = All;
                            Caption = 'Filters';
                            ToolTip = 'Specifies the filters to be applied on the record.';
                            Editable = false;
                            MultiLine = true;
                        }
                    }

                    group(NoFilterDetails)
                    {
                        Visible = Filters = '';
                        ShowCaption = false;

                        label(NoFiltersSet)
                        {
                            ApplicationArea = All;
                            Caption = 'No filter are set on the entity.';
                            Style = AttentionAccent;
                        }
                    }
                }
            }
            group(Overview)
            {
                Visible = Step = Step::Overview;
                group(TheEnd)
                {
                    Caption = 'Overview';
                    InstructionalText = 'Review your selections, and update them if needed. Click Finish to download the document.';
                }

                field(RecordName; RecordName)
                {
                    ApplicationArea = All;
                    Caption = 'Entity';
                    ToolTip = 'Specifies the entity to be used when applying the template.';
                    Editable = false;
                }
                field(FiltersOverview; Filters)
                {
                    ApplicationArea = All;
                    Visible = (not SingleRecordSelected) and (Filters <> '');
                    Caption = 'Filters';
                    ToolTip = 'Specifies the filters to be applied on the record.';
                    Editable = false;
                    MultiLine = true;
                }
                field(NumberOfRecords; Format(NumberOfRecords))
                {
                    ApplicationArea = All;
                    Caption = 'No. of Entities';
                    ToolTip = 'Specifies how many entities the template will be applied to.';
                    Editable = false;
                }

                field(TemplateCodeOverview; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Template Code';
                    ToolTip = 'Specifies code of the template to apply.';
                    Editable = false;
                }
                field(TemplateOverview; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Template Name';
                    ToolTip = 'Specifies the name of the template to apply.';
                    Editable = false;
                }
                field(OutputOverview; SaveFormat)
                {
                    ApplicationArea = All;
                    Caption = 'Output format';
                    ToolTip = 'Specifies the format of the final document.';
                    Editable = false;
                }
                field(SplitDocumentsOverview; SplitDocuments)
                {
                    ApplicationArea = All;
                    Visible = not SingleRecordSelected;
                    Caption = 'Split documents';
                    ToolTip = 'Specifies whether one document per record should be created or one document for all entities.';
                    Editable = false;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Finish)
            {
                ApplicationArea = All;
                Visible = (Step = Step::Overview) or (not FromUnknownSource and SkipOverview);
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = ' ';

                trigger OnAction()
                var
                    WordTemplates: Codeunit "Word Template";
                begin
                    MergeTemplate(WordTemplates);

                    if not AsDocumentStream then
                        WordTemplates.DownloadDocument();

                    FinishedWizard := true;
                    CurrPage.Close();
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Visible = (Step <> Step::Overview) and ((FromUnknownSource) or (not FromUnknownSource and not SkipOverview));
                Enabled = WordTemplatesExist;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = ' ';

                trigger OnAction()
                var
                    RecordRef: RecordRef;
                    FieldRef: FieldRef;
                    SystemIdFilter: Text;
                begin
                    if Step = Step::Template then begin
                        if not DataIntialized then
                            if WithBusinessContactRelation then begin
                                DictOfRecords.Get(Rec."Table ID", SystemIdFilter);
                                RecordRef.Open(Rec."Table ID");
                                FieldRef := RecordRef.Field(RecordRef.SystemIdNo());
                                FieldRef.SetFilter(SystemIdFilter);
                                DataVariant := RecordRef;
                                DataIntialized := true;
                            end else begin
                                RecordRef.Open(Rec."Table ID");
                                DataVariant := RecordRef;
                            end;

                        RecordRef := DataVariant;
                        NumberOfRecords := RecordRef.Count();
                        RecordName := RecordRef.Caption();
                        SkipOverview := NumberOfRecords = 1;
                        Step := Step::Output;
                        exit;
                    end;

                    if Step = Step::Output then begin
                        RecordRef := DataVariant;
                        NumberOfRecords := RecordRef.Count();
                        RecordName := RecordRef.Caption();

                        // If user do not know the known source, then always show overview.
                        // Otherwise, only show overview when there are multiple records.
                        if (FromUnknownSource) or (not FromUnknownSource and not SkipOverview) then
                            Step := Step::Overview;

                        exit;
                    end;
                end;
            }
            action(Back)
            {
                ApplicationArea = All;
                Visible = Step <> Step::Template;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = ' ';

                trigger OnAction()
                begin
                    SkipOverview := false;
                    if Step = Step::Output then begin
                        Step := Step::Template;
                        exit;
                    end;

                    if Step = Step::Overview then begin
                        Step := Step::Output;
                        exit;
                    end
                end;
            }
            action(New)
            {
                ApplicationArea = All;
                Caption = 'New Template';
                ToolTip = 'Create a new Word template';
                Image = New;
                InFooterBar = true;
                Visible = Step = Step::Template;


                trigger OnAction()
                var
                    WordTemplatesCreationWizard: Page "Word Template Creation Wizard";
                begin
                    if TableId <> 0 then
                        WordTemplatesCreationWizard.SetTableNo(TableId);

                    WordTemplatesCreationWizard.RunModal();

                    WordTemplatesExist := not Rec.IsEmpty();
                    CurrPage.Update(true);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Table Caption");
    end;

    trigger OnOpenPage()
    var
        DocumentSharing: Codeunit "Document Sharing";
    begin
        SaveFormat := SaveFormat::Docx;
        WordTemplatesExist := not Rec.IsEmpty();
        FinishedWizard := false;
        SkipOverview := false;
        FromUnknownSource := false;
        EditDocumentTxt := EditDocumentLbl;
        ShowEditDocument := DocumentSharing.ShareEnabled(Enum::"Document Sharing Source"::System);
    end;

    procedure IsDocSaveFormat(): Boolean
    begin
        exit((SaveFormat::Doc = SaveFormat) or (SaveFormat::Docx = SaveFormat));
    end;

    protected procedure MergeTemplate(var WordTemplates: Codeunit "Word Template")
    var
        TempBlob: Codeunit "Temp Blob";
        Data: Dictionary of [Text, Text];
        InStream: InStream;
        OutStream: OutStream;
    begin
        if DocumentDataTempBlob.Length() <> 0 then begin
            DocumentDataTempBlob.CreateInStream(InStream);
            TempBlob.CreateOutStream(OutStream);
            CopyStream(OutStream, InStream);
            TempBlob.CreateInStream(InStream);
            WordTemplates.Load(InStream);
            WordTemplates.Merge(Data, SaveFormat);
            DocumentDataTempBlob.CreateOutStream(OutStream);
            WordTemplates.GetDocument(InStream);
            CopyStream(OutStream, InStream);
        end else begin
            WordTemplates.Load(Rec.Code);
            WordTemplates.Merge(DataVariant, SplitDocuments, SaveFormat, false);
            DocumentDataTempBlob.CreateOutStream(OutStream);
            WordTemplates.GetDocument(InStream);
            CopyStream(OutStream, InStream);
        end;
    end;

    /// <summary>
    /// Sets the template to apply. If not set, the user will be prompted to choose a template as part of the wizard.
    /// </summary>
    /// <param name="WordTemplate">The template to set.</param>
    procedure SetTemplate(WordTemplate: Record "Word Template")
    var
        WordTemplates: Codeunit "Word Template";
        RecordRef: RecordRef;
    begin
        Rec := WordTemplate;

        // Reloading the template in order to get the table ID. It might be the case that the related table is no longer present.
        WordTemplates.Load(WordTemplate.Code);
        TableId := WordTemplates.GetTableId();

        if TableId = 0 then
            Error(NoSourceRecordErr);

        RecordRef.Open(TableId);
        DataVariant := RecordRef;
        DataIntialized := true;

        Step := Step::Output;
    end;

    /// <summary>
    /// Sets the record to be used when applying the template.
    /// </summary>
    /// <param name="RecordVariant">The record to set.</param>
    procedure SetData(RecordVariant: Variant)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(RecordVariant);
        DataVariant := RecordRef;
        TableId := RecordRef.Number();

        SingleRecordSelected := RecordRef.Count() = 1;
        DataIntialized := true;
        FiltersSet := true;
        WithBusinessContactRelation := false;

        Rec.SetRange("Table ID", TableId);
    end;

    /// <summary>
    /// Set the entities that user can select to create the word template
    /// </summary>
    /// <param name="Dict">Dictionary of TableId to SystemId filters.</param>
    internal procedure SetData(Dict: Dictionary of [Integer, Text])
    var
        I: Integer;
        FilterBuilder: TextBuilder;
    begin
        for I := 1 to Dict.Count() do begin
            FilterBuilder.Append(Format(Dict.Keys().Get(I)));
            if I <> Dict.Count() then
                FilterBuilder.Append('|');
        end;
        DictOfRecords := Dict;
        DataIntialized := false;
        SingleRecordSelected := true;
        WithBusinessContactRelation := true;

        Rec.SetFilter("Table ID", FilterBuilder.ToText());
    end;

    /// <summary>
    /// Get the document format.
    /// </summary>
    /// <returns>The format as a text.</returns>
    internal procedure GetDocumentFormat(): Text;
    begin
        exit(Text.LowerCase(Format(SaveFormat)));
    end;

    /// <summary>
    /// Get the word template stored in the Blob.
    /// </summary>
    /// <param name="InStream">Stream that will contain the word template.</param>
    internal procedure GetDocumentStream(var InStream: InStream)
    begin
        DocumentDataTempBlob.CreateInStream(InStream);
    end;

    /// <summary>
    /// Save the word template into a Blob, that can then be retrived by a stream.
    /// </summary>
    internal procedure SaveAsDocumentStream()
    begin
        AsDocumentStream := true;
    end;

    /// <summary>
    /// Returns if the user completed the dialog to add a word template.
    /// </summary>
    /// <returns>True if completed otherwise false.</returns>
    internal procedure WasDialogCompleted(): Boolean
    begin
        exit(FinishedWizard);
    end;

    /// <summary>
    /// Ensures that user is presented with the overview tab if the wizard is run without a source record.
    /// </summary>
    internal procedure SetIsUnknownSource()
    begin
        FromUnknownSource := true;
    end;

    var
        DocumentDataTempBlob: Codeunit "Temp Blob";
        DocumentOutStream: OutStream;
        DataVariant: Variant;
        DictOfRecords: Dictionary of [Integer, Text];
        DataIntialized, FiltersSet, SingleRecordSelected : Boolean;
        WordTemplatesExist: Boolean;
        TableId: Integer;
        Filters, RecordName : Text;
        NumberOfRecords: Integer;
        SaveFormat: Enum "Word Templates Save Format";
        Step: Option Template,Output,Overview;
        SplitDocuments: Boolean;
        AsDocumentStream: Boolean;
        WithBusinessContactRelation: Boolean;
        SkipOverview: Boolean;
        FromUnknownSource: Boolean;
        ShowEditDocument: Boolean;
        EditDocumentTxt: Text;
        EditDocumentLbl: Label 'Edit document';
        EditedDocumentLbl: Label 'Edit document (already edited)';
        EditEditedDocumentTxt: Label 'Do you want to keep the changes made earlier?';
        NoSourceRecordErr: Label 'This template is not associated with an entity and hence it can only be applied programmatically.';
        SetFiltersLbl: Label 'Set filters';
        EditLbl: Label 'You can edit the document created from the Word template to provide a custom message. After editing the document, you must save and close it before returning here to continue.';
        FilterHelpLbl: Label 'You can define a filter to choose which rows get a template associated.';

    protected var
        FinishedWizard: Boolean;
}
