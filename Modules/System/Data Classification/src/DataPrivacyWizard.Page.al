// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1180 "Data Privacy Wizard"
{
    Extensible = false;
    Caption = 'Data Privacy Utility';
    PageType = NavigatePage;
    SourceTable = "Data Privacy Entities";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control17)
            {
                Editable = false;
                ShowCaption = false;
                Visible = NOT (CurrentPage = 5);
            }
            group(Control19)
            {
                Editable = false;
                ShowCaption = false;
                Visible = (CurrentPage = 5);
            }
            group(Step1)
            {
                InstructionalText = '';
                Visible = CurrentPage = 1;
                group("Para1.1")
                {
                    Caption = 'Welcome to Data Privacy Utility';
                    InstructionalText = '';
                    group("Para1.1.1")
                    {
                        Caption = '';
                        InstructionalText = 'You can export data for a person to Excel or to a RapidStart configuration package.';
                        group("Para1.1.1.1")
                        {
                            Caption = '';
                            InstructionalText = 'Up to date information on privacy requests can be found at the link below.';
                            Visible = CurrentPage = 1;
                            field(PrivacyURL; PrivacyURL)
                            {
                                ApplicationArea = All;
                                Editable = false;
                                ExtendedDatatype = URL;
                                ShowCaption = false;
                                Visible = CurrentPage = 1;
                            }
                        }
                    }
                }
                group("Para1.2")
                {
                    Caption = 'Let''s go!';
                    group("Para1.2.1")
                    {
                        Caption = '';
                        InstructionalText = 'Choose Next to start the process.';
                    }
                }
            }
            group(Step2)
            {
                Caption = '';
                Visible = CurrentPage = 2;
                group("Para2.1")
                {
                    Caption = 'I want to...';
                    field(ActionType; ActionType)
                    {
                        ApplicationArea = All;
                        OptionCaption = 'Export a data subject''s data,Create a data privacy configuration package', Comment = 'Note to translators.  These options must be translated based on being prefixed with "I want to" text.';
                        ShowCaption = false;
                    }
                    field(AvailableOptionsDescription; AvailableOptionsDescription)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
            group(Step3)
            {
                Caption = '';
                Visible = CurrentPage = 3;
                group("Para3.1")
                {
                    Caption = 'Specify the data that you want to export.';
                    field(EntityType; EntityType)
                    {
                        ApplicationArea = All;
                        Caption = 'Data Subject';
                        TableRelation = "Data Privacy Entities"."Table Caption";

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            Reset();
                            DeleteAll();
                            if PAGE.RunModal(PAGE::"Data Subject", Rec) = ACTION::LookupOK then begin
                                EntityType := "Table Caption";
                                EntityTypeTableNo := "Table No.";
                                if EntityType <> EntityTypeGlobal then
                                    EntityNo := '';
                                EntityTypeGlobal := EntityType;
                            end;
                        end;
                    }
                    field(EntityTypeTableNo; EntityTypeTableNo)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Visible = false;
                    }
                    field(EntityNo; EntityNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Data Subject Identifier';

                        trigger OnDrillDown()
                        begin
                            DataPrivacyEventMgmt.OnDrillDownForEntityNumber(EntityTypeTableNo, EntityNo);
                        end;

                        trigger OnValidate()
                        begin
                            DataPrivacyEventMgmt.OnEntityNoValidate(EntityTypeTableNo, EntityNo);
                        end;
                    }
                    field(DataSensitivity; DataSensitivity)
                    {
                        ApplicationArea = All;
                        Caption = 'Data Sensitivity';
                    }
                }
                group("Para3.05")
                {
                    Caption = '';
                    InstructionalText = 'Choose to generate and preview the data that will be exported. Note that this can take a while, depending on the size of the dataset.';
                    Visible = (CurrentPage = 3) AND (ActionType < 1);
                }
                group("Para3.2")
                {
                    Caption = '';
                    InstructionalText = 'Choose Next to export the data.';
                    Visible = (CurrentPage = 3) AND (ActionType = 0);
                }
                group("Para3.4")
                {
                    Caption = '';
                    InstructionalText = 'Choose Next to create the configuration package';
                    Visible = ActionType = 1;
                }
            }
            group(Step4)
            {
                Caption = '';
                Visible = CurrentPage = 4;
                group("Para4.1")
                {
                    Caption = 'Preview the data that will be exported';
                    part(DataPrivacySubPage; "Data Privacy ListPage")
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                    }
                }
                group("Para4.2")
                {
                    Caption = '';
                    InstructionalText = 'Choose Next to export the data.';
                    Visible = (CurrentPage = 4) AND (ActionType = 0);
                }
            }
            group(Step5)
            {
                Caption = '<Step5>';
                InstructionalText = '';
                Visible = CurrentPage = 5;
                group("Para5.1")
                {
                    Caption = 'Success!';
                    InstructionalText = '';
                    group("Para5.1.1")
                    {
                        Caption = '';
                        InstructionalText = 'The data is being exported. The Excel workbook will show up in the Report Inbox on your home page.';
                        Visible = (CurrentPage = 5) AND (ActionType = 0);
                        group("Para5.1.1.1")
                        {
                            Caption = '';
                            InstructionalText = 'We recommend that you verify the data that is exported to Excel. Please also verify the filters in the configuration package to make sure that you are getting the data that you want.';
                            Visible = (CurrentPage = 5) AND (ActionType = 0);
                        }
                    }
                    group("Para5.1.3")
                    {
                        Caption = '';
                        InstructionalText = 'Your configuration package has been successfully created.';
                        Visible = (CurrentPage = 5) AND (ActionType = 1);
                        field(EditConfigPackage; EditConfigPackage)
                        {
                            ApplicationArea = All;
                            Caption = 'Edit Configuration Package';
                        }
                        group("Para5.1.4.1")
                        {
                            Caption = '';
                            InstructionalText = 'Please verify the filters in the configuration package to make sure that you will get the data that you want.';
                            Visible = (CurrentPage = 5) AND (ActionType = 1);
                        }
                    }
                }
            }
            group(Step6)
            {
                Caption = '<Step5>';
                InstructionalText = '';
                Visible = CurrentPage = 6;
                group("Para6.1")
                {
                    Caption = 'Process finished.';
                    InstructionalText = '';
                    group("Para6.1.1")
                    {
                        Caption = '';
                        InstructionalText = 'No data was found that could be generated, so no export file was created.';
                        Visible = (CurrentPage = 6) AND (ActionType = 0);
                    }
                    group("Para6.1.2")
                    {
                        Caption = '';
                        InstructionalText = 'No data was found that could be generated, so no configuration package was created.';
                        Visible = (CurrentPage = 6) AND (ActionType = 1);
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentPage := 1;
        PrivacyURL := PrivacyUrlTxt;
    end;

    trigger OnOpenPage()
    begin
        EnableControls();
    end;

    var
        DataPrivacyEventMgmt: Codeunit "Data Privacy Event Mgmt.";
        CurrentPage: Integer;
        ActionType: Option "Export a data subject's data","Create a data privacy configuration package";
        EntityType: Text[80];
        EntityTypeTableNo: Integer;
        EntityNo: Code[50];
        DataSensitivity: Option Sensitive,Personal,"Company Confidential",Normal,Unclassified;
        EntityTypeGlobal: Text[80];
        EditConfigPackage: Boolean;
        OptionsDescriptionTxt: Label '\Choose what you want to do with the privacy data.\\You can export data for a specific data subject, such as a customer.\You can also create a configuration package so that you can view and edit the fields and tables that the data will be exported from.';
        AvailableOptionsDescription: Text;
        PrivacyURL: Text;
        PrivacyUrlTxt: Label 'https://docs.microsoft.com/en-us/dynamics365/business-central/admin-responding-to-requests-about-personal-data', Locked = true;

    local procedure ResetControls()
    begin
        EditConfigPackage := true;
    end;

    local procedure EnableControls()
    begin
        ResetControls();
        AvailableOptionsDescription := OptionsDescriptionTxt;
    end;

    [Scope('OnPrem')]
    procedure SetEntitityType(EntityTypeText: Text[80]; EntityTypeTable: Integer)
    begin
        EntityType := EntityTypeText;
        EntityTypeTableNo := EntityTypeTable;
    end;
}

