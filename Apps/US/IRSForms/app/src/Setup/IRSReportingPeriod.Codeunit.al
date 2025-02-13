// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 10042 "IRS Reporting Period"
{
    Access = Internal;

    var
        TableWithRecordsCountMsg: Label '\\%2: %1 records', Comment = '%1 = number of records, %2 = caption of the table';
        ReportingPeriodAlreadyHasSetupMsg: Label 'The reporting period already has setup.';
        SamePeriodFromAndPeriodToErr: Label 'The From Period cannot be the same as the To Period';
        CopiedSetupWithDetailsMsg: Label 'The setup has been copied from %1 to %2. Details:', Comment = '%1 = From Period, %2 = To Period';
        NothingToCopyMsg: Label 'Nothing to copy';

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

    procedure CopyReportingPeriodSetup(Notification: Notification)
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        PeriodNo: Text;
    begin
        PeriodNo := Notification.GetData('ToPeriodNo');
        CopyReportingPeriodSetup(CopyStr(PeriodNo, 1, MaxStrLen(IRSReportingPeriod."No.")));
    end;

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

    procedure CopyReportingPeriodSetup(FromPeriodNo: Code[20]; ToPeriodNo: Code[20])
    var
        IRS1099Form: Record "IRS 1099 Form";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
        NewIRS1099Form: Record "IRS 1099 Form";
        NewIRS1099FormBox: Record "IRS 1099 Form Box";
        NewIRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        NewIRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        SetupCompletedMessage: Text;
        SomethingHasBeenCopied: Boolean;
    begin
        if FromPeriodNo = ToPeriodNo then
            Error(SamePeriodFromAndPeriodToErr);
        SetupCompletedMessage := CopiedSetupWithDetailsMsg;
        IRS1099Form.SetRange("Period No.", FromPeriodNo);
        if IRS1099Form.FindSet() then begin
            SomethingHasBeenCopied := true;
            SetupCompletedMessage += StrSubstNo(TableWithRecordsCountMsg, IRS1099Form.Count(), IRS1099Form.TableCaption);
            repeat
                NewIRS1099Form := IRS1099Form;
                NewIRS1099Form."Period No." := ToPeriodNo;
                NewIRS1099Form.Insert();
            until IRS1099Form.Next() = 0;
        end;
        IRS1099FormBox.SetRange("Period No.", FromPeriodNo);
        if IRS1099FormBox.FindSet() then begin
            SomethingHasBeenCopied := true;
            SetupCompletedMessage += StrSubstNo(TableWithRecordsCountMsg, IRS1099FormBox.Count(), IRS1099FormBox.TableCaption);
            repeat
                NewIRS1099FormBox := IRS1099FormBox;
                NewIRS1099FormBox."Period No." := ToPeriodNo;
                NewIRS1099FormBox.Insert();
            until IRS1099FormBox.Next() = 0;
        end;
        IRS1099VendorFormBoxSetup.SetRange("Period No.", FromPeriodNo);
        if IRS1099VendorFormBoxSetup.FindSet() then begin
            SomethingHasBeenCopied := true;
            SetupCompletedMessage += StrSubstNo(TableWithRecordsCountMsg, IRS1099VendorFormBoxSetup.Count(), IRS1099VendorFormBoxSetup.TableCaption);
            repeat
                NewIRS1099VendorFormBoxSetup := IRS1099VendorFormBoxSetup;
                NewIRS1099VendorFormBoxSetup."Period No." := ToPeriodNo;
                NewIRS1099VendorFormBoxSetup.Insert();
            until IRS1099VendorFormBoxSetup.Next() = 0;
        end;
        IRS1099FormStatementLine.SetRange("Period No.", FromPeriodNo);
        if IRS1099FormStatementLine.FindSet() then begin
            SomethingHasBeenCopied := true;
            SetupCompletedMessage += StrSubstNo(TableWithRecordsCountMsg, IRS1099FormStatementLine.Count(), IRS1099FormStatementLine.TableCaption);
            repeat
                NewIRS1099FormStatementLine := IRS1099FormStatementLine;
                NewIRS1099FormStatementLine."Period No." := ToPeriodNo;
                NewIRS1099FormStatementLine.Insert();
                SomethingHasBeenCopied := true;
            until IRS1099FormStatementLine.Next() = 0;
        end;
        if SomethingHasBeenCopied then
            Message(SetupCompletedMessage, FromPeriodNo, ToPeriodNo)
        else
            Message(NothingToCopyMsg);
    end;
}
