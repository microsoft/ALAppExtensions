// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using System.Environment;
using System.Telemetry;

codeunit 10042 "IRS Reporting Period"
{
    Access = Internal;

    var
        Telemetry: Codeunit Telemetry;
        TableWithRecordsCountMsg: Label '\\%2: %1 records', Comment = '%1 = number of records, %2 = caption of the table';
#if not CLEAN28
        ReportingPeriodAlreadyHasSetupMsg: Label 'The reporting period already has setup.';
#endif
        SamePeriodFromAndPeriodToErr: Label 'The From Period cannot be the same as the To Period';
        CopiedSetupWithDetailsMsg: Label 'The setup has been copied from %1 to %2. Details:', Comment = '%1 = From Period, %2 = To Period';
        NothingToCopyMsg: Label 'Nothing to copy';
        ConsecutiveTYUpdateErr: Label 'Updating IRS form boxes is only allowed from one year to the next consecutive year. Updating from %1 to %2 is not allowed.', Comment = '%1 = From Year, %2 = To Year';
        MISC14DocumentsExistErr: Label 'The update of form boxes to tax year 2025 cannot be performed because there are existing 1099 form documents for MISC-14 form box. \Delete the existing form documents and try again.';
        Show1099FormDocumentsTxt: Label 'Show 1099 Form Documents';
        TY2024To2025UpdateCompletedMsg: Label 'The IRS form boxes have been updated to tax year 2025. \Excess golden parachute payments have been moved from MISC-14 to NEC-03 form box. Details:';
        AddedFormBoxMsg: Label '\\Added form box: %1', Comment = '%1 = form box number';
        DeletedFormBoxMsg: Label '\\Deleted form box: %1', Comment = '%1 = form box number';
        UpdatedVendorsMsg: Label '\\Updated vendors';
        UpdatedVendorDocsMsg: Label '\\Updated vendor documents';
        UpdatedPostedVendorDocsMsg: Label '\\Updated posted vendor documents';
        FormBoxUpdateWarningTitleTxt: Label 'IRS Form Box Changes Detected';
        FormBoxUpdateWarningMsg: Label 'The IRS has moved Excess Golden Parachute Payments from form box MISC-14 to NEC-03 for tax year 2025.\\Your data can be updated automatically to reflect this change.\\Choose how to proceed:';
        AutoUpdateOptionTxt: Label 'Automatically update data (Recommended)';
        ManualUpdateOptionTxt: Label 'Proceed without updating (Manual update required)';
        CancelOptionTxt: Label 'Cancel';
        FormBoxUpdate2025TelemetryMsg: Label 'Form box update 2024->2025: user selected option: %1', Comment = '%1 = user choice number', Locked = true;
        UpdatedVendorFormBoxSetupsTelemetryMsg: Label 'Updated vendor form box setups: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;
        UpdatedVendorFormBoxAdjustmentsTelemetryMsg: Label 'Updated vendor form box adjustments: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;
        UpdatedGenJournalLinesTelemetryMsg: Label 'Updated Gen. Journal Lines: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;
        UpdatedPurchaseHeadersTelemetryMsg: Label 'Updated Purchase Headers: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;
        UpdatedVendorLedgerEntriesTelemetryMsg: Label 'Updated Vendor Ledger Entries: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;
        UpdatedPostedGenJournalLinesTelemetryMsg: Label 'Updated Posted Gen. Journal Lines: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;
        UpdatedPurchInvHeadersTelemetryMsg: Label 'Updated Purch. Inv. Headers: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;
        UpdatedPurchCrMemoHeadersTelemetryMsg: Label 'Updated Purch. Cr. Memo Headers: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;
        UpdatedPurchaseHeaderArchivesTelemetryMsg: Label 'Updated Purchase Header Archives: %1 -> %2', Comment = '%1 = from form box no, %2 = to form box no', Locked = true;

    procedure ShowIRSFormsGuideNotificationIfRequired()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        Notification: Notification;
        RunIRSFormsGuideQst: Label 'Do you want to run IRS Forms Guide to complete the setup?';
        OpenIRSFormsGuidePageLbl: Label 'Open IRS Forms Guide';
    begin
        if not IRSReportingPeriod.IsEmpty() then
            exit;
        Notification.Id := GetShowIRSFormsGuideIfRequiredNotificatioId();
        if Notification.Recall() then;
        Notification.Message := RunIRSFormsGuideQst;
        Notification.Scope(NotificationScope::LocalScope);
        Notification.AddAction(OpenIRSFormsGuidePageLbl, Codeunit::"IRS Reporting Period", 'OpenIRSFormsGuidePageFromNotification');
        Notification.Send();
    end;

    procedure OpenIRSFormsGuidePageFromNotification(Notification: Notification)
    var
        IRSFormsGuide: Page "IRS Forms Guide";
    begin
        IRSFormsGuide.Run();
    end;

    procedure GetReportingPeriod(PostingDate: Date): Code[20]
    begin
        exit(GetReportingPeriod(PostingDate, PostingDate));
    end;

    procedure GetReportingPeriod(StartingDate: Date; EndingDate: Date): Code[20]
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSReportingPeriod.SetFilter("Starting Date", '<=%1', StartingDate);
        IRSReportingPeriod.SetFilter("Ending Date", '>=%1', EndingDate);
        if IRSReportingPeriod.FindFirst() then
            exit(IRSReportingPeriod."No.");
    end;

#if not CLEAN28
#pragma warning disable AL0432
    [Obsolete('Not used anymore', '28.0')]
    procedure CopyReportingPeriodSetup(Notification: Notification)
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        PeriodNo: Text;
    begin
        PeriodNo := Notification.GetData('ToPeriodNo');
        CopyReportingPeriodSetup(CopyStr(PeriodNo, 1, MaxStrLen(IRSReportingPeriod."No.")));
    end;

    [Obsolete('Use CopyReportingPeriodSetup with FromPeriodNo parameter instead.', '28.0')]
    procedure CopyReportingPeriodSetup(ToPeriodNo: Code[20])
    var
        IRS1099Form: Record "IRS 1099 Form";
        IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
        IRS1099CopySetupFrom: Report "IRS 1099 Copy Setup From";
    begin
        IRS1099Form.SetRange("Period No.", ToPeriodNo);
        if not IRS1099Form.IsEmpty() then
            error(ReportingPeriodAlreadyHasSetupMsg);
        IRS1099FormStatementLine.SetRange("Period No.", ToPeriodNo);
        if not IRS1099FormStatementLine.IsEmpty() then
            error(ReportingPeriodAlreadyHasSetupMsg);
        IRS1099CopySetupFrom.InitializeRequest(ToPeriodNo);
        IRS1099CopySetupFrom.RunModal();
    end;
#pragma warning restore AL0432
#endif

    procedure CopyReportingPeriodSetupFrom(FromPeriodNo: Code[20])
    var
        IRS1099CopySetupFrom: Report "IRS 1099 Copy Setup From";
    begin
        IRS1099CopySetupFrom.SetCopyPeriodFrom(FromPeriodNo);
        IRS1099CopySetupFrom.RunModal();
    end;

    procedure CopyReportingPeriodSetup(FromPeriodNo: Code[20]; ToPeriodNo: Code[20])
    var
        TempSelectedCompany: Record Company temporary;
    begin
        TempSelectedCompany.Name := CopyStr(CompanyName(), 1, MaxStrLen(TempSelectedCompany.Name));
        TempSelectedCompany.Insert();
        CopyReportingPeriodSetup(FromPeriodNo, ToPeriodNo, TempSelectedCompany);
    end;

    procedure CopyReportingPeriodSetup(FromPeriodNo: Code[20]; ToPeriodNo: Code[20]; var TempSelectedCompany: Record Company temporary)
    var
        CurrCompanyIRSReportingPeriod, IRSReportingPeriod : Record "IRS Reporting Period";
        SetupCompletedMessage: Text;
        SomethingHasBeenCopied, SummaryMessageCreated : Boolean;
    begin
        if not TempSelectedCompany.FindSet() then begin
            Telemetry.LogMessage('0000QK6', 'No companies selected to copy IRS 1099 setup', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        CurrCompanyIRSReportingPeriod.Get(ToPeriodNo);
        SetupCompletedMessage := StrSubstNo(CopiedSetupWithDetailsMsg, FromPeriodNo, ToPeriodNo);
        repeat
            IRSReportingPeriod.ChangeCompany(TempSelectedCompany.Name);
            if not IRSReportingPeriod.Get(CurrCompanyIRSReportingPeriod."No.") then begin
                IRSReportingPeriod := CurrCompanyIRSReportingPeriod;
                IRSReportingPeriod.Insert();
            end;
            CopyReportingPeriodSetupPerCompany(SetupCompletedMessage, SomethingHasBeenCopied, SummaryMessageCreated, FromPeriodNo, ToPeriodNo, TempSelectedCompany.Name);
        until TempSelectedCompany.Next() = 0;
        if SomethingHasBeenCopied then
            Message(SetupCompletedMessage, FromPeriodNo, ToPeriodNo)
        else
            Message(NothingToCopyMsg);
    end;

    local procedure CopyReportingPeriodSetupPerCompany(var SetupCompletedMessage: Text; var SomethingHasBeenCopied: Boolean; var SummaryMessageCreated: Boolean; FromPeriodNo: Code[20]; ToPeriodNo: Code[20]; CompanyNameToUpdate: Text[30])
    var
        IRS1099Form: Record "IRS 1099 Form";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
        IRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
        NewIRS1099Form: Record "IRS 1099 Form";
        NewIRS1099FormBox: Record "IRS 1099 Form Box";
        NewIRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        NewIRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        NewIRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
    begin
        if FromPeriodNo = ToPeriodNo then
            Error(SamePeriodFromAndPeriodToErr);

        NewIRS1099Form.ChangeCompany(CompanyNameToUpdate);
        NewIRS1099FormBox.ChangeCompany(CompanyNameToUpdate);
        NewIRS1099FormStatementLine.ChangeCompany(CompanyNameToUpdate);
        NewIRS1099VendorFormBoxSetup.ChangeCompany(CompanyNameToUpdate);
        NewIRS1099VendorFormBoxAdj.ChangeCompany(CompanyNameToUpdate);

        IRS1099Form.SetRange("Period No.", FromPeriodNo);
        if IRS1099Form.FindSet() then begin
            repeat
                NewIRS1099Form := IRS1099Form;
                NewIRS1099Form."Period No." := ToPeriodNo;
                NewIRS1099Form.Insert();
            until IRS1099Form.Next() = 0;
            UpdateSummaryMessage(SetupCompletedMessage, SomethingHasBeenCopied, IRS1099Form.TableCaption, IRS1099Form.Count(), SummaryMessageCreated);
        end;
        IRS1099FormBox.SetRange("Period No.", FromPeriodNo);
        if IRS1099FormBox.FindSet() then begin
            repeat
                NewIRS1099FormBox := IRS1099FormBox;
                NewIRS1099FormBox."Period No." := ToPeriodNo;
                NewIRS1099FormBox.Insert();
            until IRS1099FormBox.Next() = 0;
            UpdateSummaryMessage(SetupCompletedMessage, SomethingHasBeenCopied, IRS1099FormBox.TableCaption, IRS1099FormBox.Count(), SummaryMessageCreated);
        end;
        IRS1099VendorFormBoxSetup.SetRange("Period No.", FromPeriodNo);
        if IRS1099VendorFormBoxSetup.FindSet() then begin
            repeat
                NewIRS1099VendorFormBoxSetup := IRS1099VendorFormBoxSetup;
                NewIRS1099VendorFormBoxSetup."Period No." := ToPeriodNo;
                NewIRS1099VendorFormBoxSetup.Insert();
            until IRS1099VendorFormBoxSetup.Next() = 0;
            UpdateSummaryMessage(SetupCompletedMessage, SomethingHasBeenCopied, IRS1099VendorFormBoxSetup.TableCaption, IRS1099VendorFormBoxSetup.Count(), SummaryMessageCreated);
        end;
        IRS1099FormStatementLine.SetRange("Period No.", FromPeriodNo);
        if IRS1099FormStatementLine.FindSet() then begin
            repeat
                NewIRS1099FormStatementLine := IRS1099FormStatementLine;
                NewIRS1099FormStatementLine."Period No." := ToPeriodNo;
                NewIRS1099FormStatementLine.Insert();
                SomethingHasBeenCopied := true;
            until IRS1099FormStatementLine.Next() = 0;
            UpdateSummaryMessage(SetupCompletedMessage, SomethingHasBeenCopied, IRS1099FormStatementLine.TableCaption, IRS1099FormStatementLine.Count(), SummaryMessageCreated);
        end;
        IRS1099VendorFormBoxAdj.SetRange("Period No.", FromPeriodNo);
        if IRS1099VendorFormBoxAdj.FindSet() then begin
            repeat
                NewIRS1099VendorFormBoxAdj := IRS1099VendorFormBoxAdj;
                NewIRS1099VendorFormBoxAdj."Period No." := ToPeriodNo;
                NewIRS1099VendorFormBoxAdj.Insert();
            until IRS1099VendorFormBoxAdj.Next() = 0;
            UpdateSummaryMessage(SetupCompletedMessage, SomethingHasBeenCopied, IRS1099VendorFormBoxAdj.TableCaption, IRS1099VendorFormBoxAdj.Count(), SummaryMessageCreated);
        end;
        SummaryMessageCreated := true;
    end;

    local procedure UpdateSummaryMessage(var SetupCompletedMessage: Text; var SomethingHasBeenCopied: Boolean; TableCaption: Text; RecordsCount: Integer; SummaryMessageCreated: Boolean)
    begin
        if SummaryMessageCreated then
            exit;
        SomethingHasBeenCopied := true;
        SetupCompletedMessage += StrSubstNo(TableWithRecordsCountMsg, RecordsCount, TableCaption);
    end;

    local procedure GetShowIRSFormsGuideIfRequiredNotificatioId(): Guid
    begin
        exit('c704edeb-3655-4841-85e2-b1a025cc7b49');
    end;

    procedure UpdateDataForNewTaxYear(FromPeriodNo: Code[20]; ToPeriodNo: Code[20]; ConfirmBeforeUpdate: Boolean)
    var
        TempCompany: Record Company temporary;
    begin
        TempCompany.Name := CopyStr(CompanyName(), 1, MaxStrLen(TempCompany.Name));
        TempCompany.Insert();
        UpdateDataForNewTaxYear(FromPeriodNo, ToPeriodNo, TempCompany, ConfirmBeforeUpdate);
    end;

    procedure UpdateDataForNewTaxYear(FromPeriodNo: Code[20]; ToPeriodNo: Code[20]; var TempSelectedCompany: Record Company temporary; ConfirmBeforeUpdate: Boolean)
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        FromYear: Integer;
        ToYear: Integer;
    begin
        if IRSReportingPeriod.Get(FromPeriodNo) then
            FromYear := Date2DMY(IRSReportingPeriod."Ending Date", 3);
        if IRSReportingPeriod.Get(ToPeriodNo) then
            ToYear := Date2DMY(IRSReportingPeriod."Ending Date", 3);

        if (FromYear = 0) or (ToYear = 0) then
            exit;

        if ToYear <> (FromYear + 1) then
            Error(ConsecutiveTYUpdateErr, FromYear, ToYear);

        if (FromYear = 2024) and (ToYear = 2025) then
            if IsUpdateFrom2024To2025Required(ToPeriodNo, TempSelectedCompany, ConfirmBeforeUpdate) then
                if TempSelectedCompany.FindSet() then
                    repeat
                        UpdateFormBoxesFrom2024To2025(ToPeriodNo, TempSelectedCompany.Name);
                    until TempSelectedCompany.Next() = 0;
    end;

    local procedure IsUpdateFrom2024To2025Required(PeriodNo2025: Code[20]; var TempSelectedCompany: Record Company temporary; ConfirmBeforeUpdate: Boolean): Boolean
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
        MISC14Exists: Boolean;
        NEC03Exists: Boolean;
        UserChoice: Integer;
        UpdateRequired: Boolean;
    begin
        UpdateRequired := false;

        // Check companies one by one until we find one that needs update
        if TempSelectedCompany.FindSet() then
            repeat
                IRS1099FormBox.ChangeCompany(TempSelectedCompany.Name);
                MISC14Exists := IRS1099FormBox.Get(PeriodNo2025, 'MISC', 'MISC-14');
                NEC03Exists := IRS1099FormBox.Get(PeriodNo2025, 'NEC', 'NEC-03');
                if MISC14Exists or not NEC03Exists then
                    UpdateRequired := true;
            until (TempSelectedCompany.Next() = 0) or UpdateRequired;

        // if no form box changes needed in any company, silently exit
        if not UpdateRequired then
            exit(false);

        // if confirmation is not required, automatically proceed with update
        if not ConfirmBeforeUpdate then
            exit(true);

        // show dialog with options once for all companies
        UserChoice := StrMenu(
            StrSubstNo('%1,%2,%3', AutoUpdateOptionTxt, ManualUpdateOptionTxt, CancelOptionTxt), 1, FormBoxUpdateWarningTitleTxt + '\\' + FormBoxUpdateWarningMsg);

        Telemetry.LogMessage('0000QKO', StrSubstNo(FormBoxUpdate2025TelemetryMsg, UserChoice), Verbosity::Normal, DataClassification::SystemMetadata);

        case UserChoice of
            1: // Automatically update data
                exit(true);
            2: // Proceed without updating
                exit(false);
            0, 3: // Cancel or close dialog
                Error('');
        end;
    end;

    local procedure UpdateFormBoxesFrom2024To2025(PeriodNo2025: Code[20]; CompanyNameToUpdate: Text[30])
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
        IRS1099FormStmtLine: Record "IRS 1099 Form Statement Line";
        IRSFormsData: Codeunit "IRS Forms Data";
        CustomDimensions: Dictionary of [Text, Text];
        IRSFormDocsFilter: Text;
        UpdateCompletedMessage: Text;
        StmtLineNo: Integer;
        VendorsUpdated: Boolean;
        VendorDocsUpdated: Boolean;
        PostedVendorDocsUpdated: Boolean;
        ErrorInfo: ErrorInfo;
    begin
        // Excess Parachute Payment amount moved from MISC-14 in 2024 to NEC-03 in 2025

        // Change company context for all record variables
        IRS1099FormBox.ChangeCompany(CompanyNameToUpdate);
        IRS1099FormStmtLine.ChangeCompany(CompanyNameToUpdate);

        // existing 1099 form documents with MISC-14 form box must be removed manually before updating
        IRSFormDocsFilter := GetIRS1099FormDocsFilter(PeriodNo2025, 'MISC', 'MISC-14', CompanyNameToUpdate);
        if IRSFormDocsFilter <> '' then begin
            ErrorInfo.Message := MISC14DocumentsExistErr;
            CustomDimensions.Add('DocumentIDFilter', IRSFormDocsFilter);
            ErrorInfo.CustomDimensions(CustomDimensions);
            ErrorInfo.AddAction(Show1099FormDocumentsTxt, Codeunit::"IRS Reporting Period", 'ShowIRS1099FormDocsFilteredByID');
            Error(ErrorInfo);
        end;

        // add NEC-03 form box
        if not IRS1099FormBox.Get(PeriodNo2025, 'NEC', 'NEC-03') then begin
            IRSFormsData.AddFormBox(PeriodNo2025, 'NEC', 'NEC-03', 'Excess golden parachute payments', 0);
            UpdateCompletedMessage += StrSubstNo(AddedFormBoxMsg, 'NEC-03');
            Telemetry.LogMessage('0000QKG', StrSubstNo(AddedFormBoxMsg, 'NEC-03'), Verbosity::Normal, DataClassification::SystemMetadata);
        end;

        // add NEC-03 statement line
        IRS1099FormStmtLine.SetRange("Period No.", PeriodNo2025);
        IRS1099FormStmtLine.SetRange("Form No.", 'NEC');
        IRS1099FormStmtLine.SetRange("Row No.", 'NEC-03');
        if not IRS1099FormStmtLine.FindFirst() then begin
            IRS1099FormStmtLine.SetRange("Row No.");
            if IRS1099FormStmtLine.FindLast() then;
            StmtLineNo := IRS1099FormStmtLine."Line No." + 10000;
            IRSFormsData.AddFormStatementLine(PeriodNo2025, 'NEC', 'NEC-03', StmtLineNo, 'Excess golden parachute payments');
        end;

        // update vendor form boxes and adjustments from MISC-14 to NEC-03
        VendorsUpdated := UpdateVendorFormBoxes(PeriodNo2025, 'MISC', 'MISC-14', 'NEC', 'NEC-03', CompanyNameToUpdate);
        if VendorsUpdated then
            UpdateCompletedMessage += UpdatedVendorsMsg;

        // update form box in vendor documents from MISC-14 to NEC-03
        VendorDocsUpdated := UpdateVendorDocs(PeriodNo2025, 'MISC', 'MISC-14', 'NEC', 'NEC-03', CompanyNameToUpdate);
        if VendorDocsUpdated then
            UpdateCompletedMessage += UpdatedVendorDocsMsg;

        // update form box in posted vendor documents from MISC-14 to NEC-03
        PostedVendorDocsUpdated := UpdatePostedVendorDocs(PeriodNo2025, 'MISC', 'MISC-14', 'NEC', 'NEC-03', CompanyNameToUpdate);
        if PostedVendorDocsUpdated then
            UpdateCompletedMessage += UpdatedPostedVendorDocsMsg;

        // remove MISC-14 statement line
        IRS1099FormStmtLine.SetRange("Period No.", PeriodNo2025);
        IRS1099FormStmtLine.SetRange("Form No.", 'MISC');
        IRS1099FormStmtLine.SetRange("Row No.", 'MISC-14');
        IRS1099FormStmtLine.DeleteAll();

        // remove MISC-14 form box
        if IRS1099FormBox.Get(PeriodNo2025, 'MISC', 'MISC-14') then begin
            IRS1099FormBox.Delete();
            UpdateCompletedMessage += StrSubstNo(DeletedFormBoxMsg, 'MISC-14');
            Telemetry.LogMessage('0000QKG', StrSubstNo(DeletedFormBoxMsg, 'MISC-14'), Verbosity::Normal, DataClassification::SystemMetadata);
        end;

        if UpdateCompletedMessage <> '' then begin
            UpdateCompletedMessage := TY2024To2025UpdateCompletedMsg + UpdateCompletedMessage;
            Message(UpdateCompletedMessage);
        end;
    end;

    local procedure GetIRS1099FormDocsFilter(PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; CompanyNameToUpdate: Text[30]) DocumentIDFilter: Text
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        PrevDocID: Integer;
    begin
        IRS1099FormDocLine.ChangeCompany(CompanyNameToUpdate);
        PrevDocID := 0;
        IRS1099FormDocLine.SetRange("Period No.", PeriodNo);
        IRS1099FormDocLine.SetRange("Form No.", FormNo);
        IRS1099FormDocLine.SetRange("Form Box No.", FormBoxNo);
        if IRS1099FormDocLine.FindSet() then
            repeat
                if IRS1099FormDocLine."Document ID" <> PrevDocID then
                    DocumentIDFilter += Format(IRS1099FormDocLine."Document ID") + '|';
                PrevDocID := IRS1099FormDocLine."Document ID";
            until IRS1099FormDocLine.Next() = 0;
        if DocumentIDFilter <> '' then
            DocumentIDFilter := DelChr(DocumentIDFilter, '>', '|');
    end;

    procedure ShowIRS1099FormDocsFilteredByID(ErrorInfo: ErrorInfo)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocuments: Page "IRS 1099 Form Documents";
        CustomDimensions: Dictionary of [Text, Text];
        IRSFormDocsFilter: Text;
    begin
        CustomDimensions := ErrorInfo.CustomDimensions();
        if CustomDimensions.Get('DocumentIDFilter', IRSFormDocsFilter) then begin
            IRS1099FormDocHeader.SetFilter(ID, IRSFormDocsFilter);
            IRS1099FormDocuments.SetTableView(IRS1099FormDocHeader);
        end;
        IRS1099FormDocuments.Run();
    end;

    local procedure UpdateVendorFormBoxes(PeriodNo: Code[20]; FromFormNo: Code[20]; FromFormBoxNo: Code[20]; ToFormNo: Code[20]; ToFormBoxNo: Code[20]; CompanyNameToUpdate: Text[30]) Updated: Boolean
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        NewIRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        IRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
        NewIRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
    begin
        Updated := false;

        IRS1099VendorFormBoxSetup.ChangeCompany(CompanyNameToUpdate);
        NewIRS1099VendorFormBoxSetup.ChangeCompany(CompanyNameToUpdate);
        IRS1099VendorFormBoxAdj.ChangeCompany(CompanyNameToUpdate);
        NewIRS1099VendorFormBoxAdj.ChangeCompany(CompanyNameToUpdate);

        // update vendor form box setups
        IRS1099VendorFormBoxSetup.SetRange("Period No.", PeriodNo);
        IRS1099VendorFormBoxSetup.SetRange("Form No.", FromFormNo);
        IRS1099VendorFormBoxSetup.SetRange("Form Box No.", FromFormBoxNo);
        if IRS1099VendorFormBoxSetup.FindSet() then begin
            repeat
                NewIRS1099VendorFormBoxSetup := IRS1099VendorFormBoxSetup;
                NewIRS1099VendorFormBoxSetup.Delete();
                NewIRS1099VendorFormBoxSetup."Form No." := ToFormNo;
                NewIRS1099VendorFormBoxSetup."Form Box No." := ToFormBoxNo;
                if NewIRS1099VendorFormBoxSetup.Insert() then
                    Updated := true;
            until IRS1099VendorFormBoxSetup.Next() = 0;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedVendorFormBoxSetupsTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;

        // update vendor form box adjustments
        IRS1099VendorFormBoxAdj.SetRange("Period No.", PeriodNo);
        IRS1099VendorFormBoxAdj.SetRange("Form No.", FromFormNo);
        IRS1099VendorFormBoxAdj.SetRange("Form Box No.", FromFormBoxNo);
        if IRS1099VendorFormBoxAdj.FindSet() then begin
            repeat
                NewIRS1099VendorFormBoxAdj := IRS1099VendorFormBoxAdj;
                NewIRS1099VendorFormBoxAdj.Delete();
                NewIRS1099VendorFormBoxAdj."Form No." := ToFormNo;
                NewIRS1099VendorFormBoxAdj."Form Box No." := ToFormBoxNo;
                if NewIRS1099VendorFormBoxAdj.Insert() then
                    Updated := true;
            until IRS1099VendorFormBoxAdj.Next() = 0;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedVendorFormBoxAdjustmentsTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;
    end;

    local procedure UpdateVendorDocs(PeriodNo: Code[20]; FromFormNo: Code[20]; FromFormBoxNo: Code[20]; ToFormNo: Code[20]; ToFormBoxNo: Code[20]; CompanyNameToUpdate: Text[30]) Updated: Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
    begin
        Updated := false;

        GenJournalLine.ChangeCompany(CompanyNameToUpdate);
        PurchaseHeader.ChangeCompany(CompanyNameToUpdate);

        // update Gen. Journal Lines
        GenJournalLine.SetRange("IRS 1099 Reporting Period", PeriodNo);
        GenJournalLine.SetRange("IRS 1099 Form No.", FromFormNo);
        GenJournalLine.SetRange("IRS 1099 Form Box No.", FromFormBoxNo);
        if GenJournalLine.FindSet() then begin
            repeat
                GenJournalLine."IRS 1099 Form No." := ToFormNo;
                GenJournalLine."IRS 1099 Form Box No." := ToFormBoxNo;
                GenJournalLine.Modify();
            until GenJournalLine.Next() = 0;
            Updated := true;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedGenJournalLinesTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;

        // update Purchase Headers
        PurchaseHeader.SetRange("IRS 1099 Reporting Period", PeriodNo);
        PurchaseHeader.SetRange("IRS 1099 Form No.", FromFormNo);
        PurchaseHeader.SetRange("IRS 1099 Form Box No.", FromFormBoxNo);
        if PurchaseHeader.FindSet() then begin
            repeat
                PurchaseHeader."IRS 1099 Form No." := ToFormNo;
                PurchaseHeader."IRS 1099 Form Box No." := ToFormBoxNo;
                PurchaseHeader.Modify();
            until PurchaseHeader.Next() = 0;
            Updated := true;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedPurchaseHeadersTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;
    end;

    local procedure UpdatePostedVendorDocs(PeriodNo: Code[20]; FromFormNo: Code[20]; FromFormBoxNo: Code[20]; ToFormNo: Code[20]; ToFormBoxNo: Code[20]; CompanyNameToUpdate: Text[30]) Updated: Boolean
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchaseHeaderArchive: Record "Purchase Header Archive";
    begin
        Updated := false;

        VendorLedgerEntry.ChangeCompany(CompanyNameToUpdate);
        PostedGenJournalLine.ChangeCompany(CompanyNameToUpdate);
        PurchInvHeader.ChangeCompany(CompanyNameToUpdate);
        PurchCrMemoHdr.ChangeCompany(CompanyNameToUpdate);
        PurchaseHeaderArchive.ChangeCompany(CompanyNameToUpdate);

        // update Vendor Ledger Entries
        VendorLedgerEntry.SetRange("IRS 1099 Reporting Period", PeriodNo);
        VendorLedgerEntry.SetRange("IRS 1099 Form No.", FromFormNo);
        VendorLedgerEntry.SetRange("IRS 1099 Form Box No.", FromFormBoxNo);
        if VendorLedgerEntry.FindSet() then begin
            repeat
                VendorLedgerEntry."IRS 1099 Form No." := ToFormNo;
                VendorLedgerEntry."IRS 1099 Form Box No." := ToFormBoxNo;
                VendorLedgerEntry.Modify();
            until VendorLedgerEntry.Next() = 0;
            Updated := true;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedVendorLedgerEntriesTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;

        // update Posted Gen. Journal Lines
        PostedGenJournalLine.SetRange("IRS 1099 Reporting Period", PeriodNo);
        PostedGenJournalLine.SetRange("IRS 1099 Form No.", FromFormNo);
        PostedGenJournalLine.SetRange("IRS 1099 Form Box No.", FromFormBoxNo);
        if PostedGenJournalLine.FindSet() then begin
            repeat
                PostedGenJournalLine."IRS 1099 Form No." := ToFormNo;
                PostedGenJournalLine."IRS 1099 Form Box No." := ToFormBoxNo;
                PostedGenJournalLine.Modify();
            until PostedGenJournalLine.Next() = 0;
            Updated := true;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedPostedGenJournalLinesTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;

        // update Purch. Inv. Headers
        PurchInvHeader.SetRange("IRS 1099 Reporting Period", PeriodNo);
        PurchInvHeader.SetRange("IRS 1099 Form No.", FromFormNo);
        PurchInvHeader.SetRange("IRS 1099 Form Box No.", FromFormBoxNo);
        if PurchInvHeader.FindSet() then begin
            repeat
                PurchInvHeader."IRS 1099 Form No." := ToFormNo;
                PurchInvHeader."IRS 1099 Form Box No." := ToFormBoxNo;
                PurchInvHeader.Modify();
            until PurchInvHeader.Next() = 0;
            Updated := true;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedPurchInvHeadersTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;

        // update Purch. Cr. Memo Headers
        PurchCrMemoHdr.SetRange("IRS 1099 Reporting Period", PeriodNo);
        PurchCrMemoHdr.SetRange("IRS 1099 Form No.", FromFormNo);
        PurchCrMemoHdr.SetRange("IRS 1099 Form Box No.", FromFormBoxNo);
        if PurchCrMemoHdr.FindSet() then begin
            repeat
                PurchCrMemoHdr."IRS 1099 Form No." := ToFormNo;
                PurchCrMemoHdr."IRS 1099 Form Box No." := ToFormBoxNo;
                PurchCrMemoHdr.Modify();
            until PurchCrMemoHdr.Next() = 0;
            Updated := true;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedPurchCrMemoHeadersTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;

        // update Purchase Header Archives
        PurchaseHeaderArchive.SetRange("IRS 1099 Reporting Period", PeriodNo);
        PurchaseHeaderArchive.SetRange("IRS 1099 Form No.", FromFormNo);
        PurchaseHeaderArchive.SetRange("IRS 1099 Form Box No.", FromFormBoxNo);
        if PurchaseHeaderArchive.FindSet() then begin
            repeat
                PurchaseHeaderArchive."IRS 1099 Form No." := ToFormNo;
                PurchaseHeaderArchive."IRS 1099 Form Box No." := ToFormBoxNo;
                PurchaseHeaderArchive.Modify();
            until PurchaseHeaderArchive.Next() = 0;
            Updated := true;
            Telemetry.LogMessage('0000QKG', StrSubstNo(UpdatedPurchaseHeaderArchivesTelemetryMsg, FromFormBoxNo, ToFormBoxNo), Verbosity::Normal, DataClassification::SystemMetadata);
        end;
    end;
}
