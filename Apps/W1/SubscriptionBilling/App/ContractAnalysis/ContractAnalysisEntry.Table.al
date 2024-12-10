table 8019 "Contract Analysis Entry"
{
    Caption = 'Contract Analysis Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "Contract Analysis Entries";
    LookupPageId = "Contract Analysis Entries";
    Access = Internal;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
        }
        field(3; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            NotBlank = true;
            TableRelation = "Service Commitment Package";
            Editable = false;
        }
        field(4; Template; Code[20])
        {
            Caption = 'Template';
            NotBlank = true;
            TableRelation = "Service Commitment Template";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; "Service Start Date"; Date)
        {
            Caption = 'Service Start Date';
        }
        field(7; "Service End Date"; Date)
        {
            Caption = 'Service End Date';
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
        field(14; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
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
            TableRelation = Item."No." where("Service Commitment Option" = filter("Invoicing Item" | "Service Commitment Item"));
        }
        field(18; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(19; "Contract No."; Code[20])
        {
            Caption = 'Contract';
            TableRelation = if (Partner = const(Customer)) "Customer Contract" where("Sell-to Customer No." = field("Partner No.")) else
            if (Partner = const(Vendor)) "Vendor Contract";
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
        field(27; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract Line"."Line No." where("Contract No." = field("Contract No.")) else
            if (Partner = const(Vendor)) "Vendor Contract Line"."Line No." where("Contract No." = field("Contract No."));
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
            Caption = 'Service Amount (LCY)';
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
        field(39; "Quantity Decimal"; Decimal)
        {
            Caption = 'Quantity';
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
        field(1005; "Service Commitment Entry No."; Integer)
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
        field(8009; "Service Object Item No."; Code[20])
        {
            Caption = 'Service Object Item No.';
        }
        field(8010; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure InitFromServiceCommitment(ServiceCommitment: Record "Service Commitment")
    begin
        ServiceCommitment.CalcFields("Service Object Description", "Item No.", "Quantity Decimal");
        Rec.Init();
        Rec."Service Object No." := ServiceCommitment."Service Object No.";
        Rec."Service Object Description" := ServiceCommitment."Service Object Description";
        Rec."Service Object Item No." := ServiceCommitment."Item No.";
        Rec."Service Commitment Entry No." := ServiceCommitment."Entry No.";
        Rec.Description := ServiceCommitment.Description;
        Rec."Contract No." := ServiceCommitment."Contract No.";
        Rec."Contract Line No." := ServiceCommitment."Contract Line No.";
        Rec."Service Start Date" := ServiceCommitment."Service Start Date";
        Rec."Service End Date" := ServiceCommitment."Service End Date";
        Rec."Quantity Decimal" := ServiceCommitment."Quantity Decimal";
        Rec.Price := ServiceCommitment.Price;
        Rec."Price (LCY)" := ServiceCommitment."Price (LCY)";
        Rec."Service Amount" := ServiceCommitment."Service Amount";
        Rec."Service Amount (LCY)" := ServiceCommitment."Service Amount (LCY)";
        Rec.Discount := ServiceCommitment.Discount;
        Rec."Discount %" := ServiceCommitment."Discount %";
        Rec."Discount Amount" := ServiceCommitment."Discount Amount";
        Rec."Discount Amount (LCY)" := ServiceCommitment."Discount Amount (LCY)";
        Rec."Calculation Base %" := ServiceCommitment."Calculation Base %";
        Rec."Calculation Base Amount" := ServiceCommitment."Calculation Base Amount";
        Rec."Calculation Base Amount (LCY)" := ServiceCommitment."Calculation Base Amount (LCY)";
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
        Rec."Package Code" := ServiceCommitment."Package Code";
        Rec.Partner := ServiceCommitment.Partner;
        Rec."Partner No." := ServiceCommitment.GetPartnerNoFromContract();
        Rec."Dimension Set ID" := ServiceCommitment."Dimension Set ID";
        Rec."Usage Based Billing" := ServiceCommitment."Usage Based Billing";
    end;

    internal procedure CalculateMonthlyRecurringRevenue(ServiceCommitment: Record "Service Commitment")
    begin
        if not (Rec.Partner = Enum::"Service Partner"::Customer) then
            exit;

        Rec."Monthly Recurr. Revenue (LCY)" := CalculateMonthlyPrice(ServiceCommitment."Service Amount (LCY)", ServiceCommitment."Billing Base Period");
        if Rec.Discount then
            Rec."Monthly Recurr. Revenue (LCY)" := Rec."Monthly Recurr. Revenue (LCY)" * -1;
    end;

    internal procedure CalculateMonthlyRecurringCost(ServiceCommitment: Record "Service Commitment")
    var
        VendorServiceCommitment: Record "Service Commitment";
        CalculatedMonthlyPrice: Decimal;
    begin
        case ServiceCommitment.Partner of
            Enum::"Service Partner"::Customer:
                if FindRelatedVendorServiceCommitment(VendorServiceCommitment, ServiceCommitment) then begin
                    repeat
                        CalculatedMonthlyPrice += CalculateMonthlyPrice(ServiceCommitment."Service Amount (LCY)", ServiceCommitment."Billing Base Period");
                        if VendorServiceCommitment.Discount then
                            CalculatedMonthlyPrice := CalculatedMonthlyPrice - 1;
                    until VendorServiceCommitment.Next() = 0;
                    Rec."Monthly Recurring Cost (LCY)" := CalculatedMonthlyPrice;
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    Rec."Monthly Recurring Cost (LCY)" := CalculateMonthlyPrice(ServiceCommitment."Service Amount (LCY)", ServiceCommitment."Billing Base Period");
                    if ServiceCommitment.Discount then
                        Rec."Monthly Recurring Cost (LCY)" := Rec."Monthly Recurring Cost (LCY)" * -1;
                end;
        end;
    end;

    local procedure FindRelatedVendorServiceCommitment(var VendorServiceCommitment: Record "Service Commitment"; CustomerServiceCommitment: Record "Service Commitment"): Boolean
    begin
        VendorServiceCommitment.SetRange(Partner, "Service Partner"::Vendor);
        VendorServiceCommitment.SetRange("Package Code", CustomerServiceCommitment."Package Code");
        VendorServiceCommitment.SetRange("Service Object No.", CustomerServiceCommitment."Service Object No.");
        VendorServiceCommitment.SetRange("Invoicing via", "Invoicing Via"::Contract);
        VendorServiceCommitment.SetFilter("Contract No.", '<>%1', '');
        VendorServiceCommitment.SetFilter("Service End Date", '%1|>=%2', 0D, Today());
        exit(VendorServiceCommitment.FindFirst());
    end;

    local procedure CalculateMonthlyPrice(ServiceAmountLCY: Decimal; BillingBasePeriod: DateFormula): Decimal
    var
        EssDateTimeMgt: Codeunit "Date Time Management";
        DateFormulaManagement: Codeunit "Date Formula Management";
        PeriodLetter: Char;
        PeriodCount: Integer;
    begin
        DateFormulaManagement.FindDateFormulaType(BillingBasePeriod, PeriodCount, PeriodLetter);
        if PeriodLetter in ['D', 'W'] then
            exit(EssDateTimeMgt.CalculateProRatedAmount(ServiceAmountLCY, CalcDate('<-CM>', Rec."Analysis Date"), 0T, CalcDate('<CM>', Rec."Analysis Date"), 0T, BillingBasePeriod))
        else
            case PeriodLetter of
                'M':
                    exit(ServiceAmountLCY / PeriodCount);
                'Y':
                    exit(ServiceAmountLCY / (PeriodCount * 12));
                'Q':
                    exit(ServiceAmountLCY / (PeriodCount * 3));
            end;
    end;
}
