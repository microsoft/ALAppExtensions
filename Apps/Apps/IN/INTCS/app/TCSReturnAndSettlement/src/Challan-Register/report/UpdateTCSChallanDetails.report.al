// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Foundation.Company;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

report 18870 "Update TCS Challan Details"
{
    Caption = 'Update TCS Challan Details';
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PayTCSDocumentNo; PayTCSDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pay TCS Document No.';
                        ToolTip = 'Specifies the document number of the TCS entry to be paid to government.';
                    }
                    field(ChallanNumber; ChallanNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Challan No.';
                        ToolTip = 'Specifies the challan number provided by the bank while depositing the TCS amount.';
                    }
                    field(ChallanDt; ChallanDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Challan Date';
                        ToolTip = 'Specifies the challan date on which TCS is paid to government.';
                    }
                    field(Bank; BankName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank Name';
                        ToolTip = 'Specifies the name of the bank where TCS amount has been deposited.';
                    }
                    field(BSR; BSRCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'BSR Code';
                        ToolTip = 'Specifies the Basic Statistical Return Code provided by the bank while depositing the TCS amount.';
                    }
                    field(CheckNumber; CheckNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cheque No.';
                        ToolTip = 'Specifies the No. of the check through which payment has been made.';
                    }
                    field(CheckDt; CheckDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cheque Date';
                        ToolTip = 'Specifies the date of the check through which payment has been made.';
                    }
                    field(MinorCode; MinorHeadCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Minor Head Code';
                        ToolTip = 'Specifies the minor head code used for the payment.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            MinorHeadCode := MinorHeadCode::"200";
        end;
    }

    trigger OnPreReport()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        if PayTCSDocNo = '' then
            Error(PayTCSDocNoErr);
        if ChallanNo = '' then
            Error(ChallanNoErr);
        if StrLen(ChallanNo) > 5 then
            Error(ChallanNoLengthValidationErr);
        if ChallanDate = 0D then
            Error(ChallanDateErr);
        if BankName = '' then
            Error(BankNameErr);

        if BSRCode = '' then
            if CompanyInformation."Company Status" <> CompanyInformation."Company Status"::Government then
                Error(BSRCodeErr);

        if StrLen(BSRCode) < 7 then
            if CompanyInformation."Company Status" <> CompanyInformation."Company Status"::Government then
                Error(BSRLengthErr);

        if MinorHeadCode = MinorHeadCode::" " then
            Error(MinorHeadCodeNotBlankErr);

        TCSEntry.Reset();
        TCSEntry.SetRange("Pay TCS Document No.", PayTCSDocNo);
        TCSEntry.SetRange("Challan No.", ' ');
        if TCSEntry.FindSet() then begin
            repeat
                TCSEntry."Challan No." := ChallanNo;
                TCSEntry."Challan Date" := ChallanDate;
                TCSEntry."Bank Name" := BankName;
                TCSEntry."BSR Code" := BSRCode;
                TCSEntry."Check/DD No." := CheckNo;
                TCSEntry."Check Date" := CheckDate;
                TCSEntry."Minor Head Code" := MinorHeadCode;
                TCSEntry.Modify();
            until TCSEntry.Next() = 0;
            UpdateTCSChallanRegister();
        end else
            Error(NoRecordErr);
    end;

    var
        TCSEntry: Record "TCS Entry";
        ChallanNo: Code[5];
        PayTCSDocNo: Code[20];
        CheckNo: Code[10];
        ChallanDate: Date;
        CheckDate: Date;
        BankName: Text[100];
        BSRCode: Text[7];
        MinorHeadCode: Enum "Minor Head Type";
        BSRCodeErr: Label 'You must enter a BSR code.';
        BSRLengthErr: Label 'The BSR code must have at least 7 digits.';
        PayTCSDocNoErr: Label 'You must enter a pay TCS document number.';
        ChallanNoErr: Label 'You must enter a Challan number.';
        ChallanDateErr: Label 'You must enter a Challan date.';
        NoRecordErr: Label 'There are no records with this document number.';
        BankNameErr: Label 'You must enter a bank name.';
        MinorHeadCodeNotBlankErr: Label 'The Minor Head Code field must not be empty.';
        ChallanNoLengthValidationErr: Label 'The Challan number must not be longer than 5 characters.';

    procedure SetDocumentNo(DocumentNo: Code[20])
    begin
        PayTCSDocNo := DocumentNo;
    end;

    local procedure UpdateTCSChallanRegister()
    var
        TCSChallanRegister: Record "TCS Challan Register";
        CompanyInformation: Record "Company Information";
        UpdateTCSEntry: Record "TCS Entry";
    begin
        CompanyInformation.Get();
        TCSEntry.Reset();
        TCSEntry.SetRange("Pay TCS Document No.", PayTCSDocNo);
        TCSEntry.SetCurrentKey("Pay TCS Document No.", "Posting Date");
        TCSEntry.FindLast();

        TCSChallanRegister.SetRange("Challan No.", ChallanNo);
        TCSChallanRegister.SetRange("Challan Date", ChallanDate);
        TCSChallanRegister.SetRange("TCS Payment Date", TCSEntry."TCS Payment Date");
        if TCSChallanRegister.FindFirst() then begin
            TCSChallanRegister."Last Bank Challan No." := TCSChallanRegister."Challan No.";
            TCSChallanRegister."Last Bank-Branch Code" := TCSChallanRegister."BSR Code";
            TCSChallanRegister."Last Date of Challan No." := TCSChallanRegister."Last Date of Challan No.";
            TCSChallanRegister."Challan No." := ChallanNo;
            TCSChallanRegister."BSR Code" := BSRCode;
            TCSChallanRegister."Challan Date" := ChallanDate;
            TCSChallanRegister."Bank Name" := BankName;
            TCSChallanRegister."Minor Head Code" := MinorHeadCode;
            if CompanyInformation."Company Status" = CompanyInformation."Company Status"::Government then begin
                TCSChallanRegister."Last Transfer Voucher No." := TCSChallanRegister."Transfer Voucher No.";
                TCSChallanRegister."Transfer Voucher No." := ChallanNo;
            end;
            TCSChallanRegister.Modify();
        end else begin
            TCSChallanRegister.Init();
            TCSChallanRegister."Challan No." := ChallanNo;
            TCSChallanRegister."Last Bank Challan No." := ChallanNo;
            TCSChallanRegister."BSR Code" := CopyStr(BSRCode, 1, 7);
            TCSChallanRegister."Last Bank-Branch Code" := CopyStr(BSRCode, 1, 7);
            TCSChallanRegister."Challan Date" := ChallanDate;
            TCSChallanRegister."Last Date of Challan No." := ChallanDate;
            TCSChallanRegister."Bank Name" := BankName;
            TCSChallanRegister."Pay TCS Document No." := PayTCSDocNo;
            TCSChallanRegister."Minor Head Code" := MinorHeadCode;
            TCSChallanRegister."TCS Payment Date" := ChallanDate;
            TCSChallanRegister."T.C.A.N. No." := TCSEntry."T.C.A.N. No.";
            TCSChallanRegister."Check / DD No." := TCSEntry."Check/DD No.";
            TCSChallanRegister."Check / DD Date" := TCSEntry."Check Date";
            TCSChallanRegister."TCS Nature of Collection" := TCSEntry."TCS Nature of Collection";
            TCSChallanRegister."Financial Year" := GetFinancialYear(TCSEntry."Posting Date");
            TCSChallanRegister.Quarter := GetQuarter(TCSEntry."Posting Date");
            TCSChallanRegister."Assessment Year" := GetAssessmentYear(TCSEntry."Posting Date");
            if CompanyInformation."Company Status" = CompanyInformation."Company Status"::Government then
                TCSChallanRegister."Transfer Voucher No." := ChallanNo;
            TCSChallanRegister."User ID" := CopyStr(UserId, 1, MaxStrLen(TCSChallanRegister."User ID"));
            TCSChallanRegister.Insert();

            UpdateTCSEntry.Reset();
            UpdateTCSEntry.SetRange("Challan No.", TCSChallanRegister."Challan No.");
            UpdateTCSEntry.ModifyAll("Challan Register Entry No.", TCSChallanRegister."Entry No.");
        end;
    end;

    local procedure GetQuarter(EntryDate: Date): Code[10]
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', EntryDate);
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', EntryDate);
        TaxAccountingPeriod.SetRange("Tax Type Code", GetTCSAccountingPeriodType());
        if TaxAccountingPeriod.FindFirst() then
            exit(TaxAccountingPeriod.Quarter);
    end;

    local procedure GetFinancialYear(EntryDate: Date): Code[10]
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', EntryDate);
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', EntryDate);
        TaxAccountingPeriod.SetRange("Tax Type Code", GetTCSAccountingPeriodType());
        if TaxAccountingPeriod.FindFirst() then
            exit(TaxAccountingPeriod."Financial Year");
    end;

    local procedure GetTCSAccountingPeriodType(): Code[10]
    var
        TCSSetup: Record "TCS Setup";
        TaxType: Record "Tax Type";
    begin
        TCSSetup.Get();
        TCSSetup.TestField("Tax Type");
        TaxType.SetRange(Code, TCSSetup."Tax Type");
        if TaxType.FindFirst() then
            exit(TaxType."Accounting Period");
    end;

    local procedure GetAssessmentYear(EntryDate: Date): Code[6]
    var
        StartDate: Date;
        EndDate: Date;
    begin
        StartDate := GetAccountingStartEndDate(EntryDate, 0);
        EndDate := GetAccountingStartEndDate(EntryDate, 1);
        if Date2DMY(StartDate, 3) = Date2DMY(EndDate, 3) then
            exit(Format(Date2DMY(StartDate, 3) + 1));

        exit(Format(Date2DMY(EndDate, 3)) + Format(CalcDate('<+1Y>', EndDate), 2, '<Year,2>'));
    end;

    local procedure GetAccountingStartEndDate(ReferenceDate: Date; StartorEnd: Integer): Date
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        TaxAccountingPeriod.Reset();
        TaxAccountingPeriod.SetRange(Closed, false);
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', ReferenceDate);
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', ReferenceDate);
        if TaxAccountingPeriod.FindLast() then begin
            if StartorEnd = 0 then
                exit(TaxAccountingPeriod."Starting Date");

            exit(TaxAccountingPeriod."Ending Date");
        end;
    end;
}
