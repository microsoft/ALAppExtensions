namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;
using Microsoft.Utilities;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.Currency;

table 8061 "Billing Line"
{
    DataClassification = CustomerContent;
    LookupPageId = "Billing Lines";
    DrillDownPageId = "Billing Lines";
    Caption = 'Billing Line';
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
            TableRelation = if (Partner = const(Customer)) "Customer Contract" else
            if (Partner = const(Vendor)) "Vendor Contract";
        }
        field(21; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract Line"."Line No." where("Contract No." = field("Contract No.")) else
            if (Partner = const(Vendor)) "Vendor Contract Line"."Line No." where("Contract No." = field("Contract No."));
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
        field(200; Indent; Integer)
        {
            Caption = 'Indent';
        }
        field(201; "Detail Overview"; Enum "Contract Detail Overview")
        {
            Caption = 'Detail Overview';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Service Object No.", "Service Commitment Entry No.", "Billing to")
        {
        }
        key(SK2; "Partner No.", "Contract No.", "Contract Line No.", "Billing from")
        {
        }
        key(SK3; "Contract No.", "Contract Line No.", "Billing from")
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
            Error(OnlyLastServiceLineCanBeDeletedErr, "Service Object No.");
        RecalculateCustomerContractHarmonizedBillingFields();
    end;

    var
        PageManagement: Codeunit "Page Management";
        DocumentExistsErr: Label 'There is an unposted invoice or credit memo for the service commitment. Please delete this document before updating the data.';
        OnlyLastServiceLineCanBeDeletedErr: Label 'Only last Billing Line for service can be deleted or all Billing Lines. Please make your selection accordingly or use the "Clear Billing Proposal" action. (%1)';
        CannotDeleteBillingLinesWithDocumentNoErr: Label 'Billing line connected with a sales/purchase document cannot be deleted.';

    internal procedure FindFirstBillingLineForServiceCommitment(var BillingLine2: Record "Billing Line")
    begin
        BillingLine2.SetCurrentKey("Service Object No.", "Service Commitment Entry No.", "Billing to");
        BillingLine2.SetAscending("Billing to", false);
        BillingLine2.SetRange("Service Object No.", "Service Object No.");
        BillingLine2.SetRange("Service Commitment Entry No.", "Service Commitment Entry No.");
        BillingLine2.FindFirst();
    end;

    internal procedure ResetServiceCommitmentNextBillingDate()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        GetServiceCommitment(ServiceCommitment);

        OnBeforeUpdateNextBillingDateInResetServiceCommitmentNextBillingDate(ServiceCommitment);
        if ("Document Type" = "Document Type"::"Credit Memo") and ("Correction Document Type" <> "Rec. Billing Document Type"::None) then
            ServiceCommitment.UpdateNextBillingDate("Billing to")
        else
            ServiceCommitment.UpdateNextBillingDate("Billing from" - 1);
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
        BillingLine.SetRange("Contract No.", Rec."Contract No.");
        BillingLine.CalcSums("Service Amount");
        exit(BillingLine."Service Amount");
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
        BillingLine.CalcSums("Service Amount");
        exit(BillingLine."Service Amount");
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

    internal procedure GetBillingDocumentTypeFromTextDocumentType(DocumentType: Text) RecurringBillingDocumentType: Enum "Rec. Billing Document Type"
    begin
        case DocumentType of
            Format(RecurringBillingDocumentType::Invoice):
                RecurringBillingDocumentType := RecurringBillingDocumentType::Invoice;
            Format(RecurringBillingDocumentType::"Credit Memo"):
                RecurringBillingDocumentType := RecurringBillingDocumentType::"Credit Memo";
        end;
    end;

    internal procedure InitNewBillingLine()
    begin
        Init();
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
        "Entry No." := 0;
    end;

    internal procedure OpenSalesDocumentCard()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(GetSalesDocumentTypeFromBillingDocumentType(), "Document No.") then
            PageManagement.PageRunModal(SalesHeader);
    end;

    internal procedure OpenPurchaseDocumentCard()
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
        Rec.SetRange("Contract No.", ContractNo);
    end;

    internal procedure FilterBillingLineOnContractLine(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer)
    begin
        Rec.FilterBillingLineOnContract(ServicePartner, ContractNo);
        Rec.SetRange("Contract Line No.", ContractLineNo);
    end;

    local procedure RecalculateCustomerContractHarmonizedBillingFields()
    var
        CustomerContract: Record "Customer Contract";
    begin
        if Rec.IsPartnerVendor() then
            exit;
        CustomerContract.Get(Rec."Contract No.");
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

    [InternalEvent(false, false)]
    local procedure OnBeforeUpdateNextBillingDateInResetServiceCommitmentNextBillingDate(var ServiceCommitment: Record "Service Commitment")
    begin
    end;

    local procedure GetServiceCommitment(var ServiceCommitment: Record "Service Commitment")
    begin
        ServiceCommitment.Get("Service Commitment Entry No.");
    end;
}