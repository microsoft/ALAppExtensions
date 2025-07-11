// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Setup;
using System.Environment;
using System.Environment.Configuration;
using System.Telemetry;
using System.Utilities;

page 10022 "IRS 1096 Setup Wizard"
{
    Caption = 'IRS 1096 Setup Wizard';
    PageType = NavigatePage;
    SourceTable = "Purchases & Payables Setup";
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
                    ApplicationArea = BasicUS;
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
                    ApplicationArea = BasicUS;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to Intrastat Report Setup")
                {
                    Caption = 'Welcome to IRS 1096 Setup';
                    InstructionalText = 'Form 1096 is used to transmit paper tax forms to the IRS. This feature enables running the Form 1096 report in Dynamics 365 Business Central and sending it to the IRS if this is required, and it is related only to already transmitted 1099 paper forms.';
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
                    Caption = 'General';
                    field("IRS 1096 Form No. Series"; Rec."IRS 1096 Form No. Series")
                    {
                        ApplicationArea = BasicUS;
                        ToolTip = 'Specifies the code for the number series that will be used to assign numbers for 1096 forms per certain period.';
                        Editable = true;
                        ShowMandatory = true;
                    }
                }
            }
            group(FinishedParent)
            {
                ShowCaption = false;
                Visible = FinishStepVisible;
                group(FinishedChild)
                {
                    Caption = 'The IRS 1096 setup is complete.';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        Caption = '';
                        InstructionalText = 'You''re ready to create and print 1096 forms.';
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
                ApplicationArea = BasicUS;
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
                ApplicationArea = BasicUS;
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
                ApplicationArea = BasicUS;
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
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        FeatureTelemetry.LogUptake('0000ISD', IRS1096FormTok, Enum::"Feature Uptake Status"::Discovered);
        Commit();
        PurchasesPayablesSetup.Get();
        Rec := PurchasesPayablesSetup;
        Rec.Insert();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if CloseAction = Action::OK then
            if not SetupFinished then begin
                if not Confirm(SetupNotCompletedQst, false) then
                    Error('')
            end else begin
                PurchasesPayablesSetup.Get();
                PurchasesPayablesSetup."IRS 1096 Form No. Series" := Rec."IRS 1096 Form No. Series";
                PurchasesPayablesSetup.Modify(true);
                FeatureTelemetry.LogUptake('0000ISE', IRS1096FormTok, Enum::"Feature Uptake Status"::"Set up");
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
        FinishStepVisible: Boolean;
        SetupFinished: Boolean;
        Step: Option Start,Step2,FinishStep;
        SetupNotCompletedQst: Label 'The setup is not complete.\\Are you sure you want to exit?';
        IRS1096FormTok: Label 'IRS 1096 Form', Locked = true;
        NoSeriesIsNotSpecifiedQst: Label '%1 was not specified in %2. Do you want to continue?', Comment = '%1 - no. series field caption; %2 = purchases & payables table caption';

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

        EnableControls();
    end;

    local procedure ValidateControlsBeforeStep(Backwards: Boolean): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if (Not Backwards) and Step2Visible and (Rec."IRS 1096 Form No. Series" = '') then
            exit(ConfirmManagement.GetResponse(
                StrSubstNo(NoSeriesIsNotSpecifiedQst, Rec.FieldCaption("IRS 1096 Form No. Series"), Rec.TableCaption()), false));
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
        FinishStepVisible := false;
    end;

    local procedure FinishAction();
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        SetupFinished := true;
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"IRS 1096 Setup Wizard");
        CurrPage.Close();
    end;
}
