// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Projects.Project.Job;
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
                        if SalesAdvLetterHeaderCZZ.Get("Advance Letter No.") then begin
                            "Posting Date" := SalesAdvLetterHeaderCZZ."Posting Date";
                            "Currency Code" := SalesAdvLetterHeaderCZZ."Currency Code";
                            "Currency Factor" := SalesAdvLetterHeaderCZZ."Currency Factor";
                        end;
                    "Advance Letter Type"::Purchase:
                        if PurchAdvLetterHeaderCZZ.Get("Advance Letter No.") then begin
                            "Posting Date" := PurchAdvLetterHeaderCZZ."Posting Date";
                            "Currency Code" := PurchAdvLetterHeaderCZZ."Currency Code";
                            "Currency Factor" := PurchAdvLetterHeaderCZZ."Currency Factor";
                        end;
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

            trigger OnValidate()
            var
                CurrencyExchangeRate: Record "Currency Exchange Rate";
            begin
                "Amount (LCY)" :=
                    Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                        "Posting Date", "Currency Code", Amount, "Currency Factor"));
            end;
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
        field(12; "Amount to Use (LCY)"; Decimal)
        {
            Caption = 'Amount to Use (LCY)';
            DataClassification = CustomerContent;
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            Editable = false;
        }
        field(21; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(50; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51; "Job No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
            Editable = false;
            ToolTip = 'Specifies the project number for the sales advance document.';
        }
        field(52; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Job No."));
            Editable = false;
            ToolTip = 'Specifies the project task number of the sales advance document.';
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
                NewAdvanceLetterApplicationCZZ.CopyFrom(SalesAdvLetterHeaderCZZ);

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
                if NewAdvanceLetterApplicationCZZ.Amount > 0 then begin
                    OnGetPossibleSalesAdvanceOnBeforeInsertNewAdvanceLetterApplication(NewAdvanceLetterApplicationCZZ, AdvanceLetterApplicationCZZ);
                    NewAdvanceLetterApplicationCZZ.Insert();
                end;
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
                NewAdvanceLetterApplicationCZZ.CopyFrom(PurchAdvLetterHeaderCZZ);

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

        case NewFromAdvLetterUsageDocTypeCZZ of
            NewFromAdvLetterUsageDocTypeCZZ::"Purchase Invoice",
            NewFromAdvLetterUsageDocTypeCZZ::"Purchase Order",
            NewFromAdvLetterUsageDocTypeCZZ::"Sales Invoice",
            NewFromAdvLetterUsageDocTypeCZZ::"Sales Order":
                begin
                    AdvanceLetterApplicationCZZ.SetRange("Document Type", NewFromAdvLetterUsageDocTypeCZZ);
                    AdvanceLetterApplicationCZZ.SetRange("Document No.", NewFromDocumentNo);
                    if AdvanceLetterApplicationCZZ.FindSet() then
                        repeat
                            NewAdvanceLetterApplicationCZZ := AdvanceLetterApplicationCZZ;
                            case AdvanceLetterApplicationCZZ."Advance Letter Type" of
                                AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales:
                                    begin
                                        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
                                        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type"::Usage, SalesAdvLetterEntryCZZ."Entry Type"::Close);
                                        SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                                        NewAdvanceLetterApplicationCZZ."Amount to Use" := -SalesAdvLetterEntryCZZ.Amount;
                                        NewAdvanceLetterApplicationCZZ."Amount to Use (LCY)" := -SalesAdvLetterEntryCZZ."Amount (LCY)";
                                    end;
                                AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase:
                                    begin
                                        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
                                        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type"::Usage, PurchAdvLetterEntryCZZ."Entry Type"::Close);
                                        PurchAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
                                        NewAdvanceLetterApplicationCZZ."Amount to Use" := PurchAdvLetterEntryCZZ.Amount;
                                        NewAdvanceLetterApplicationCZZ."Amount to Use (LCY)" := PurchAdvLetterEntryCZZ."Amount (LCY)";
                                    end;
                            end;
                            OnGetAssignedAdvanceOnBeforeInsertNewAdvanceLetterApplication(NewAdvanceLetterApplicationCZZ, AdvanceLetterApplicationCZZ);
                            NewAdvanceLetterApplicationCZZ.Insert();
                        until AdvanceLetterApplicationCZZ.Next() = 0;
                end;
            NewFromAdvLetterUsageDocTypeCZZ::"Posted Purchase Invoice":
                GetAssignedAdvanceToPostedPurchaseInvoice(NewFromDocumentNo, NewAdvanceLetterApplicationCZZ);
            NewFromAdvLetterUsageDocTypeCZZ::"Posted Sales Invoice":
                GetAssignedAdvanceToPostedSalesInvoice(NewFromDocumentNo, NewAdvanceLetterApplicationCZZ);
        end;
    end;

    procedure GetAssignedAdvance(JobNo: Code[20]; var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
        GetAssignedAdvance(JobNo, '', NewAdvanceLetterApplicationCZZ);
    end;

    procedure GetAssignedAdvance(JobNo: Code[20]; JobTaskNo: Code[20]; var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        NewAdvanceLetterApplicationCZZ.Reset();
        NewAdvanceLetterApplicationCZZ.DeleteAll();

        SalesAdvLetterHeaderCZZ.SetAutoCalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        SalesAdvLetterHeaderCZZ.SetRange("Job No.", JobNo);
        if JobTaskNo <> '' then
            SalesAdvLetterHeaderCZZ.SetRange("Job Task No.", JobTaskNo);
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3',
                    SalesAdvLetterEntryCZZ."Entry Type"::Payment,
                    SalesAdvLetterEntryCZZ."Entry Type"::Usage,
                    SalesAdvLetterEntryCZZ."Entry Type"::Close);
                SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");

                NewAdvanceLetterApplicationCZZ.Init();
                NewAdvanceLetterApplicationCZZ.CopyFrom(SalesAdvLetterHeaderCZZ);
                NewAdvanceLetterApplicationCZZ.Amount := SalesAdvLetterHeaderCZZ."Amount Including VAT";
                NewAdvanceLetterApplicationCZZ."Amount (LCY)" := SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)";
                NewAdvanceLetterApplicationCZZ."Amount to Use" := -SalesAdvLetterEntryCZZ.Amount;
                NewAdvanceLetterApplicationCZZ."Amount to Use (LCY)" := -SalesAdvLetterEntryCZZ."Amount (LCY)";
                NewAdvanceLetterApplicationCZZ.Insert();
            until SalesAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure GetAssignedAdvanceToPostedPurchaseInvoice(DocumentNo: Code[20]; var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
    begin
        PurchAdvLetterEntryCZZ.SetRange("Document No.", DocumentNo);
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        if PurchAdvLetterEntryCZZ.FindSet() then
            repeat
                if not AdvanceLetterApplicationCZZ.Get(
                    "Advance Letter Type CZZ"::Purchase, PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.",
                    "Adv. Letter Usage Doc.Type CZZ"::"Posted Purchase Invoice", DocumentNo)
                then begin
                    PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                    PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '%1|%2|%3',
                        PurchAdvLetterEntryCZZ."Entry Type"::Payment,
                        PurchAdvLetterEntryCZZ."Entry Type"::Usage,
                        PurchAdvLetterEntryCZZ."Entry Type"::Close);
                    PurchAdvLetterEntryCZZ2.CalcSums(Amount);

                    AdvanceLetterApplicationCZZ.Init();
                    AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase;
                    AdvanceLetterApplicationCZZ."Advance Letter No." := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                    AdvanceLetterApplicationCZZ."Document Type" := "Adv. Letter Usage Doc.Type CZZ"::"Posted Purchase Invoice";
                    AdvanceLetterApplicationCZZ."Document No." := DocumentNo;
                    AdvanceLetterApplicationCZZ."Posting Date" := PurchAdvLetterEntryCZZ."Posting Date";
                    AdvanceLetterApplicationCZZ."Currency Code" := PurchAdvLetterEntryCZZ."Currency Code";
                    AdvanceLetterApplicationCZZ."Currency Factor" := PurchAdvLetterEntryCZZ."Currency Factor";
                    AdvanceLetterApplicationCZZ."Amount to Use" := PurchAdvLetterEntryCZZ2.Amount;
                    AdvanceLetterApplicationCZZ."Amount to Use (LCY)" := PurchAdvLetterEntryCZZ2."Amount (LCY)";
                    AdvanceLetterApplicationCZZ.Amount := -PurchAdvLetterEntryCZZ.Amount;
                    AdvanceLetterApplicationCZZ."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";
                    AdvanceLetterApplicationCZZ.Insert();
                end else begin
                    AdvanceLetterApplicationCZZ.Amount -= PurchAdvLetterEntryCZZ.Amount;
                    AdvanceLetterApplicationCZZ."Amount (LCY)" -= PurchAdvLetterEntryCZZ."Amount (LCY)";
                    AdvanceLetterApplicationCZZ.Modify();
                end;
            until PurchAdvLetterEntryCZZ.Next() = 0;
    end;

    local procedure GetAssignedAdvanceToPostedSalesInvoice(DocumentNo: Code[20]; var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.SetRange("Document No.", DocumentNo);
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        if SalesAdvLetterEntryCZZ.FindSet() then
            repeat
                if not AdvanceLetterApplicationCZZ.Get(
                    "Advance Letter Type CZZ"::Sales, SalesAdvLetterEntryCZZ."Sales Adv. Letter No.",
                    "Adv. Letter Usage Doc.Type CZZ"::"Posted Sales Invoice", DocumentNo)
                then begin
                    SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                    SalesAdvLetterEntryCZZ2.SetFilter("Entry Type", '%1|%2|%3',
                        SalesAdvLetterEntryCZZ."Entry Type"::Payment,
                        SalesAdvLetterEntryCZZ."Entry Type"::Usage,
                        SalesAdvLetterEntryCZZ."Entry Type"::Close);
                    SalesAdvLetterEntryCZZ2.CalcSums(Amount, "Amount (LCY)");

                    AdvanceLetterApplicationCZZ.Init();
                    AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales;
                    AdvanceLetterApplicationCZZ."Advance Letter No." := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
                    AdvanceLetterApplicationCZZ."Document Type" := "Adv. Letter Usage Doc.Type CZZ"::"Posted Sales Invoice";
                    AdvanceLetterApplicationCZZ."Document No." := DocumentNo;
                    AdvanceLetterApplicationCZZ."Posting Date" := SalesAdvLetterEntryCZZ."Posting Date";
                    AdvanceLetterApplicationCZZ."Currency Code" := SalesAdvLetterEntryCZZ."Currency Code";
                    AdvanceLetterApplicationCZZ."Currency Factor" := SalesAdvLetterEntryCZZ."Currency Factor";
                    AdvanceLetterApplicationCZZ."Amount to Use" := -SalesAdvLetterEntryCZZ2.Amount;
                    AdvanceLetterApplicationCZZ."Amount to Use (LCY)" := -SalesAdvLetterEntryCZZ2."Amount (LCY)";
                    AdvanceLetterApplicationCZZ.Amount := SalesAdvLetterEntryCZZ.Amount;
                    AdvanceLetterApplicationCZZ."Amount (LCY)" := SalesAdvLetterEntryCZZ."Amount (LCY)";
                    AdvanceLetterApplicationCZZ.Insert();
                end else begin
                    AdvanceLetterApplicationCZZ.Amount += SalesAdvLetterEntryCZZ.Amount;
                    AdvanceLetterApplicationCZZ."Amount (LCY)" += SalesAdvLetterEntryCZZ."Amount (LCY)";
                    AdvanceLetterApplicationCZZ.Modify();
                end;
            until SalesAdvLetterEntryCZZ.Next() = 0;
    end;

    internal procedure CopyFrom(AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
        "Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type";
        "Advance Letter No." := AdvanceLetterApplicationCZZ."Advance Letter No.";
        "Document Type" := AdvanceLetterApplicationCZZ."Document Type";
        "Document No." := AdvanceLetterApplicationCZZ."Document No.";
        "Job No." := AdvanceLetterApplicationCZZ."Job No.";
        "Job Task No." := AdvanceLetterApplicationCZZ."Job Task No.";
        "Posting Date" := AdvanceLetterApplicationCZZ."Posting Date";
        "Currency Code" := AdvanceLetterApplicationCZZ."Currency Code";
        "Currency Factor" := AdvanceLetterApplicationCZZ."Currency Factor";
        Amount := AdvanceLetterApplicationCZZ.Amount;
        "Amount (LCY)" := AdvanceLetterApplicationCZZ."Amount (LCY)";
        "Amount to Use" := AdvanceLetterApplicationCZZ."Amount to Use";
        "Amount to Use (LCY)" := AdvanceLetterApplicationCZZ."Amount to Use (LCY)";
    end;

    internal procedure CopyFrom(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        "Advance Letter Type" := "Advance Letter Type"::Sales;
        "Advance Letter No." := SalesAdvLetterHeaderCZZ."No.";
        "Posting Date" := SalesAdvLetterHeaderCZZ."Posting Date";
        "Currency Code" := SalesAdvLetterHeaderCZZ."Currency Code";
        "Currency Factor" := SalesAdvLetterHeaderCZZ."Currency Factor";
        "Job No." := SalesAdvLetterHeaderCZZ."Job No.";
        "Job Task No." := SalesAdvLetterHeaderCZZ."Job Task No.";
    end;

    internal procedure CopyFrom(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        "Advance Letter Type" := "Advance Letter Type"::Purchase;
        "Advance Letter No." := PurchAdvLetterHeaderCZZ."No.";
        "Posting Date" := PurchAdvLetterHeaderCZZ."Posting Date";
        "Currency Code" := PurchAdvLetterHeaderCZZ."Currency Code";
        "Currency Factor" := PurchAdvLetterHeaderCZZ."Currency Factor";
    end;

    internal procedure Add(AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
        if not IsTemporary() then
            exit;

        Init();
        Rec := AdvanceLetterApplicationCZZ;
        Insert();
    end;

    internal procedure ApplyChanges()
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
    begin
        if not IsTemporary() then
            exit;

        AdvanceLetterApplicationCZZ.Get("Advance Letter Type", "Advance Letter No.", "Document Type", "Document No.");
        if Amount <= 0 then
            AdvanceLetterApplicationCZZ.Delete(true)
        else begin
            AdvanceLetterApplicationCZZ.Amount := Amount;
            AdvanceLetterApplicationCZZ."Amount (LCY)" := "Amount (LCY)";
            AdvanceLetterApplicationCZZ.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPossiblePurchAdvanceOnBeforeInsertNewAdvanceLetterApplication(var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPossibleSalesAdvanceOnBeforeInsertNewAdvanceLetterApplication(var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAssignedAdvanceOnBeforeInsertNewAdvanceLetterApplication(var NewAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
    end;
}
