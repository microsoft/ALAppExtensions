// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Documents;

reportextension 31000 "Suggest Payments CZZ" extends "Suggest Payments CZB"
{
    dataset
    {
        addafter("Vendor Ledger Entry Disc")
        {
            dataitem("Purch. Adv. Letter Header CZZ"; "Purch. Adv. Letter Header CZZ")
            {
                DataItemTableView = sorting("Advance Due Date") where(Status = const("To Pay"), "On Hold" = const(''));
                CalcFields = "To Pay";

                trigger OnPreDataItem()
                var
                    PurchaseAdvancesTxt: Label 'Processing Purchase Advances...';
                begin
                    if not VendorAdvancesCZZ then
                        CurrReport.Break();
                    if StopPayments then
                        CurrReport.Break();
                    WindowDialog.Open(PurchaseAdvancesTxt);
                    DialogOpen := true;

                    SetRange("Advance Due Date", 0D, LastDueDateToPayReq);
                    case CurrencyType of
                        CurrencyType::"Payment Order":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
                        CurrencyType::"Bank Account":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Currency Code");
                    end;
                    if VendorNoFilter <> '' then
                        SetFilter("Pay-to Vendor No.", VendorNoFilter);
                end;

                trigger OnAfterGetRecord()
                begin
                    if VendorType = VendorType::OnlyBalance then
                        if VendorBalanceTest("Pay-to Vendor No.") then
                            CurrReport.Skip();
                    if SkipBlocked and VendorBlockedTest("Pay-to Vendor No.") then begin
                        IsSkippedBlocked := true;
                        CurrReport.Skip();
                    end;
                    if (CalcSuggestedAmountToApply() <> 0) and not BankAccountCZZ."Payment Partial Suggestion CZB" then
                        CurrReport.Skip();

                    AddPurchaseAdvanceCZZ("Purch. Adv. Letter Header CZZ");
                    if StopPayments then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if DialogOpen then begin
                        WindowDialog.Close();
                        DialogOpen := false;
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            addafter(VendorTypeCZB)
            {
                field(VendorAdvancesCZZ; VendorAdvancesCZZ)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Advances';
                    ToolTip = 'Specifies payment suggestion of purchase advances.';
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        BankAccountCZZ.Get(PaymentOrderHeaderCZB."Bank Account No.");
    end;

    var
        BankAccountCZZ: Record "Bank Account";
        VendorAdvancesCZZ: Boolean;

    procedure AddPurchaseAdvanceCZZ(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        PaymentOrderLineCZB.Init();
        PaymentOrderLineCZB.Validate("Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB."Line No." := LineNo;
        LineNo += 10000;

        PaymentOrderLineCZB.Type := PaymentOrderLineCZB.Type::Vendor;
        case CurrencyType of
            CurrencyType::" ":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PurchAdvLetterHeaderCZZ."Currency Code" then
                    PaymentOrderLineCZB.Validate("Payment Order Currency Code", PurchAdvLetterHeaderCZZ."Currency Code");
            CurrencyType::"Payment Order":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PaymentOrderHeaderCZB."Payment Order Currency Code" then
                    PaymentOrderLineCZB.Validate("Payment Order Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
            CurrencyType::"Bank Account":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PaymentOrderHeaderCZB."Currency Code" then
                    PaymentOrderLineCZB.Validate("Payment Order Currency Code", PaymentOrderHeaderCZB."Currency Code");
        end;
        PaymentOrderLineCZB.Validate("Purch. Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        AddPaymentLine();
    end;
}
