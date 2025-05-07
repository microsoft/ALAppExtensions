namespace Microsoft.SubscriptionBilling;

using Microsoft.Utilities;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.Currency;
using System.Security.User;

table 8061 "Billing Line"
{
    DataClassification = CustomerContent;
    LookupPageId = "Billing Lines";
    DrillDownPageId = "Billing Lines";
    Caption = 'Billing Line';

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
            TableRelation = if (Partner = const(Customer)) "Customer Subscription Contract" else
            if (Partner = const(Vendor)) "Vendor Subscription Contract";
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
        field(54; "Update Required"; Boolean)
        {
            Caption = 'Update Required';

            trigger OnValidate()
            begin
                if ("Document Type" <> "Document Type"::None) and ("Document No." <> '') then
                    Error(DocumentExistsErr);
            end;
        }
        field(55; "Document Type"; Enum "Rec. Billing Document Type")
        {
            Caption = 'Document Type';
        }
        field(56; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = if ("Document Type" = const(Invoice), Partner = const(Customer)) "Sales Header"."No." where("Document Type" = const(Invoice)) else
            if ("Document Type" = const("Credit Memo"), Partner = const(Customer)) "Sales Header"."No." where("Document Type" = const("Credit Memo")) else
            if ("Document Type" = const("Credit Memo"), Partner = const(Vendor)) "Purchase Header"."No." where("Document Type" = const("Credit Memo")) else
            if ("Document Type" = const("Invoice"), Partner = const(Vendor)) "Purchase Header"."No." where("Document Type" = const("Invoice"));
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
        field(200; Indent; Integer)
        {
            Caption = 'Indent';
        }
        field(201; "Detail Overview"; Enum "Contract Detail Overview")
        {
            Caption = 'Detail Overview';
        }
        field(202; Rebilling; Boolean)
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
        key(SK1; "Subscription Header No.", "Subscription Line Entry No.", "Billing to")
        {
        }
        key(SK2; "Partner No.", "Subscription Contract No.", "Subscription Contract Line No.", "Billing from")
        {
        }
        key(SK3; "Subscription Contract No.", "Subscription Contract Line No.", "Billing from")
        {
        }
    }

    trigger OnDelete()
    var
        BillingLine2: Record "Billing Line";
    begin
        if "Document No." <> '' then
            Error(CannotDeleteBillingLinesWithDocumentNoErr);
        FindFirstBillingLineForServiceCommitment(BillingLine2);
        if (BillingLine2."Entry No." = "Entry No.") then
            ResetServiceCommitmentNextBillingDate()
        else
            Error(OnlyLastServiceLineCanBeDeletedErr, "Subscription Header No.");
        RecalculateCustomerContractHarmonizedBillingFields();
    end;

    var
        PageManagement: Codeunit "Page Management";
        DocumentExistsErr: Label 'There is an unposted invoice or credit memo for the Subscription Line. Please delete this document before updating the data.';
        OnlyLastServiceLineCanBeDeletedErr: Label 'Only last Billing Line for Subscription Line can be deleted or all Billing Lines. Please make your selection accordingly or use the "Clear Billing Proposal" action. (%1)';
        CannotDeleteBillingLinesWithDocumentNoErr: Label 'Billing line connected with a sales/purchase document cannot be deleted.';

    internal procedure FindFirstBillingLineForServiceCommitment(var BillingLine2: Record "Billing Line")
    begin
        BillingLine2.SetCurrentKey("Subscription Header No.", "Subscription Line Entry No.", "Billing to");
        BillingLine2.SetAscending("Billing to", false);
        BillingLine2.SetRange("Subscription Header No.", "Subscription Header No.");
        BillingLine2.SetRange("Subscription Line Entry No.", "Subscription Line Entry No.");
        BillingLine2.FindFirst();
    end;

    internal procedure ResetServiceCommitmentNextBillingDate()
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        GetServiceCommitment(ServiceCommitment);

        OnBeforeUpdateNextBillingDateInResetSubscriptionLineNextBillingDate(ServiceCommitment);
        if ("Document Type" = "Document Type"::"Credit Memo") and ("Correction Document Type" <> "Rec. Billing Document Type"::None) then
            ServiceCommitment.UpdateNextBillingDate("Billing to")
        else
            ServiceCommitment.UpdateNextBillingDate("Billing from" - 1);

        //Update next billing to date to last invoiced date from metadata if the billing line being deleted is rebilling
        UpdateNextBillingDateFromUsageDataMetadata(ServiceCommitment);
        ServiceCommitment.Modify(false);
    end;

    internal procedure GetSalesDocumentTypeForContractNo() SalesDocumentType: Enum "Sales Document Type"
    var
        ServiceAmount: Decimal;
    begin
        ServiceAmount := GetServiceAmountForContract();
        SalesDocumentType := GetSalesDocumentTypeForAmount(ServiceAmount);
    end;

    internal procedure GetPurchaseDocumentTypeForContractNo() PurchaseDocumentType: Enum "Purchase Document Type"
    var
        ServiceAmount: Decimal;
    begin
        ServiceAmount := GetServiceAmountForContract();
        PurchaseDocumentType := GetPurchaseDocumentTypeForAmount(ServiceAmount);
    end;

    local procedure GetServiceAmountForContract(): Decimal
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.Copy(Rec);
        BillingLine.SetRange("Subscription Contract No.", Rec."Subscription Contract No.");
        BillingLine.CalcSums(Amount);
        exit(BillingLine.Amount);
    end;

    internal procedure GetSalesDocumentTypeForCustomerNo() SalesDocumentType: Enum "Sales Document Type"
    var
        ServiceAmount: Decimal;
    begin
        ServiceAmount := GetServiceAmountForPartnerNo(true);
        SalesDocumentType := GetSalesDocumentTypeForAmount(ServiceAmount);
    end;

    internal procedure GetPurchaseDocumentTypeForVendorNo() PurchaseDocumentType: Enum "Purchase Document Type"
    var
        ServiceAmount: Decimal;
    begin
        ServiceAmount := GetServiceAmountForPartnerNo(false);
        PurchaseDocumentType := GetPurchaseDocumentTypeForAmount(ServiceAmount);
    end;

    local procedure GetServiceAmountForPartnerNo(UseDetailOverviewFilter: Boolean): Decimal
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.Copy(Rec);
        BillingLine.SetRange(Partner, Rec.Partner);
        BillingLine.SetRange("Partner No.", Rec."Partner No.");
        if UseDetailOverviewFilter then
            BillingLine.SetRange("Detail Overview", Rec."Detail Overview");
        BillingLine.SetRange("Currency Code", Rec."Currency Code");
        BillingLine.CalcSums(Amount);
        exit(BillingLine.Amount);
    end;

    local procedure GetSalesDocumentTypeForAmount(Amount: Decimal) SalesDocumentType: Enum "Sales Document Type"
    begin
        if Amount >= 0 then
            SalesDocumentType := SalesDocumentType::Invoice
        else
            SalesDocumentType := SalesDocumentType::"Credit Memo";
    end;

    local procedure GetPurchaseDocumentTypeForAmount(Amount: Decimal) PurchaseDocumentType: Enum "Purchase Document Type"
    begin
        if Amount >= 0 then
            PurchaseDocumentType := PurchaseDocumentType::Invoice
        else
            PurchaseDocumentType := PurchaseDocumentType::"Credit Memo";
    end;

    internal procedure GetSalesDocumentTypeFromBillingDocumentType() SalesDocumentType: Enum "Sales Document Type"
    begin
        case "Document Type" of
            "Document Type"::Invoice:
                SalesDocumentType := SalesDocumentType::Invoice;
            "Document Type"::"Credit Memo":
                SalesDocumentType := SalesDocumentType::"Credit Memo";
        end;
    end;

    internal procedure GetPurchaseDocumentTypeFromBillingDocumentType() PurchaseDocumentType: Enum "Purchase Document Type"
    begin
        case "Document Type" of
            "Document Type"::Invoice:
                PurchaseDocumentType := PurchaseDocumentType::Invoice;
            "Document Type"::"Credit Memo":
                PurchaseDocumentType := PurchaseDocumentType::"Credit Memo";
        end;
    end;

    internal procedure GetBillingDocumentTypeFromSalesDocumentType(SalesDocumentType: Enum "Sales Document Type") RecurringBillingDocumentType: Enum "Rec. Billing Document Type"
    begin
        case SalesDocumentType of
            SalesDocumentType::Invoice:
                RecurringBillingDocumentType := RecurringBillingDocumentType::Invoice;
            SalesDocumentType::"Credit Memo":
                RecurringBillingDocumentType := RecurringBillingDocumentType::"Credit Memo";
        end;
    end;

    internal procedure GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseDocumentType: Enum "Purchase Document Type") RecurringBillingDocumentType: Enum "Rec. Billing Document Type"
    begin
        case PurchaseDocumentType of
            PurchaseDocumentType::Invoice:
                RecurringBillingDocumentType := RecurringBillingDocumentType::Invoice;
            PurchaseDocumentType::"Credit Memo":
                RecurringBillingDocumentType := RecurringBillingDocumentType::"Credit Memo";
        end;
    end;

    internal procedure InitNewBillingLine()
    begin
        Init();
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
        "Entry No." := 0;
    end;

    local procedure OpenSalesDocumentCard()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(GetSalesDocumentTypeFromBillingDocumentType(), "Document No.") then
            PageManagement.PageRunModal(SalesHeader);
    end;

    local procedure OpenPurchaseDocumentCard()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(GetPurchaseDocumentTypeFromBillingDocumentType(), "Document No.") then
            PageManagement.PageRunModal(PurchaseHeader);
    end;

    internal procedure OpenDocumentCard()
    var
    begin
        case Partner of
            Partner::Customer:
                OpenSalesDocumentCard();
            Partner::Vendor:
                OpenPurchaseDocumentCard();
        end;
    end;

    internal procedure FilterBillingLineOnContract(ServicePartner: Enum "Service Partner"; ContractNo: Code[20])
    begin
        Rec.SetRange(Partner, ServicePartner);
        Rec.SetRange("Subscription Contract No.", ContractNo);
    end;

    internal procedure FilterBillingLineOnContractLine(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer)
    begin
        Rec.FilterBillingLineOnContract(ServicePartner, ContractNo);
        Rec.SetRange("Subscription Contract Line No.", ContractLineNo);
    end;

    local procedure RecalculateCustomerContractHarmonizedBillingFields()
    var
        CustomerContract: Record "Customer Subscription Contract";
    begin
        if Rec.IsPartnerVendor() then
            exit;
        CustomerContract.Get(Rec."Subscription Contract No.");
        CustomerContract.RecalculateHarmonizedBillingFieldsBasedOnNextBillingDate(0);
    end;

    internal procedure IsPartnerVendor(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Vendor);
    end;

    internal procedure GetSign(): Integer
    begin
        if Rec.Discount then
            exit(-1);
        exit(1);
    end;

    internal procedure GetCorrectionDocumentNo(ServicePartner: Enum "Service Partner"; DocumentNo: Code[20]): Code[20]
    begin
        Rec.SetRange(Partner, ServicePartner);
        Rec.SetRange("Document Type", Rec."Document Type"::"Credit Memo");
        Rec.SetRange("Document No.", DocumentNo);
        Rec.SetRange("Correction Document Type", Rec."Correction Document Type"::Invoice);
        if Rec.FindFirst() then
            exit(Rec."Correction Document No.");
        exit('');
    end;

    internal procedure FilterBillingLineOnDocumentLine(DocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20]; DocumentLineNo: Integer)
    begin
        Rec.SetRange("Document Type", DocumentType);
        Rec.SetRange("Document No.", DocumentNo);
        Rec.SetRange("Document Line No.", DocumentLineNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateNextBillingDateInResetSubscriptionLineNextBillingDate(var SubscriptionLine: Record "Subscription Line")
    begin
    end;

    local procedure GetServiceCommitment(var ServiceCommitment: Record "Subscription Line")
    begin
        ServiceCommitment.Get("Subscription Line Entry No.");
    end;

    local procedure UpdateNextBillingDateFromUsageDataMetadata(var ServiceCommitment: Record "Subscription Line")
    var
        UsageDataBilling: Record "Usage Data Billing";
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
        SupplierChargeEndDate: date;
    begin
        if not ServiceCommitment.IsUsageBasedBillingValid() then
            exit;
        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Rec.Partner, UsageBasedDocTypeConv.ConvertRecurringBillingDocTypeToUsageBasedBillingDocType(Rec."Document Type"), Rec."Document No.");
        if not UsageDataBilling.FindFirst() then
            exit;
        if UsageDataBilling.Rebilling then begin
            SupplierChargeEndDate := ServiceCommitment.GetSupplierChargeStartDateIfRebillingMetadataExist(Rec."Billing from");
            if SupplierChargeEndDate <> 0D then
                ServiceCommitment."Next Billing Date" := SupplierChargeEndDate;
        end;
    end;

    internal procedure RebillingUsageDataExist(): Boolean
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.SetRange("Subscription Header No.", Rec."Subscription Header No.");
        UsageDataBilling.SetRange("Subscription Line Entry No.", Rec."Subscription Line Entry No.");
        UsageDataBilling.SetRange("Charge Start Date", Rec."Billing from");
        UsageDataBilling.SetRange("Document Type", "Usage Based Billing Doc. Type"::None);
        UsageDataBilling.SetRange(Rebilling, true);
        exit(not UsageDataBilling.IsEmpty());
    end;
}