namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Finance.Currency;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using System.Security.User;

table 8064 "Billing Line Archive"
{
    DataClassification = CustomerContent;
    LookupPageId = "Archived Billing Lines";
    DrillDownPageId = "Archived Billing Lines";
    Caption = 'Archived Billing Line';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(10; "Partner No."; Code[20])
        {
            Caption = 'Partner No.';
            TableRelation = if (Partner = const(Customer)) Customer else
            if (Partner = const(Vendor)) Vendor;
        }
        field(20; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            TableRelation = if (Partner = const(Customer)) "Customer Subscription Contract";
        }
        field(21; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No.")) else
            if (Partner = const(Vendor)) "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
        }
        field(30; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
        }
        field(31; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Subscription Line Entry No.';
        }
        field(32; "Subscription Description"; Text[100])
        {
            Caption = 'Subscription Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header".Description where("No." = field("Subscription Header No.")));
            Editable = false;
        }
        field(33; "Subscription Line Description"; Text[100])
        {
            Caption = 'Subscription Line Description';
        }
        field(34; "Subscription Line Start Date"; Date)
        {
            Caption = 'Subscription Line Start Date';
        }
        field(35; "Subscription Line End Date"; Date)
        {
            Caption = 'Subscription Line End Date';
        }
        field(36; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(38; Discount; Boolean)
        {
            Caption = 'Discount';
        }
        field(39; "Service Object Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(50; "Billing from"; Date)
        {
            Caption = 'Billing from';
        }
        field(51; "Billing to"; Date)
        {
            Caption = 'Billing to';
        }
        field(52; Amount; Decimal)
        {
            Caption = 'Amount';
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(53; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
        }
        field(55; "Document Type"; Enum "Rec. Billing Document Type")
        {
            Caption = 'Document Type';
        }
        field(56; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = if ("Document Type" = const(Invoice), Partner = const(Customer)) "Sales Invoice Header" else
            if ("Document Type" = const("Credit Memo"), Partner = const(Customer)) "Sales Cr.Memo Header" else
            if ("Document Type" = const("Invoice"), Partner = const(Vendor)) "Purch. Inv. Header" else
            if ("Document Type" = const("Credit Memo"), Partner = const(Vendor)) "Purch. Cr. Memo Hdr.";
        }
        field(57; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Price';
        }
        field(58; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            MinValue = 0;
            MaxValue = 100;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(60; "Correction Document Type"; Enum "Rec. Billing Document Type")
        {
            Caption = 'Correction Document Type';
        }
        field(61; "Correction Document No."; Code[20])
        {
            Caption = 'Correction Document No.';
            TableRelation = if ("Correction Document Type" = const(Invoice), Partner = const(Customer)) "Sales Invoice Header"."No." else
            if ("Correction Document Type" = const("Credit Memo"), Partner = const(Customer)) "Sales Cr.Memo Header"."No." else
            if ("Correction Document Type" = const(Invoice), Partner = const(Vendor)) "Purch. Inv. Header"."No." else
            if ("Correction Document Type" = const("Credit Memo"), Partner = const(Vendor)) "Purch. Cr. Memo Hdr."."No.";
        }
        field(62; "Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Document Line No.';
            TableRelation = if (Partner = const(Customer),
                                "Document Type" = const(Invoice)) "Sales Line"."Line No." where("Document Type" = const(Invoice), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = const("Credit Memo")) "Sales Line"."Line No." where("Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = const(Invoice)) "Purchase Line"."Line No." where("Document Type" = const(Invoice), "Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = const("Credit Memo")) "Purchase Line"."Line No." where("Document Type" = const("Credit Memo"), "Document No." = field("Document No."));
        }
        field(100; "Billing Template Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = "Billing Template";
        }
        field(101; "Currency Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = Currency.Code;
        }
        field(102; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(103; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Subscription Contract No.", "Subscription Contract Line No.", "Billing from")
        {
        }
    }
    internal procedure PostedDocumentExist(): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case "Document Type" of
            "Document Type"::Invoice:
                exit(SalesInvoiceHeader.Get("Document No."));
            "Document Type"::"Credit Memo":
                exit(SalesCrMemoHeader.Get("Document No."));
        end
    end;

    internal procedure ShowDocumentCard()
    begin
        case Partner of
            Partner::Customer:
                ShowPostedSalesDocumentCard();
            Partner::Vendor:
                ShowPostedPurchaseDocumentCard();
        end;
    end;

    local procedure ShowPostedSalesDocumentCard()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case "Document Type" of
            "Document Type"::Invoice:
                if SalesInvoiceHeader.Get("Document No.") then
                    Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
            "Document Type"::"Credit Memo":
                if SalesCrMemoHeader.Get("Document No.") then
                    Page.Run(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
        end;
    end;

    local procedure ShowPostedPurchaseDocumentCard()
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        PurchaseCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        case "Document Type" of
            "Document Type"::Invoice:
                if PurchaseInvoiceHeader.Get("Document No.") then
                    Page.Run(Page::"Posted Purchase Invoice", PurchaseInvoiceHeader);
            "Document Type"::"Credit Memo":
                if PurchaseCrMemoHeader.Get("Document No.") then
                    Page.Run(Page::"Posted Purchase Credit Memo", PurchaseCrMemoHeader);
        end;
    end;

    internal procedure PostedPurchaseDocumentExist(): Boolean
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        PurchaseCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        case "Document Type" of
            "Document Type"::Invoice:
                exit(PurchaseInvoiceHeader.Get("Document No."));
            "Document Type"::"Credit Memo":
                exit(PurchaseCrMemoHeader.Get("Document No."));
        end;
    end;

    internal procedure FilterBillingLineArchiveOnContract(ServicePartner: Enum "Service Partner"; ContractNo: Code[20])
    begin
        Rec.SetRange(Partner, ServicePartner);
        Rec.SetRange("Subscription Contract No.", ContractNo);
    end;

    internal procedure FilterBillingLineArchiveOnContractLine(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer)
    begin
        Rec.FilterBillingLineArchiveOnContract(ServicePartner, ContractNo);
        Rec.SetRange("Subscription Contract Line No.", ContractLineNo);
    end;

    internal procedure FilterBillingLineArchiveOnDocument(RecurringBillingDocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20])
    begin
        Rec.SetRange("Document Type", RecurringBillingDocumentType);
        Rec.SetRange("Document No.", DocumentNo);
    end;

    internal procedure FilterBillingLineArchiveOnServiceCommitment(ServiceCommitmentEntryNo: Integer)
    begin
        Rec.SetRange("Subscription Line Entry No.", ServiceCommitmentEntryNo);
    end;

    internal procedure IsInvoiceCredited(ServicePartner: Enum "Service Partner"; DocumentNo: Code[20]): Boolean
    begin
        Rec.SetRange(Partner, ServicePartner);
        Rec.SetRange("Document Type", Rec."Document Type"::"Credit Memo");
        Rec.SetRange("Correction Document Type", Rec."Correction Document Type"::Invoice);
        Rec.SetRange("Correction Document No.", DocumentNo);
        exit(not Rec.IsEmpty());
    end;
}