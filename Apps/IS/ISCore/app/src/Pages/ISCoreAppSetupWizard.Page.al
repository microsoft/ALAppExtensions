#if not CLEAN24
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.Foundation.Navigate;
using Microsoft.Sales.Setup;
using System.Environment.Configuration;
using System.Environment;
using System.Telemetry;
using System.Utilities;
using System.Upgrade;

page 14604 "IS Core App Setup Wizard"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Iceland - Core App Setup';
    PageType = NavigatePage;
    ObsoleteReason = 'Used to enable the IS Core App. The IS (Iceland) Core App is the application that incorporates Icelandic local features extracted from the Base App. During the transition period (up to version 27), the app needs to be enabled using that page. Starting from version 27, the IS Core App will be enabled by default.';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';

    Permissions = tabledata "Sales & Receivables Setup" = IMD,
                  tabledata "G/L Account" = IMD,
                  tabledata "Depreciation Book" = IMD;

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
                group("Welcome to Iceland Core App Setup")
                {
                    Caption = 'Welcome to the Iceland-Core App Setup';
                    InstructionalText = 'After you enable this feature for all users, you cannot turn it off again. This is because the feature may include changes to your data and may initiate an upgrade of some database tables as soon as you enable it. We strongly recommend that you first enable and test this feature on a sandbox environment that has a copy of production data before doing this on a production environment. For detailed information about the impact of enabling this feature, you should choose No and use the Learn more link. Are you sure you want to enable this feature?';
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to see which data will be updated.';
                }
            }
            group(Step2)
            {
                Visible = Step2Visible;
                group(WhatIsUpdated)
                {
                    Caption = 'What is updated';
                    group(WhatIsUpdatedDescr)
                    {
                        ShowCaption = false;
                        field(Description; ReviewDataTok)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                            ToolTip = 'Review affected data.';
                        }
                    }
                }
                group(ReviewAffectedData)
                {
                    ShowCaption = false;
                    field(ReviewDataField; ReviewDataLinkTok)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            ReviewData();
                        end;
                    }
                }
                group(DataUpgradeAgreement)
                {
                    ShowCaption = false;

                    field(Agreed; DataUpgradeAgreed)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'I accept the data update';
                        ToolTip = 'Specifies whether the user does understand the update procedure and agree to proceed.';

                        trigger OnValidate()
                        begin
                            FinishActionEnabled := DataUpgradeAgreed;
                        end;
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
    begin
        FeatureTelemetry.LogUptake('0000LN1', ISCoreAppTok, Enum::"Feature Uptake Status"::Discovered);
        CountRecordsForDataUpdate();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
    begin
        if CloseAction = Action::OK then
            if not SetupFinished then begin
                if not Confirm(SetupNotCompletedQst, false) then
                    Error('');
            end else
                FeatureTelemetry.LogUptake('0000LN2', ISCoreAppTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    var
        TempDocumentEntry: Record "Document Entry" temporary;
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
        SetupFinished: Boolean;
        DataUpgradeAgreed: Boolean;
        Step: Option Start,Step2,Step3,FinishStep;
        SetupNotCompletedQst: Label 'The setup is not complete.\\Are you sure you want to exit?';
        ISCoreAppTok: Label 'IS Core App', Locked = true;
        ReviewDataLinkTok: Label 'Review Affected Data';
        ReviewDataTok: Label 'Records from several Base Application tables will be copied to the new Iceland-Core App tables. Please review affected data as the data update can take longer in case of large amount of records. ', Comment = '%1, %2, %3, %4 - table captions';

    procedure IsSetupFinished(): Boolean
    begin
        exit(SetupFinished);
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
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

        NextActionEnabled := false;
        BackActionEnabled := true;
    end;

    local procedure ShowFinishStep()
    begin
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
    end;

    local procedure FinishAction();
    var
        ISCoreAppSetup: Record "IS Core App Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        EnableISCoreApp: Codeunit "Enable IS Core App";
    begin
        OnBeforeFinishAction();
        SetupFinished := true;
        EnableISCoreApp.TransferData();
        EnableISCoreApp.UpdateDocumentRetentionPeriod();

        ISCoreAppSetup.Get();
        ISCoreAppSetup.Enabled := true;
        ISCoreAppSetup.Modify();

        UpgradeTag.SetUpgradeTag(EnableISCoreApp.GetISCoreAppUpdateTag());
        CurrPage.Close();
    end;

    local procedure ReviewData();
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Clear(DataUpgradeOverview);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;

    local procedure CountRecordsForDataUpdate(): Boolean;
    var
        IRSGroups: Record "IRS Groups";
        IRSNumbers: Record "IRS Numbers";
        IRSTypes: Record "IRS Types";
        DepreciationBook: Record "Depreciation Book";
        GLAccount: Record "G/L Account";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        CountRecords(Database::"IRS Groups", IRSGroups.TableCaption);
        CountRecords(Database::"IRS Numbers", IRSNumbers.TableCaption);
        CountRecords(Database::"IRS Types", IRSTypes.TableCaption);
        CountRecords(Database::"Depreciation Book", DepreciationBook.TableCaption);
        CountRecords(Database::"G/L Account", GLAccount.TableCaption);
        CountRecords(Database::"Sales & Receivables Setup", SalesReceivablesSetup.TableCaption);
        exit(not TempDocumentEntry.IsEmpty());
    end;

    local procedure CountRecords(SourceTableId: Integer; SourceTableName: Text[30])
    var
        Company: Record Company;
        SourceRecRef: RecordRef;
        RecordCount: Integer;
    begin
        if Company.FindSet() then
            repeat
                SourceRecRef.Open(SourceTableId, false, Company.Name);

                if SourceRecRef.FindSet() then
                    RecordCount += SourceRecRef.Count;
                SourceRecRef.Close();
            until Company.Next() = 0;

        InsertDocumentEntry(SourceTableId, SourceTableName, RecordCount);
    end;

    local procedure InsertDocumentEntry(TableID: Integer; TableName: Text; RecordCount: Integer)
    begin
        if RecordCount = 0 then
            exit;

        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." += 1;
        TempDocumentEntry."Table ID" := TableID;
        TempDocumentEntry."Table Name" := CopyStr(TableName, 1, MaxStrLen(TempDocumentEntry."Table Name"));
        TempDocumentEntry."No. of Records" := RecordCount;
        TempDocumentEntry.Insert();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeFinishAction()
    begin
    end;
}
#endif