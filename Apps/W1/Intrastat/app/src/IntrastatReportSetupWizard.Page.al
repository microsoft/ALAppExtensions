// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.NoSeries;
using System.Environment;
using System.Telemetry;
using System.Utilities;

page 4815 "Intrastat Report Setup Wizard"
{
    ApplicationArea = BasicEU, BasicCH, BasicNO;
    Caption = 'Intrastat Report Setup';
    PageType = NavigatePage;
    SourceTable = "Intrastat Report Setup";

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
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
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
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to Intrastat Report Setup")
                {
                    Caption = 'Welcome to Intrastat Report Setup';
                    InstructionalText = 'Intrastat Report Setup is used to enable intrastat reporting and set defaults for it. You can specify whether you need to report Intrastat from shipments (dispatches), receipts (arrivals) or both depending on thresholds set by your local regulations. You can also set default transaction types for regular and return documents, used for nature of transaction reporting.';
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to specify basic Intrastat reporting info.';
                }
                group("Important")
                {
                    Caption = 'Important';
                    InstructionalText = 'All VAT Reports Configuration records for Intrastat Report will be removed during the process.';
                }
            }
            group(Step2)
            {
                Visible = Step2Visible;

                group(General)
                {
                    Caption = 'General Information';
                    field("Report Receipts"; Rec."Report Receipts")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies that you must include arrivals of received goods in Intrastat reports.';
                        Editable = true;
                    }
                    field("Report Shipments"; Rec."Report Shipments")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies that you must include shipments of dispatched items in Intrastat reports.';
                        Editable = true;
                    }
                    field("Include Drop Shipment"; Rec."Include Drop Shipment")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies if drop shipment transactions are included in Intrastat reports.';
                        Editable = true;
                    }
                    field("Shipments Based On"; Rec."Shipments Based On")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies based on which country code Intrastat report lines are taken.';
                    }
                    field("VAT No. Based On"; Rec."VAT No. Based On")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies based on which customer/vendor code VAT number is taken for the Intrastat report.';
                    }
                    field("Intrastat Contact Type"; Rec."Intrastat Contact Type")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the Intrastat contact type.';
                    }
                    field("Intrastat Contact No."; Rec."Intrastat Contact No.")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the Intrastat contact.';
                    }
                    field("Company VAT No. on File"; Rec."Company VAT No. on File")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies how the company''s VAT registration number exports to the Intrastat file. 0 is the value of the VAT Reg. No. field, 1 adds the EU country code as a prefix, and 2 removes the EU country code.';
                    }
                    field("Vend. VAT No. on File"; Rec."Vend. VAT No. on File")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies how a vendor''s VAT registration number exports to the Intrastat file. 0 is the value of the VAT Reg. No. field, 1 adds the EU country code as a prefix, and 2 removes the EU country code.';
                    }
                    field("Cust. VAT No. on File"; Rec."Cust. VAT No. on File")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies how a customer''s VAT registration number exports to the Intrastat file. 0 is the value of the VAT Reg. No. field, 1 adds the EU country code as a prefix, and 2 removes the EU country code.';
                    }
                    field("Get Partner VAT For"; Rec."Get Partner VAT For")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies for which type of line Partner''s VAT registration number is updated.';
                    }
                    field("Def. Country Code for Item Tr."; Rec."Def. Country Code for Item Tr.")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the default source of country code for item tracking.';
                    }
                    group(Numbering)
                    {
                        Caption = 'Numbering';
                        field("Intrastat Nos."; Rec."Intrastat Nos.")
                        {
                            ApplicationArea = BasicEU, BasicCH, BasicNO;
                            ToolTip = 'Specifies the code for the number series that will be used to assign numbers to intrastat documents. To see the number series that have been set up in the No. Series table, click the drop-down arrow in the field.';
                        }
                    }
                }
            }

            group(Step3)
            {
                Visible = Step3Visible;
                ShowCaption = false;
                group(Defaults)
                {
                    Caption = 'Defaults';
                    field("Default Transaction Type"; Rec."Default Trans. - Purchase")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the default transaction type for regular sales shipments and service shipments, and purchase receipts.';
                    }
                    field("Default Trans. Type - Returns"; Rec."Default Trans. - Return")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the default transaction type for sales returns and service returns, and purchase returns.';
                    }
                    field("Def. Private Person VAT No."; Rec."Def. Private Person VAT No.")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the default private person VAT number.';
                    }
                    field("Def. 3-Party Trade VAT No."; Rec."Def. 3-Party Trade VAT No.")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the default 3-party trade VAT number.';
                    }
                    field("Def. VAT for Unknown State"; Rec."Def. VAT for Unknown State")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the default VAT number for unknown state.';
                    }
                    field("Def. Country/Region Code"; Rec."Def. Country/Region Code")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Shows the default receiving country code.';
                    }
                }
            }
            group(Step4)
            {
                Visible = FinishStepVisible;
                ShowCaption = false;
                group(Reporting)
                {
                    Caption = 'Reporting';
                    field("Data Exch. Def. Code"; Rec."Data Exch. Def. Code")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the data exchange definition code to generate the intrastat file.';
                        Enabled = not Rec."Split Files";
                    }
                    field("Data Exch. Def. Name"; Rec."Data Exch. Def. Name")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the data exchange definition name to generate the intrastat file.';
                        Enabled = not Rec."Split Files";
                    }
                    field("Split Files"; Rec."Split Files")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies if Receipts and Shipments shall be reported in two separate files.';
                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("Zip Files"; Rec."Zip Files")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies if report file (-s) shall be added to Zip file.';
                    }
                    field("Data Exch. Def. Code - Receipt"; Rec."Data Exch. Def. Code - Receipt")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for received goods.';
                        Enabled = Rec."Split Files";
                    }
                    field("Data Exch. Def. Name - Receipt"; Rec."Data Exch. Def. Name - Receipt")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for received goods.';
                        Enabled = Rec."Split Files";
                    }
                    field("Data Exch. Def. Code - Shpt."; Rec."Data Exch. Def. Code - Shpt.")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for shipped goods.';
                        Enabled = Rec."Split Files";
                    }
                    field("Data Exch. Def. Name - Shpt."; Rec."Data Exch. Def. Name - Shpt.")
                    {
                        ApplicationArea = BasicEU, BasicCH, BasicNO;
                        ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for shipped goods.';
                        Enabled = Rec."Split Files";
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionOpenChecklist)
            {
                ApplicationArea = BasicEU, BasicCH, BasicNO;
                Caption = 'Intrastat Report Checklist';
                Image = CheckList;
                InFooterBar = true;
                RunObject = Page "Intrastat Report Checklist";
                Visible = Step = Step::Step2;
            }
            action(ActionBack)
            {
                ApplicationArea = BasicEU, BasicCH, BasicNO;
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
                ApplicationArea = BasicEU, BasicCH, BasicNO;
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
                ApplicationArea = BasicEU, BasicCH, BasicNO;
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
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
    begin
        FeatureTelemetry.LogUptake('0000I8X', IntrastatReportTok, Enum::"Feature Uptake Status"::Discovered);
        Commit();

        if Rec.FindFirst() then
            Rec.Delete(true);
        IntrastatReportMgt.InitSetup(Rec);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NoSeries: Record "No. Series";
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
    begin
        if CloseAction = Action::OK then
            if not SetupFinished then begin
                if not Confirm(SetupNotCompletedQst, false) then
                    Error('')
                else begin
                    if NoSeries.Get('INTRA') then
                        NoSeries.Delete(true);
                    if not IntrastatReportChecklist.IsEmpty then
                        IntrastatReportChecklist.DeleteAll();
                    Rec.Delete(true);
                end;
            end else
                FeatureTelemetry.LogUptake('0000I8Y', IntrastatReportTok, Enum::"Feature Uptake Status"::"Set up");
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
        Step: Option Start,Step2,Step3,FinishStep;
        SetupNotCompletedQst: Label 'The setup is not complete.\\Are you sure you want to exit?';
        IntrastatReportTok: Label 'Intrastat Report', Locked = true;

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
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
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
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        OnBeforeFinishAction();
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Intrastat Report");
        if VATReportsConfiguration.FindSet() then
            VATReportsConfiguration.DeleteAll(true);

        SetupFinished := true;
        CurrPage.Close();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeFinishAction()
    begin
    end;
}