// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.Documents;
using Microsoft.Finance.Currency;
using Microsoft.Purchases.Vendor;

tableextension 31039 "Payment Order Line CZZ" extends "Payment Order Line CZB"
{
    fields
    {
        field(31000; "Purch. Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Purchase Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Vendor), "No." = filter('<>''''')) "Purch. Adv. Letter Header CZZ"."No."
                            where("Pay-to Vendor No." = field("No."), Status = const("To Pay")) else
            if (Type = const(Vendor)) "Purch. Adv. Letter Header CZZ"."No." where(Status = const("To Pay"));

            trigger OnValidate()
            var
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                Vendor: Record Vendor;
                VendorBankAccount: Record "Vendor Bank Account";
                CurrencyExchangeRate: Record "Currency Exchange Rate";
            begin
                if "Purch. Advance Letter No. CZZ" = '' then
                    exit;
                if CurrFieldNo = FieldNo("Purch. Advance Letter No. CZZ") then
                    "Amount Must Be Checked" := not PaymentOrderManagementCZB.CheckPaymentOrderLineApply(Rec, false);

                Rec.TestField(Type, Rec.Type::Vendor);

                PurchAdvLetterHeaderCZZ.Get("Purch. Advance Letter No. CZZ");
                Rec.Validate("No.", PurchAdvLetterHeaderCZZ."Pay-to Vendor No.");
                Validate("Applied Currency Code", PurchAdvLetterHeaderCZZ."Currency Code");
                if PurchAdvLetterHeaderCZZ."Advance Due Date" > "Due Date" then
                    "Due Date" := PurchAdvLetterHeaderCZZ."Advance Due Date";
                "Original Due Date" := PurchAdvLetterHeaderCZZ."Advance Due Date";
                if Amount = 0 then begin
                    PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
                    if "Payment Order Currency Code" = PurchAdvLetterHeaderCZZ."Currency Code" then
                        Rec.Validate("Amount (Paym. Order Currency)", PurchAdvLetterHeaderCZZ."To Pay")
                    else
                        Rec.Validate("Amount (LCY)", Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                          PurchAdvLetterHeaderCZZ."Document Date", PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."To Pay",
                          CurrencyExchangeRate.ExchangeRate(PurchAdvLetterHeaderCZZ."Document Date", PurchAdvLetterHeaderCZZ."Currency Code"))));
                end;
                Rec."Original Amount" := Amount;
                Rec."Original Amount (LCY)" := "Amount (LCY)";
                Rec."Orig. Amount(Pay.Order Curr.)" := "Amount (Paym. Order Currency)";
                Vendor.Get(PurchAdvLetterHeaderCZZ."Pay-to Vendor No.");
                Description := CreateDescription(GetPlaceholderDescriptionValues(PurchAdvLetterHeaderCZZ, Vendor."No.", Vendor.Name));
                if Description = '' then
                    if PurchAdvLetterHeaderCZZ."Posting Description" <> '' then
                        Description := PurchAdvLetterHeaderCZZ."Posting Description"
                    else
                        Description := CopyStr(StrSubstNo(AdvanceNoTxt, PurchAdvLetterHeaderCZZ."No."), 1, MaxStrLen(Description));
                Rec.Validate("Variable Symbol", PurchAdvLetterHeaderCZZ."Variable Symbol");
                if PurchAdvLetterHeaderCZZ."Constant Symbol" <> '' then
                    Rec.Validate("Constant Symbol", PurchAdvLetterHeaderCZZ."Constant Symbol");
                Rec.Validate("Specific Symbol", PurchAdvLetterHeaderCZZ."Specific Symbol");

                if PurchAdvLetterHeaderCZZ."Bank Account Code" <> '' then begin
                    Rec.Validate("Cust./Vendor Bank Account Code", PurchAdvLetterHeaderCZZ."Bank Account Code");
                    Rec."Account No." := PurchAdvLetterHeaderCZZ."Bank Account No.";
                    Rec."SWIFT Code" := PurchAdvLetterHeaderCZZ."SWIFT Code";
                    Rec."Transit No." := PurchAdvLetterHeaderCZZ."Transit No.";
                    Rec.IBAN := PurchAdvLetterHeaderCZZ."IBAN";
                end else
                    if Vendor."Preferred Bank Account Code" <> '' then begin
                        VendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code");
                        Rec.Validate("Cust./Vendor Bank Account Code", VendorBankAccount.Code);
                        Rec."Account No." := VendorBankAccount."Bank Account No.";
                        Rec."SWIFT Code" := VendorBankAccount."SWIFT Code";
                        Rec."Transit No." := VendorBankAccount."Transit No.";
                        Rec.IBAN := VendorBankAccount."IBAN";
                    end;
            end;
        }
    }

    var
        PaymentOrderManagementCZB: Codeunit "Payment Order Management CZB";
        AdvanceTxt: Label 'Advance';
        AdvanceNoTxt: Label 'Advance %1', Comment = '%1 = Advance No.';

    local procedure GetPlaceholderDescriptionValues(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PartnerNo: Text[20]; PartnerName: Text[100]) PlaceholderValues: List of [Text[100]]
    begin
        PlaceholderValues.Add(AdvanceTxt);
        PlaceholderValues.Add(PurchAdvLetterHeaderCZZ."No.");
        PlaceholderValues.Add(PartnerNo);
        PlaceholderValues.Add(PartnerName);
        PlaceholderValues.Add(GetExternalDocumentNo(PurchAdvLetterHeaderCZZ));
    end;

    local procedure GetExternalDocumentNo(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"): Text[35]
    begin
        if PurchAdvLetterHeaderCZZ."Variable Symbol" <> '' then
            exit(PurchAdvLetterHeaderCZZ."Variable Symbol");
        exit(PurchAdvLetterHeaderCZZ."Vendor Adv. Letter No.");
    end;
}
