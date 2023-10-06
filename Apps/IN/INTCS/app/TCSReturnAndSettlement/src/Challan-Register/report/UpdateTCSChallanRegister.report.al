// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Foundation.Company;
using Microsoft.Finance.TaxBase;

report 18871 "Update TCS Challan Register"
{
    Caption = 'Update TCS Challan Register';
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem("TCS Challan Register"; "TCS Challan Register")
        {
            DataItemTableView = sorting("Entry No.");

            trigger OnAfterGetRecord()
            begin
                "TCS Interest Amount" := InterestAmount;
                "TCS Others" := OtherAmount;
                "TCS Fee" := LateFee;
                "Paid By Book Entry" := PaidByBook;
                "Transfer Voucher No." := TransferVoucherNo;
                Modify();
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Entry No.", EntryNo);
            end;
        }
    }

    requestpage
    {
        SaveValues = false;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(InterestAmt; InterestAmount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Interest Amount';
                        ToolTip = 'Specifies the value of interest payable.';
                    }
                    field(OthersAmt; OtherAmount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Others';
                        ToolTip = 'Specifies the value of other charges payable.';
                    }
                    field(TCSFees; LateFee)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fee';
                        ToolTip = 'Specifies the value of fees payable.';
                    }
                    field(PaidByBookEntry; PaidByBook)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Paid By Book Entry';
                        ToolTip = 'Select this field to specify that challan has been paid by book entry.';

                        trigger OnValidate()
                        begin
                            if not (CompanyInformation."Company Status" = CompanyInformation."Company Status"::Government) and (PaidByBook = TRUE) then
                                Error(PaidByBookErr);
                        end;
                    }
                    field(TransferVoucherNumber; TransferVoucherNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Transfer Voucher No.';
                        ToolTip = 'Specifies the transfer voucher reference.';
                    }
                }
            }
        }

    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        PaidByBook := false;
    end;

    trigger OnPreReport()
    begin
        DeductorCategory.Get(CompanyInformation."Deductor Category");
        if DeductorCategory."Transfer Voucher No. Mandatory" and (TransferVoucherNo = '') then
            Error(DeductorCategErr, DeductorCategory.Code, DeductorCategory.Description);
        if not DeductorCategory."Transfer Voucher No. Mandatory" and (TransferVoucherNo <> '') then
            Error(DeductorCatVouchErr, DeductorCategory.Code, DeductorCategory.Description);
        if DeductorCategory."Transfer Voucher No. Mandatory" and (TransferVoucherNo <> '') and not PaidByBook then
            Error(PaidByBookEntryErr);
    end;

    var
        CompanyInformation: Record "Company Information";
        DeductorCategory: Record "Deductor Category";
        InterestAmount: Decimal;
        OtherAmount: Decimal;
        EntryNo: Integer;
        PaidByBook: Boolean;
        TransferVoucherNo: Code[9];
        LateFee: Decimal;
        PaidByBookErr: Label 'Paid by book entry can be true only for government organisations.';
        DeductorCategErr: Label 'Transfer Voucher No. cannot be empty when Deductor Category is %1 - %2.', Comment = '%1 = DeductorCategory.Code, %2 = DeductorCategory.Description';
        DeductorCatVouchErr: Label 'Transfer Voucher No. cannot be entered when  Deductor Category is %1 - %2.', Comment = '%1 = DeductorCategory.Code, %2 = DeductorCategory.Description';
        PaidByBookEntryErr: Label 'Paid by Book Entry cannot be false when Transfer Voucher No. is entered.';

    procedure UpdateChallan(
        NewInterestAmount: Decimal;
        NewOtherAmount: Decimal;
        NewLateFee: Decimal;
        NewEntryNo: Integer)
    begin
        InterestAmount := NewInterestAmount;
        OtherAmount := NewOtherAmount;
        LateFee := NewLateFee;
        EntryNo := NewEntryNo;
    end;
}
