namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

table 8056 "Service Comm. Package Line"
{
    Caption = 'Service Commitment Package Line';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            NotBlank = true;
            TableRelation = "Service Commitment Package";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';

            trigger OnValidate()
            begin
                CheckCalculationBaseTypeAgainstVendor();
            end;
        }
        field(4; Template; Code[20])
        {
            Caption = 'Template';
            TableRelation = "Service Commitment Template";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                ServiceCommitmentTemplate: Record "Service Commitment Template";
            begin
                if ServiceCommitmentTemplate.Get(Template) then begin
                    Description := ServiceCommitmentTemplate.Description;
                    "Calculation Base Type" := ServiceCommitmentTemplate."Calculation Base Type";
                    "Invoicing via" := ServiceCommitmentTemplate."Invoicing via";
                    "Invoicing Item No." := ServiceCommitmentTemplate."Invoicing Item No.";
                    "Calculation Base %" := ServiceCommitmentTemplate."Calculation Base %";
                    "Billing Base Period" := ServiceCommitmentTemplate."Billing Base Period";
                    Evaluate("Billing Rhythm", '');
                    Discount := ServiceCommitmentTemplate.Discount;
                    CheckCalculationBaseTypeAgainstVendor();
                    Rec."Usage Based Billing" := ServiceCommitmentTemplate."Usage Based Billing";
                    Rec."Usage Based Pricing" := ServiceCommitmentTemplate."Usage Based Pricing";
                    Rec."Pricing Unit Cost Surcharge %" := ServiceCommitmentTemplate."Pricing Unit Cost Surcharge %";
                end;
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; "Invoicing via"; Enum "Invoicing Via")
        {
            Caption = 'Invoicing via';
            InitValue = Contract;

            trigger OnValidate()
            begin
                if "Invoicing via" = "Invoicing via"::Sales then
                    "Invoicing Item No." := '';
                ErrorIfInvoicingViaIsNotContractForDiscount();
            end;
        }
        field(7; "Invoicing Item No."; Code[20])
        {
            Caption = 'Invoicing Item No.';
            TableRelation = Item."No." where("Service Commitment Option" = const("Invoicing Item"));

            trigger OnValidate()
            begin
                if "Invoicing via" = "Invoicing via"::Sales then
                    Error(InvoicingItemNoErr);
                ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount();
            end;
        }
        field(8; "Calculation Base Type"; Enum "Calculation Base Type")
        {
            Caption = 'Calculation Base Type';

            trigger OnValidate()
            begin
                CheckCalculationBaseTypeAgainstVendorError(Rec.Partner, Rec."Calculation Base Type");
            end;
        }
        field(9; "Calculation Base %"; Decimal)
        {
            Caption = 'Calculation Base %';
            MinValue = 0;
            DecimalPlaces = 0 : 5;
        }
        field(10; "Billing Base Period"; DateFormula)
        {
            Caption = 'Billing Base Period';
            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaNegative("Billing Base Period");
            end;
        }
        field(11; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaEmpty("Billing Rhythm", FieldCaption("Billing Rhythm"));
                DateFormulaManagement.ErrorIfDateFormulaNegative("Billing Rhythm");
            end;
        }
        field(12; "Service Comm. Start Formula"; DateFormula)
        {
            Caption = 'Service Commitment Start Formula';
        }
        field(13; "Initial Term"; DateFormula)
        {
            Caption = 'Initial Term';
            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaNegative("Initial Term");
            end;
        }
        field(14; "Notice Period"; DateFormula)
        {
            Caption = 'Notice Period';
            trigger OnValidate()
            begin
                TestField("Extension Term");
                DateFormulaManagement.ErrorIfDateFormulaNegative("Notice Period");
            end;
        }
        field(15; "Extension Term"; DateFormula)
        {
            Caption = 'Subsequent Term';
            trigger OnValidate()
            begin
                if Format("Extension Term") = '' then
                    Clear("Notice Period");
                DateFormulaManagement.ErrorIfDateFormulaNegative("Extension Term");
            end;
        }
        field(16; Discount; Boolean)
        {
            Caption = 'Discount';
            trigger OnValidate()
            begin
                ErrorIfInvoicingViaIsNotContractForDiscount();
                ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount();
                ErrorIfDiscountUsedWithUsageBasedBilling();
            end;
        }
        field(18; "Price Binding Period"; DateFormula)
        {
            Caption = 'Price Binding Period';
        }
        field(59; "Period Calculation"; enum "Period Calculation")
        {
            Caption = 'Period Calculation';
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
                end else
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
        key(PK; "Package Code", "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnModify()
    begin
        xRec.Get(xRec."Package Code", xRec."Line No.");
        if ((xRec."Billing Base Period" <> Rec."Billing Base Period") or (xRec."Billing Rhythm" <> Rec."Billing Rhythm")) then
            DateFormulaManagement.CheckIntegerRatioForDateFormulas("Billing Base Period", FieldCaption("Billing Base Period"), "Billing Rhythm", FieldCaption("Billing Rhythm"));
    end;

    var
        DateFormulaManagement: Codeunit "Date Formula Management";
        CalculationBaseTypeChangedErr: Label 'The Calculation Base Type cannot be changed to "Document Price And Discount", since no discounts can be given for Vendors in Quotes and Orders.';
        CalculationBaseTypeChangedNotificationMsg: Label 'Calculation Base Type was changed to Document Price, since no discounts can be given for Vendors in Quotes and Orders.';
        InvoicingItemNoErr: Label 'Service commitments for a sales document are not invoiced. No value may be entered in the Invoicing Item No..';
        DiscountCanBeInvoicedViaContractErr: Label 'Recurring discounts can only be granted for Invoicing via Contract.';
        DiscountCannotBeAssignedErr: Label 'Service Commitment Package lines, which are discounts can only be assigned to Service Commitment Items.';
        RecurringDiscountCannotBeGrantedErr: Label 'Recurring discounts cannot be granted be granted in conjunction with Usage Based Billing.';

    local procedure CheckCalculationBaseTypeAgainstVendor()
    begin
        if IsWrongCalculationBaseTypeForVendor(Partner, "Calculation Base Type") then begin
            "Calculation Base Type" := "Calculation Base Type"::"Document Price";
            NotifyCalculationBaseTypeChanged();
        end;
    end;

    internal procedure CheckCalculationBaseTypeAgainstVendorError(ServicePartner: Enum "Service Partner"; CalculationBaseType: Enum "Calculation Base Type")
    begin
        if IsWrongCalculationBaseTypeForVendor(ServicePartner, CalculationBaseType) then
            Error(CalculationBaseTypeChangedErr);
    end;

    local procedure IsWrongCalculationBaseTypeForVendor(ServicePartner: Enum "Service Partner"; CalculationBaseType: Enum "Calculation Base Type"): Boolean
    begin
        exit((ServicePartner = Enum::"Service Partner"::Vendor) and (CalculationBaseType = Enum::"Calculation Base Type"::"Document Price And Discount"));
    end;

    local procedure NotifyCalculationBaseTypeChanged()
    var
        CalculationBaseTypeChangeNotification: Notification;
    begin
        CalculationBaseTypeChangeNotification.Id := CreateGuid();
        CalculationBaseTypeChangeNotification.Message(CalculationBaseTypeChangedNotificationMsg);
        CalculationBaseTypeChangeNotification.Scope(NotificationScope::LocalScope);
        CalculationBaseTypeChangeNotification.Send();
    end;

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
        if Item."Service Commitment Option" <> Enum::"Item Service Commitment Type"::"Service Commitment Item" then
            Error(DiscountCannotBeAssignedErr);
    end;

    local procedure ErrorIfDiscountUsedWithUsageBasedBilling()
    begin
        if Rec.Discount then
            if Rec."Usage Based Billing" then
                Error(RecurringDiscountCannotBeGrantedErr);
    end;

    internal procedure IsPartnerVendor(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Vendor);
    end;
}
