namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Finance.Currency;
using System.Security.AccessControl;

table 8009 "Imported Service Commitment"
{
    DataClassification = CustomerContent;
    Caption = 'Imported Service Commitment';
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            NotBlank = true;
        }
        field(2; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
            ValidateTableRelation = false;
        }
        field(3; "Service Commitment Entry No."; Integer)
        {
            Caption = 'Service Commitment Entry No.';
        }
        field(4; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(5; "Contract No."; Code[20])
        {
            Caption = 'Contract';
            TableRelation = if (Partner = const(Customer)) "Customer Contract" else
            if (Partner = const(Vendor)) "Vendor Contract";
            ValidateTableRelation = false;
        }
        field(6; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract Line"."Line No." where("Contract No." = field("Contract No.")) else
            if (Partner = const(Vendor)) "Vendor Contract Line"."Line No." where("Contract No." = field("Contract No."));
            ValidateTableRelation = false;
        }
        field(7; "Contract Line Type"; Enum "Contract Line Type")
        {
            Caption = 'Contract Line Type';
        }
        field(8; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            NotBlank = true;
            TableRelation = "Service Commitment Package";
        }
        field(9; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "Service Commitment Template";
            ValidateTableRelation = false;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Service Start Date"; Date)
        {
            Caption = 'Service Start Date';
        }
        field(12; "Service End Date"; Date)
        {
            Caption = 'Service End Date';
        }
        field(13; "Next Billing Date"; Date)
        {
            Caption = 'Next Billing Date';
        }
        field(15; "Calculation Base Amount"; Decimal)
        {
            Caption = 'Calculation Base Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(16; "Calculation Base %"; Decimal)
        {
            Caption = 'Calculation Base %';
            MinValue = 0;
            MaxValue = 100;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(17; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            MinValue = 0;
            MaxValue = 100;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(18; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(19; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(20; "Billing Base Period"; DateFormula)
        {
            Caption = 'Billing Base Period';
        }
        field(21; "Invoicing via"; Enum "Invoicing Via")
        {
            Caption = 'Invoicing via';
        }
        field(22; "Invoicing Item No."; Code[20])
        {
            Caption = 'Invoicing Item No.';
            TableRelation = Item."No." where("Service Commitment Option" = const("Invoicing Item"));
        }
        field(23; "Notice Period"; DateFormula)
        {
            Caption = 'Notice Period';
        }
        field(24; "Initial Term"; DateFormula)
        {
            Caption = 'Initial Term';
        }
        field(25; "Extension Term"; DateFormula)
        {
            Caption = 'Subsequent Term';
        }
        field(26; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
        }
        field(27; "Discount Amount (LCY)"; Decimal)
        {
            Caption = 'Discount Amount (LCY)';
            Editable = false;
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(28; "Service Amount (LCY)"; Decimal)
        {
            Caption = 'Service Amount (LCY)';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(29; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                Rec.SetCurrencyData();
            end;
        }
        field(30; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            MinValue = 0;
        }
        field(31; "Currency Factor Date"; Date)
        {
            Caption = 'Currency Factor Date';
        }
        field(32; "Calculation Base Amount (LCY)"; Decimal)
        {
            Caption = 'Calculation Base Amount (LCY)';
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(37; "Quantity Decimal"; Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object"."Quantity Decimal" where("No." = field("Service Object No.")));
        }
        field(39; "Next Price Update"; Date)
        {
            Caption = 'Next Price Update';
        }
        field(40; "Exclude from Price Update"; Boolean)
        {
            Caption = 'Exclude from Price Update';
        }
        field(100; "Service Commitment created"; Boolean)
        {
            Caption = 'Service Commitment created';
            Editable = false;
        }
        field(101; "Error Text"; Text[250])
        {
            Caption = 'Error Text';
            Editable = false;
        }
        field(102; "Processed by"; Code[50])
        {
            Caption = 'Processed by';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            Editable = false;
            ValidateTableRelation = false;
        }
        field(103; "Processed at"; DateTime)
        {
            Caption = 'Processed at';
            Editable = false;
        }
        field(104; "Contract Line created"; Boolean)
        {
            Caption = 'Contract Line created';
            Editable = false;
        }
        field(8000; "Usage Based Billing"; Boolean)
        {
            Caption = 'Usage Based Billing';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8001; "Usage Based Pricing"; Enum "Usage Based Pricing")
        {
            Caption = 'Usage Based Pricing';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8002; "Pricing Unit Cost Surcharge %"; Decimal)
        {
            Caption = 'Pricing Unit Cost Surcharge %';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8003; "Supplier Reference Entry No."; Integer)
        {
            Caption = 'Supplier Reference Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Usage Data Supplier Reference" where(Type = const(Subscription));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure IsContractCommentLine(): Boolean
    begin
        exit(Rec."Contract Line Type" = Rec."Contract Line Type"::Comment)
    end;

    internal procedure ClearErrorTextAndSetProcessedFields()
    begin
        Rec."Error Text" := '';
        Rec."Processed at" := CurrentDateTime();
        Rec."Processed by" := CopyStr(UserId(), 1, MaxStrLen(Rec."Processed by"));
    end;

    internal procedure SetCurrencyData()
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if Rec."Currency Code" = '' then begin
            "Currency Factor" := 0;
            "Currency Factor Date" := 0D;
        end
        else begin
            Currency.Get("Currency Code");
            if "Currency Factor Date" = 0D then
                "Currency Factor Date" := WorkDate();
            if (Rec."Currency Factor Date" <> xRec."Currency Factor Date") or (Rec."Currency Code" <> xRec."Currency Code") then
                "Currency Factor" := CurrExchRate.ExchangeRate("Currency Factor Date", "Currency Code");
        end
    end;
}