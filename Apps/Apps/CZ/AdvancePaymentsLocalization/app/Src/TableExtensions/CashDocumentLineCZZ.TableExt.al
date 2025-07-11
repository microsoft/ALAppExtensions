// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.CashDesk;

tableextension 31028 "Cash Document Line CZZ" extends "Cash Document Line CZP"
{
    fields
    {
        field(31000; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Document Type" = const(Receipt), "Account Type" = const(Customer), "Gen. Document Type" = const(Payment)) "Sales Adv. Letter Header CZZ" where("Bill-to Customer No." = field("Account No."), "Currency Code" = field("Currency Code"), Status = const("To Pay")) else
            if ("Document Type" = const(Withdrawal), "Account Type" = const(Vendor), "Gen. Document Type" = const(Payment)) "Purch. Adv. Letter Header CZZ" where("Pay-to Vendor No." = field("Account No."), "Currency Code" = field("Currency Code"), Status = const("To Pay"));

            trigger OnValidate()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
            begin
                if "Advance Letter No. CZZ" <> '' then begin
                    TestField("Gen. Document Type", "Gen. Document Type"::Payment);
                    case "Document Type" of
                        "Document Type"::Receipt:
                            begin
                                TestField("Account Type", "Account Type"::Customer);
                                SalesAdvLetterHeaderCZZ.Get("Advance Letter No. CZZ");
                                SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", "Account No.");
                                SalesAdvLetterHeaderCZZ.TestField("Currency Code", "Currency Code");
                                if Amount = 0 then begin
                                    SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
                                    Validate(Amount, SalesAdvLetterHeaderCZZ."To Pay");
                                end;
                                Validate("Dimension Set ID", SalesAdvLetterHeaderCZZ."Dimension Set ID");
                            end;
                        "Document Type"::Withdrawal:
                            begin
                                TestField("Account Type", "Account Type"::Vendor);
                                PurchAdvLetterHeaderCZZ.Get("Advance Letter No. CZZ");
                                PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", "Account No.");
                                PurchAdvLetterHeaderCZZ.TestField("Currency Code", "Currency Code");
                                if Amount = 0 then begin
                                    PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
                                    Validate(Amount, PurchAdvLetterHeaderCZZ."To Pay");
                                end;
                                Validate("Dimension Set ID", PurchAdvLetterHeaderCZZ."Dimension Set ID");
                            end;
                        else
                            TestField("Advance Letter No. CZZ", '');
                    end;
                end;
            end;

            trigger OnLookup()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
            begin
                TestField("Gen. Document Type", "Gen. Document Type"::Payment);
                if not ((("Document Type" = "Document Type"::Receipt) and ("Account Type" = "Account Type"::Customer)) or
                        (("Document Type" = "Document Type"::Withdrawal) and ("Account Type" = "Account Type"::Vendor))) then
                    FieldError("Account Type");
                TestField("Account No.");

                case "Account Type" of
                    "Account Type"::Customer:
                        begin
                            SalesAdvLetterHeaderCZZ.FilterGroup(2);
                            SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", "Account No.");
                            SalesAdvLetterHeaderCZZ.SetRange(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
                            SalesAdvLetterHeaderCZZ.SetRange("Currency Code", "Currency Code");
                            SalesAdvLetterHeaderCZZ.FilterGroup(0);
                            if Page.RunModal(0, SalesAdvLetterHeaderCZZ) = Action::LookupOK then
                                Validate("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
                        end;
                    "Account Type"::Vendor:
                        begin
                            PurchAdvLetterHeaderCZZ.FilterGroup(2);
                            PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", "Account No.");
                            PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
                            PurchAdvLetterHeaderCZZ.SetRange("Currency Code", "Currency Code");
                            PurchAdvLetterHeaderCZZ.FilterGroup(0);
                            if Page.RunModal(0, PurchAdvLetterHeaderCZZ) = Action::LookupOK then
                                Validate("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
                        end;
                end;
            end;
        }
        modify("Document Type")
        {
            trigger OnAfterValidate()
            begin
                "Advance Letter No. CZZ" := '';
            end;
        }
        modify("Account Type")
        {
            trigger OnAfterValidate()
            begin
                "Advance Letter No. CZZ" := '';
            end;
        }
        modify("Gen. Document Type")
        {
            trigger OnAfterValidate()
            begin
                "Advance Letter No. CZZ" := '';
            end;
        }
        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                "Advance Letter No. CZZ" := '';
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            begin
                "Advance Letter No. CZZ" := '';
            end;
        }
    }

    procedure IsAdvancePaymentCZZ(): Boolean
    begin
        exit(
          ("Document Type" = "Document Type"::Receipt) and
          ("Account Type" = "Account Type"::Customer) and
          ("Gen. Document Type" = "Gen. Document Type"::Payment) and
          ("Advance Letter No. CZZ" <> ''));
    end;

    procedure IsAdvanceRefundCZZ(): Boolean
    begin
        exit(
          ("Document Type" = "Document Type"::Withdrawal) and
          ("Account Type" = "Account Type"::Customer) and
          ("Gen. Document Type" = "Gen. Document Type"::Refund) and
          ("Applies-To Doc. Type" = "Applies-To Doc. Type"::Payment) and
          ("Applies-To Doc. No." <> ''));
    end;
}
