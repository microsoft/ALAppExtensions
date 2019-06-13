// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1752 "Data Classification Wizard"
{
    Caption = 'Data Classification Assisted Setup Guide';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Data Privacy Entities";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control42)
            {
                Editable = false;
                ShowCaption = false;
                Visible = NOT FinishEnabled;
            }
            group(Control40)
            {
                Editable = false;
                ShowCaption = false;
                Visible = FinishEnabled;
            }
            group(Control2)
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
                field(HelpLbl;HelpLbl)
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    Editable = false;
                    ShowCaption = false;
                    Style = StandardAccent;
                    StyleExpr = TRUE;

                    trigger OnDrillDown()
                    begin
                        OpenHelpUrl();
                    end;
                }
            }
            group(Control3)
            {
                ShowCaption = false;
                Visible = Step = Step::"Choose Mode";
                group("Let's Get Started")
                {
                    Caption = 'Let''s Get Started';
                    InstructionalText = 'You can export data to an Excel worksheet, add the classifications, and then import the worksheet. For example, this is great for:';
                    label("- Adding classifications in bulk.")
                    {
                        ApplicationArea = All;
                        Caption = '- Adding classifications in bulk.';
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
                    field("<ExportModeSelected>";ExportModeSelected)
                    {
                        ApplicationArea = All;
                        Caption = 'Export Classification Data to Excel';

                        trigger OnValidate()
                        begin
                            SetExpertAndImportMode();
                        end;
                    }
                    field(ImportModeSelected;ImportModeSelected)
                    {
                        ApplicationArea = All;
                        Caption = 'Import Classification Data from Excel';

                        trigger OnValidate()
                        begin
                            SetExpertAndExportMode();
                        end;
                    }
                    group(Control11)
                    {
                        InstructionalText = 'You can also view lists of tables and fields and manually classify your data.';
                        ShowCaption = false;
                        field(ExpertModeSelected;ExpertModeSelected)
                        {
                            ApplicationArea = All;
                            Caption = 'Classify Data Manually';

                            trigger OnValidate()
                            begin
                                SetImportAndExportMode();
                            end;
                        }
                    }
                }
            }
            group(Control33)
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
                        field(LedgerEntriesDefaultClassification;LedgerEntriesDefaultClassification)
                        {
                            ApplicationArea = All;
                            Caption = 'Data from posting is:';
                        }
                        field(ViewFieldsLbl;ViewFieldsLbl)
                        {
                            ApplicationArea = All;
                            DrillDown = true;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = TRUE;

                            trigger OnDrillDown()
                            begin
                                RunDataClassificationWorksheetForTableWhoseNameContains('Entry');
                            end;
                        }
                        field(TemplatesDefaultClassification;TemplatesDefaultClassification)
                        {
                            ApplicationArea = All;
                            Caption = 'Data on templates is:';
                        }
                        field(Control38;ViewFieldsLbl)
                        {
                            ApplicationArea = All;
                            DrillDown = true;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = TRUE;

                            trigger OnDrillDown()
                            begin
                                RunDataClassificationWorksheetForTableWhoseNameContains('Template');
                            end;
                        }
                        field(SetupTablesDefaultClassification;SetupTablesDefaultClassification)
                        {
                            ApplicationArea = All;
                            Caption = 'Data on setup tables is:';
                        }
                        field(Control56;ViewFieldsLbl)
                        {
                            ApplicationArea = All;
                            DrillDown = true;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            StyleExpr = TRUE;

                            trigger OnDrillDown()
                            begin
                                RunDataClassificationWorksheetForTableWhoseNameContains('Setup');
                            end;
                        }
                    }
                }
            }
            group(Control4)
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
                    }
                    repeater(Control20)
                    {
                        ShowCaption = false;
                        field(Include;Include)
                        {
                            ApplicationArea = All;
                        }
                        field(Entity;"Table Caption")
                        {
                            ApplicationArea = All;
                            Caption = 'Data Subject';
                            DrillDown = false;
                            Editable = false;
                        }
                        field("Default Data Sensitivity";"Default Data Sensitivity")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }
            group(Control24)
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
                    field("Entity 2";"Table Caption")
                    {
                        ApplicationArea = All;
                        Caption = 'Data Subject';
                        DrillDown = false;
                        Editable = false;
                    }
                    field("Fields";Fields)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Style = StandardAccent;
                        StyleExpr = TRUE;

                        trigger OnDrillDown()
                        begin
                            RunDataClassificationWorksheetForTable();
                        end;
                    }
                    field(Status;Status)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        StyleExpr = StatusStyle;

                        trigger OnDrillDown()
                        begin
                            RunDataClassificationWorksheetForTable();
                        end;
                    }
                }
            }
            group(Control36)
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
                    field("Similar Fields Label";"Similar Fields Label")
                    {
                        ApplicationArea = All;
                        Caption = 'Fields';
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            RunDataClassificationWorksheetForPersonalAndSensitiveDataInTable();
                        end;
                    }
                    field("Status 2";"Status 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Status';
                        Editable = false;
                        StyleExpr = SimilarFieldsStatusStyle;

                        trigger OnDrillDown()
                        begin
                            RunDataClassificationWorksheetForPersonalAndSensitiveDataInTable();
                        end;
                    }
                }
            }
            group(Control29)
            {
                ShowCaption = false;
                Visible = (Step = Step::Finish) AND NOT ExportModeSelected;
                group("That's it")
                {
                    Caption = 'That''s it';
                    InstructionalText = 'We have applied the classifications to your data. If you want, you can review and update the classifications in the Data Classification Worksheet.';
                    field("<Control30>";ShowWorksheet)
                    {
                        ApplicationArea = All;
                        Caption = 'Open Data Classification Worksheet';
                    }
                }
            }
            group(Control27)
            {
                ShowCaption = false;
                Visible = (Step = Step::Finish) AND ExportModeSelected;
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
    }

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
        SetSimilarFieldsStatusStyle();
    end;

    trigger OnOpenPage()
    begin
        ResetControls();
        ShowWorksheet := true;
        SetDefaultClassifications();
    end;

    var
        HelpUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=869249', Comment='Locked';
        HelpLbl: Label 'Learn more';
        Step: Option Welcome,"Choose Mode","Set Rules",Apply,Verify,"Verify Related Fields",Finish;
        StatusStyle: Text;
        SimilarFieldsStatusStyle: Text;
        NextEnabled: Boolean;
        BackEnabled: Boolean;
        FinishEnabled: Boolean;
        ShowWorksheet: Boolean;
        ImportModeSelected: Boolean;
        ExpertModeSelected: Boolean;
        ExportModeSelected: Boolean;
        LedgerEntriesDefaultClassification: Option Unclassified,Sensitive,Personal,"Company Confidential",Normal;
        SetupTablesDefaultClassification: Option Unclassified,Sensitive,Personal,"Company Confidential",Normal;
        TemplatesDefaultClassification: Option Unclassified,Sensitive,Personal,"Company Confidential",Normal;
        ViewFieldsLbl: Label 'View fields';

    local procedure ResetControls()
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := false;
        Reset();

        if IsEmpty() then
          DataClassificationMgt.OnGetPrivacyMasterTables(Rec);

        case Step of
          Step::Welcome:
            BackEnabled := false;
          Step::"Choose Mode":
            NextEnabled := IsNextEnabled();
          Step::Verify,
          Step::"Verify Related Fields":
            SetRange(Include,true);
          Step::Finish:
            begin
              FinishEnabled := true;
              NextEnabled := false;
            end;
        end;
    end;

    local procedure SetDefaultClassifications()
    begin
        LedgerEntriesDefaultClassification := LedgerEntriesDefaultClassification::"Company Confidential";
        TemplatesDefaultClassification := TemplatesDefaultClassification::Normal;
        SetupTablesDefaultClassification := SetupTablesDefaultClassification::Normal;
    end;

    local procedure SetStatusStyle()
    begin
        if Status = Status::"Review Needed" then
          StatusStyle := 'UnFavorable'
        else
          StatusStyle := 'Favorable';
    end;

    local procedure SetSimilarFieldsStatusStyle()
    begin
        if "Status 2" = "Status 2"::"Review Needed" then
          SimilarFieldsStatusStyle := 'UnFavorable'
        else
          SimilarFieldsStatusStyle := 'Favorable';
    end;

    local procedure RunDataClassificationWorksheetForTableWhoseNameContains(TableNoFilter: Text)
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataSensitivity.SetRange("Company Name",CompanyName());
        DataSensitivity.SetFilter("Table No",DataClassificationMgt.GetTableNoFilterForTablesWhoseNameContains(TableNoFilter));
        PAGE.Run(PAGE::"Data Classification Worksheet",DataSensitivity);
    end;

    local procedure RunDataClassificationWorksheetForTable()
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.SetRange("Company Name",CompanyName());
        DataSensitivity.FilterGroup(2);
        DataSensitivity.SetRange("Table No","Table No.");
        PAGE.RunModal(PAGE::"Data Classification Worksheet",DataSensitivity);

        Reviewed := true;
        Status := Status::Reviewed;
        CurrPage.Update();
    end;

    local procedure RunDataClassificationWorksheetForPersonalAndSensitiveDataInTable()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataSensitivity.SetRange("Company Name",CompanyName());
        DataSensitivity.SetRange("Table No","Table No.");
        DataSensitivity.SetFilter("Data Sensitivity",StrSubstNo('%1|%2',
            DataSensitivity."Data Sensitivity"::Personal,
            DataSensitivity."Data Sensitivity"::Sensitive));
        DataClassificationMgt.FindSimilarFieldsInRelatedTables(DataSensitivity);
        PAGE.RunModal(PAGE::"Data Classification Worksheet",DataSensitivity);

        "Similar Fields Reviewed" := true;
        "Status 2" := "Status 2"::Reviewed;
        CurrPage.Update();
    end;

    local procedure IsNextEnabled(): Boolean
    begin
        exit(ImportModeSelected or ExpertModeSelected or ExportModeSelected);
    end;

    local procedure OpenHelpUrl()
    begin
        HyperLink(HelpUrlTxt);
    end;

    local procedure SetExpertAndImportMode()
    begin
        if ExportModeSelected = true then begin
          ExpertModeSelected := false;
          ImportModeSelected := false;
        end;

        NextEnabled := IsNextEnabled();
    end;

    local procedure SetExpertAndExportMode()
    begin
        if ImportModeSelected = true then begin
          ExpertModeSelected := false;
          ExportModeSelected := false;
        end;

        NextEnabled := IsNextEnabled();
    end;

    local procedure SetImportAndExportMode()
    begin
        if ExpertModeSelected = true then begin
          ImportModeSelected := false;
          ExportModeSelected := false;
        end;

        NextEnabled := IsNextEnabled();
    end;
}

