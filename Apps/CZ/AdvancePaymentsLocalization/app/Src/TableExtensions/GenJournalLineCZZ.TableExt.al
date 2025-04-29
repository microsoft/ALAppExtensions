// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

tableextension 31004 "Gen. Journal Line CZZ" extends "Gen. Journal Line"
{
    fields
    {
        field(31010; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const(Customer), "Document Type" = const(Payment)) "Sales Adv. Letter Header CZZ" where("Bill-to Customer No." = field("Account No."), "Currency Code" = field("Currency Code"), Status = const("To Pay")) else
            if ("Account Type" = const(Vendor), "Document Type" = const(Payment)) "Purch. Adv. Letter Header CZZ" where("Pay-to Vendor No." = field("Account No."), "Currency Code" = field("Currency Code"), Status = const("To Pay"));

            trigger OnValidate()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
            begin
                "Adv. Letter Template Code CZZ" := '';
                if "Advance Letter No. CZZ" <> '' then begin
                    TestField("Document Type", "Document Type"::Payment);
                    case "Account Type" of
                        "Account Type"::Customer:
                            begin
                                SalesAdvLetterHeaderCZZ.Get("Advance Letter No. CZZ");
                                SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", "Account No.");
                                SalesAdvLetterHeaderCZZ.TestField("Currency Code", "Currency Code");
                                if Amount = 0 then begin
                                    SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
                                    Validate(Amount, -SalesAdvLetterHeaderCZZ."To Pay");
                                end;
                                Validate("Dimension Set ID", SalesAdvLetterHeaderCZZ."Dimension Set ID");
                                "Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
                            end;
                        "Account Type"::Vendor:
                            begin
                                PurchAdvLetterHeaderCZZ.Get("Advance Letter No. CZZ");
                                PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", "Account No.");
                                PurchAdvLetterHeaderCZZ.TestField("Currency Code", "Currency Code");
                                if Amount = 0 then begin
                                    PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
                                    Validate(Amount, PurchAdvLetterHeaderCZZ."To Pay");
                                end;
                                Validate("Dimension Set ID", PurchAdvLetterHeaderCZZ."Dimension Set ID");
                                "Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
                            end;
                        else
                            FieldError("Account Type");
                    end;
                end;
            end;

            trigger OnLookup()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
            begin
                TestField("Document Type", "Document Type"::Payment);
                if not ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) then
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
        field(31011; "Adv. Letter No. (Entry) CZZ"; Code[20])
        {
            Caption = 'Advance Letter No. (Entry)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(31012; "Use Advance G/L Account CZZ"; Boolean)
        {
            Caption = 'Use Advance G/L Account';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(31013; "Adv. Letter Template Code CZZ"; Code[20])
        {
            Caption = 'Advance Letter Template Code';
            DataClassification = CustomerContent;
            Editable = false;
        }

        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                if "Account No." <> xRec."Account No." then
                    Validate("Advance Letter No. CZZ", '');
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            begin
                if "Currency Code" <> xRec."Currency Code" then
                    Validate("Advance Letter No. CZZ", '');
            end;
        }
    }

    procedure InitNewLineCZZ(PostingDate: Date; DocumentDate: Date; VATDate: Date; OriginalDocumentVATDate: Date; PostingDescription: Text[100])
    begin
        InitNewLineCZZ(PostingDate, DocumentDate, VATDate, OriginalDocumentVATDate, PostingDescription, '', '', 0, '');
    end;

    procedure InitNewLineCZZ(PostingDate: Date; DocumentDate: Date; VATDate: Date; OriginalDocumentVATDate: Date; PostingDescription: Text[100]; ShortcutDim1Code: Code[20]; ShortcutDim2Code: Code[20]; DimSetID: Integer; ReasonCode: Code[10])
    begin
        InitNewLine(PostingDate, DocumentDate, VATDate, PostingDescription, ShortcutDim1Code, ShortcutDim2Code, DimSetID, ReasonCode);
        "Original Doc. VAT Date CZL" := OriginalDocumentVATDate;
        OnAfterInitNewLineCZZ(Rec);
    end;

    procedure InitNewLineCZZ(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        InitNewLineCZZ(
            CustLedgerEntry."Posting Date", CustLedgerEntry."Document Date",
            CustLedgerEntry."VAT Date CZL", 0D, CustLedgerEntry.Description,
            CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code",
            CustLedgerEntry."Dimension Set ID", CustLedgerEntry."Reason Code");
    end;

    procedure InitNewLineCZZ(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        InitNewLineCZZ(
            VendorLedgerEntry."Posting Date", VendorLedgerEntry."Document Date",
            VendorLedgerEntry."VAT Date CZL", VendorLedgerEntry."VAT Date CZL", VendorLedgerEntry.Description,
            VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code",
            VendorLedgerEntry."Dimension Set ID", VendorLedgerEntry."Reason Code");
    end;

    procedure CopyFromSalesAdvLetterHeaderCZZ(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        "Bill-to/Pay-to No." := SalesAdvLetterHeaderCZZ."Bill-to Customer No.";
        "Country/Region Code" := SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code";
        "VAT Registration No." := SalesAdvLetterHeaderCZZ."VAT Registration No.";
        "Registration No. CZL" := SalesAdvLetterHeaderCZZ."Registration No.";
        "Tax Registration No. CZL" := SalesAdvLetterHeaderCZZ."Tax Registration No.";
        "System-Created Entry" := true;
#if not CLEAN25
#pragma warning disable AL0432
        OnAfterCopyGenJnlLineFromSalesAdvLetterHeaderCZZ(SalesAdvLetterHeaderCZZ, Rec);
#pragma warning restore AL0432
#endif
        OnAfterCopyGenJournalLineFromSalesAdvLetterHeaderCZZ(SalesAdvLetterHeaderCZZ, Rec);
    end;

    procedure CopyFromSalesAdvLetterEntryCZZ(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        "Shortcut Dimension 1 Code" := SalesAdvLetterEntryCZZ."Global Dimension 1 Code";
        "Shortcut Dimension 2 Code" := SalesAdvLetterEntryCZZ."Global Dimension 2 Code";
        "Dimension Set ID" := SalesAdvLetterEntryCZZ."Dimension Set ID";
        "Adv. Letter No. (Entry) CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
#if not CLEAN25
#pragma warning disable AL0432
        OnAfterCopyGenJnlLineFromSalesAdvLetterEntryCZZ(SalesAdvLetterEntryCZZ, Rec);
#pragma warning restore AL0432
#endif
        OnAfterCopyGenJournalLineFromSalesAdvLetterEntryCZZ(SalesAdvLetterEntryCZZ, Rec);
    end;

    procedure CopyFromPurchAdvLetterHeaderCZZ(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        "Bill-to/Pay-to No." := PurchAdvLetterHeaderCZZ."Pay-to Vendor No.";
        "Country/Region Code" := PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code";
        "VAT Registration No." := PurchAdvLetterHeaderCZZ."VAT Registration No.";
        "Registration No. CZL" := PurchAdvLetterHeaderCZZ."Registration No.";
        "Tax Registration No. CZL" := PurchAdvLetterHeaderCZZ."Tax Registration No.";
        "System-Created Entry" := true;
        OnAfterCopyGenJnlLineFromPurchAdvLetterHeaderCZZ(PurchAdvLetterHeaderCZZ, Rec);
    end;

    procedure CopyFromPurchAdvLetterEntryCZZ(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        "Shortcut Dimension 1 Code" := PurchAdvLetterEntryCZZ."Global Dimension 1 Code";
        "Shortcut Dimension 2 Code" := PurchAdvLetterEntryCZZ."Global Dimension 2 Code";
        "Dimension Set ID" := PurchAdvLetterEntryCZZ."Dimension Set ID";
        "Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        OnAfterCopyGenJnlLineFromPurchAdvLetterEntryCZZ(PurchAdvLetterEntryCZZ, Rec);
    end;

    procedure CopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    begin
        "VAT Bus. Posting Group" := AdvancePostingBufferCZZ."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := AdvancePostingBufferCZZ."VAT Prod. Posting Group";
        "VAT Calculation Type" := AdvancePostingBufferCZZ."VAT Calculation Type";
        "VAT %" := AdvancePostingBufferCZZ."VAT %";
        CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ);
        OnAfterCopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ, Rec);
    end;

    procedure CopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    begin
        GetCurrency();
        Amount := AdvancePostingBufferCZZ.Amount;
        "VAT Amount" := AdvancePostingBufferCZZ."VAT Amount";
        "VAT Base Amount" := AdvancePostingBufferCZZ."VAT Base Amount";
        "VAT Difference" := "VAT Amount" -
            Round(Amount * "VAT %" / (100 + "VAT %"), Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
        "Amount (LCY)" := AdvancePostingBufferCZZ."Amount (ACY)";
        "VAT Amount (LCY)" := AdvancePostingBufferCZZ."VAT Amount (ACY)";
        "VAT Base Amount (LCY)" := AdvancePostingBufferCZZ."VAT Base Amount (ACY)";
        "Currency Factor" := 1;
        if "Amount (LCY)" <> 0 then
            "Currency Factor" := Amount / "Amount (LCY)";
        OnAfterCopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ, Rec);
    end;

    procedure CopyFromCustLedgerEntryCZZ(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CopyDocumentFields(
            "Document Type"::" ", CustLedgerEntry."Document No.",
            CustLedgerEntry."External Document No.", CustLedgerEntry."Source Code", '');
        "Account Type" := "Account Type"::Customer;
        "Account No." := CustLedgerEntry."Customer No.";
        SetCurrencyFactor(CustLedgerEntry."Currency Code", CustLedgerEntry."Original Currency Factor");
        "Source Currency Code" := CustLedgerEntry."Currency Code";
        "Sell-to/Buy-from No." := CustLedgerEntry."Sell-to Customer No.";
        "Bill-to/Pay-to No." := CustLedgerEntry."Customer No.";
        "IC Partner Code" := CustLedgerEntry."IC Partner Code";
        "Salespers./Purch. Code" := CustLedgerEntry."Salesperson Code";
        "On Hold" := CustLedgerEntry."On Hold";
        "Posting Group" := CustLedgerEntry."Customer Posting Group";
        "System-Created Entry" := true;
        OnAfterCopyFromCustLedgerEntryCZZ(CustLedgerEntry, Rec);
    end;

    procedure CopyFromVendorLedgerEntryCZZ(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        CopyDocumentFields(
            "Document Type"::" ", VendorLedgerEntry."Document No.",
            VendorLedgerEntry."External Document No.", VendorLedgerEntry."Source Code", '');
        "Account Type" := "Account Type"::Vendor;
        "Account No." := VendorLedgerEntry."Vendor No.";
        SetCurrencyFactor(VendorLedgerEntry."Currency Code", VendorLedgerEntry."Original Currency Factor");
        "Source Currency Code" := VendorLedgerEntry."Currency Code";
        "Sell-to/Buy-from No." := VendorLedgerEntry."Buy-from Vendor No.";
        "Bill-to/Pay-to No." := VendorLedgerEntry."Vendor No.";
        "IC Partner Code" := VendorLedgerEntry."IC Partner Code";
        "Salespers./Purch. Code" := VendorLedgerEntry."Purchaser Code";
        "On Hold" := VendorLedgerEntry."On Hold";
        "Posting Group" := VendorLedgerEntry."Vendor Posting Group";
        "System-Created Entry" := true;
        OnAfterCopyFromVendorLedgerEntryCZZ(VendorLedgerEntry, Rec);
    end;

    procedure GetAdvanceGLAccountNoCZZ(): Code[20]
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        case "Account Type" of
            "Account Type"::Customer:
                begin
                    SalesAdvLetterHeaderCZZ.Get("Adv. Letter No. (Entry) CZZ");
                    SalesAdvLetterHeaderCZZ.TestField("Advance Letter Code");
                    AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
                end;
            "Account Type"::Vendor:
                begin
                    PurchAdvLetterHeaderCZZ.Get("Adv. Letter No. (Entry) CZZ");
                    PurchAdvLetterHeaderCZZ.TestField("Advance Letter Code");
                    AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
                end;
        end;

        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        exit(AdvanceLetterTemplateCZZ."Advance Letter G/L Account");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitNewLineCZZ(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
#if not CLEAN25
    [Obsolete('Replaced by OnAfterCopyGenJournalLineFromSalesAdvLetterHeaderCZZ event.', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyGenJnlLineFromSalesAdvLetterHeaderCZZ(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Rec: Record "Gen. Journal Line")
    begin
    end;

    [Obsolete('Replaced by OnAfterCopyGenJournalLineFromSalesAdvLetterEntryCZZ event.', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyGenJnlLineFromSalesAdvLetterEntryCZZ(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; Rec: Record "Gen. Journal Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyGenJournalLineFromSalesAdvLetterHeaderCZZ(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyGenJournalLineFromSalesAdvLetterEntryCZZ(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyGenJnlLineFromPurchAdvLetterHeaderCZZ(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyGenJnlLineFromPurchAdvLetterEntryCZZ(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromAdvancePostingBufferCZZ(AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromAdvancePostingBufferAmountsCZZ(AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromCustLedgerEntryCZZ(CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromVendorLedgerEntryCZZ(VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}
