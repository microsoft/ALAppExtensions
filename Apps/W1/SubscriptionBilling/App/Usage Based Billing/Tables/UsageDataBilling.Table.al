namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;

table 8006 "Usage Data Billing"
{
    Caption = 'Usage Data Billing';
    DataClassification = CustomerContent;
    DrillDownPageId = "Usage Data Billings";
    LookupPageId = "Usage Data Billings";
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Usage Data Import Entry No."; Integer)
        {
            Caption = 'Usage Data Import Entry No.';
        }
        field(3; "Supplier No."; Code[20])
        {
            Caption = 'Supplier No.';
        }
        field(4; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(5; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract" else
            if (Partner = const(Vendor)) "Vendor Contract";
        }
        field(6; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract Line"."Line No." where("Contract No." = field("Contract No.")) else
            if (Partner = const(Vendor)) "Vendor Contract Line"."Line No." where("Contract No." = field("Contract No."));
        }
        field(7; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
        }
        field(8; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';
            fieldClass = Flowfield;
            CalcFormula = lookup("Service Object".Description where("No." = field("Service Object No.")));
            Editable = false;
        }
        field(9; "Service Commitment Entry No."; Integer)
        {
            Caption = 'Service Commitment Entry No.';
        }
        field(10; "Service Commitment Description"; Text[100])
        {
            Caption = 'Service Commitment Description';
        }
        field(11; "Processing Status"; Enum "Processing Status")
        {
            Caption = 'Processing Status';
            Editable = false;
            trigger OnValidate()
            begin
                if "Processing Status" in ["Processing Status"::None, "Processing Status"::Ok] then
                    SetReason('');
                if "Processing Status" = "Processing Status"::None then
                    "Processing Date" := 0D
                else
                    "Processing Date" := WorkDate();
            end;
        }
        field(12; "Processing Date"; Date)
        {
            Caption = 'Processing Date';
            Editable = false;
        }
        field(13; "Processing Time"; Time)
        {
            Caption = 'Processing Time';
        }
        field(14; "Reason (Preview)"; Text[80])
        {
            Caption = 'Reason (Preview)';
            Editable = false;

            trigger OnLookup()
            begin
                ShowReason();
            end;
        }
        field(15; Reason; Blob)
        {
            Caption = 'Reason';
        }
        field(16; "Charge Start Date"; Date)
        {
            Caption = 'Charge Start Date';
        }
        field(17; "Charge Start Time"; Time)
        {
            Caption = 'Charge Start Time';
        }
        field(18; "Charge End Date"; Date)
        {
            Caption = 'Charge End Date';
        }
        field(19; "Charge End Time"; Time)
        {
            Caption = 'Charge End Time';
        }
        field(20; "Charged Period (Days)"; Decimal)
        {
            Caption = 'Charged Period (Days)';
        }
        field(21; "Charged Period (Hours)"; Decimal)
        {
            Caption = 'Charged Period (Hours)';
        }
        field(22; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(23; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            AutoFormatExpression = "Currency Code";
        }
        field(24; "Cost Amount"; Decimal)
        {
            Caption = 'Cost Amount';
            AutoFormatExpression = "Currency Code";
        }
        field(25; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            AutoFormatExpression = "Currency Code";
        }
        field(26; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatExpression = "Currency Code";
        }
        field(27; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(28; "Usage Base Pricing"; enum "Usage Based Pricing")
        {
            Caption = 'Usage Base Pricing';
        }
        field(29; "Pricing Unit Cost Surcharge %"; Decimal)
        {
            Caption = 'Pricing Unit Cost Surcharge %';
        }
        field(30; "Billing Line Entry No."; Integer)
        {
            Caption = 'Billing Line Entry No.';
            TableRelation =
            if (Partner = const(Customer), "Document Type" = filter("Invoice")) "Billing Line"."Entry No."
                                                                                     where(Partner = const(Customer), "Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = filter("Credit Memo")) "Billing Line"."Entry No."
                                                                                     where(Partner = const(Customer), "Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = filter("Posted Invoice")) "Billing Line Archive"."Entry No."
                                                                                     where(Partner = const(Customer), "Document Type" = const(Invoice), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = filter("Posted Credit Memo")) "Billing Line Archive"."Entry No."
                                                                                     where(Partner = const(Customer), "Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = filter("Invoice")) "Billing Line"."Entry No."
                                                                                     where(Partner = const(Vendor), "Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = filter("Credit Memo")) "Billing Line"."Entry No."
                                                                                     where(Partner = const(Vendor), "Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = filter("Posted Invoice")) "Billing Line Archive"."Entry No."
                                                                                     where(Partner = const(Vendor), "Document Type" = const(Invoice), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = filter("Posted Credit Memo")) "Billing Line Archive"."Entry No."
                                                                                     where(Partner = const(Vendor), "Document Type" = const("Credit Memo"), "Document No." = field("Document No."));
        }
        field(31; "Document Type"; Enum "Usage Based Billing Doc. Type")
        {
            Caption = 'Document Type';
        }
        field(32; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = if (Partner = const(Customer),
                                "Document Type" = const(Invoice)) "Sales Header"."No." where("Document Type" = const(Invoice))
            else
            if (Partner = const(Customer), "Document Type" = const("Credit Memo")) "Sales Header"."No." where("Document Type" = const("Credit Memo"))
            else
            if (Partner = const(Customer), "Document Type" = const("Posted Invoice")) "Sales Invoice Header"."No."
            else
            if (Partner = const(Customer), "Document Type" = const("Posted Credit Memo")) "Sales Cr.Memo Header"."No."
            else
            if (Partner = const(Vendor), "Document Type" = const(Invoice)) "Purchase Header"."No." where("Document Type" = const(Invoice))
            else
            if (Partner = const(Vendor), "Document Type" = const("Credit Memo")) "Purchase Header"."No." where("Document Type" = const("Credit Memo"))
            else
            if (Partner = const(Vendor), "Document Type" = const("Posted Invoice")) "Purch. Inv. Header"."No."
            else
            if (Partner = const(Vendor), "Document Type" = const("Posted Credit Memo")) "Purch. Cr. Memo Hdr."."No.";
        }
        field(33; "Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Document Line No.';
            TableRelation = if (Partner = const(Customer),
                                "Document Type" = const(Invoice)) "Sales Line"."Line No." where("Document Type" = const(Invoice), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = const("Credit Memo")) "Sales Line"."Line No." where("Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = const("Posted Invoice")) "Sales Invoice Line"."Line No." where("Document No." = field("Document No."))
            else
            if (Partner = const(Customer), "Document Type" = const("Posted Credit Memo")) "Sales Cr.Memo Line"."Line No." where("Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = const(Invoice)) "Purchase Line"."Line No." where("Document Type" = const(Invoice), "Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = const("Credit Memo")) "Purchase Line"."Line No." where("Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = const("Posted Invoice")) "Purch. Inv. Line"."Line No." where("Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = const("Posted Credit Memo")) "Purch. Cr. Memo Line"."Line No." where("Document No." = field("Document No."));
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key1; "Usage Data Import Entry No.", "Service Object No.", "Service Commitment Entry No.", Partner, "Document Type", "Charge End Date", "Charge End Time")
        {
            SumIndexFields = Quantity, Amount;
            MaintainSiftIndex = true;
        }

    }
    trigger OnInsert()
    begin
        "Processing Date" := Today();
        "Processing Time" := Time();
    end;

    trigger OnModify()
    begin
        "Processing Date" := Today();
        "Processing Time" := Time();
    end;

    internal procedure SetReason(ReasonText: Text)
    var
        TextManagement: Codeunit "Text Management";
        RRef: RecordRef;
    begin
        if ReasonText = '' then begin
            Clear("Reason (Preview)");
            Clear(Reason);
        end else begin
            "Reason (Preview)" := CopyStr(ReasonText, 1, MaxStrLen("Reason (Preview)"));
            RRef.GetTable(Rec);
            TextManagement.WriteBlobText(RRef, FieldNo(Reason), ReasonText);
            RRef.SetTable(Rec);
        end;
    end;

    internal procedure InitFromUsageDataGenericImport(UsageDataGenericImport: Record "Usage Data Generic Import")
    begin
        Rec.Init();
        Rec."Entry No." := 0;
        Rec."Usage Data Import Entry No." := UsageDataGenericImport."Usage Data Import Entry No.";
        Rec."Service Object No." := UsageDataGenericImport."Service Object No.";
        Rec."Charge Start Date" := UsageDataGenericImport."Billing Period Start Date";
        Rec."Charge Start Time" := 000000T;
        Rec."Charge End Date" := CalcDate('<+1D>', UsageDataGenericImport."Billing Period End Date");
        Rec."Charge End Time" := 000000T;
        Rec."Unit Cost" := UsageDataGenericImport.Cost;
        Rec.Quantity := UsageDataGenericImport.Quantity;
        if UsageDataGenericImport."Cost Amount" = 0 then
            Rec."Cost Amount" := UsageDataGenericImport.Quantity * UsageDataGenericImport.Cost
        else
            Rec."Cost Amount" := UsageDataGenericImport."Cost Amount";
        Rec."Unit Price" := UsageDataGenericImport.Price;
        Rec.Amount := UsageDataGenericImport.Amount;
        Rec."Currency Code" := UsageDataGenericImport.GetCurrencyCode();
        Rec.UpdateChargedPeriod();
        OnAfterInitFromUsageDataGenericImport(Rec, UsageDataGenericImport);
    end;

    internal procedure FilterOnUsageDataImportAndServiceCommitment(UsageDataImport: Record "Usage Data Import"; ServiceCommitment: Record "Service Commitment")
    begin
        Rec.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        Rec.FilterOnServiceCommitment(ServiceCommitment);
    end;

    internal procedure FilterOnServiceCommitment(ServiceCommitment: Record "Service Commitment")
    begin
        Rec.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
    end;

    internal procedure UpdateChargedPeriod()
    var
        Milliseconds: BigInteger;
    begin
        Milliseconds := EssDateTimeMgt.GetDurationForRange("Charge Start Date", "Charge Start Time", "Charge End Date", "Charge End Time");
        "Charged Period (Days)" := Milliseconds / EssDateTimeMgt.GetMillisecondsForDay();
        "Charged Period (Hours)" := Milliseconds / EssDateTimeMgt.GetMillisecondsForHour();
    end;

    internal procedure ShowReason()
    var
        TextManagement: Codeunit "Text Management";
        RRef: RecordRef;
    begin
        CalcFields(Reason);
        RRef.GetTable(Rec);
        TextManagement.ShowFieldText(RRef, FieldNo(Reason));
    end;

    internal procedure ShowRelatedDocuments(var UsageBasedBilling: Record "Usage Data Billing"; DocumentType: Option Contract,"Contract Invoices","Posted Contract Invoices"; ServicePartner: Enum "Service Partner")
    begin
        UsageBasedBilling.SetRange(Partner, ServicePartner);
        case DocumentType of
            DocumentType::Contract:
                if ServicePartner = "Service Partner"::Customer then
                    MarkAndOpenCustomerContracts(UsageBasedBilling)
                else
                    MarkAndOpenVendorContracts(UsageBasedBilling);
            DocumentType::"Contract Invoices":
                if ServicePartner = "Service Partner"::Customer then
                    MarkAndOpenSalesInvoices(UsageBasedBilling)
                else
                    MarkAndOpenPurchaseInvoices(UsageBasedBilling);
            DocumentType::"Posted Contract Invoices":
                if ServicePartner = "Service Partner"::Customer then
                    MarkAndOpenPostedSalesInvoices(UsageBasedBilling)
                else
                    MarkAndOpenPostedPurchaseInvoices(UsageBasedBilling);
        end;
    end;

    local procedure MarkAndOpenCustomerContracts(var UsageDataBilling: Record "Usage Data Billing")
    var
        CustomerContract: Record "Customer Contract";
    begin
        UsageDataBilling.SetFilter("Contract No.", '<>%1', '');
        if UsageDataBilling.FindSet() then
            repeat
                if CustomerContract.Get(UsageDataBilling."Contract No.") then
                    CustomerContract.Mark(true);
            until UsageDataBilling.Next() = 0;
        CustomerContract.MarkedOnly(true);
        if CustomerContract.Count <> 0 then
            Page.Run(Page::"Customer Contracts", CustomerContract);
    end;

    local procedure MarkAndOpenVendorContracts(var UsageDataBilling: Record "Usage Data Billing")
    var
        VendorContract: Record "Vendor Contract";
    begin
        UsageDataBilling.SetFilter("Contract No.", '<>%1', '');
        if UsageDataBilling.FindSet() then
            repeat
                if VendorContract.Get(UsageDataBilling."Contract No.") then
                    VendorContract.Mark(true);
            until UsageDataBilling.Next() = 0;
        VendorContract.MarkedOnly(true);
        if VendorContract.Count <> 0 then
            Page.Run(Page::"Vendor Contracts", VendorContract);
    end;

    local procedure MarkAndOpenSalesInvoices(var UsageDataBilling: Record "Usage Data Billing")
    var
        SalesHeader: Record "Sales Header";
    begin
        MarkSalesHeaderFromUsageDataBilling(UsageDataBilling, SalesHeader);
        if SalesHeader.Count <> 0 then
            Page.Run(Page::"Sales Invoice List", SalesHeader);
    end;

    local procedure MarkAndOpenPurchaseInvoices(var UsageDataBilling: Record "Usage Data Billing")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        MarkPurchaseHeaderFromUsageDataBilling(UsageDataBilling, PurchaseHeader);
        if PurchaseHeader.Count <> 0 then
            Page.Run(Page::"Purchase Invoices", PurchaseHeader);
    end;

    local procedure MarkAndOpenPostedSalesInvoices(var UsageDataBilling: Record "Usage Data Billing")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        MarkSalesInvHeaderFromUsageDataBilling(UsageDataBilling, SalesInvoiceHeader);
        if SalesInvoiceHeader.Count <> 0 then
            Page.Run(Page::"Posted Sales Invoices", SalesInvoiceHeader);
    end;

    local procedure MarkAndOpenPostedPurchaseInvoices(var UsageDataBilling: Record "Usage Data Billing")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        MarkPurchInvHeaderFromUsageDataBilling(UsageDataBilling, PurchInvHeader);
        if PurchInvHeader.Count <> 0 then
            Page.Run(Page::"Posted Purchase Invoices", PurchInvHeader);
    end;

    internal procedure MarkPurchaseHeaderFromUsageDataBilling(var UsageDataBilling: Record "Usage Data Billing"; var PurchaseHeader: Record "Purchase Header")
    begin
        UsageDataBilling.SetRange("Document Type", "Usage Based Billing Doc. Type"::Invoice);
        UsageDataBilling.SetFilter("Document No.", '<>%1', '');
        if UsageDataBilling.FindSet() then
            repeat
                if PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, UsageDataBilling."Document No.") then
                    PurchaseHeader.Mark(true);
            until UsageDataBilling.Next() = 0;
        PurchaseHeader.MarkedOnly(true);
    end;

    internal procedure MarkPurchInvHeaderFromUsageDataBilling(var UsageDataBilling: Record "Usage Data Billing"; var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        UsageDataBilling.SetRange("Document Type", "Usage Based Billing Doc. Type"::"Posted Invoice");
        UsageDataBilling.SetFilter("Document No.", '<>%1', '');
        if UsageDataBilling.FindSet() then
            repeat
                if PurchInvHeader.Get(UsageDataBilling."Document No.") then
                    PurchInvHeader.Mark(true);
            until UsageDataBilling.Next() = 0;
        PurchInvHeader.MarkedOnly(true);
    end;

    internal procedure MarkSalesInvHeaderFromUsageDataBilling(var UsageDataBilling: Record "Usage Data Billing"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        UsageDataBilling.SetRange("Document Type", "Usage Based Billing Doc. Type"::"Posted Invoice");
        UsageDataBilling.SetFilter("Document No.", '<>%1', '');
        if UsageDataBilling.FindSet() then
            repeat
                if SalesInvoiceHeader.Get(UsageDataBilling."Document No.") then
                    SalesInvoiceHeader.Mark(true);
            until UsageDataBilling.Next() = 0;
        SalesInvoiceHeader.MarkedOnly(true);
    end;

    internal procedure MarkSalesHeaderFromUsageDataBilling(var UsageDataBilling: Record "Usage Data Billing"; var SalesHeader: Record "Sales Header")
    begin
        UsageDataBilling.SetRange("Document Type", "Usage Based Billing Doc. Type"::Invoice);
        UsageDataBilling.SetFilter("Document No.", '<>%1', '');
        if UsageDataBilling.FindSet() then
            repeat
                if SalesHeader.Get(Enum::"Sales Document Type"::Invoice, UsageDataBilling."Document No.") then
                    SalesHeader.Mark(true);
            until UsageDataBilling.Next() = 0;
        SalesHeader.MarkedOnly(true);
    end;

    internal procedure FilterOnDocumentTypeAndDocumentNo(UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20])
    begin
        Rec.SetRange("Document Type", UsageBasedBillingDocType);
        Rec.SetRange("Document No.", DocumentNo);
    end;

    internal procedure SaveDocumentValues(UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20];
                                                                      DocumentLineNo: Integer;
                                                                      BillingLineEntryNo: Integer)
    begin
        Rec."Document Type" := UsageBasedBillingDocType;
        Rec."Document No." := DocumentNo;
        Rec."Document Line No." := DocumentLineNo;
        Rec."Billing Line Entry No." := BillingLineEntryNo;
        Rec.Modify(false);
    end;

    internal procedure IsPartnerVendor(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Vendor);
    end;

    internal procedure IsPartnerCustomer(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Customer);
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInitFromUsageDataGenericImport(var UsageDataBilling: Record "Usage Data Billing"; UsageDataGenericImport: Record "Usage Data Generic Import")
    begin
    end;

    var
        EssDateTimeMgt: Codeunit "Date Time Management";
}
