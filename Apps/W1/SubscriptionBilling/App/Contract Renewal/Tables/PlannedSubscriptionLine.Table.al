namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Pricing;
using Microsoft.Sales.Document;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;

table 8002 "Planned Subscription Line"
{
    DataClassification = CustomerContent;
    Caption = 'Planned Subscription Line';
    LookupPageId = "Planned Service Commitments";
    DrillDownPageId = "Planned Service Commitments";

    fields
    {
        field(1; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(3; "Subscription Package Code"; Code[20])
        {
            Caption = 'Subscription Package Code';
            NotBlank = true;
            TableRelation = "Subscription Package";
            Editable = false;
        }
        field(4; Template; Code[20])
        {
            Caption = 'Template';
            NotBlank = true;
            TableRelation = "Sub. Package Line Template";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; "Subscription Line Start Date"; Date)
        {
            Caption = 'Subscription Line Start Date';

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateEmpty("Subscription Line Start Date", FieldCaption("Subscription Line Start Date"));
                CheckServiceDates();
            end;
        }
        field(7; "Subscription Line End Date"; Date)
        {
            Caption = 'Subscription Line End Date';

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateEmpty("Subscription Line Start Date", FieldCaption("Subscription Line Start Date"));
                CheckServiceDates();
            end;
        }
        field(8; "Next Billing Date"; Date)
        {
            Caption = 'Next Billing Date';
            Editable = false;
        }
        field(9; "Calculation Base Amount"; Decimal)
        {
            Caption = 'Calculation Base Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 2;

            trigger OnValidate()
            begin
                if "Currency Code" <> '' then begin
                    Currency.InitRoundingPrecision();
                    "Calculation Base Amount (LCY)" :=
                            Round(CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", "Calculation Base Amount" * "Calculation Base %" / 100, "Currency Factor"),
                            Currency."Unit-Amount Rounding Precision");
                end else
                    "Calculation Base Amount (LCY)" := "Calculation Base Amount";

                CalculatePrice();
            end;
        }
        field(10; "Calculation Base %"; Decimal)
        {
            Caption = 'Calculation Base %';
            MinValue = 0;
            BlankZero = true;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CalculatePrice();
            end;
        }
        field(11; "Price"; Decimal)
        {
            Caption = 'Price';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;

            trigger OnValidate()
            begin
                if "Currency Code" = '' then
                    "Price (LCY)" := Price;
            end;
        }
        field(12; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            MinValue = 0;
            MaxValue = 100;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(13; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(14; Amount; Decimal)
        {
            Caption = 'Amount';
            BlankZero = true;
            AutoFormatType = 1;

        }
        field(15; "Billing Base Period"; DateFormula)
        {
            Caption = 'Billing Base Period';

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaEmpty("Billing Base Period", FieldCaption("Billing Base Period"));
                DateFormulaManagement.ErrorIfDateFormulaNegative("Billing Base Period");
            end;
        }
        field(16; "Invoicing via"; Enum "Invoicing Via")
        {
            Caption = 'Invoicing via';
        }
        field(17; "Invoicing Item No."; Code[20])
        {
            Caption = 'Invoicing Item No.';
            TableRelation = Item."No." where("Subscription Option" = const("Invoicing Item"));
        }
        field(18; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(19; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            TableRelation = if (Partner = const(Customer)) "Customer Subscription Contract" where("Sell-to Customer No." = field("Subscription Customer No.")) else
            if (Partner = const(Vendor)) "Vendor Subscription Contract";
        }
        field(20; "Notice Period"; DateFormula)
        {
            Caption = 'Notice Period';

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaNegative("Notice Period");
            end;
        }
        field(21; "Initial Term"; DateFormula)
        {
            Caption = 'Initial Term';

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaNegative("Initial Term");
            end;
        }
        field(22; "Extension Term"; DateFormula)
        {
            Caption = 'Subsequent Term';

            trigger OnValidate()
            begin
                if Format("Extension Term") = '' then
                    TestField("Notice Period", "Extension Term");
                DateFormulaManagement.ErrorIfDateFormulaNegative("Extension Term");
            end;
        }
        field(23; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaEmpty("Billing Rhythm", FieldCaption("Billing Rhythm"));
                DateFormulaManagement.ErrorIfDateFormulaNegative("Billing Rhythm");
            end;
        }
        field(24; "Cancellation Possible Until"; Date)
        {
            Caption = 'Cancellation Possible Until';
        }
        field(25; "Term Until"; Date)
        {
            Caption = 'Term Until';

        }
        field(26; "Subscription Customer No."; Code[20])
        {
            Caption = 'Subscription Customer No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header"."End-User Customer No." where("No." = field("Subscription Header No.")));
        }
        field(27; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No.")) else
            if (Partner = const(Vendor)) "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
        }
        field(42; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(31; "Price (LCY)"; Decimal)
        {
            Caption = 'Price (LCY)';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(32; "Discount Amount (LCY)"; Decimal)
        {
            Caption = 'Discount Amount (LCY)';
            Editable = false;
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(33; "Service Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(34; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(35; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(36; "Currency Factor Date"; Date)
        {
            Caption = 'Currency Factor Date';
            Editable = false;
        }
        field(37; "Calculation Base Amount (LCY)"; Decimal)
        {
            Caption = 'Calculation Base Amount (LCY)';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(50; "Next Price Update"; Date)
        {
            Caption = 'Next Price Update';
        }
        field(53; "Type Of Update"; Enum "Type Of Price Update")
        {
            Caption = 'Type Of Update';
        }
        field(54; "Perform Update On"; Date)
        {
            Caption = 'Perform Update On';
        }
        field(55; "Price Binding Period"; DateFormula)
        {
            Caption = 'Price Binding Period';
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(101; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';

            trigger OnValidate()
            var
                Currency: Record Currency;
            begin
                if Rec."Currency Code" <> '' then begin
                    Currency.Initialize("Currency Code");
                    Currency.TestField("Unit-Amount Rounding Precision");
                    "Unit Cost" :=
                      Round(
                        CurrExchRate.ExchangeAmtLCYToFCY(
                          "Currency Factor Date", Rec."Currency Code",
                          "Unit Cost (LCY)", Rec."Currency Factor"),
                        Currency."Unit-Amount Rounding Precision")
                end else
                    "Unit Cost" := "Unit Cost (LCY)";
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(1000; "Sales Quote No."; Code[20])
        {
            Caption = 'Sales Quote No.';
            Editable = false;
            TableRelation = "Sales Header"."No." where("No." = field("Sales Quote No."));
        }
        field(1001; "Sales Quote Line No."; Integer)
        {
            Caption = 'Sales Quote Line No.';
            Editable = false;
        }
        field(1002; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            Editable = false;
            TableRelation = "Sales Header"."No." where("Document Type" = filter(Order), "No." = field("Sales Order No."));
        }
        field(1003; "Sales Order Line No."; Integer)
        {
            Caption = 'Sales Order Line No.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Contract; "Subscription Contract No.", "Subscription Contract Line No.") { }
        key(Quote; "Sales Quote No.", "Sales Quote Line No.") { }
    }
    trigger OnModify()
    begin
        xRec.Get(xRec."Entry No.");
        if ((xRec."Billing Base Period" <> Rec."Billing Base Period") or (xRec."Billing Rhythm" <> Rec."Billing Rhythm")) then
            DateFormulaManagement.CheckIntegerRatioForDateFormulas("Billing Base Period", FieldCaption("Billing Base Period"), "Billing Rhythm", FieldCaption("Billing Rhythm"));
    end;

    local procedure CheckServiceDates()
    begin
        if ("Subscription Line Start Date" <> 0D) and ("Subscription Line End Date" <> 0D) then
            if "Subscription Line Start Date" > "Subscription Line End Date" then
                Error(DateBeforeDateErr, FieldCaption("Subscription Line End Date"), FieldCaption("Subscription Line Start Date"));
        if "Next Billing Date" <> 0D then begin
            if ("Subscription Line Start Date" <> 0D) and ("Next Billing Date" < "Subscription Line Start Date") then
                Error(DateBeforeDateErr, FieldCaption("Next Billing Date"), FieldCaption("Subscription Line Start Date"));
            if ("Subscription Line End Date" <> 0D) and ("Next Billing Date" > "Subscription Line End Date") then
                Error(DateAfterDateErr, FieldCaption("Next Billing Date"), FieldCaption("Subscription Line End Date"));
        end;
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if OldDimSetID <> "Dimension Set ID" then
            Modify();
    end;

    local procedure CalculatePrice()
    begin
        if "Calculation Base Amount" <> 0 then begin
            Currency.InitRoundingPrecision();
            Validate(Price, Round("Calculation Base Amount" * "Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision"));
        end else
            Validate(Price, 0);
    end;

    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        DateFormulaManagement: Codeunit "Date Formula Management";
        DateBeforeDateErr: Label '%1 cannot be before %2.';
        DateAfterDateErr: Label '%1 cannot be after %2.';
}