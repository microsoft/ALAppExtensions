// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                    Caption = 'Few more things left!';
                    InstructionalText = 'Select settings of the output.';
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

                group(Filters)
                {
                    ShowCaption = false;
                    Visible = not FiltersSet;

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
                            RecordRef.GetTable(Data);
                            WordTemplatesImpl.SetFiltersOnRecord(RecordRef);
                            Data := RecordRef;

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
                Visible = Step = Step::Overview;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = ' ';

                trigger OnAction()
                var
                    WordTemplates: Codeunit "Word Template";
                begin
                    WordTemplates.Load(Rec.Code);
                    WordTemplates.Merge(Data, SplitDocuments, SaveFormat);
                    WordTemplates.DownloadDocument();
                    CurrPage.Close();
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Visible = Step <> Step::Overview;
                Enabled = WordTemplatesExist;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = ' ';

                trigger OnAction()
                var
                    RecordRef: RecordRef;
                begin
                    if Step = Step::Template then begin
                        if not DataIntialized then begin
                            RecordRef.Open(Rec."Table ID");
                            Data := RecordRef;
                        end;
                        Step := Step::Output;
                        exit;
                    end;

                    if Step = Step::Output then begin
                        RecordRef := Data;
                        NumberOfRecords := RecordRef.Count();
                        RecordName := RecordRef.Caption();

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
    begin
        SaveFormat := SaveFormat::Docx;
        WordTemplatesExist := not Rec.IsEmpty();
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
        Data := RecordRef;
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
        Data := RecordRef;
        TableId := RecordRef.Number();

        SingleRecordSelected := RecordRef.Count() = 1;
        DataIntialized := true;
        FiltersSet := true;

        Rec.SetRange("Table ID", TableId);
    end;

    var
        Data: Variant;
        DataIntialized, FiltersSet, SingleRecordSelected : Boolean;
        WordTemplatesExist: Boolean;
        TableId: Integer;
        Filters, RecordName : Text;
        NumberOfRecords: Integer;
        SaveFormat: Enum "Word Templates Save Format";
        Step: Option Template,Output,Overview;
        SplitDocuments: Boolean;
        NoSourceRecordErr: Label 'This template is not associated with an entity and hence it can only be applied programmatically.';
        SetFiltersLbl: Label 'Set filters';
}
