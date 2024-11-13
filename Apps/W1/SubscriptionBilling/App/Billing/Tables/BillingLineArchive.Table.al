namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;

table 8064 "Billing Line Archive"
{
    DataClassification = CustomerContent;
    LookupPageId = "Archived Billing Lines";
    DrillDownPageId = "Archived Billing Lines";
    Caption = 'Archived Billing Line';
    Access = Internal;

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
            TableRelation = User."User Name";
        }
        field(10; "Partner No."; Code[20])
        {
            Caption = 'Partner No.';
            TableRelation = if (Partner = const(Customer)) Customer else
            if (Partner = const(Vendor)) Vendor;
        }
        field(20; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract";
        }
        field(21; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract Line"."Line No." where("Contract No." = field("Contract No."));
        }
        field(30; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
        }
        field(31; "Service Commitment Entry No."; Integer)
        {
            Caption = 'Service Commitment Entry No.';
        }
        field(32; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object".Description where("No." = field("Service Object No.")));
            Editable = false;
        }
        field(33; "Service Commitment Description"; Text[100])
        {
            Caption = 'Service Commitment Description';
        }
        field(34; "Service Start Date"; Date)
        {
            Caption = 'Service Start Date';
        }
        field(35; "Service End Date"; Date)
        {
            Caption = 'Service End Date';
        }
        field(36; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(38; Discount; Boolean)
        {
            Caption = 'Discount';
        }
        field(39; "Service Obj. Quantity Decimal"; Decimal)
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
        field(52; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
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
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Contract No.", "Contract Line No.", "Billing from")
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
        Rec.SetRange("Contract No.", ContractNo);
    end;

    internal procedure FilterBillingLineArchiveOnContractLine(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer)
    begin
        Rec.FilterBillingLineArchiveOnContract(ServicePartner, ContractNo);
        Rec.SetRange("Contract Line No.", ContractLineNo);
    end;

    internal procedure FilterBillingLineArchiveOnDocument(RecurringBillingDocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20])
    begin
        Rec.SetRange("Document Type", RecurringBillingDocumentType);
        Rec.SetRange("Document No.", DocumentNo);
    end;

    internal procedure FilterBillingLineArchiveOnServiceCommitment(ServiceCommitmentEntryNo: Integer)
    begin
        Rec.SetRange("Service Commitment Entry No.", ServiceCommitmentEntryNo);
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