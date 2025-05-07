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
        field(5; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            TableRelation = if (Partner = const(Customer)) "Customer Subscription Contract" else
            if (Partner = const(Vendor)) "Vendor Subscription Contract";
        }
        field(6; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No.")) else
            if (Partner = const(Vendor)) "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
        }
        field(7; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
        }
        field(8; "Subscription Description"; Text[100])
        {
            Caption = 'Subscription Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header".Description where("No." = field("Subscription Header No.")));
            Editable = false;
        }
        field(9; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Subscription Line Entry No.';
        }
        field(10; "Subscription Line Description"; Text[100])
        {
            Caption = 'Subscription Line Description';
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
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
            ObsoleteReason = 'No longer needed as the time component is not relevant for processing of usage data.';
        }
        field(18; "Charge End Date"; Date)
        {
            Caption = 'Charge End Date';
        }
        field(19; "Charge End Time"; Time)
        {
            Caption = 'Charge End Time';
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
            ObsoleteReason = 'No longer needed as the time component is not relevant for processing of usage data.';
        }
        field(20; "Charged Period (Days)"; Decimal)
        {
            Caption = 'Charged Period (Days)';
        }
        field(21; "Charged Period (Hours)"; Decimal)
        {
            Caption = 'Charged Period (Hours)';
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
            ObsoleteReason = 'No longer needed as the time component is not relevant for processing of usage data.';
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
        field(28; "Usage Base Pricing"; Enum "Usage Based Pricing")
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
            if (Partner = const(Customer), "Document Type" = filter(Invoice)) "Billing Line"."Entry No."
                                                                                     where(Partner = const(Customer), "Document Type" = const(Invoice), "Document No." = field("Document No."))
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
            if (Partner = const(Vendor), "Document Type" = filter(Invoice)) "Billing Line"."Entry No."
                                                                                     where(Partner = const(Vendor), "Document Type" = const(Invoice), "Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = filter("Credit Memo")) "Billing Line"."Entry No."
                                                                                     where(Partner = const(Vendor), "Document Type" = const("Credit Memo"), "Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = filter("Posted Invoice")) "Billing Line Archive"."Entry No."
                                                                                     where(Partner = const(Vendor), "Document Type" = const(Invoice), "Document No." = field("Document No."))
            else
            if (Partner = const(Vendor), "Document Type" = filter("Posted Credit Memo")) "Billing Line Archive"."Entry No."
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
        field(34; Rebilling; Boolean)
        {
            Caption = 'Rebilling';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key1; "Usage Data Import Entry No.", "Subscription Header No.", "Subscription Line Entry No.", Partner, "Document Type", "Charge End Date")
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

    trigger OnDelete()
    begin
        if not Rec.IsInvoiced() then begin
            RevertServiceCommitmentNextBillingDateIfRebillingMetadataExist();
            DeleteUsageDataBillingMetadata();
        end;
    end;

    local procedure DeleteUsageDataBillingMetadata()
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        UsageDataBillingMetadata.SetRange("Usage Data Billing Entry No.", Rec."Entry No.");
        UsageDataBillingMetadata.DeleteAll();
    end;

    local procedure RevertServiceCommitmentNextBillingDateIfRebillingMetadataExist()
    var
        ServiceCommitment: Record "Subscription Line";
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        UsageDataBillingMetadata.FilterOnServiceCommitment(Rec."Subscription Line Entry No.");
        UsageDataBillingMetadata.SetRange(Rebilling, true);
        if not UsageDataBillingMetadata.FindLast() then
            exit;
        ServiceCommitment.Get(UsageDataBillingMetadata."Subscription Line Entry No.");
        ServiceCommitment."Next Billing Date" := UsageDataBillingMetadata."Original Invoiced to Date" + 1;
        ServiceCommitment.Modify();
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

    internal procedure InitFrom(UsageDataImportEntryNo: Integer; ServiceObjectNo: Code[20]; BillingPeriodStartDate: Date;
                        BillingPeriodEndDate: Date; UnitCost: Decimal; NewQuantity: Decimal; CostAmount: Decimal; UnitPrice: Decimal;
                        NewAmount: Decimal; CurrencyCode: Code[10])
    begin
        Rec.Init();
        Rec."Entry No." := 0;
        Rec."Usage Data Import Entry No." := UsageDataImportEntryNo;
        Rec."Subscription Header No." := ServiceObjectNo;
        Rec."Charge Start Date" := BillingPeriodStartDate;
        Rec."Charge End Date" := BillingPeriodEndDate;
        Rec."Unit Cost" := UnitCost;
        Rec.Quantity := NewQuantity;
        if CostAmount = 0 then
            Rec."Cost Amount" := NewQuantity * unitCost
        else
            Rec."Cost Amount" := CostAmount;
        Rec."Unit Price" := UnitPrice;
        Rec.Amount := NewAmount;
        Rec."Currency Code" := CurrencyCode;
        Rec.UpdateChargedPeriod();
    end;

    internal procedure FilterOnUsageDataImportAndServiceCommitment(UsageDataImportEntryNo: Integer; ServiceCommitment: Record "Subscription Line")
    begin
        Rec.SetRange("Usage Data Import Entry No.", UsageDataImportEntryNo);
        Rec.FilterOnServiceCommitment(ServiceCommitment);
    end;

    internal procedure FilterOnServiceCommitment(ServiceCommitment: Record "Subscription Line")
    begin
        Rec.SetRange("Subscription Line Entry No.", ServiceCommitment."Entry No.");
    end;

    internal procedure UpdateChargedPeriod()
    begin
        "Charged Period (Days)" := Rec."Charge End Date" - Rec."Charge Start Date" + 1;
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
        CustomerContract: Record "Customer Subscription Contract";
    begin
        UsageDataBilling.SetFilter("Subscription Contract No.", '<>%1', '');
        if UsageDataBilling.FindSet() then
            repeat
                if CustomerContract.Get(UsageDataBilling."Subscription Contract No.") then
                    CustomerContract.Mark(true);
            until UsageDataBilling.Next() = 0;
        CustomerContract.MarkedOnly(true);
        if CustomerContract.Count <> 0 then
            Page.Run(Page::"Customer Contracts", CustomerContract);
    end;

    local procedure MarkAndOpenVendorContracts(var UsageDataBilling: Record "Usage Data Billing")
    var
        VendorContract: Record "Vendor Subscription Contract";
    begin
        UsageDataBilling.SetFilter("Subscription Contract No.", '<>%1', '');
        if UsageDataBilling.FindSet() then
            repeat
                if VendorContract.Get(UsageDataBilling."Subscription Contract No.") then
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

    local procedure MarkPurchInvHeaderFromUsageDataBilling(var UsageDataBilling: Record "Usage Data Billing"; var PurchInvHeader: Record "Purch. Inv. Header")
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

    local procedure MarkSalesInvHeaderFromUsageDataBilling(var UsageDataBilling: Record "Usage Data Billing"; var SalesInvoiceHeader: Record "Sales Invoice Header")
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

    local procedure MarkSalesHeaderFromUsageDataBilling(var UsageDataBilling: Record "Usage Data Billing"; var SalesHeader: Record "Sales Header")
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

    internal procedure FilterOnDocumentTypeAndDocumentNo(ServicePartner: Enum "Service Partner"; UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20])
    begin
        Rec.SetRange(Partner, ServicePartner);
        Rec.SetRange("Document Type", UsageBasedBillingDocType);
        Rec.SetRange("Document No.", DocumentNo);
    end;

    internal procedure SaveDocumentValues(UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20]; DocumentEntryNo: Integer; BillingLineEntryNo: Integer)
    begin
        Rec."Document Type" := UsageBasedBillingDocType;
        Rec."Document No." := DocumentNo;
        Rec."Document Line No." := DocumentEntryNo;
        Rec."Billing Line Entry No." := BillingLineEntryNo;
        Rec.Modify(false);
        OnAfterSaveDocumentValues(Rec);
    end;

    internal procedure IsPartnerVendor(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Vendor);
    end;

    internal procedure IsPartnerCustomer(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Customer);
    end;

    local procedure FilterContractLine(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; EntryNo: Integer)
    begin
        Rec.SetRange(Partner, ServicePartner);
        Rec.SetRange("Subscription Contract No.", ContractNo);
        Rec.SetRange("Subscription Contract Line No.", EntryNo);
    end;

    local procedure FilterDocumentWithLine(ServicePartner: Enum "Service Partner"; DocumentType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20]; EntryNo: Integer)
    begin
        Rec.FilterOnDocumentTypeAndDocumentNo(ServicePartner, DocumentType, DocumentNo);
        Rec.SetRange("Document Line No.", EntryNo);
    end;

    local procedure FilterBillingLine(ServiceObjectNo: Code[20]; ServCommEntryNo: Integer; DocumentType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20])
    begin
        Rec.SetRange("Subscription Header No.", ServiceObjectNo);
        Rec.SetRange("Subscription Line Entry No.", ServCommEntryNo);
        Rec.SetRange("Document Type", DocumentType);
        Rec.SetRange("Document No.", DocumentNo);
    end;

    local procedure FilterServiceCommitmentLine(ServicePartner: Enum "Service Partner"; ServiceObjectNo: Code[20]; EntryNo: Integer)
    begin
        Rec.SetRange(Partner, ServicePartner);
        Rec.SetRange("Subscription Header No.", ServiceObjectNo);
        Rec.SetRange("Subscription Line Entry No.", EntryNo);
    end;

    internal procedure ShowForContractLine(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; EntryNo: Integer)
    begin
        FilterContractLine(ServicePartner, ContractNo, EntryNo);
        Page.RunModal(Page::"Usage Data Billings", Rec);
    end;

    internal procedure ShowForDocuments(ServicePartner: Enum "Service Partner"; DocumentType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20]; EntryNo: Integer)
    begin
        FilterDocumentWithLine(ServicePartner, DocumentType, DocumentNo, EntryNo);
        Page.RunModal(Page::"Usage Data Billings", Rec);
    end;

    internal procedure ShowForSalesDocuments(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; EntryNo: Integer)
    begin
        ShowForDocuments(Enum::"Service Partner"::Customer, UsageBasedDocTypeConv.ConvertSalesDocTypeToUsageBasedBillingDocType(DocumentType), DocumentNo, EntryNo);
    end;

    internal procedure ShowForPurchaseDocuments(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; EntryNo: Integer)
    begin
        ShowForDocuments(Enum::"Service Partner"::Vendor, UsageBasedDocTypeConv.ConvertPurchaseDocTypeToUsageBasedBillingDocType(DocumentType), DocumentNo, EntryNo);
    end;

    internal procedure ShowForRecurringBilling(ServiceObjectNo: Code[20]; ServCommEntryNo: Integer; DocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20])
    begin
        FilterBillingLine(ServiceObjectNo, ServCommEntryNo, UsageBasedDocTypeConv.ConvertRecurringBillingDocTypeToUsageBasedBillingDocType(DocumentType), DocumentNo);
        Page.RunModal(Page::"Usage Data Billings", Rec);
    end;

    internal procedure ShowForServiceCommitments(ServicePartner: Enum "Service Partner"; ServiceObjectNo: Code[20]; EntryNo: Integer)
    begin
        FilterServiceCommitmentLine(ServicePartner, ServiceObjectNo, EntryNo);
        Page.RunModal(Page::"Usage Data Billings", Rec);
    end;

    internal procedure ExistForContractLine(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; EntryNo: Integer): Boolean
    begin
        FilterContractLine(ServicePartner, ContractNo, EntryNo);
        exit(not Rec.IsEmpty());
    end;

    internal procedure ExistForDocuments(ServicePartner: Enum "Service Partner"; DocumentType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20]; EntryNo: Integer): Boolean
    begin
        FilterDocumentWithLine(ServicePartner, DocumentType, DocumentNo, EntryNo);
        exit(not Rec.IsEmpty());
    end;

    internal procedure ExistForSalesDocuments(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; EntryNo: Integer): Boolean
    begin
        exit(ExistForDocuments(Enum::"Service Partner"::Customer, UsageBasedDocTypeConv.ConvertSalesDocTypeToUsageBasedBillingDocType(DocumentType), DocumentNo, EntryNo));
    end;

    internal procedure ExistForPurchaseDocuments(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; EntryNo: Integer): Boolean
    begin
        exit(ExistForDocuments(Enum::"Service Partner"::Vendor, UsageBasedDocTypeConv.ConvertPurchaseDocTypeToUsageBasedBillingDocType(DocumentType), DocumentNo, EntryNo));
    end;

    internal procedure ExistForRecurringBilling(ServiceObjectNo: Code[20]; ServCommEntryNo: Integer; DocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20]): Boolean
    begin
        FilterBillingLine(ServiceObjectNo, ServCommEntryNo, UsageBasedDocTypeConv.ConvertRecurringBillingDocTypeToUsageBasedBillingDocType(DocumentType), DocumentNo);
        exit(not Rec.IsEmpty());
    end;

    internal procedure ExistForServiceCommitments(ServicePartner: Enum "Service Partner"; ServiceObjectNo: Code[20]; EntryNo: Integer): Boolean
    begin
        FilterServiceCommitmentLine(ServicePartner, ServiceObjectNo, EntryNo);
        exit(not Rec.IsEmpty());
    end;

    internal procedure UpdateRebilling()
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        UsageDataBillingMetadata.SetRange("Subscription No.", Rec."Subscription Header No.");
        UsageDataBillingMetadata.SetRange("Subscription Line Entry No.", Rec."Subscription Line Entry No.");
        UsageDataBillingMetadata.SetRange("Supplier Charge End Date", Rec."Charge End Date");
        UsageDataBillingMetadata.SetFilter("Supplier Charge Start Date", '<=%1', Rec."Charge Start Date");
        UsageDataBillingMetadata.SetRange(Invoiced, true);
        Rec.Rebilling := not UsageDataBillingMetadata.IsEmpty;
    end;

    internal procedure InsertMetadata()
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        UsageDataBillingMetadata.SetRange("Usage Data Billing Entry No.", Rec."Entry No.");
        if UsageDataBillingMetadata.IsEmpty then
            UsageDataBillingMetadata.InsertFromUsageDataBilling(Rec)
        else
            UsageDataBillingMetadata.ModifyAll(Rebilling, Rec.Rebilling, false);
    end;

    internal procedure SetMetadataAsInvoiced()
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        UsageDataBillingMetadata.SetRange("Billing Document Type", Rec."Document Type");
        UsageDataBillingMetadata.SetRange("Billing Document No.", Rec."Document No.");
        if UsageDataBillingMetadata.IsEmpty then
            exit;

        UsageDataBillingMetadata.ModifyAll(Invoiced, true, false);
    end;

    internal procedure IsInvoiced(): Boolean
    begin
        exit((Rec."Document Type" <> "Usage Based Billing Doc. Type"::None) and (Rec."Document No." <> ''));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSaveDocumentValues(UsageDateBilling: Record "Usage Data Billing")
    begin
    end;

    var
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
}
