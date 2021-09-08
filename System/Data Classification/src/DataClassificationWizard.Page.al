// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality that allows users to classify their data.
/// </summary>
page 1752 "Data Classification Wizard"
{
    Extensible = true;
    Caption = 'Data Classification Assisted Setup Guide';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Data Privacy Entities";
    SourceTableTemporary = true;
    ContextSensitiveHelpPage = 'admin-classifying-data-sensitivity';

    layout
    {
        area(content)
        {
            group(WelcomePage)
            {
                ShowCaption = false;
                Visible = Step = Step::Welcome;
                group("Welcome to the Data Classification Assisted Setup Guide")
                {
                    Caption = 'Welcome to the Data Classification Assisted Setup Guide';
                    InstructionalText = 'Data classification is an important part of protecting the privacy of personal and sensitive data, and is often required by data privacy laws. Classification can make it easier to retrieve personal data, for example, in response to a request, and it can add another layer of protection. This guide helps you classify the sensitivity of the data in tables and fields. ';
                }
                group("Classifications include:")
                {
                    Caption = 'Classifications include:';
                    //The GridLayout property is only supported on controls of type Grid
                    //GridLayout = Rows;
                    label("- Sensitive - Private data, such as political or religious beliefs.")
                    {
                        ApplicationArea = All;
                        Caption = '- Sensitive - Private data, such as political or religious beliefs.';
                    }
                    label("- Personal - Any data that can be used to identify someone.")
                    {
                        ApplicationArea = All;
                        Caption = '- Personal - Any data that can be used to identify someone.';
                    }
                    label("- Company Confidential - Business data that you do not want to expose. For example, ledger entries.")
                    {
                        ApplicationArea = All;
                        Caption = '- Company Confidential - Business data that you do not want to expose. For example, ledger entries.';
                    }
                    label("- Normal - Data that does not belong to other classifications.")
                    {
                        ApplicationArea = All;
                        Caption = '- Normal - Data that does not belong to other classifications.';
                    }
                }
                group("Legal disclaimer")
                {
                    Caption = 'Legal disclaimer';
                    InstructionalText = 'Microsoft is providing this Data Classification feature as a matter of convenience only. It''s your responsibility to classify the data appropriately and comply with any laws and regulations that are applicable to you. Microsoft disclaims all responsibility towards any claims related to your classification of the data.';
                }
                field(HelpLbl; LearnMoreTok)
                {
                    ApplicationArea = All;
                    Caption = 'Learn more';
                    ToolTip = 'Click here to learn more.';
                    DrillDown = true;
                    Editable = false;
                    ShowCaption = false;
                    Style = StandardAccent;
                    StyleExpr = TRUE;

                    trigger OnDrillDown()
                    begin
                        HyperLink(HelpUrlTxt);
                    end;
                }
            }
            group(ChooseModePage)
            {
                ShowCaption = false;
                Visible = Step = Step::"Choose Mode";
                group("Let's Get Started")
                {
                    Caption = 'Let''s Get Started';
                    InstructionalText = 'You can export data to an Excel worksheet, specify classifications for unclassified fields, and then import the worksheet. For example, this is great for:';
                    label("- Adding classifications in bulk.")
                    {
                        ApplicationArea = All;
                        Caption = '- Classifying data in bulk.';
                        Importance = Additional;
                        MultiLine = true;
                    }
                    label("- Sharing data with a partner who is classifying data for you.")
                    {
                        ApplicationArea = All;
                        Caption = '- Sharing data with a partner who is classifying data for you.';
                    }
                    label("- Importing the classifications from another company.")
                    {
                        ApplicationArea = All;
                        Caption = '- Importing the classifications from another company.';
                    }
                    field("ExportModeSelected"; IsExportModeSelectedValue)
                    {
                        ApplicationArea = All;
                        Caption = 'Export Classification Data to Excel';
                        ToolTip = 'Specifies that you want to export all of your data sensitivity classifications to an Excel worksheet. You can edit the sensitivity settings, and then import the file to apply your changes. You can also use the same worksheet to classify data sensitivities in other companies.';

                        trigger OnValidate()
                        begin
                            if IsExportModeSelected() then begin
                                SetExpertModeSelected(false);
                                SetImportModeSelected(false);
                            end;
                        end;
                    }
                    field(ImportModeSelected; IsImportModeSelectedValue)
                    {
                        ApplicationArea = All;
                        Caption = 'Import Classification Data from Excel';
                        ToolTip = 'Specifies that you want to import and apply data sensitivity classifications from an Excel worksheet.';

                        trigger OnValidate()
                        begin
                            if IsImportModeSelected() then begin
                                SetExpertModeSelected(false);
                                SetExportModeSelected(false);
                            end;
                        end;
                    }
                    group(ExpertModeGroup)
                    {
                        InstructionalText = 'You can also view lists of tables and fields and manually classify your data.';
                        ShowCaption = false;
                        field(ExpertModeSelected; IsExpertModeSelectedValue)
                        {
                            ApplicationArea = All;
                            Caption = 'Classify Data Manually';
                            ToolTip = 'Specifies that you want to classify data sensitivity yourself. If you choose this option, you can specify data sensitivity for individual fields and data subjects. Note that this includes only data related to setups, posting, templates, and data subjects. There are fields that you must classify either in the Classification Worksheet page or in Excel.';

                            trigger OnValidate()
                            begin
                                if IsExpertModeSelected() then begin
                                    SetExportModeSelected(false);
                                    SetImportModeSelected(false);
                                end;
                            end;
                        }
                    }
                }
            }
            group(SetRulesPage)
            {
                ShowCaption = false;
                Visible = Step = Step::"Set Rules";
                group("Bulk-classify data based on its use")
                {
                    Caption = 'Bulk-classify data based on its use';
                    group("Examples:")
                    {
                        Caption = 'Examples:';
                        InstructionalText = 'Data from posting includes G/L entries. Data on templates used to create customers, vendors, or items. Data on setup tables that configure functionality. These classifications apply only to fields that are currently Unclassified. We recommend that you review the fields before you apply the classifications.';
                    }
                    group(Control53)
                    {
                        //The GridLayout property is only supported on controls of type Grid
                        //GridLayout = Columns;
                        ShowCaption = false;
                        field(LedgerEntriesDefaultClassification; LedgerEntriesDefaultClassifications)
                        {
                            ApplicationArea = All;
                            Caption = 'Data from posting is:';
                            ToolTip = 'Specifies the default sensitivity classifications to apply to fields that are related to posting. You can view the fields to classify them individually.';
                            OptionCaption = 'Unclassified,Sensitive,Personal,Company Confidential,Normal';
                        }
                        field(ViewFieldsLbl; ViewFieldsTok)
                        {
                            ApplicationArea = All;
                            ToolTip = 'View a list of fields that are used to post transactions.';
                            DrillDown = true;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = true;

                            trigger OnDrillDown()
                            var
                                DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
                            begin
                                DataClassificationMgtImpl.RunDataClassificationWorksheetForTableWhoseNameContains('Entry');
                            end;
                        }
                        field(TemplatesDefaultClassification; TemplatesDefaultClassifications)
                        {
                            ApplicationArea = All;
                            Caption = 'Data on templates is:';
                            TooltIp = 'Specifies the default sensitivity classifications to apply to templates that are used to create new records, such as customers or items. You can view the fields to classify them individually.';
                            OptionCaption = 'Unclassified,Sensitive,Personal,Company Confidential,Normal';
                        }
                        field(Control38; ViewFieldsTok)
                        {
                            ApplicationArea = All;
                            ToolTip = 'View a list of fields that are used on templates.';
                            DrillDown = true;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = true;

                            trigger OnDrillDown()
                            var
                                DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
                            begin
                                DataClassificationMgtImpl.RunDataClassificationWorksheetForTableWhoseNameContains('Template');
                            end;
                        }
                        field(SetupTablesDefaultClassification; SetupTablesDefaultClassifications)
                        {
                            ApplicationArea = All;
                            Caption = 'Data on setup tables is:';
                            Tooltip = 'Specifies the default sensitivity classifications to apply to data on setup tables that control how you will use features, such as the tables used by the general ledger. You can view the fields to classify them individually.';
                            OptionCaption = 'Unclassified,Sensitive,Personal,Company Confidential,Normal';
                        }
                        field(Control56; ViewFieldsTok)
                        {
                            ApplicationArea = All;
                            ToolTip = 'View a list of fields that are used on setup tables.';
                            DrillDown = true;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = true;

                            trigger OnDrillDown()
                            var
                                DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
                            begin
                                DataClassificationMgtImpl.RunDataClassificationWorksheetForTableWhoseNameContains('Setup');
                            end;
                        }
                    }
                }
            }
            group(ApplyPage)
            {
                ShowCaption = false;
                Visible = Step = Step::Apply;
                group("Choose the tables that you want to classify")
                {
                    Caption = 'Choose the tables that you want to classify';
                    InstructionalText = 'When you classify a table, the classification applies to all fields in the table. You can choose a table to change classifications for individual fields.';
                    label(Control19)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Caption = '';
                    }
                    repeater(Control20)
                    {
                        ShowCaption = false;
                        field(Include; Include)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies whether to apply the classification to the type of data subjects.';
                        }
                        field(Entity; "Table Caption")
                        {
                            ApplicationArea = All;
                            Caption = 'Data Subject';
                            DrillDown = false;
                            Editable = false;
                            ToolTip = 'Specifies the type of data subjects to apply the data classification to.';
                        }
                        field("Default Data Sensitivity"; "Default Data Sensitivity")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the sensitivity classification to apply to the type of data subjects.';
                        }
                    }
                }
            }
            group(VerifyIndividualFieldsPage)
            {
                ShowCaption = false;
                Visible = Step = Step::Verify;
                group("Good work! Now classify individual fields")
                {
                    Caption = 'Good work! Now classify individual fields';
                    InstructionalText = 'The default classification has been added to the tables. Now you can classify individual fields in the tables, and  the entities that relate to the tables. ';
                }
                group("Review the classifications for all the entities before you continue!")
                {
                    Caption = 'Review the classifications for all the entities before you continue!';
                }
                repeater(Control25)
                {
                    ShowCaption = false;
                    field("Entity 2"; "Table Caption")
                    {
                        ApplicationArea = All;
                        Caption = 'Data Subject';
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the type of data subjects to apply the data classification to.';
                    }
                    field("Fields"; Fields)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Style = StandardAccent;
                        StyleExpr = true;
                        ToolTip = 'Specifies the number of fields that the data classification will be applied to.';

                        trigger OnDrillDown()
                        begin
                            RunDataClassificationWorksheetForTable();
                        end;
                    }
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        StyleExpr = StatusStyle;
                        ToolTip = 'Specifies if you have reviewed the classifications that will be applied to the data subjects.';

                        trigger OnDrillDown()
                        begin
                            RunDataClassificationWorksheetForTable();
                        end;
                    }
                }
            }
            group(VerifyRelatedFieldsPage)
            {
                ShowCaption = false;
                Visible = Step = Step::"Verify Related Fields";
                group("We're getting there!")
                {
                    Caption = 'We''re getting there!';
                    InstructionalText = 'Review the classifications for similar fields before you continue.';
                }
                repeater(Control52)
                {
                    ShowCaption = false;
                    field("Similar Fields Label"; "Similar Fields Label")
                    {
                        ApplicationArea = All;
                        Caption = 'Fields';
                        ToolTip = 'Specifies the number of fields that the data classification will be applied to.';
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            RunDataClassificationWorksheetForPersonalAndSensitiveDataInTable();
                        end;
                    }
                    field("Status 2"; "Status 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Status';
                        ToolTip = 'Specifies if you have reviewed the classifications that will be applied to the data subjects.';
                        Editable = false;
                        StyleExpr = SimilarFieldsStatusStyle;

                        trigger OnDrillDown()
                        begin
                            RunDataClassificationWorksheetForPersonalAndSensitiveDataInTable();
                        end;
                    }
                }
            }
            group(FinishPage)
            {
                ShowCaption = false;
                Visible = (Step = Step::Finish) AND NOT IsExportModeSelectedValue;
                group("That's it")
                {
                    Caption = 'That''s it';
                    InstructionalText = 'We have applied the classifications to your data. If you want, you can review and update the classifications in the Data Classification Worksheet.';
                    field("<Control30>"; ShowWorksheet)
                    {
                        ApplicationArea = All;
                        Caption = 'Open Data Classification Worksheet';
                        ToolTip = 'Specifies that you want to open the Data Classification Worksheet to review the classifications that you applied. For example, this is useful for verifying that a classification is specified for all fields.';
                    }
                }
            }
            group(FinishPageForExportMode)
            {
                ShowCaption = false;
                Visible = (Step = Step::Finish) AND IsExportModeSelectedValue;
                group(Control46)
                {
                    Caption = 'That''s it';
                    InstructionalText = 'The Excel worksheet is ready, and you can start classifying your data.  When you are done, run this guide again to import the updated Excel worksheet and apply the classifications.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                ToolTip = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    if Step = Step::Verify then
                        Reset();
                    NextStep(true);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                ToolTip = 'Finish';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    if ShowWorksheet then
                        PAGE.Run(PAGE::"Data Classification Worksheet");
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Status = Status::"Review Needed" then
            StatusStyle := 'UnFavorable'
        else
            StatusStyle := 'Favorable';

        if "Status 2" = "Status 2"::"Review Needed" then
            SimilarFieldsStatusStyle := 'UnFavorable'
        else
            SimilarFieldsStatusStyle := 'Favorable';
    end;

    trigger OnOpenPage()
    begin
        ResetControls();

        ShowWorksheet := true;

        LedgerEntriesDefaultClassifications := LedgerEntriesDefaultClassifications::"Company Confidential";
        TemplatesDefaultClassifications := TemplatesDefaultClassifications::Normal;
        SetupTablesDefaultClassifications := SetupTablesDefaultClassifications::Normal;
    end;

    var
        HelpUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=869249', Locked = true;
        LearnMoreTok: Label 'Learn more';
        Step: Option Welcome,"Choose Mode","Set Rules",Apply,Verify,"Verify Related Fields",Finish;
        StatusStyle: Text;
        SimilarFieldsStatusStyle: Text;
        NextEnabled: Boolean;
        BackEnabled: Boolean;
        FinishEnabled: Boolean;
        ShowWorksheet: Boolean;
        IsImportModeSelectedValue: Boolean;
        IsExpertModeSelectedValue: Boolean;
        IsExportModeSelectedValue: Boolean;
        LedgerEntriesDefaultClassifications: Option Unclassified,Sensitive,Personal,"Company Confidential",Normal;
        SetupTablesDefaultClassifications: Option Unclassified,Sensitive,Personal,"Company Confidential",Normal;
        TemplatesDefaultClassifications: Option Unclassified,Sensitive,Personal,"Company Confidential",Normal;
        ViewFieldsTok: Label 'View fields';
        ReviewSimilarFieldsErr: Label 'You must review the classifications for similar fields before you can continue.';
        ReviewFieldsErr: Label 'You must review the classifications for fields before you can continue.';

    /// <summary>
    /// Resets the buttons on the page, enabling and disabling them according to the current step.
    /// </summary>	
    procedure ResetControls()
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := false;
        Reset();

        if IsEmpty() then
            DataClassificationMgt.RaiseOnGetDataPrivacyEntities(Rec);

        case Step of
            Step::Welcome:
                BackEnabled := false;
            Step::"Choose Mode":
                NextEnabled := ShouldEnableNext();
            Step::Verify,
          Step::"Verify Related Fields":
                SetRange(Include, true);
            Step::Finish:
                begin
                    FinishEnabled := true;
                    NextEnabled := false;
                end;
        end;
    end;

    local procedure RunDataClassificationWorksheetForTable()
    var
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
    begin
        DataClassificationMgtImpl.RunDataClassificationWorksheetForTable("Table No.");

        Reviewed := true;
        Status := Status::Reviewed;
        CurrPage.Update();
    end;

    local procedure RunDataClassificationWorksheetForPersonalAndSensitiveDataInTable()
    var
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
    begin
        DataClassificationMgtImpl.RunDataClassificationWorksheetForPersonalAndSensitiveDataInTable("Table No.");

        "Similar Fields Reviewed" := true;
        "Status 2" := "Status 2"::Reviewed;
        CurrPage.Update();
    end;

    /// <summary>
    /// Queries on whether or not the Next button should be enabled.
    /// </summary>	
    /// <returns>True if the Next button should be enabled and false otherwise.</returns>
    procedure ShouldEnableNext(): Boolean
    begin
        exit(IsImportModeSelectedValue or IsExpertModeSelectedValue or IsExportModeSelectedValue);
    end;

    /// <summary>
    /// Setter for the IsExportModeSelectedValue.
    /// </summary>
    /// <param name="Value">The Value to set.</param>
    procedure SetExportModeSelected(Value: Boolean)
    begin
        IsExportModeSelectedValue := Value;
    end;

    /// <summary>
    /// Setter for the IsExpertModeSelectedValue.
    /// </summary>
    /// <param name="Value">The Value to set.</param>
    procedure SetExpertModeSelected(Value: Boolean)
    begin
        IsExpertModeSelectedValue := Value;
    end;

    /// <summary>
    /// Setter for the SetImportModeSelected.
    /// </summary>
    /// <param name="Value">The Value to set.</param>
    procedure SetImportModeSelected(Value: Boolean)
    begin
        IsImportModeSelectedValue := Value;
    end;

    /// <summary>
    /// Selects the next step.
    /// </summary>	
    /// <param name="Backward">A boolean value that specifies if the next step should be to go back.</param>	
    procedure NextStep(Backward: Boolean)
    begin
        if Backward then begin
            if (Step = Step::Finish) and (IsImportModeSelectedValue or IsExportModeSelectedValue) then
                Step := Step::"Choose Mode"
            else
                Step += -1;
        end else begin
            CheckMandatoryActions();
            Step += 1;
        end;

        ResetControls();
    end;

    /// <summary>
    /// Displays errors if the preconditions for an action are not met.
    /// </summary>		
    procedure CheckMandatoryActions()
    begin
        if Step = Step::"Verify Related Fields" then begin
            SetRange("Similar Fields Reviewed", false);
            if FindFirst() then
                Error(ReviewSimilarFieldsErr);
        end;
        if Step = Step::Verify then begin
            SetRange(Reviewed, false);
            if FindFirst() then
                Error(ReviewFieldsErr);
        end;
    end;

    /// <summary>
    /// Queries on whether the Next button is enabled.
    /// </summary>			
    /// <returns>True if the Next button is enabled and false otherwise.</returns>
    procedure IsNextEnabled(): Boolean
    begin
        exit(NextEnabled);
    end;

    /// <summary>
    /// Gets the current step.
    /// </summary>			
    /// <returns>The current step.</returns>	
    procedure GetStep(): Option
    begin
        exit(Step);
    end;

    /// <summary>
    /// Sets the current step.
    /// </summary>	
    /// <param name="StepValue">The new value of the current step.</param>	
    procedure SetStep(StepValue: Option)
    begin
        Step := StepValue;
    end;

    /// <summary>
    /// Queries on whether import mode is selected.
    /// </summary>			
    /// <returns>True if import mode is selected and false otherwise.</returns>		
    procedure IsImportModeSelected(): Boolean
    begin
        exit(IsImportModeSelectedValue);
    end;

    /// <summary>
    /// Queries on whether export mode is selected.
    /// </summary>			
    /// <returns>True if export mode is selected and false otherwise.</returns>		
    procedure IsExportModeSelected(): Boolean
    begin
        exit(IsExportModeSelectedValue);
    end;

    /// <summary>
    /// Queries on whether expert mode is selected.
    /// </summary>			
    /// <returns>True if expert mode is selected and false otherwise.</returns>		
    procedure IsExpertModeSelected(): Boolean
    begin
        exit(IsExpertModeSelectedValue);
    end;

    /// <summary>
    /// Gets the default classification for ledger entries.
    /// </summary>			
    /// <returns>The default classification for ledger entries.</returns>		
    procedure GetLedgerEntriesDefaultClassification(): Option
    begin
        exit(LedgerEntriesDefaultClassifications);
    end;

    /// <summary>
    /// Gets the default classification for templates.
    /// </summary>			
    /// <returns>The default classification for templates.</returns>	
    procedure GetTemplatesDefaultClassification(): Option
    begin
        exit(TemplatesDefaultClassifications);
    end;

    /// <summary>
    /// Gets the default classification for setup tables.
    /// </summary>			
    /// <returns>The default classification for setup tables.</returns>	
    procedure GetSetupTablesDefaultClassification(): Option
    begin
        exit(SetupTablesDefaultClassifications);
    end;
}

