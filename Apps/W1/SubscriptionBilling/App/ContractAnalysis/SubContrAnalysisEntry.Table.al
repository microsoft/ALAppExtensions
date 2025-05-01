#pragma warning disable AA0247
table 8019 "Sub. Contr. Analysis Entry"
{
    Caption = 'Subscription Contract Analysis Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "Contract Analysis Entries";
    LookupPageId = "Contract Analysis Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
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
        }
        field(7; "Subscription Line End Date"; Date)
        {
            Caption = 'Subscription Line End Date';
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
        }
        field(10; "Calculation Base %"; Decimal)
        {
            Caption = 'Calculation Base %';
            MinValue = 0;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(11; "Price"; Decimal)
        {
            Caption = 'Price';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;
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
        }
        field(17; "Invoicing Item No."; Code[20])
        {
            Caption = 'Invoicing Item No.';
            TableRelation = Item."No." where("Subscription Option" = filter("Invoicing Item" | "Service Commitment Item"));
        }
        field(18; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(19; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            TableRelation = if (Partner = const(Customer)) "Customer Subscription Contract" where("Sell-to Customer No." = field("Partner No.")) else
            if (Partner = const(Vendor)) "Vendor Subscription Contract";
        }
        field(20; "Notice Period"; DateFormula)
        {
            Caption = 'Notice Period';
        }
        field(21; "Initial Term"; DateFormula)
        {
            Caption = 'Initial Term';
        }
        field(22; "Extension Term"; DateFormula)
        {
            Caption = 'Subsequent Term';
        }
        field(23; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
        }
        field(24; "Cancellation Possible Until"; Date)
        {
            Caption = 'Cancellation Possible Until';
        }
        field(25; "Term Until"; Date)
        {
            Caption = 'Term Until';
        }
        field(27; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No.")) else
            if (Partner = const(Vendor)) "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
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
        field(33; "Amount (LCY)"; Decimal)
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
        field(38; Discount; Boolean)
        {
            Caption = 'Discount';
            Editable = false;
        }
        field(39; Quantity; Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
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
            Editable = false;
        }
        field(202; "Renewal Term"; DateFormula)
        {
            Caption = 'Renewal Term';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(1000; "Analysis Date"; Date)
        {
            Caption = 'Analysis Date';

        }
        field(1001; "Monthly Recurr. Revenue (LCY)"; Decimal)
        {
            Caption = 'Monthly Recurring Revenue (LCY)';

        }
        field(1002; "Monthly Recurring Cost (LCY)"; Decimal)
        {
            Caption = 'Monthly Recurring Cost (LCY)';

        }
        field(1005; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(1006; "Partner No."; Code[20])
        {
            Caption = 'Partner No.';
            TableRelation = if (Partner = const(Customer)) Customer else
            if (Partner = const(Vendor)) Vendor;
        }
        field(8000; "Usage Based Billing"; Boolean)
        {
            Caption = 'Usage Based Billing';
        }
        field(8007; "Sub. Header Source Type"; Enum "Service Object Type")
        {
            Caption = 'Subscription Source Type';
        }
        field(8008; "Sub. Header Source No."; Code[20])
        {
            Caption = 'Subscription Source No.';
        }
        field(8009; "Service Object Item No."; Code[20])
        {
            Caption = 'Subscription Item No.';
            ObsoleteReason = 'Replaced by field Subscription Source No.';
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(8010; "Subscription Description"; Text[100])
        {
            Caption = 'Subscription Description';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure InitFromServiceCommitment(ServiceCommitment: Record "Subscription Line")
    begin
        ServiceCommitment.CalcFields("Subscription Description", "Source Type", "Source No.", Quantity);
        Rec.Init();
        Rec."Subscription Header No." := ServiceCommitment."Subscription Header No.";
        Rec."Subscription Description" := ServiceCommitment."Subscription Description";
        Rec."Sub. Header Source Type" := ServiceCommitment."Source Type";
        Rec."Sub. Header Source No." := ServiceCommitment."Source No.";
        Rec."Subscription Line Entry No." := ServiceCommitment."Entry No.";
        Rec.Description := ServiceCommitment.Description;
        Rec."Subscription Contract No." := ServiceCommitment."Subscription Contract No.";
        Rec."Subscription Contract Line No." := ServiceCommitment."Subscription Contract Line No.";
        Rec."Subscription Line Start Date" := ServiceCommitment."Subscription Line Start Date";
        Rec."Subscription Line End Date" := ServiceCommitment."Subscription Line End Date";
        Rec.Quantity := ServiceCommitment.Quantity;
        Rec.Price := ServiceCommitment.Price;
        Rec."Price (LCY)" := ServiceCommitment."Price (LCY)";
        Rec.Amount := ServiceCommitment.Amount;
        Rec."Amount (LCY)" := ServiceCommitment."Amount (LCY)";
        Rec.Discount := ServiceCommitment.Discount;
        Rec."Discount %" := ServiceCommitment."Discount %";
        Rec."Discount Amount" := ServiceCommitment."Discount Amount";
        Rec."Discount Amount (LCY)" := ServiceCommitment."Discount Amount (LCY)";
        Rec."Calculation Base %" := ServiceCommitment."Calculation Base %";
        Rec."Calculation Base Amount" := ServiceCommitment."Calculation Base Amount";
        Rec."Calculation Base Amount (LCY)" := ServiceCommitment."Calculation Base Amount (LCY)";
        Rec."Unit Cost" := ServiceCommitment."Unit Cost";
        Rec."Unit Cost (LCY)" := ServiceCommitment."Unit Cost (LCY)";
        Rec."Term Until" := ServiceCommitment."Term Until";
        Rec."Billing Base Period" := ServiceCommitment."Billing Base Period";
        Rec."Billing Rhythm" := ServiceCommitment."Billing Rhythm";
        Rec."Cancellation Possible Until" := ServiceCommitment."Cancellation Possible Until";
        Rec."Currency Code" := ServiceCommitment."Currency Code";
        Rec."Currency Factor" := ServiceCommitment."Currency Factor";
        Rec."Currency Factor Date" := ServiceCommitment."Currency Factor Date";
        Rec."Extension Term" := ServiceCommitment."Extension Term";
        Rec."Initial Term" := ServiceCommitment."Initial Term";
        Rec."Invoicing Item No." := ServiceCommitment."Invoicing Item No.";
        Rec."Next Billing Date" := ServiceCommitment."Next Billing Date";
        Rec."Notice Period" := ServiceCommitment."Notice Period";
        Rec.Template := ServiceCommitment.Template;
        Rec."Subscription Package Code" := ServiceCommitment."Subscription Package Code";
        Rec.Partner := ServiceCommitment.Partner;
        Rec."Partner No." := ServiceCommitment.GetPartnerNoFromContract();
        Rec."Dimension Set ID" := ServiceCommitment."Dimension Set ID";
        Rec."Usage Based Billing" := ServiceCommitment."Usage Based Billing";
        OnAfterInitFromServiceCommitment(Rec, ServiceCommitment);
    end;

    internal procedure CalculateMonthlyRecurringRevenue(ServiceCommitment: Record "Subscription Line")
    begin
        if not (Rec.Partner = Enum::"Service Partner"::Customer) then
            exit;

        Rec."Monthly Recurr. Revenue (LCY)" := CalculateMonthlyPrice(ServiceCommitment."Amount (LCY)", ServiceCommitment."Billing Base Period");
        if Rec.Discount then
            Rec."Monthly Recurr. Revenue (LCY)" := Rec."Monthly Recurr. Revenue (LCY)" * -1;
    end;

    internal procedure CalculateMonthlyRecurringCost(ServiceCommitment: Record "Subscription Line")
    var
        CalculatedMonthlyAmount: Decimal;
    begin
        case ServiceCommitment.Partner of
            Enum::"Service Partner"::Customer:
                begin
                    ServiceCommitment.CalcFields(Quantity);
                    CalculatedMonthlyAmount := CalculateMonthlyPrice(ServiceCommitment."Unit Cost (LCY)" * ServiceCommitment.Quantity, ServiceCommitment."Billing Base Period");
                    if ServiceCommitment.Discount then
                        CalculatedMonthlyAmount *= -1;
                    Rec."Monthly Recurring Cost (LCY)" := CalculatedMonthlyAmount;
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    Rec."Monthly Recurring Cost (LCY)" := CalculateMonthlyPrice(ServiceCommitment."Amount (LCY)", ServiceCommitment."Billing Base Period");
                    if ServiceCommitment.Discount then
                        Rec."Monthly Recurring Cost (LCY)" := Rec."Monthly Recurring Cost (LCY)" * -1;
                end;
        end;
    end;

    local procedure CalculateMonthlyPrice(ServiceAmountLCY: Decimal; BillingBasePeriod: DateFormula): Decimal
    var
        ServiceCommitment: Record "Subscription Line";
        DateFormulaManagement: Codeunit "Date Formula Management";
        PeriodLetter: Char;
        PeriodCount: Integer;
    begin
        DateFormulaManagement.FindDateFormulaType(BillingBasePeriod, PeriodCount, PeriodLetter);
        if PeriodLetter in ['D', 'W'] then begin
            ServiceCommitment."Billing Base Period" := BillingBasePeriod;
            ServiceCommitment."Billing Rhythm" := BillingBasePeriod;
            ServiceCommitment.Price := ServiceAmountLCY;
            exit(ServiceCommitment.UnitPriceForPeriod(CalcDate('<-CM>', Rec."Analysis Date"), CalcDate('<CM>', Rec."Analysis Date")));
        end else
            case PeriodLetter of
                'M':
                    exit(ServiceAmountLCY / PeriodCount);
                'Y':
                    exit(ServiceAmountLCY / (PeriodCount * 12));
                'Q':
                    exit(ServiceAmountLCY / (PeriodCount * 3));
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromServiceCommitment(var ContractAnalysisEntry: Record "Sub. Contr. Analysis Entry"; ServiceCommitment: Record "Subscription Line")
    begin
    end;
}
