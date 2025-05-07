namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Finance.Currency;
using System.Security.User;

table 8009 "Imported Subscription Line"
{
    DataClassification = CustomerContent;
    Caption = 'Imported Subscription Line';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            NotBlank = true;
        }
        field(2; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
            ValidateTableRelation = false;
        }
        field(3; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Subscription Line Entry No.';
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
            ValidateTableRelation = false;
        }
        field(6; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No.")) else
            if (Partner = const(Vendor)) "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
            ValidateTableRelation = false;
        }
        field(7; "Sub. Contract Line Type"; Enum "Contract Line Type")
        {
            Caption = 'Subscription Contract Line Type';
        }
        field(8; "Subscription Package Code"; Code[20])
        {
            Caption = 'Subscription Package Code';
            NotBlank = true;
            TableRelation = "Subscription Package";
        }
        field(9; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "Sub. Package Line Template";
            ValidateTableRelation = false;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Subscription Line Start Date"; Date)
        {
            Caption = 'Subscription Line Start Date';
        }
        field(12; "Subscription Line End Date"; Date)
        {
            Caption = 'Subscription Line End Date';
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
        field(19; Amount; Decimal)
        {
            Caption = 'Amount';
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
            trigger OnValidate()
            begin
                if "Invoicing via" = "Invoicing via"::Sales then begin
                    "Invoicing Item No." := '';
                    "Create Contract Deferrals" := "Create Contract Deferrals"::No;
                end else
                    "Create Contract Deferrals" := "Create Contract Deferrals"::"Contract-dependent";
            end;
        }
        field(22; "Invoicing Item No."; Code[20])
        {
            Caption = 'Invoicing Item No.';
            TableRelation = Item."No." where("Subscription Option" = const("Invoicing Item"));
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
        field(28; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
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
                Rec.InitCurrencyData();
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
        field(37; Quantity; Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header".Quantity where("No." = field("Subscription Header No.")));
        }
        field(39; "Next Price Update"; Date)
        {
            Caption = 'Next Price Update';
        }
        field(40; "Exclude from Price Update"; Boolean)
        {
            Caption = 'Exclude from Price Update';
        }
        field(41; "Create Contract Deferrals"; Enum "Create Contract Deferrals")
        {
            Caption = 'Create Contract Deferrals';
        }
        field(100; "Subscription Line created"; Boolean)
        {
            Caption = 'Subscription Line created';
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
            TableRelation = "User Setup";
            Editable = false;
            ValidateTableRelation = false;
        }
        field(103; "Processed at"; DateTime)
        {
            Caption = 'Processed at';
            Editable = false;
        }
        field(104; "Sub. Contract Line created"; Boolean)
        {
            Caption = 'Subscription Contract Line created';
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
        exit(Rec."Sub. Contract Line Type" = Rec."Sub. Contract Line Type"::Comment)
    end;

    internal procedure ClearErrorTextAndSetProcessedFields()
    begin
        Rec."Error Text" := '';
        Rec."Processed at" := CurrentDateTime();
        Rec."Processed by" := CopyStr(UserId(), 1, MaxStrLen(Rec."Processed by"));
    end;

    internal procedure InitCurrencyData()
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