// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Wizard to create a Word template.
/// </summary>
page 9995 "Word Template Creation Wizard"
{
    PageType = NavigatePage;
    SourceTable = "Word Templates Table";
    Caption = 'Create a Word Template';
    Permissions = tabledata "Word Template" = rm,
                  tabledata "Word Templates Table" = rm,
                  tabledata "Word Templates Related Table" = i,
                  tabledata AllObjWithCaption = r;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(TableSelection)
            {
                Visible = Step = Step::Select;

                label(SelectEntity)
                {
                    ApplicationArea = All;
                    Caption = 'Choose the source of the data for the template.';
                }

                field(AddNewEntity; AddNewEntityLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Editable = false;
                    Visible = TableFilterExpression = '';

                    trigger OnDrillDown()
                    var
                        WordTemplateImpl: Codeunit "Word Template Impl.";
                        TableId: Integer;
                    begin
                        TableId := WordTemplateImpl.AddTable();
                        if TableId <> 0 then begin
                            Rec.Get(TableId);
                            CurrPage.Update(false);
                        end;
                    end;
                }

                repeater(Tables)
                {
                    Editable = false;
                    field(Name; Rec."Table Caption")
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of the data source from which the template will get data.';
                        Editable = false;
                    }
                }
            }

            group(RelatedTableSelection)
            {
                Visible = Step = Step::SelectRelated;

                label(SelectRelatedEntity)
                {
                    ApplicationArea = All;
                    Caption = 'You can also merge data from fields on entities that are related to the source entity. For example, if the source is the Customer entity, your template can include data from the Salesperson/Purchaser entity.​';
                }

                label(RelatedEntityOptions)
                {
                    ApplicationArea = All;
                    Caption = 'Related entities share a field, typically an identifier such as its name, code, or ID, with the source entity. Predefined relations are available in the simple option. To define a relation, if you know the shared field, use the advanced option.​';
                }

                field(AddRelatedEntity; AddRelatedEntityLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Currpage.RelatedTables.Page.AddRelatedTable(WordTemplate."Table ID", true);
                    end;
                }

                field(AddRelatedEntityAdvanced; AddRelatedEntityAdvancedLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Currpage.RelatedTables.Page.AddRelatedTable(WordTemplate."Table ID", false);
                    end;
                }

                part(RelatedTables; "Word Templates Related Part")
                {
                    ApplicationArea = All;
                }
            }

            group(DownloadSection)
            {
                Visible = Step = Step::Download;

                group(DowloandInstructions)
                {
                    Caption = 'Download an empty template';
                    InstructionalText = 'Download a ZIP file that contains a Word document and a data source file. Right-click the ZIP file and choose Extract All. Before you open the Word document, make sure that no other documents are open in Word. The fields you can use in the template are available on the Mailings tab in Word.';
                }

                field(Download; DowloadTemplateLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        WordTemplates: Codeunit "Word Template";
                        RelatedTableIds: List of [Integer];
                        RelatedTableCodes: List of [Code[5]];
                    begin
                        if WordTemplate."Table ID" = 0 then
                            WordTemplate."Table ID" := Rec."Table ID";

                        CurrPage.RelatedTables.Page.GetRelatedTables(RelatedTableIds, RelatedTableCodes);

                        if RelatedTableIds.Count = 0 then
                            WordTemplates.Create(WordTemplate."Table ID")
                        else
                            WordTemplates.Create(WordTemplate."Table ID", RelatedTableIds, RelatedTableCodes);

                        WordTemplates.DownloadTemplate();
                    end;
                }

                field(LearnMore; LearnMoreLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Hyperlink(LearnMoreUrlTxt);
                    end;
                }
            }

            group(UploadSection)
            {
                Visible = Step = Step::Upload;

                group(UploadInstructions)
                {
                    Caption = 'Upload a template';
                    InstructionalText = 'Upload a template file using the link below.';
                }

                field(Upload; UploadTemplateLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        WordTemplateImpl: Codeunit "Word Template Impl.";
                    begin
                        if WordTemplateImpl.Upload(WordTemplate, UploadedFileName) then
                            TemplateUploaded := true;

                        WordTemplate.CalcFields("Table Caption");
                        CurrPage.Update();
                    end;
                }

                group(UploadDetails)
                {
                    Visible = TemplateUploaded;
                    ShowCaption = false;

                    field(FileName; UploadedFileName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Uploaded file';
                        ToolTip = 'The name of the file that was uploaded.';
                    }

                    field(TemplateEntity; WordTemplate."Table Caption")
                    {
                        ApplicationArea = All;
                        Caption = 'Entity';
                        ToolTip = 'Specifies the entity used in the template in the uploaded file.';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            WordTemplateImpl: Codeunit "Word Template Impl.";
                            TableId: Integer;
                        begin
                            TableID := WordTemplateImpl.SelectTable();

                            if TableId <> 0 then begin
                                WordTemplate."Table ID" := TableId;
                                WordTemplate.CalcFields("Table Caption");
                                CurrPage.Update();
                            end;
                        end;
                    }


                }

                group(NoUploadDetails)
                {
                    Visible = not TemplateUploaded;
                    ShowCaption = false;

                    label(NoFileUploaded)
                    {
                        ApplicationArea = All;
                        Caption = 'No template has been uploaded yet.';
                        Style = AttentionAccent;
                    }
                }
            }

            group(DetailsSection)
            {
                Visible = Step = Step::Details;

                group(AlmostThere)
                {
                    Caption = 'Almost there!';
                    InstructionalText = 'Give the template a name, and then upload it. Choose Finish when you''re done.';
                }

                field(TemplateCode; WordTemplate.Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Caption = 'Code';
                    ToolTip = 'Specifies the code of the template.';

                    trigger OnValidate()
                    var
                        WordTemplateRec: Record "Word Template";
                    begin
                        if WordTemplateRec.Get(WordTemplate.Code) then
                            Error(CodeAlreadyUsedErr)
                    end;
                }

                field(TemplateName; WordTemplate.Name)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the template.';
                }

                field(TemplateLanguage; WordTemplate."Language Name")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Caption = 'Language';
                    ToolTip = 'Specifies the language of the template.';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        Language: Codeunit Language;
                    begin
                        Language.LookupLanguageCode(WordTemplate."Language Code");

                        WordTemplate.CalcFields("Language Name");
                        CurrPage.Update();
                    end;
                }
            }

            group(OverviewSection)
            {
                Visible = Step = Step::Overview;

                group(Overview)
                {
                    Caption = 'Overview';
                    InstructionalText = 'Please review the template details, go back to previous pages in case you want to edit them. Click Finish to create the template.';
                }

                field(TemplateCodeOverview; WordTemplate.Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Code';
                    ToolTip = 'Specifies the code of the template.';
                }

                field(TemplateNameOverview; WordTemplate.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the template.';
                }

                field(TemplateLanguageOverview; WordTemplate."Language Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Language';
                    ToolTip = 'Specifies the language of the template.';
                }

                field(TempalteTableOverview; WordTemplate."Table Caption")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Entity';
                    ToolTip = 'Specifies the entity of the template.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Back)
            {
                ApplicationArea = All;
                Image = PreviousRecord;
                Visible = Step <> Step::Select;
                InFooterBar = true;

                trigger OnAction()
                begin
                    case Step of
                        Step::SelectRelated:
                            Step := Step::Select;
                        Step::Download:
                            Step := Step::SelectRelated;
                        Step::Upload:
                            if TableSetSkipped then
                                Step := Step::Select
                            else
                                Step := Step::Download;
                        Step::Details:
                            Step := Step::Upload;
                        Step::Overview:
                            Step := Step::Details;
                    end;
                end;
            }

            action(Next)
            {
                ApplicationArea = All;
                Image = NextRecord;
                Visible = Step <> Step::Overview;
                InFooterBar = true;

                trigger OnAction()
                begin
                    case Step of
                        Step::Select:
                            begin
                                if Rec."Table ID" = 0 then
                                    Error(MissingEntityErr);

                                TableSetSkipped := false;
                                WordTemplate."Table ID" := Rec."Table ID";
                                CurrPage.RelatedTables.Page.SetTableNo(WordTemplate."Table ID");
                                Step := Step::SelectRelated;
                            end;
                        Step::SelectRelated:
                            Step := Step::Download;
                        Step::Download:
                            begin
                                WordTemplate.CalcFields("Table Caption");
                                Step := Step::Upload;
                            end;
                        Step::Upload:
                            begin
                                if not TemplateUploaded then
                                    Error(TemplateNotUploadedErr);

                                SetDefaultWordTemplateLanguageCode();
                                Step := Step::Details;
                            end;
                        Step::Details:
                            begin
                                if (WordTemplate.Code = '') or (WordTemplate.Name = '') or (WordTemplate."Language Code" = '') then
                                    Error(MissingDetailsErr);

                                Step := Step::Overview;
                            end;
                    end;
                end;
            }

            action(Skip)
            {
                ApplicationArea = All;
                Image = Stop;
                Visible = Step = Step::Download;
                InFooterBar = true;

                trigger OnAction()
                begin
                    WordTemplate.CalcFields("Table Caption");
                    Step := Step::Upload;
                end;
            }

            action(Finish)
            {
                ApplicationArea = All;
                Image = NextRecord;
                Visible = Step = Step::Overview;
                InFooterBar = true;

                trigger OnAction()
                var
                    RelatedTables: Record "Word Templates Related Table";
                    TempRelatedTables: Record "Word Templates Related Table" temporary;
                    WordTemplateImpl: Codeunit "Word Template Impl.";
                begin
                    WordTemplateImpl.InsertWordTemplate(WordTemplate);

                    if TableSetExternally and not WordTemplateImpl.AllowedTableExist(WordTemplate."Table ID") then
                        WordTemplateImpl.AddTable(WordTemplate."Table ID");

                    // Add related tables
                    CurrPage.RelatedTables.Page.GetRelatedTables(TempRelatedTables);
                    if TempRelatedTables.Findset() then
                        repeat
                            RelatedTables.TransferFields(TempRelatedTables);
                            RelatedTables.Code := WordTemplate.Code;
                            RelatedTables.Insert();
                        until TempRelatedTables.Next() = 0;

                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000FW1', 'Word templates', Enum::"Feature Uptake Status"::Discovered);

        if WordTemplate."Table ID" <> 0 then begin
            Rec.SetFilter("Table ID", TableFilterExpression);
            Rec.Get(WordTemplate."Table ID");
            CurrPage.Update(false);
        end;
    end;

    procedure SetMultipleTableNo(TableIds: List of [Integer]; SelectedTable: Integer)
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
        I: Integer;
        FilterBuilder: TextBuilder;
    begin
        TableSetExternally := true;
        for I := 1 to TableIds.Count() do begin
            WordTemplateImpl.AddTable(TableIds.Get(I));
            FilterBuilder.Append(Format(TableIds.Get(I)));
            if I <> TableIds.Count() then
                FilterBuilder.Append('|');
        end;
        OnSetTableNo(SelectedTable);
        // As this method populates the page, before it is run, 
        // we commit to make sure that database transactions are done.
        Commit();

        TableFilterExpression := FilterBuilder.ToText();
        WordTemplate."Table ID" := SelectedTable;
    end;

    procedure SetTableNo(Value: Integer)
    var
        TableNos: List of [Integer];
    begin
        TableNos.Add(Value);
        SetMultipleTableNo(TableNos, Value);
    end;

    procedure SetRelatedTable(RelatedTableId: Integer; FieldNo: Integer; RelatedCode: Code[5])
    begin
        CurrPage.RelatedTables.Page.SetRelatedTable(WordTemplate."Table ID", RelatedTableId, FieldNo, RelatedCode);
    end;

    local procedure SetDefaultWordTemplateLanguageCode()
    var
        Language: Codeunit Language;
    begin
        // Don't set the language if it is already set.
        if WordTemplate."Language Code" <> '' then
            exit;

        WordTemplate."Language Code" := Language.GetUserLanguageCode();
        WordTemplate.CalcFields("Language Name");
        CurrPage.Update();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetTableNo(Value: Integer)
    begin
    end;

    var
        WordTemplate: Record "Word Template";
        UploadedFileName, TableFilterExpression : Text;
        TableSetExternally, TableSetSkipped : Boolean;
        TemplateUploaded: Boolean;
        AddNewEntityLbl: Label 'Add new entity';
        AddRelatedEntityLbl: Label 'Add a related entity (simple)';
        AddRelatedEntityAdvancedLbl: Label 'Add a related entity (advanced)';
        DowloadTemplateLbl: Label 'Download a blank template.';
        UploadTemplateLbl: Label 'Upload the template';
        LearnMoreLbl: Label 'Learn more';
        LearnMoreUrlTxt: Label 'https://www.microsoft.com';
        MissingDetailsErr: Label 'Please fill in all fields before continuing.';
        MissingEntityErr: Label 'Please select an entity before continuing.';
        TemplateNotUploadedErr: Label 'Please upload a template before continuing.';
        CodeAlreadyUsedErr: Label 'A template with this code already exists.';
        Step: Option Select,SelectRelated,Download,Upload,Details,Overview;
}
