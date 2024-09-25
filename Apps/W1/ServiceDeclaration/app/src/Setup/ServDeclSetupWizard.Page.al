// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using System.Environment;
using System.Environment.Configuration;
using System.Telemetry;
using System.Utilities;

page 5021 "Serv. Decl. Setup Wizard"
{
    Caption = 'Service Declaration Setup Wizard';
    PageType = NavigatePage;
    SourceTable = "Service Declaration Setup";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStd; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to Intrastat Report Setup")
                {
                    Caption = 'Welcome to Service Declaration Setup';
                    InstructionalText = 'In some EU countries, authorities require reporting for exporting services to the other EU countries. This feature enables collecting EU service’s intertrade and its reporting to the authorities. Even this feature is primarily created for Belgian, French and Italian markets, it can be used in all EU countries if needed as reporting is configurable.';
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to specify start a setup.';
                }
            }
            group(Step2)
            {
                Visible = Step2Visible;

                group(General)
                {
                    Caption = 'Setup';
                    field("Declaration No. Series"; Rec."Declaration No. Series")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the no. series for the service declarations.';
                        Editable = true;
                        ShowMandatory = true;
                    }
                    field("Data Exch. Def. Code"; Rec."Data Exch. Def. Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the data exchange definition code used to generate the exported file for the service declaration.';
                        ShowMandatory = true;
                    }
                    field("Report Item Charges"; Rec."Report Item Charges")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the item charges have to be reported in the service declaration. If enabled, system checks the service transaction code for item charges and include them into service declarations.';
                    }
                    field("Sell-To/Bill-To Customer No."; Rec."Sell-To/Bill-To Customer No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Tooltip = 'Specifies which customer must be taken to compare his country code with the country code from the Company Information page. Only documents where these two codes are different will be considered for the service declaration. Bill-To.: The country code will be taken from the Bill-to Customer. Sell-To. : The country code will be taken from the Sell-to Customer.';
                    }
                    field("Buy-From/Pay-To Vendor No."; Rec."Buy-From/Pay-To Vendor No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies which vendor must be taken to compare his country code with the country code from the Company Information page. Only documents where these two codes are different will be considered for the service declaration. Buy-From.: The country code will be taken from the Buy-From Vendor. Pay-To. : The country code will be taken from the Pay-To Vendor.';
                    }
                    field("Enable VAT Registration No."; Rec."Enable VAT Registration No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the VAT Registration No. is enabled for the service declaration.';
                    }
                    field("Vend. VAT Reg. No. Type"; Rec."Vend. VAT Reg. No. Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies how a vendor''s VAT registration number exports to the file. 0 is the value of the VAT Reg. No. field, 1 adds the country code as a prefix, and 2 removes the country code.';
                    }
                    field("Cust. VAT Reg. No. Type"; Rec."Cust. VAT Reg. No. Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies how a customer''s VAT registration number exports to the file. 0 is the value of the VAT Reg. No. field, 1 adds the country code as a prefix, and 2 removes the country code.';
                    }
                    field("Def. Customer/Vendor VAT No."; Rec."Def. Customer/Vendor VAT No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the VAT registration number that will be used if customer or vendor company does not have its own VAT registration number.';
                        Visible = false;
                    }
                    field("Def. Private Person VAT No."; Rec."Def. Private Person VAT No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the VAT registration number that will be used if customer or vendor private person does not have its own VAT registration number.';
                        Visible = false;
                    }
                }
            }
            group(Step3)
            {
                ShowCaption = false;
                Visible = Step3Visible;
                group(Step3General)
                {
                    Caption = 'Service transaction types';
                    InstructionalText = 'Specify a list of service transaction types to be used for the sales and purchase documents.';
                }
                group(Step3TransTypes)
                {
                    ShowCaption = false;
                    field(OpenMappingSetup; OpenServTransTypesPageLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        ApplicationArea = Basic, Suite;

                        trigger OnDrillDown()
                        var
                            ServiceTransactionTypesPage: Page "Service Transaction Types";
                        begin
                            ServiceTransactionTypesPage.RunModal();
                            UpdateServTransTypesCount();
                        end;
                    }
                    field(ServTransTypesInfo; ServTransTypesCount)
                    {
                        Caption = 'Total number of codes:';
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies how many service transaction types have been specified.';
                    }
                }
            }
            group(FinishedParent)
            {
                ShowCaption = false;
                Visible = FinishStepVisible;
                group(FinishedChild)
                {
                    Caption = 'The Service Declaration setup is complete.';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        Caption = '';
                        InstructionalText = 'You''re ready to create and export service declarations.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners();
        EnableControls();
    end;

    trigger OnOpenPage()
    var
        ServDeclSetup: Record "Service Declaration Setup";
        ServDeclMgt: Codeunit "Service Declaration Mgt.";
    begin
        FeatureTelemetry.LogUptake('0000IRD', ServDeclFormTok, Enum::"Feature Uptake Status"::Discovered);
        Commit();
        ServDeclMgt.InitServDeclSetup(ServDeclSetup);
        Rec := ServDeclSetup;
        Rec.Insert();
        ServDeclMgt.InsertVATReportsConfiguration();
        UpdateServTransTypesCount();
        EnableServTransType := ServDeclSetup."Enable Serv. Trans. Types";
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ServDeclSetup: Record "Service Declaration Setup";
    begin
        if CloseAction = Action::OK then
            if not SetupFinished then begin
                if not Confirm(SetupNotCompletedQst, false) then
                    Error('')
            end else begin
                ServDeclSetup := Rec;
                if not ServDeclSetup.Insert(true) then
                    ServDeclSetup.Modify(true);
                FeatureTelemetry.LogUptake('0000IRE', ServDeclFormTok, Enum::"Feature Uptake Status"::"Set up");
            end;
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TopBannerVisible: Boolean;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        FinishStepVisible: Boolean;
        SetupFinished: Boolean;
        EnableServTransType: Boolean;
        Step: Option Start,Step2,Step3,FinishStep;
        ServTransTypesCount: Integer;
        SetupNotCompletedQst: Label 'The setup is not complete.\\Are you sure you want to exit?';
        ServDeclFormTok: Label 'Service Declaration', Locked = true;

        FieldValueIsNotSpecifiedQst: Label '%1 was not specified in %2. Do you want to continue?', Comment = '%1 - no. series field caption; %2 = purchases & payables table caption';
        OpenServTransTypesPageLbl: Label 'Open the service transaction types page to specify the list of codes.';

    procedure IsSetupFinished(): Boolean
    begin
        exit(SetupFinished);
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png',
           Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png',
           Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if not ValidateControlsBeforeStep(Backwards) then
            exit;
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;
        if (not EnableServTransType) and (Step = Step::Step3) then
            if Backwards then
                Step -= 1
            else
                Step += 1;

        EnableControls();
    end;

    local procedure ValidateControlsBeforeStep(Backwards: Boolean): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if (Not Backwards) and Step2Visible and (Rec."Declaration No. Series" = '') then
            exit(ConfirmManagement.GetResponse(
                StrSubstNo(FieldValueIsNotSpecifiedQst, Rec.FieldCaption("Declaration No. Series"), Rec.TableCaption()), false));
        if (Not Backwards) and Step2Visible and (Rec."Data Exch. Def. Code" = '') then
            exit(ConfirmManagement.GetResponse(
                StrSubstNo(FieldValueIsNotSpecifiedQst, Rec.FieldCaption("Data Exch. Def. Code"), Rec.TableCaption()), false));
        exit(true);
    end;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::Step2:
                ShowStep2();
            Step::Step3:
                ShowStep3();
            Step::FinishStep:
                ShowFinishStep();
        end;
    end;

    local procedure ShowStep1()
    begin
        Step1Visible := true;

        BackActionEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowStep2()
    begin
        Step2Visible := true;

        NextActionEnabled := true;
        BackActionEnabled := true;
    end;

    local procedure ShowStep3()
    begin
        Step3Visible := true;

        NextActionEnabled := true;
        BackActionEnabled := true;
    end;

    local procedure ShowFinishStep()
    begin
        FinishStepVisible := true;

        BackActionEnabled := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;
        FinishStepVisible := false;
    end;

    local procedure FinishAction();
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        SetupFinished := true;
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Serv. Decl. Setup Wizard");
        CurrPage.Close();
    end;

    local procedure UpdateServTransTypesCount()
    var
        ServiceTransactionType: Record "Service Transaction Type";
    begin
        ServTransTypesCount := ServiceTransactionType.Count();
    end;
}
