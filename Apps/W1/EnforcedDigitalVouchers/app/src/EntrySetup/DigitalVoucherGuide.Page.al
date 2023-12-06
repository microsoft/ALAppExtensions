// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Environment;
using System.Environment.Configuration;
using System.Telemetry;
using System.Utilities;

page 5580 "Digital Voucher Guide"
{
    PageType = NavigatePage;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStd."Media Reference")
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
                field(MediaResourcesDone; MediaResourcesFinished."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Start)
            {
                Visible = WelcomeStepVisible;
                group(Welcome)
                {
                    Caption = 'Welcome to the setup of digital vouchers';
                    Visible = WelcomeStepVisible;
                    group(FeatureDescription)
                    {
                        Caption = '';
                        InstructionalText = 'In some countries authorities require to make sure that for every single document there is a digital voucher assigned.';
                    }
                }
            }

            group(Setup)
            {
                ShowCaption = false;
                Visible = VoucherEntryTypeSetup;
                group(SetupGeneral)
                {
                    Caption = 'Setup digital voucher by entry type';
                    InstructionalText = 'For each entry type you want to enforce digital voucher, add the setup and define the rules to check the voucher.';
                }
                group(OpenVoucherEntrySetupGroup)
                {
                    ShowCaption = false;
                    field(OpenVoucherEntrySetup; OpenVoucherEntrySetupLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        ApplicationArea = Basic, Suite;

                        trigger OnDrillDown()
                        var
                            DigitalVoucherEntrySetup: Page "Digital Voucher Entry Setup";
                        begin
                            DigitalVoucherEntrySetup.SetOpenFromGuide();
                            DigitalVoucherEntrySetup.RunModal();
                            UpdateVoucherEntrySetupInfo();
                        end;
                    }
                    field(VoucherEntrySetupInfo; VoucherEntrySetupDefined)
                    {
                        Caption = 'Voucher Entry setups defined:';
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of digital voucher setups by entry type.';
                    }
                }
            }

            group(FinishedParent)
            {
                ShowCaption = false;
                Visible = FinishActionEnabled;
                group(FinishedChild)
                {
                    Caption = 'The digital voucher setup is completed!';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        Caption = '';
                        InstructionalText = 'You have enforced the digital voucher functionality.';
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

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if not SetupFinished then begin
                if not Confirm(SetupNotCompletedQst, false) then
                    Error('')
            end else begin
                DigitalVoucherSetup.Enabled := true;
                DigitalVoucherSetup.Modify();
                FeatureTelemetry.LogUptake('0000LQC', DigitalVoucherTok, Enum::"Feature Uptake Status"::"Set up");
            end;
    end;

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        DigitalVoucherSetup.InitSetup();
        FeatureTelemetry.LogUptake('0000LQD', DigitalVoucherTok, Enum::"Feature Uptake Status"::Discovered);
        Commit();

        Step := Step::Start;
        UpdateVoucherEntrySetupInfo();
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        DigitalVoucherSetup: Record "Digital Voucher Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Step: Option Start,Setup,Finish;
        VoucherEntrySetupDefined: Text[20];
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        WelcomeStepVisible: Boolean;
        VoucherEntryTypeSetup: Boolean;
        TopBannerVisible: Boolean;
        SetupFinished: Boolean;
        SetupNotCompletedQst: label 'Set up of digital vouchers has not been completed. This feature will not be enabled.\\Are you sure that you want to exit?';
        OpenVoucherEntrySetupLbl: label 'Open the setup page to define voucher setup by entry type.';
        DigitalVoucherTok: label 'Enforced Digital Vouchers', Locked = true;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::Setup:
                ShowVoucherSetupStep();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure FinishAction();
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        FeatureTelemetry.LogUptake('0000LQE', DigitalVoucherTok, Enum::"Feature Uptake Status"::"Set up");
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Digital Voucher Guide");
        SetupFinished := true;
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step -= 1
        else
            Step += 1;

        EnableControls();
    end;

    local procedure ShowWelcomeStep();
    begin
        WelcomeStepVisible := true;
        VoucherEntryTypeSetup := false;
        BackActionEnabled := false;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowVoucherSetupStep();
    begin
        WelcomeStepVisible := false;
        VoucherEntryTypeSetup := true;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish();
    begin
        WelcomeStepVisible := false;
        VoucherEntryTypeSetup := false;
        BackActionEnabled := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        WelcomeStepVisible := false;
        VoucherEntryTypeSetup := false;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStd.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesFinished.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesFinished."Media Reference".HasValue();
    end;

    local procedure UpdateVoucherEntrySetupInfo()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        VoucherEntrySetupDefined := Format(DigitalVoucherEntrySetup.Count());
    end;
}
