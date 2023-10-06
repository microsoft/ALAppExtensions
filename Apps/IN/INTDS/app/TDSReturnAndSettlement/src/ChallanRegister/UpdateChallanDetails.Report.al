// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Foundation.Company;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

report 18748 "Update Challan Details"
{
    Caption = 'Update Challan Details';
    ProcessingOnly = true;
    UseRequestPage = true;
    UsageCategory = ReportsAndAnalysis;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Pay TDS Document No."; PayTDSDocNo)
                    {
                        Caption = 'Pay TDS Document No.';
                        ToolTip = 'Specifies the document number of the TDS entry to be paid to government.';
                        ApplicationArea = Basic, Suite;
                    }
                    field("Challan No."; ChallanNo)
                    {
                        Caption = 'Challan No.';
                        ToolTip = 'Specifies the challan number provided by the bank while depositing the TDS amount.';
                        ApplicationArea = Basic, Suite;
                    }
                    field("Challan Date"; ChallanDate)
                    {
                        Caption = 'Challan Date';
                        ToolTip = 'Specifies the challan date on which TDS is paid to government.';
                        ApplicationArea = Basic, Suite;
                    }
                    field("Bank Name"; BankName)
                    {
                        Caption = 'Bank Name';
                        ToolTip = 'Specifies the name of the bank where TDS amount has been deposited.';
                        ApplicationArea = Basic, Suite;
                    }
                    field("BSR Code"; BSRCode)
                    {
                        Caption = 'BSR Code';
                        ToolTip = 'Specifies the Basic Statistical Return Code provided by the bank while depositing the TDS amount.';
                        ApplicationArea = Basic, Suite;
                    }
                    field("Check No."; CheckNo)
                    {
                        Caption = 'Cheque No.';
                        ToolTip = 'Specifies the No. of the check through which payment has been made.';
                        ApplicationArea = Basic, Suite;
                    }
                    field("Check Date"; CheckDate)
                    {
                        Caption = 'Cheque Date';
                        ToolTip = 'Specifies the date of the check through which payment has been made.';
                        ApplicationArea = Basic, Suite;
                    }
                    field("Minor Head Code"; MinorHeadCode)
                    {
                        Caption = 'Minor Head Code';
                        ToolTip = 'Specifies the minor head code used for the payment.';
                        ApplicationArea = Basic, Suite;
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
        PayTDSDocNoErr: Label 'Enter Pay TDS Document No.';
        ChallanNoErr: Label 'Enter Challan No.';
        ChallanDateErr: Label 'Enter Challan Date.';
        BSRCodeErr: Label 'Enter BSR Code.';
        BankNameErr: Label 'Enter Bank Name.';
        MinorHeadCodeNotBlankErr: Label 'Minor Head Code must not be Blank.';
        BSRLengthErr: Label 'BSR code must have at least 7 digits.';
    begin
        CompanyInformation.Get();
        if PayTDSDocNo = '' then
            Error(PayTDSDocNoErr);

        if ChallanNo = '' then
            Error(ChallanNoErr);

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

        UpdateTDSRegister();
    end;

    var
        ChallanNo: Code[5];
        ChallanDate: Date;
        BankName: Text[100];
        PayTDSDocNo: Code[20];
        BSRCode: Text[7];
        CheckNo: Code[10];
        CheckDate: Date;
        MinorHeadCode: Enum "Minor Head Type";

    procedure SetDocumentNo(DocumentNo: Code[20])
    begin
        PayTDSDocNo := DocumentNo;
    end;

    local procedure UpdateChallanRegister()
    var
        TDSChallanRegister: Record "TDS Challan Register";
        TDSEntry: Record "TDS Entry";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        TDSEntry.SetCurrentKey("Pay TDS Document No.", "Posting Date");
        TDSEntry.SetRange("Challan No.", ChallanNo);
        TDSEntry.FindLast();

        TDSChallanRegister.Reset();
        TDSChallanRegister.SetRange("Pay TDS Document No.", PayTDSDocNo);
        TDSChallanRegister.SetRange("TDS Payment Date", TDSEntry."TDS Payment Date");
        if TDSChallanRegister.FindFirst() then begin
            TDSChallanRegister."Last Bank Challan No." := TDSChallanRegister."Challan No.";
            TDSChallanRegister."Last Bank-Branch Code" := TDSChallanRegister."BSR Code";
            TDSChallanRegister."Last Date of Challan No." := TDSChallanRegister."Last Date of Challan No.";
            TDSChallanRegister."Challan No." := ChallanNo;
            TDSChallanRegister."BSR Code" := BSRCode;
            TDSChallanRegister."Challan Date" := ChallanDate;
            TDSChallanRegister."Bank Name" := BankName;
            TDSChallanRegister."Minor Head Code" := MinorHeadCode;
            if CompanyInformation."Company Status" = CompanyInformation."Company Status"::Government then begin
                TDSChallanRegister."Last Transfer Voucher No." := TDSChallanRegister."Transfer Voucher No.";
                TDSChallanRegister."Transfer Voucher No." := ChallanNo;
            end;
            TDSChallanRegister.Modify();
        end else begin
            TDSChallanRegister.Init();
            TDSChallanRegister."Challan No." := ChallanNo;
            TDSChallanRegister."Last Bank Challan No." := ChallanNo;
            TDSChallanRegister."BSR Code" := CopyStr(BSRCode, 1, 7);
            TDSChallanRegister."Last Bank-Branch Code" := CopyStr(BSRCode, 1, 7);
            TDSChallanRegister."Challan Date" := ChallanDate;
            TDSChallanRegister."Last Date of Challan No." := ChallanDate;
            TDSChallanRegister."Bank Name" := BankName;
            TDSChallanRegister."Pay TDS Document No." := PayTDSDocNo;
            TDSChallanRegister."Minor Head Code" := MinorHeadCode;
            TDSChallanRegister."TDS Payment Date" := ChallanDate;
            TDSChallanRegister."Non Resident Payment" := TDSEntry."Non Resident Payments";
            TDSChallanRegister."T.A.N. No." := TDSEntry."T.A.N. No.";
            TDSChallanRegister."TDS Section" := TDSEntry.Section;
            TDSChallanRegister."Check / DD No." := TDSEntry."Check/DD No.";
            TDSChallanRegister."Check / DD Date" := TDSEntry."Check Date";
            TDSChallanRegister."Financial Year" := GetFinancialYear(TDSEntry."Posting Date");
            TDSChallanRegister.Quarter := GetQuarter(TDSEntry."Posting Date");
            TDSChallanRegister."Assessment Year" := GetAssessmentYear(TDSEntry."Posting Date");
            if CompanyInformation."Company Status" = CompanyInformation."Company Status"::Government then
                TDSChallanRegister."Transfer Voucher No." := ChallanNo;
            TDSChallanRegister."User ID" := CopyStr(UserId, 1, 50);
            TDSChallanRegister.Insert();
            TDSEntry.Reset();
            TDSEntry.SetRange("Challan No.", TDSChallanRegister."Challan No.");
            TDSEntry.ModifyAll("Challan Register Entry No.", TDSChallanRegister."Entry No.");
        end;
    end;

    local procedure UpdateTDSRegister()
    var
        TDSEntry: Record "TDS Entry";
        NoRecordErr: Label 'There are no records with this document no.';
    begin
        TDSEntry.Reset();
        TDSEntry.SetRange("Pay TDS Document No.", PayTDSDocNo);
        TDSEntry.SetRange("Challan No.", '');
        if TDSEntry.FindSet() then begin
            repeat
                TDSEntry."Challan No." := ChallanNo;
                TDSEntry."Challan Date" := ChallanDate;
                TDSEntry."Bank Name" := BankName;
                TDSEntry."BSR Code" := BSRCode;
                TDSEntry."Check/DD No." := CheckNo;
                TDSEntry."Check Date" := CheckDate;
                TDSEntry."Minor Head Code" := MinorHeadCode;
                TDSEntry.Modify();
            until TDSEntry.Next() = 0;
            UpdateChallanRegister();
        end else
            Message(NoRecordErr);
    end;

    local procedure GetQuarter(EntryDate: Date): Code[10]
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        SetTaxAccountingPeriod(TaxAccountingPeriod, EntryDate);
        if TaxAccountingPeriod.FindFirst() then
            exit(TaxAccountingPeriod.Quarter);
    end;

    local procedure GetFinancialYear(EntryDate: Date): Code[9]
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
    begin
        SetTaxAccountingPeriod(TaxAccountingPeriod, EntryDate);
        if TaxAccountingPeriod.FindFirst() then
            exit(CopyStr(TaxAccountingPeriod."Financial Year", 1, 9));
    end;

    local procedure SetTaxAccountingPeriod(var TaxAccountingPeriod: Record "Tax Accounting Period"; EntryDate: Date)
    begin
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', EntryDate);
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', EntryDate);
        TaxAccountingPeriod.SetRange("Tax Type Code", GetTDSAccountingPeriodType());
    end;

    local procedure GetTDSAccountingPeriodType(): Code[10]
    var
        TDSSetup: Record "TDS Setup";
        TaxType: Record "Tax Type";
    begin
        if not TDSSetup.Get() then
            exit;
        TDSSetup.TestField("Tax Type");

        TaxType.SetRange(Code, TDSSetup."Tax Type");
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
