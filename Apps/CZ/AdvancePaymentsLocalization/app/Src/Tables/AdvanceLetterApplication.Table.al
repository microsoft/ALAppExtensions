// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

table 31007 "Advance Letter Application CZZ"
{
    Caption = 'Advance Letter Application';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Advance Letter Type"; Enum "Advance Letter Type CZZ")
        {
            Caption = 'Advance Letter Type';
            DataClassification = CustomerContent;
        }
        field(2; "Advance Letter No."; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Advance Letter Type" = const(Sales)) "Sales Adv. Letter Header CZZ"."No." else
            if ("Advance Letter Type" = const(Purchase)) "Purch. Adv. Letter Header CZZ"."No.";

            trigger OnValidate()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
            begin
                if "Advance Letter No." = '' then begin
                    "Posting Date" := 0D;
                    exit;
                end;

                case "Advance Letter Type" of
                    "Advance Letter Type"::Sales:
                        if SalesAdvLetterHeaderCZZ.Get("Advance Letter No.") then
                            "Posting Date" := SalesAdvLetterHeaderCZZ."Posting Date";
                    "Advance Letter Type"::Purchase:
                        if PurchAdvLetterHeaderCZZ.Get("Advance Letter No.") then
                            "Posting Date" := PurchAdvLetterHeaderCZZ."Posting Date";
                end;
            end;
        }
        field(3; "Document Type"; Enum "Adv. Letter Usage Doc.Type CZZ")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Document Type" = const("Sales Order")) "Sales Header"."No." where("Document Type" = const(Order)) else
            if ("Document Type" = const("Sales Invoice")) "Sales Header"."No." where("Document Type" = const(Invoice)) else
            if ("Document Type" = const("Purchase Order")) "Purchase Header"."No." where("Document Type" = const(Order)) else
            if ("Document Type" = const("Purchase Invoice")) "Purchase Header"."No." where("Document Type" = const(Invoice));
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(9; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(11; "Amount to Use"; Decimal)
        {
            Caption = 'Amount to Use';
            DataClassification = CustomerContent;
        }
        field(50; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Advance Letter Type", "Advance Letter No.", "Document Type", "Document No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        case "Document Type" of
            "Document Type"::"Sales Order":
                if SalesAdvLetterHeaderCZZ.Get("Advance Letter No.") then
                    if SalesAdvLetterHeaderCZZ."Order No." = "Document No." then begin
                        SalesAdvLetterHeaderCZZ."Order No." := '';
                        SalesAdvLetterHeaderCZZ."Posting Description" := '';
                        SalesAdvLetterHeaderCZZ.Modify();
                    end;
            "Document Type"::"Purchase Order":
                if PurchAdvLetterHeaderCZZ.Get("Advance Letter No.") then
                    if PurchAdvLetterHeaderCZZ."Order No." = "Document No." then begin
                        PurchAdvLetterHeaderCZZ."Order No." := '';
                        PurchAdvLetterHeaderCZZ."Posting Description" := '';
                        PurchAdvLetterHeaderCZZ.Modify();
                    end;
        end;
    end;

    procedure GetPossibleSalesAdvance(NewFromAdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; NewFromDocumentNo: Code[20]; NewBillToCustomerNo: Code[20]; NewPostingDate: Date; NewCurrencyCode: Code[10]; var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
    begin
        NewAdvanceLetterApplicationCZZ.Reset();
        NewAdvanceLetterApplicationCZZ.DeleteAll();

        SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", NewBillToCustomerNo);
        SalesAdvLetterHeaderCZZ.SetRange("Currency Code", NewCurrencyCode);
        SalesAdvLetterHeaderCZZ.SetFilter(Status, '%1|%2', SalesAdvLetterHeaderCZZ.Status::"To Pay", SalesAdvLetterHeaderCZZ.Status::"To Use");
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                NewAdvanceLetterApplicationCZZ.Init();
                NewAdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales;
                NewAdvanceLetterApplicationCZZ."Advance Letter No." := SalesAdvLetterHeaderCZZ."No.";
                NewAdvanceLetterApplicationCZZ."Posting Date" := SalesAdvLetterHeaderCZZ."Posting Date";

                SalesAdvLetterEntryCZZ.Reset();
                SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                SalesAdvLetterEntryCZZ.SetRange("Currency Code", NewCurrencyCode);
                SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
                SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', NewPostingDate);
                SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                NewAdvanceLetterApplicationCZZ.Amount := -SalesAdvLetterEntryCZZ.Amount;
                NewAdvanceLetterApplicationCZZ."Amount (LCY)" := -SalesAdvLetterEntryCZZ."Amount (LCY)";

                SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
                SalesAdvLetterEntryCZZ.SetRange("Posting Date");
                SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                NewAdvanceLetterApplicationCZZ.Amount -= SalesAdvLetterEntryCZZ.Amount;
                NewAdvanceLetterApplicationCZZ."Amount (LCY)" -= SalesAdvLetterEntryCZZ."Amount (LCY)";

                AdvanceLetterApplicationCZZ.Reset();
                AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
                AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
                AdvanceLetterApplicationCZZ.FilterGroup(-1);
                AdvanceLetterApplicationCZZ.SetFilter("Document Type", '<>%1', NewFromAdvLetterUsageDocTypeCZZ);
                AdvanceLetterApplicationCZZ.SetFilter("Document No.", '<>%1', NewFromDocumentNo);
                AdvanceLetterApplicationCZZ.FilterGroup(0);
                AdvanceLetterApplicationCZZ.CalcSums(Amount, "Amount (LCY)");
                NewAdvanceLetterApplicationCZZ.Amount -= AdvanceLetterApplicationCZZ.Amount;
                NewAdvanceLetterApplicationCZZ."Amount (LCY)" -= AdvanceLetterApplicationCZZ."Amount (LCY)";
                NewAdvanceLetterApplicationCZZ."Document Type" := NewFromAdvLetterUsageDocTypeCZZ;
                NewAdvanceLetterApplicationCZZ."Document No." := NewFromDocumentNo;
                if NewAdvanceLetterApplicationCZZ.Amount > 0 then
                    NewAdvanceLetterApplicationCZZ.Insert();
            until SalesAdvLetterHeaderCZZ.Next() = 0;
    end;

    procedure GetPossiblePurchAdvance(NewFromAdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; NewFromDocumentNo: Code[20]; NewPayToVendorNo: Code[20]; NewPostingDate: Date; NewCurrencyCode: Code[10]; var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
    begin
        NewAdvanceLetterApplicationCZZ.Reset();
        NewAdvanceLetterApplicationCZZ.DeleteAll();

        PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", NewPayToVendorNo);
        PurchAdvLetterHeaderCZZ.SetRange("Currency Code", NewCurrencyCode);
        PurchAdvLetterHeaderCZZ.SetFilter(Status, '%1|%2', PurchAdvLetterHeaderCZZ.Status::"To Pay", PurchAdvLetterHeaderCZZ.Status::"To Use");
        if PurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                NewAdvanceLetterApplicationCZZ.Init();
                NewAdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase;
                NewAdvanceLetterApplicationCZZ."Advance Letter No." := PurchAdvLetterHeaderCZZ."No.";
                NewAdvanceLetterApplicationCZZ."Posting Date" := PurchAdvLetterHeaderCZZ."Posting Date";

                PurchAdvLetterEntryCZZ.Reset();
                PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                PurchAdvLetterEntryCZZ.SetRange("Currency Code", NewCurrencyCode);
                PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
                PurchAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', NewPostingDate);
                PurchAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                NewAdvanceLetterApplicationCZZ.Amount := PurchAdvLetterEntryCZZ.Amount;
                NewAdvanceLetterApplicationCZZ."Amount (LCY)" := PurchAdvLetterEntryCZZ."Amount (LCY)";

                PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
                PurchAdvLetterEntryCZZ.SetRange("Posting Date");
                PurchAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                NewAdvanceLetterApplicationCZZ.Amount += PurchAdvLetterEntryCZZ.Amount;
                NewAdvanceLetterApplicationCZZ."Amount (LCY)" += PurchAdvLetterEntryCZZ."Amount (LCY)";

                AdvanceLetterApplicationCZZ.Reset();
                AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
                AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
                AdvanceLetterApplicationCZZ.FilterGroup(-1);
                AdvanceLetterApplicationCZZ.SetFilter("Document Type", '<>%1', NewFromAdvLetterUsageDocTypeCZZ);
                AdvanceLetterApplicationCZZ.SetFilter("Document No.", '<>%1', NewFromDocumentNo);
                AdvanceLetterApplicationCZZ.FilterGroup(0);
                AdvanceLetterApplicationCZZ.CalcSums(Amount, "Amount (LCY)");
                NewAdvanceLetterApplicationCZZ.Amount -= AdvanceLetterApplicationCZZ.Amount;
                NewAdvanceLetterApplicationCZZ."Amount (LCY)" -= AdvanceLetterApplicationCZZ."Amount (LCY)";
                NewAdvanceLetterApplicationCZZ."Document Type" := NewFromAdvLetterUsageDocTypeCZZ;
                NewAdvanceLetterApplicationCZZ."Document No." := NewFromDocumentNo;
                if NewAdvanceLetterApplicationCZZ.Amount > 0 then begin
                    OnGetPossiblePurchAdvanceOnBeforeInsertNewAdvanceLetterApplication(NewAdvanceLetterApplicationCZZ, AdvanceLetterApplicationCZZ);
                    NewAdvanceLetterApplicationCZZ.Insert();
                end;
            until PurchAdvLetterHeaderCZZ.Next() = 0;
    end;

    procedure GetAssignedAdvance(NewFromAdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; NewFromDocumentNo: Code[20]; var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        NewAdvanceLetterApplicationCZZ.Reset();
        NewAdvanceLetterApplicationCZZ.DeleteAll();

        AdvanceLetterApplicationCZZ.SetRange("Document Type", NewFromAdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", NewFromDocumentNo);
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                NewAdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type";
                NewAdvanceLetterApplicationCZZ."Advance Letter No." := AdvanceLetterApplicationCZZ."Advance Letter No.";
                NewAdvanceLetterApplicationCZZ."Posting Date" := AdvanceLetterApplicationCZZ."Posting Date";
                NewAdvanceLetterApplicationCZZ.Amount := AdvanceLetterApplicationCZZ.Amount;
                NewAdvanceLetterApplicationCZZ."Amount (LCY)" := AdvanceLetterApplicationCZZ."Amount (LCY)";
                NewAdvanceLetterApplicationCZZ."Document Type" := NewFromAdvLetterUsageDocTypeCZZ;
                NewAdvanceLetterApplicationCZZ."Document No." := NewFromDocumentNo;
                case AdvanceLetterApplicationCZZ."Advance Letter Type" of
                    AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales:
                        begin
                            SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
                            SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type"::Usage, SalesAdvLetterEntryCZZ."Entry Type"::Close);
                            SalesAdvLetterEntryCZZ.CalcSums(Amount);
                            NewAdvanceLetterApplicationCZZ."Amount to Use" := -SalesAdvLetterEntryCZZ.Amount;
                        end;
                    AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase:
                        begin
                            PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
                            PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type"::Usage, PurchAdvLetterEntryCZZ."Entry Type"::Close);
                            PurchAdvLetterEntryCZZ.CalcSums(Amount);
                            NewAdvanceLetterApplicationCZZ."Amount to Use" := PurchAdvLetterEntryCZZ.Amount;
                        end;
                end;
                OnGetAssignedAdvanceOnBeforeInsertNewAdvanceLetterApplication(NewAdvanceLetterApplicationCZZ, AdvanceLetterApplicationCZZ);
                NewAdvanceLetterApplicationCZZ.Insert();
            until AdvanceLetterApplicationCZZ.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPossiblePurchAdvanceOnBeforeInsertNewAdvanceLetterApplication(var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAssignedAdvanceOnBeforeInsertNewAdvanceLetterApplication(var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
    end;
}
