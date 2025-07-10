// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Navigate;
#if not CLEAN25
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
#endif
using System.Environment;
using System.Environment.Configuration;
using System.Telemetry;
using System.Utilities;

page 10032 "IRS Forms Guide"
{
    PageType = NavigatePage;
    RefreshOnActivate = true;
    ApplicationArea = BasicUS;
    SourceTable = "IRS Forms Setup";

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
            group(Start)
            {
                Visible = WelcomeStepVisible;
                group(Welcome)
                {
                    Caption = 'Welcome to the setup of IRS Forms';
                    Visible = WelcomeStepVisible;
                    group(IRSFormsDescription)
                    {
                        Caption = '';
                        InstructionalText = 'Enable using 1099 forms to transmit the tax data to the IRS in the United States. This guide helps you set up the reporting periods, forms, form boxes and statement for Dynamics 365 Business Central. If you do not want to set this up right now, close this page.';
                    }
                }
            }
            group(DataParent)
            {
                Visible = DataStepEnabled;
                group(DataChild)
                {
                    Caption = 'Create new setup, or transfer existing data';
                    InstructionalText = 'If you’re setting up Business Central, choose Create New Setup. Business Central will create the forms and associated setup so you can fill out and print them. If you’re upgrading and already have data for your 1099 form, choose Transfer Existing Data. Both options require you to specify the reporting year for the tax data to the IRS. The data creation or the transfer process starts when you finish the guide.';

                    field(ReportingYearControl; Rec."Init Reporting Year")
                    {
                        Caption = 'Reporting Year';
                        ShowMandatory = true;
                        BlankZero = true;
                        ToolTip = 'Specifies the year for which you will be reporting the tax data to the IRS. This is applicable for both options below.';
                    }

                    field(CreateNewSetupControl; CreateNewSetup)
                    {
                        Caption = 'Create new setup';
                        ToolTip = 'Specifies whether you want to create the new setup automatically instead of doing it manually - a reporting period, forms, form boxes and a statement.';

                        trigger OnValidate()
                        begin
                            if Rec."Init Reporting Year" = 0 then
                                Error('You must specify the reporting year.');
                            TransferExistingData := false;
                        end;
                    }
                    field(TransferExistingDataControl; TransferExistingData)
                    {
                        Caption = 'Transfer existing data';
                        ToolTip = 'Specifies whether you want to transfer the data from the IRS 1099 Base Application to the new IRS forms extension. This includes IRS 1099 form boxes, vendor setup, purchase documents and vendor ledger entries.';
                        Editable = CanTransferData;

                        trigger OnValidate()
                        begin
                            if Rec."Init Reporting Year" = 0 then
                                Error('You must specify the reporting year.');
                            Rec.CheckIfDataTransferIsPossible();
                            CreateNewSetup := false;
                        end;
                    }
                    field(DataTransferStatusControl; DataTransferStatus)
                    {
                        ShowCaption = false;
                        ToolTip = 'Specifies the reason why the data transfer is not possible.';
                        Editable = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Visible = DataTransferStatus <> '';
                    }
                }
            }
            group(TransferExistingDataStepParent)
            {
                Visible = TransferExistingDataStepEnabled;
                group(TransferExistingDataWhatIsUpdated)
                {
                    Caption = 'What is updated';
                    group(TransferExistingDataWhatIsUpdatedDescr)
                    {
                        ShowCaption = false;
                        field(TransferExistingDataDescription; ReviewUpdatedDataTok)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                            ToolTip = 'Review affected data.';
                        }
                    }
                }
                group(TransferExistingDataReviewAffectedData)
                {
                    ShowCaption = false;
                    field(TransferExistingDataReviewDataField; ReviewDataLinkTok)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            ReviewData();
                        end;
                    }
                }
                group(Background)
                {
                    ShowCaption = false;
                    Visible = CanCreateTask;
                    field(BackgroundTask; Rec."Background Task")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Run in background session';
                        ToolTip = 'Specifies whether the task should be run in the current or in the background session.';
                    }
                }
                group(SetupBackgroundTaskParent)
                {
                    Caption = 'Schedule background task';
                    Visible = Rec."Background Task";
                    group(SetupBackgroundTask)
                    {
                        ShowCaption = false;
                        field("Start Date/Time"; Rec."Task Start Date/Time")
                        {
                            ApplicationArea = Basic, Suite;
                            Enabled = not Rec."Run Task Now";
                            Caption = 'Start Date/Time';
                            ToolTip = 'Specifies the earliest date and time when the task should be run in the background session.';
                        }
                        field(RunTaskNow; Rec."Run Task Now")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Run immediately';
                            ToolTip = 'Specifies whether the task should be run immediately in the background session.';
                        }
                    }
                }
                group(TransferExistingDataDataUpgradeAgreement)
                {
                    ShowCaption = false;

                    field(TransferExistingDataAgreed; DataUpgradeAgreed)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'I accept the data update';
                        ToolTip = 'Specifies whether the user does understand the update procedure and agree to proceed.';
                    }
                }
            }
            group(FeaturesStepParent)
            {
                Visible = FeaturesStepEnabled;
                group(FeaturesStepChild)
                {
                    Caption = 'Specify the features of the IRS Forms';
                    InstructionalText = 'Specify how the IRS Forms feature will be used in your company.';
                    field("Collect Details For Line"; Rec."Collect Details For Line")
                    {
                        ToolTip = 'Specifies if the mapping between the IRS 1099 Form Line and associated vendor ledger entries must be kept. That will allow you to drill-down into the Amount field, but requires an extra space in the database.';
                    }
                    field("Protect TIN"; Rec."Protect TIN")
                    {
                        ToolTip = 'Specifies if the TIN of the vendor/company must be protected when printing reports.';
                    }
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


            group(FinishedParent)
            {
                ShowCaption = false;
                Visible = FinishActionEnabled;
                group(FinishedChild)
                {
                    Caption = 'The IRS Forms setup is completed!';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        Caption = '';
                        InstructionalText = 'You''re ready to use the IRS Forms functionality! Open the IRS Reporting Periods to access the setup and documents.';
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

    trigger OnQueryClosePage(CloseAction: action): Boolean;
    begin
        if CloseAction = CloseAction::OK then
            if SetupCompleted then
                FeatureTelemetry.LogUptake('0000MHX', IRSFormsTok, Enum::"Feature Uptake Status"::"Set up")
            else
                if not Confirm(SetupNotCompletedQst) then
                    Error('');

    end;

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        Rec.InitSetup();
        CanTransferData := true;
        case true of
            Rec."Data Transfer Error Message" <> '':
                DataTransferStatus := StrSubstNo(DataTransferFailedErr, Rec."Data Transfer Error Message");
            Rec.DataTransferInProgress():
                begin
                    DataTransferStatus := 'Data transfer is in progress';
                    CanTransferData := false;
                end;
            Rec."Data Transfer Completed":
                begin
                    DataTransferStatus := 'Data transfer has been completed';
                    CanTransferData := false;
                end;
        end;
        CanCreateTask := TaskScheduler.CanCreateTask();
        FeatureTelemetry.LogUptake('0000MJO', IRSFormsTok, Enum::"Feature Uptake Status"::Discovered);
        Commit();

        Step := Step::Start;
        EnableControls();
    end;

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        MediaRepositoryDone, MediaRepositoryStandard : Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CreateNewSetup, TransferExistingData : Boolean;
        Step: Option Start,Data,TransferExistingData,Features,Finish;
        DataStepEnabled, TransferExistingDataStepEnabled : Boolean;
        FeaturesStepEnabled, BackActionEnabled, FinishActionEnabled, NextActionEnabled : Boolean;
        WelcomeStepVisible, TopBannerVisible, SetupCompleted, DataUpgradeAgreed, CanCreateTask : Boolean;
        CanTransferData: Boolean;
        DataTransferStatus: Text;
        SkipDataSetupStepQst: Label 'You have not chosen to create a new setup or to transfer the existing date.\\Are you sure that you want to skip this step and set up the feature manually?';
        ReviewUpdatedDataTok: Label 'Records from several Base Application tables will be copied to the new IRS Forms App tables. Please review affected data as the data update can take longer in case of large amount of records. In case of large amount of records you can consider a run in background session option. The data update process starts when you finish the guide.';
        ReviewDataLinkTok: Label 'Review affected data';
        SetupNotCompletedQst: Label 'Set up of IRS Forms has not been completed.\\Are you sure that you want to exit?';
        DataUpdateNotAcceptedErr: Label 'Please, accept the data update to proceed.';
        DataTransferFailedErr: Label 'The data transfer failed: %1.', Comment = '%1 = error message.';
        IRSFormsTok: Label 'IRS Forms', Locked = true;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::Data:
                ShowDataStep();
            Step::TransferExistingData:
                TransferExistingDataStep();
            Step::Features:
                ShowFeaturesStep();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure FinishAction();
    var
        IRSFormsData: Codeunit "IRS Forms Data";
        GuidedExperience: Codeunit "Guided Experience";
#if not CLEAN25
        IRSFormsFeature: Codeunit "IRS Forms Feature";
#endif
    begin
        SetupCompleted := true;
        Commit();
#if not CLEAN25
        case true of
            CreateNewSetup:
                IRSFormsData.AddReportingPeriodsWithForms(Rec."Init Reporting Year");
            TransferExistingData:
                IRSFormsFeature.UpgradeFromBaseApplication();
        end;
#else
        if CreateNewSetup then
            IRSFormsData.AddReportingPeriodsWithForms(Rec."Init Reporting Year");
#endif
#if not CLEAN25
        IRSFormsFeature.InsertAssistedSetup();
#endif
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"IRS Forms Guide");
        CurrPage.Close();
    end;

    procedure IsSetupCompleted(): Boolean
    begin
        exit(SetupCompleted);
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if not ValidateControlsBeforeStep(Backwards) then
            exit;
        if Backwards then begin
            if Step = Step::Features then
                Step := Step::Data
            else
                Step -= 1;
        end else
            if (Step = Step::Data) and (not TransferExistingData) then
                Step := Step::Features
            else
                Step += 1;
        EnableControls();
    end;

    local procedure ValidateControlsBeforeStep(Backwards: Boolean): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if (not Backwards) and DataStepEnabled and (not CreateNewSetup) and (not TransferExistingData) then
            if not ConfirmManagement.GetResponse(SkipDataSetupStepQst, false) then
                exit(false);
        if (not Backwards) and TransferExistingDataStepEnabled and (not DataUpgradeAgreed) then begin
            Message(DataUpdateNotAcceptedErr);
            exit(false);
        end;
        exit(true);
    end;

    local procedure ShowWelcomeStep();
    begin
        WelcomeStepVisible := true;
        BackActionEnabled := false;
        NextActionEnabled := true;
        DataStepEnabled := false;
        TransferExistingDataStepEnabled := false;
        FeaturesStepEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowDataStep();
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        DataStepEnabled := true;
        TransferExistingDataStepEnabled := false;
        FeaturesStepEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure TransferExistingDataStep();
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        DataStepEnabled := false;
        TransferExistingDataStepEnabled := true;
        FeaturesStepEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowFeaturesStep();
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        DataStepEnabled := false;
        TransferExistingDataStepEnabled := false;
        FeaturesStepEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish();
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := false;
        DataStepEnabled := false;
        TransferExistingDataStepEnabled := false;
        FeaturesStepEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        DataStepEnabled := false;
        TransferExistingDataStepEnabled := false;
        FeaturesStepEnabled := false;
        WelcomeStepVisible := false;
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

    local procedure ReviewData();
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Clear(DataUpgradeOverview);
#if not CLEAN25
        CountUpdatedRecords();
#endif
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;

#if not CLEAN25
    local procedure CountUpdatedRecords()
    var
#pragma warning disable AL0432
        IRS1099FormBox: Record "IRS 1099 Form-Box";
#pragma warning restore AL0432
        Vendor: Record Vendor;
#pragma warning disable AL0432
        IRS1099Adjustment: Record "IRS 1099 Adjustment";
#pragma warning restore AL0432
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        TempDocumentEntry.Reset();
        TempDocumentEntry.DeleteAll();
#pragma warning disable AL0432
        InsertDocumentEntry(Database::"IRS 1099 Form-Box", IRS1099FormBox.TableCaption(), IRS1099FormBox.Count);
        Vendor.SetFilter("IRS 1099 Code", '<>%1', '');
        InsertDocumentEntry(Database::Vendor, Vendor.TableCaption(), Vendor.Count);
        IRS1099Adjustment.SetRange(Year, Rec."Init Reporting Year");
        InsertDocumentEntry(Database::"IRS 1099 Adjustment", IRS1099Adjustment.TableCaption(), IRS1099Adjustment.Count);
        VendorLedgerEntry.SetRange("Posting Date", DMY2Date(1, 1, Rec."Init Reporting Year"), DMY2Date(31, 12, Rec."Init Reporting Year"));
        VendorLedgerEntry.SetFilter("IRS 1099 Code", '<>%1', '');
        InsertDocumentEntry(Database::"Vendor Ledger Entry", VendorLedgerEntry.TableCaption(), VendorLedgerEntry.Count);
        PurchaseHeader.SetRange("Posting Date", DMY2Date(1, 1, Rec."Init Reporting Year"), DMY2Date(31, 12, Rec."Init Reporting Year"));
        PurchaseHeader.SetFilter("IRS 1099 Code", '<>%1', '');
        InsertDocumentEntry(Database::"Purchase Header", PurchaseHeader.TableCaption(), PurchaseHeader.Count);
        PurchInvHeader.SetRange("Posting Date", DMY2Date(1, 1, Rec."Init Reporting Year"), DMY2Date(31, 12, Rec."Init Reporting Year"));
        PurchInvHeader.SetFilter("IRS 1099 Code", '<>%1', '');
        InsertDocumentEntry(Database::"Purch. Inv. Header", PurchInvHeader.TableCaption(), PurchInvHeader.Count);
        PurchCrMemoHdr.SetRange("Posting Date", DMY2Date(1, 1, Rec."Init Reporting Year"), DMY2Date(31, 12, Rec."Init Reporting Year"));
        PurchCrMemoHdr.SetFilter("IRS 1099 Code", '<>%1', '');
        InsertDocumentEntry(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.TableCaption(), PurchCrMemoHdr.Count);
#pragma warning restore AL0432
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
#endif
}
