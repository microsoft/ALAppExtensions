namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

table 8054 "Sub. Package Line Template"
{
    Caption = 'Subscription Package Line Template';
    DataClassification = CustomerContent;
    DrillDownPageId = "Service Commitment Templates";
    LookupPageId = "Service Commitment Templates";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Invoicing via"; Enum "Invoicing Via")
        {
            Caption = 'Invoicing via';
            InitValue = Contract;
            trigger OnValidate()
            begin
                if "Invoicing via" = "Invoicing via"::Sales then begin
                    "Invoicing Item No." := '';
                    "Create Contract Deferrals" := "Create Contract Deferrals"::No;
                end else
                    "Create Contract Deferrals" := "Create Contract Deferrals"::"Contract-dependent";
                ErrorIfInvoicingViaIsNotContractForDiscount();
            end;
        }
        field(4; "Invoicing Item No."; Code[20])
        {
            Caption = 'Invoicing Item No.';
            TableRelation = Item."No." where("Subscription Option" = const("Invoicing Item"));

            trigger OnValidate()
            begin
                if "Invoicing via" = "Invoicing via"::Sales then
                    Error(InvoicingItemNoErr);
                ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount();
            end;
        }
        field(5; "Calculation Base Type"; Enum "Calculation Base Type")
        {
            Caption = 'Calculation Base Type';
        }
        field(6; "Calculation Base %"; Decimal)
        {
            Caption = 'Calculation Base %';
            MinValue = 0;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Billing Base Period"; DateFormula)
        {
            Caption = 'Billing Base Period';
            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaNegative("Billing Base Period");
            end;
        }
        field(8; Discount; Boolean)
        {
            Caption = 'Discount';
            trigger OnValidate()
            begin
                ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount();
                ErrorIfDiscountUsedWithUsageBasedBilling();
            end;
        }
        field(40; "Create Contract Deferrals"; Enum "Create Contract Deferrals")
        {
            Caption = 'Create Contract Deferrals';
        }
        field(8000; "Usage Based Billing"; Boolean)
        {
            Caption = 'Usage Based Billing';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Usage Based Billing" then begin
                    Rec.TestField("Invoicing via", Enum::"Invoicing Via"::Contract);
                    Rec.TestField(Discount, false);
                    if Rec."Usage Based Pricing" = "Usage Based Pricing"::None then
                        Rec.Validate("Usage Based Pricing", "Usage Based Pricing"::"Usage Quantity");
                end
                else
                    Validate("Usage Based Pricing", "Usage Based Pricing"::None);
            end;
        }
        field(8001; "Usage Based Pricing"; Enum "Usage Based Pricing")
        {
            Caption = 'Usage Based Pricing';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Usage Based Pricing" <> Enum::"Usage Based Pricing"::None then begin
                    Rec.TestField("Invoicing via", Enum::"Invoicing Via"::Contract);
                    Validate("Usage Based Billing", true);
                    if Rec."Usage Based Pricing" <> Enum::"Usage Based Pricing"::"Unit Cost Surcharge" then
                        Validate("Pricing Unit Cost Surcharge %", 0);
                end
                else begin
                    "Usage Based Billing" := false;
                    "Pricing Unit Cost Surcharge %" := 0;
                end;
            end;
        }
        field(8002; "Pricing Unit Cost Surcharge %"; Decimal)
        {
            Caption = 'Pricing Unit Cost Surcharge %';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    local procedure ErrorIfInvoicingViaIsNotContractForDiscount()
    begin
        if not Rec.Discount then
            exit;
        if Rec."Invoicing via" <> Enum::"Invoicing Via"::Contract then
            Error(DiscountCanBeInvoicedViaContractErr);
    end;

    local procedure ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount()
    var
        Item: Record Item;
    begin
        if not Rec.Discount then
            exit;
        if not Item.Get(Rec."Invoicing Item No.") then
            exit;
        if Item."Subscription Option" <> Enum::"Item Service Commitment Type"::"Service Commitment Item" then
            Error(DiscountCannotBeAssignedErr);
    end;

    local procedure ErrorIfDiscountUsedWithUsageBasedBilling()
    begin
        if Rec.Discount then
            if Rec."Usage Based Billing" then
                Error(RecurringDiscountCannotBeGrantedErr);
    end;

    var
        DateFormulaManagement: Codeunit "Date Formula Management";
        DiscountCannotBeAssignedErr: Label 'Subscription Package Lines, which are discounts can only be assigned to Subscription Items.';
        InvoicingItemNoErr: Label 'Subscription Lines for a sales document are not invoiced. No value may be entered in the Invoicing Item No..';
        RecurringDiscountCannotBeGrantedErr: Label 'Recurring discounts cannot be granted be granted in conjunction with Usage Based Billing.';
        DiscountCanBeInvoicedViaContractErr: Label 'Recurring discounts can only be granted for Invoicing via Contract.';
}
