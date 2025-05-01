namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Foundation.Calendar;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;

table 8059 "Subscription Line"
{
    DataClassification = CustomerContent;
    Caption = 'Subscription Line';
    DrillDownPageId = "Service Commitments List";
    LookupPageId = "Service Commitments List";

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
            AutoIncrement = true;
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
                UpdateNextBillingDate("Subscription Line Start Date" - 1);
                CheckServiceDates();
                RecalculateHarmonizedBillingFieldsOnCustomerContract();
                UpdateNextPriceUpdate();
            end;
        }
        field(7; "Subscription Line End Date"; Date)
        {
            Caption = 'Subscription Line End Date';

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateEmpty("Subscription Line Start Date", FieldCaption("Subscription Line Start Date"));
                ErrorIfPlannedServiceCommitmentExists();
                CheckServiceDates();
                ClearTerminationPeriodsWhenServiceEnded();
                RefreshRenewalTerm();
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
                if not "Usage Based Billing" then begin
                    Currency.Initialize("Currency Code");
                    "Price" := Round("Price", Currency."Unit-Amount Rounding Precision");
                end;
                Validate("Discount %");
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

            trigger OnValidate()
            begin
                if "Discount %" <> 0 then
                    TestField(Discount, false);
                CalculateServiceAmount(FieldNo("Discount %"));
            end;
        }
        field(13; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 1;

            trigger OnValidate()
            begin
                if "Discount Amount" <> 0 then
                    TestField(Discount, false);
                CalculateServiceAmount(FieldNo("Discount Amount"));
            end;
        }
        field(14; Amount; Decimal)
        {
            Caption = 'Amount';
            BlankZero = true;
            AutoFormatType = 1;

            trigger OnValidate()
            begin
                CalculateServiceAmount(FieldNo(Amount));
            end;
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
            trigger OnValidate()
            begin
                if "Invoicing via" = "Invoicing via"::Sales then
                    "Create Contract Deferrals" := "Create Contract Deferrals"::No
                else
                    "Create Contract Deferrals" := "Create Contract Deferrals"::"Contract-dependent";

            end;
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
            TableRelation = if (Partner = const(Customer)) "Customer Subscription Contract" where("Sell-to Customer No." = field("Sub. Header Customer No.")) else
            if (Partner = const(Vendor)) "Vendor Subscription Contract";
        }
        field(20; "Notice Period"; DateFormula)
        {
            Caption = 'Notice Period';

            trigger OnValidate()
            begin
                if IsNoticePeriodEmpty() then
                    exit;

                DateFormulaManagement.ErrorIfDateFormulaNegative("Notice Period");

                if "Term until" <> 0D then
                    UpdateCancellationPossibleUntil();
            end;
        }
        field(21; "Initial Term"; DateFormula)
        {
            Caption = 'Initial Term';

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateFormulaNegative("Initial Term");
                RefreshRenewalTerm();
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

            trigger OnValidate()
            begin
                UpdateTermUntilUsingNoticePeriod();
            end;
        }
        field(25; "Term Until"; Date)
        {
            Caption = 'Term Until';

            trigger OnValidate()
            begin
                UpdateCancellationPossibleUntil();
            end;
        }
        field(26; "Sub. Header Customer No."; Code[20])
        {
            Caption = 'Subscription Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header"."End-User Customer No." where("No." = field("Subscription Header No.")));
            Editable = false;
        }
        field(27; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No.")) else
            if (Partner = const(Vendor)) "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
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

            trigger OnValidate()
            begin
                if ((CurrFieldNo <> FieldNo("Currency Code")) and ("Currency Code" = xRec."Currency Code")) or
                    ("Currency Code" <> xRec."Currency Code") or
                    ("Currency Code" <> '')
                 then
                    UpdateCurrencyFactorAndRecalculateAmountsFromExchRate();
            end;
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
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header".Quantity where("No." = field("Subscription Header No.")));
        }
        field(40; "Create Contract Deferrals"; Enum "Create Contract Deferrals")
        {
            Caption = 'Create Contract Deferrals';

            trigger OnValidate()
            begin
                if OpenDeferralsExist() then
                    Error(DeferralsExistErr);
            end;
        }
        field(42; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(50; "Next Price Update"; Date)
        {
            Caption = 'Next Price Update';
        }
        field(51; "Exclude from Price Update"; Boolean)
        {
            Caption = 'Exclude from Price Update';
        }
        field(52; "Price Binding Period"; DateFormula)
        {
            Caption = 'Price Binding Period';
            trigger OnValidate()
            begin
                UpdateNextPriceUpdate();
            end;
        }
        field(59; "Period Calculation"; enum "Period Calculation")
        {
            Caption = 'Period Calculation';
        }
        field(107; "Closed"; Boolean)
        {
            Caption = 'Closed';
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
                NoManualEntryOfUnitCostLCYForVendorServCommError(CurrFieldNo);
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
        field(200; "Planned Sub. Line exists"; Boolean)
        {
            Caption = 'Planned Subscription Line exists';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Planned Subscription Line" where("Entry No." = field("Entry No.")));
        }
        field(202; "Renewal Term"; DateFormula)
        {
            Caption = 'Renewal Term';

            trigger OnValidate()
            var
                BlankDateFormula: DateFormula;
            begin
                if Rec."Renewal Term" <> BlankDateFormula then
                    Rec.TestField("Subscription Line End Date");
                DateFormulaManagement.ErrorIfDateFormulaNegative("Renewal Term");
            end;
        }
        field(210; Selected; Boolean)
        {
            Caption = 'Selected';
        }
        field(211; Indent; Integer)
        {
            Caption = 'Indent';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                EditDimensionSet();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
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
        field(8006; "Created in Contract line"; Boolean)
        {
            Caption = 'Created in Contract line';
            Editable = false;
        }
        field(8007; "Source Type"; Enum "Service Object Type")
        {
            Caption = 'Source Type';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header".Type where("No." = field("Subscription Header No.")));
        }
        field(8008; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header"."Source No." where("No." = field("Subscription Header No.")));
        }
        field(8009; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header"."Item No." where("No." = field("Subscription Header No.")));
            ObsoleteReason = 'Replaced by field Source No.';
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
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header".Description where("No." = field("Subscription Header No.")));
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Contract; "Subscription Contract No.", "Subscription Contract Line No.") { }
    }

    trigger OnInsert()
    begin
        if not SkipTestPackageCode then
            TestField("Subscription Package Code");
    end;

    trigger OnModify()
    begin
        xRec.Get(xRec."Entry No.");
        if ((xRec."Billing Base Period" <> Rec."Billing Base Period") or (xRec."Billing Rhythm" <> Rec."Billing Rhythm")) then
            DateFormulaManagement.CheckIntegerRatioForDateFormulas("Billing Base Period", FieldCaption("Billing Base Period"), "Billing Rhythm", FieldCaption("Billing Rhythm"));
        DisplayErrorIfContractLinesExist(ClosedContractLineExistErr, true);
        SetUpdateRequiredOnBillingLines();
        UpdateCustomerContractLineServiceCommitmentDescription();
        ArchiveServiceCommitment();
    end;

    trigger OnDelete()
    begin
        DisplayErrorIfContractLinesExist(OpenContractLinesExistErr, false);
        DeleteContractLine();
        SetUpdateRequiredOnBillingLines();
        DisconnectBillingLineArchive();
        DeleteContractPriceUpdateLines();
    end;

    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        CalendarManagement: Codeunit "Calendar Management";
        DateFormulaManagement: Codeunit "Date Formula Management";
        DimMgt: Codeunit DimensionManagement;
        DateTimeManagement: Codeunit "Date Time Management";
        NegativeDateFormula: DateFormula;
        SkipArchiving: Boolean;
        SkipTestPackageCode: Boolean;
        DateBeforeDateErr: Label '%1 cannot be before %2.';
        OnlyOneDayBeforeErr: Label 'The %1 is only allowed to be 1 day before the %2.', Comment = '%1 = Subscription Line End Date; %2 = Next Billing Date';
        CannotBeGreaterThanErr: Label '%1 cannot be greater than %2.';
        CannotBeLessThanErr: Label '%1 cannot be less than %2.';
        OpenContractLinesExistErr: Label 'The Subscription Line cannot be deleted because it is linked to a contract line which is not yet marked as "Closed".';
        ClosedContractLineExistErr: Label 'Subscription Lines for closed contract lines may not be edited. Remove the "Finished" indicator in the contract to be able to edit the Subscription Lines.';
        DifferentCurrenciesInSerCommitmentErr: Label 'The selected Subscription Lines must be converted into different currencies. Please select only Subscription Lines with the same currency.';
        ZeroExchangeRateErr: Label 'The price could not be updated because the exchange rate is 0.';
        BillingLineForServiceCommitmentExistErr: Label 'The contract line is in the current billing. Delete the billing line to be able to adjust the Subscription Line start date.';
        BillingLineArchiveForServiceCommitmentExistErr: Label 'The contract line has already been billed. The Subscription Line start date can no longer be changed.';
        NoManualEntryOfUnitCostLCYForVendorServCommErr: Label 'Please use the fields "Calculation Base Amount" and "Calculation Base %" in order to update the unit cost.';
        DeferralsExistErr: Label 'The creation of contract deferrals cannot be changed as there are still unreleased deferrals for this contract line.';

    internal procedure CheckServiceDates()
    begin
        CheckServiceDates(Rec."Subscription Line Start Date", Rec."Subscription Line End Date", Rec."Next Billing Date");
    end;

    internal procedure CheckServiceDates(ServiceStartDate: Date; ServiceEndDate: Date; NextBillingDate: Date)
    begin
        if (ServiceStartDate <> 0D) and (ServiceEndDate <> 0D) then
            if ServiceStartDate > ServiceEndDate then
                Error(DateBeforeDateErr, Rec.FieldCaption("Subscription Line End Date"), Rec.FieldCaption("Subscription Line Start Date"));
        if NextBillingDate <> 0D then begin
            if (ServiceStartDate <> 0D) and (NextBillingDate < ServiceStartDate) then
                Error(DateBeforeDateErr, Rec.FieldCaption("Next Billing Date"), Rec.FieldCaption("Subscription Line Start Date"));
            if (ServiceEndDate <> 0D) and (CalcDate('<-1D>', NextBillingDate) > ServiceEndDate) then
                Error(OnlyOneDayBeforeErr, Rec.FieldCaption("Subscription Line End Date"), Rec.FieldCaption("Next Billing Date"));
        end;
    end;

    local procedure DisplayErrorIfContractLinesExist(ErrorTxt: Text; CheckContractLineClosed: Boolean)
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        VendorContractLine: Record "Vend. Sub. Contract Line";
    begin
        case Partner of
            Partner::Customer:
                begin
                    CustomerContractLine.FilterOnServiceCommitment(Rec);
                    if CustomerContractLine.FindFirst() then
                        if ((CheckContractLineClosed and CustomerContractLine.Closed) or (not CustomerContractLine.Closed and not CheckContractLineClosed)) then
                            Error(ErrorTxt);
                end;
            Partner::Vendor:
                begin
                    VendorContractLine.FilterOnServiceCommitment(Rec);
                    if VendorContractLine.FindFirst() then
                        if ((CheckContractLineClosed and VendorContractLine.Closed) or (not VendorContractLine.Closed and not CheckContractLineClosed)) then
                            Error(ErrorTxt);
                end;
        end;
    end;

    internal procedure ClearTerminationPeriodsWhenServiceEnded()
    begin
        if ("Subscription Line End Date" <> 0D) and ("Subscription Line End Date" < WorkDate()) then begin
            Clear("Term Until");
            Clear("Cancellation Possible Until");
        end;
    end;

    internal procedure CalculateInitialServiceEndDate()
    begin
        if IsInitialTermEmpty() then
            exit;
        if not IsExtensionTermEmpty() then
            exit;

        TestField("Subscription Line Start Date");
        "Subscription Line End Date" := CalcDate("Initial Term", "Subscription Line Start Date");
        "Subscription Line End Date" := CalcDate('<-1D>', "Subscription Line End Date");
        RefreshRenewalTerm();
    end;

    internal procedure CalculateInitialCancellationPossibleUntilDate()
    begin
        if IsExtensionTermEmpty() then
            exit;
        if IsNoticePeriodEmpty() then
            exit;
        if IsInitialTermEmpty() then
            exit;

        TestField("Subscription Line Start Date");
        "Cancellation Possible Until" := CalcDate("Initial Term", "Subscription Line Start Date");
        CalendarManagement.ReverseDateFormula(NegativeDateFormula, "Notice Period");
        "Cancellation Possible Until" := CalcDate(NegativeDateFormula, "Cancellation Possible Until");
        "Cancellation Possible Until" := CalcDate('<-1D>', "Cancellation Possible Until");
    end;

    internal procedure CalculateInitialTermUntilDate()
    begin
        if "Subscription Line End Date" <> 0D then begin
            "Term Until" := "Subscription Line End Date";
            exit;
        end;

        if IsExtensionTermEmpty() then
            exit;
        if IsNoticePeriodEmpty() and IsInitialTermEmpty() then
            exit;

        TestField("Subscription Line Start Date");
        if IsInitialTermEmpty() then begin
            "Term Until" := CalcDate("Notice Period", "Subscription Line Start Date");
            "Term Until" := CalcDate('<-1D>', "Term Until");
            UpdateCancellationPossibleUntil();
        end else begin
            "Term Until" := CalcDate("Initial Term", "Subscription Line Start Date");
            "Term Until" := CalcDate('<-1D>', "Term Until");
        end;
    end;

    internal procedure GetReferenceDate(): Date
    begin
        case true of
            "Cancellation Possible Until" <> 0D:
                exit("Cancellation Possible Until");
            "Term Until" <> 0D:
                exit("Term Until");
            "Subscription Line Start Date" <> 0D:
                exit("Subscription Line Start Date");
        end;
    end;

    internal procedure UpdateTermUntilUsingExtensionTerm(): Boolean
    begin
        if (IsExtensionTermEmpty() or
            (("Term Until" = 0D) and ("Subscription Line Start Date" = 0D))) then
            exit(false);
        if "Term Until" <> 0D then begin
            if DateTimeManagement.IsLastDayOfMonth("Term until") then begin
                "Term Until" := CalcDate("Extension Term", "Term Until");
                DateTimeManagement.MoveDateToLastDayOfMonth("Term until");
            end else
                "Term Until" := CalcDate("Extension Term", "Term Until");
        end else begin
            "Term Until" := CalcDate("Extension Term", "Subscription Line Start Date");
            if DateTimeManagement.IsLastDayOfMonth("Subscription Line Start Date") then
                DateTimeManagement.MoveDateToLastDayOfMonth("Term until");
        end;
        exit(true);
    end;

    local procedure UpdateTermUntilUsingNoticePeriod()
    begin
        if IsNoticePeriodEmpty() then
            exit;
        if "Cancellation Possible Until" = 0D then
            exit;
        "Term Until" := CalcDate("Notice Period", "Cancellation Possible Until");

        if DateTimeManagement.IsLastDayOfMonth("Cancellation possible until") then
            DateTimeManagement.MoveDateToLastDayOfMonth("Term until");
    end;

    internal procedure UpdateCancellationPossibleUntil(): Boolean
    begin
        if IsNoticePeriodEmpty() then
            exit(false);
        if "Term Until" = 0D then
            exit;
        CalendarManagement.ReverseDateFormula(NegativeDateFormula, "Notice Period");
        "Cancellation Possible Until" := CalcDate(NegativeDateFormula, "Term Until");
        if DateTimeManagement.IsLastDayOfMonth("Term until") then
            DateTimeManagement.MoveDateToLastDayOfMonth("Cancellation possible until");

        exit(true);
    end;

    internal procedure CalculatePrice()
    begin
        if "Calculation Base Amount" <> 0 then
            Validate(Price, "Calculation Base Amount" * "Calculation Base %" / 100)
        else
            Validate(Price, 0);
        if Partner = Partner::Vendor then
            CalculateUnitCost();
    end;

    internal procedure CalculateServiceAmount(CalledByFieldNo: Integer)
    var
        ServiceObject: Record "Subscription Header";
        MaxServiceAmount: Decimal;
    begin
        ServiceObject.Get("Subscription Header No.");
        Currency.Initialize("Currency Code");
        MaxServiceAmount := Price * ServiceObject.Quantity;
        if not "Usage Based Billing" then
            MaxServiceAmount := Round(MaxServiceAmount, Currency."Amount Rounding Precision");
        if CalledByFieldNo = FieldNo(Amount) then begin
            if not "Usage Based Billing" then
                Amount := Round(Amount, Currency."Amount Rounding Precision");
            if Amount > MaxServiceAmount then
                Error(CannotBeGreaterThanErr, FieldCaption(Amount), Format(MaxServiceAmount));
            if Amount < 0 then
                Error(CannotBeLessThanErr, FieldCaption(Amount), 0);
            "Discount Amount" := Round(MaxServiceAmount - Amount, Currency."Amount Rounding Precision");
            if MaxServiceAmount <> 0 then
                "Discount %" := Round(100 - (Amount / MaxServiceAmount * 100), 0.00001);
        end else begin
            ServiceObject.TestField(Quantity);
            Amount := Price * ServiceObject.Quantity;
            if not "Usage Based Billing" then
                Amount := Round(Amount, Currency."Amount Rounding Precision");
            if CalledByFieldNo = FieldNo("Discount %") then begin
                "Discount Amount" := Amount * "Discount %" / 100;
                if not "Usage Based Billing" then
                    "Discount Amount" := Round("Discount Amount", Currency."Amount Rounding Precision");
            end;
            if CalledByFieldNo = FieldNo("Discount Amount") then
                "Discount %" := Round("Discount Amount" / Amount * 100, 0.00001);
            if ("Discount Amount" > MaxServiceAmount) and ("Discount Amount" <> 0) then
                Error(CannotBeGreaterThanErr, FieldCaption("Discount Amount"), Format(MaxServiceAmount));
            Amount := Amount - "Discount Amount";
            if Amount > MaxServiceAmount then
                Error(CannotBeGreaterThanErr, FieldCaption(Amount), Format(MaxServiceAmount));
        end;
        SetLCYFields(false);
        OnAfterCalculateServiceAmount(Rec, CalledByFieldNo);
    end;

    local procedure SetUpdateRequiredOnBillingLines()
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Subscription Header No.", "Subscription Header No.");
        BillingLine.SetRange("Subscription Line Entry No.", "Entry No.");
        if BillingLine.FindSet() then
            repeat
                BillingLine.Validate("Update Required", true);
                BillingLine.Modify(false);
            until BillingLine.Next() = 0;
    end;

    internal procedure UpdateNextBillingDate(LastBillingToDate: Date)
    var
        NewNextBillingDate: Date;
        OriginalInvoicedToDate: Date;
    begin
        if ("Subscription Line End Date" >= LastBillingToDate) or ("Subscription Line End Date" = 0D) then
            NewNextBillingDate := CalcDate('<+1D>', LastBillingToDate)
        else
            NewNextBillingDate := CalcDate('<+1D>', "Subscription Line End Date");
        "Next Billing Date" := NewNextBillingDate;

        OriginalInvoicedToDate := GetOriginalInvoicedToDateIfRebillingMetadataExist();
        if OriginalInvoicedToDate <> 0D then
            "Next Billing Date" := OriginalInvoicedToDate;
        OnAfterUpdateNextBillingDate(Rec, LastBillingToDate);
    end;

    local procedure UpdateCustomerContractLineServiceCommitmentDescription()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
    begin
        if Description = xRec.Description then
            exit;
        CustomerContractLine.SetRange("Subscription Header No.", Rec."Subscription Header No.");
        CustomerContractLine.SetRange("Subscription Line Entry No.", Rec."Entry No.");
        CustomerContractLine.FilterOnServiceObjectContractLineType();
        CustomerContractLine.ModifyAll("Subscription Line Description", Rec.Description, false);
    end;

    internal procedure RecalculateAmountsFromCurrencyData()
    var
        Currency: Record Currency;
    begin
        if ((Rec."Currency Factor" = 0) and (Rec."Currency Code" = '')) then
            exit;
        Currency.Initialize("Currency Code");
        Rec.Validate("Calculation Base Amount", Round(CurrExchRate.ExchangeAmtLCYToFCY("Currency Factor Date", "Currency Code", "Calculation Base Amount (LCY)", "Currency Factor"), Currency."Unit-Amount Rounding Precision"));
    end;

    internal procedure ResetAmountsAndCurrencyFromLCY()
    begin
        Rec.Price := Rec."Price (LCY)";
        Rec.Amount := Rec."Amount (LCY)";
        Rec."Discount Amount" := Rec."Discount Amount (LCY)";
        Rec."Calculation Base Amount" := Rec."Calculation Base Amount (LCY)";
        Rec."Unit Cost" := Rec."Unit Cost (LCY)";
        Rec.SetCurrencyData(0, 0D, '');
    end;

    internal procedure SetLCYFields(IncludeUnitCost: Boolean)
    begin
        if "Currency Code" = '' then begin
            Rec."Price (LCY)" := Rec.Price;
            Rec."Amount (LCY)" := Rec.Amount;
            Rec."Discount Amount (LCY)" := Rec."Discount Amount";
            Rec."Calculation Base Amount (LCY)" := Rec."Calculation Base Amount";
            if IncludeUnitCost then
                Rec."Unit Cost (LCY)" := Rec."Unit Cost";
        end else begin
            Currency.Initialize(Rec."Currency Code");
            Currency.TestField("Unit-Amount Rounding Precision");
            Currency.TestField("Amount Rounding Precision");
            Rec."Price (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", Rec.Price, "Currency Factor"), Currency."Unit-Amount Rounding Precision");
            Rec."Amount (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", Rec.Amount, "Currency Factor"), Currency."Amount Rounding Precision");
            Rec."Discount Amount (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", Rec."Discount Amount", "Currency Factor"), Currency."Amount Rounding Precision");
            Rec."Calculation Base Amount (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", Rec."Calculation Base Amount", "Currency Factor"), Currency."Unit-Amount Rounding Precision");
            if IncludeUnitCost then
                Rec."Unit Cost (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", Rec."Unit Cost", "Currency Factor"), Currency."Unit-Amount Rounding Precision");
        end;
    end;

    local procedure IsInitialTermEmpty(): Boolean
    begin
        exit(Format("Initial Term") = '');
    end;

    local procedure IsExtensionTermEmpty(): Boolean
    begin
        exit(Format("Extension Term") = '');
    end;

    internal procedure IsNoticePeriodEmpty(): Boolean
    begin
        exit(Format("Notice Period") = '');
    end;

    internal procedure UpdateServiceCommitment(CalledByFieldNo: Integer)
    var
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
        MultipleServiceCommitmentsUpdatedMsg: Label 'There are multiple Subscription Lines in the Subscription %1. The quantity was changed for all Subscription Lines.', Comment = '%1 = Object number';
    begin
        case CalledByFieldNo of
            FieldNo(Quantity):
                begin
                    ServiceObject.Get(Rec."Subscription Header No.");
                    ServiceObject.Validate(Quantity, Quantity);
                    ServiceObject.Modify(true);
                    ServiceCommitment.SetRange("Subscription Header No.", Rec."Subscription Header No.");
                    if ServiceCommitment.Count > 1 then
                        Message(MultipleServiceCommitmentsUpdatedMsg, Rec."Subscription Header No.");
                end
            else begin
                case CalledByFieldNo of
                    FieldNo("Invoicing Item No."):
                        Validate("Invoicing Item No.", "Invoicing Item No.");
                    FieldNo("Subscription Line Start Date"):
                        begin
                            Rec.ErrorIfBillingLineArchiveForServiceCommitmentExist();
                            Rec.ErrorIfBillingLineForServiceCommitmentExist();
                            Validate("Subscription Line Start Date", "Subscription Line Start Date");
                        end;
                    FieldNo("Subscription Line End Date"):
                        Validate("Subscription Line End Date", "Subscription Line End Date");
                    FieldNo(Quantity):
                        Validate(Quantity, Quantity);
                    FieldNo("Discount %"):
                        Validate("Discount %", "Discount %");
                    FieldNo("Discount Amount"):
                        Validate("Discount Amount", "Discount Amount");
                    FieldNo(Amount):
                        Validate(Amount, Amount);
                    FieldNo("Calculation Base Amount"):
                        Validate("Calculation Base Amount", "Calculation Base Amount");
                    FieldNo("Calculation Base %"):
                        Validate("Calculation Base %", "Calculation Base %");
                    FieldNo("Billing Base Period"):
                        Validate("Billing Base Period", "Billing Base Period");
                    FieldNo("Billing Rhythm"):
                        Validate("Billing Rhythm", "Billing Rhythm");
                    FieldNo("Cancellation Possible Until"):
                        Validate("Cancellation Possible Until", "Cancellation Possible Until");
                    FieldNo("Term Until"):
                        Validate("Term Until", "Term Until");
                    FieldNo("Currency Code"):
                        Validate("Currency Code", "Currency Code");
                    FieldNo("Exclude from Price Update"):
                        Validate("Exclude from Price Update", "Exclude from Price Update");
                    FieldNo("Next Price Update"):
                        Validate("Next Price Update", "Next Price Update");
                    FieldNo("Period Calculation"):
                        Validate("Period Calculation", "Period Calculation");
                    FieldNo("Notice Period"):
                        Validate("Notice Period", "Notice Period");
                    FieldNo("Price Binding Period"):
                        Validate("Period Calculation", "Period Calculation");
                    FieldNo("Unit Cost (LCY)"):
                        Validate("Unit Cost (LCY)", "Unit Cost (LCY)");
                    FieldNo("Create Contract Deferrals"):
                        Validate("Create Contract Deferrals", "Create Contract Deferrals");
                end;
                Modify(true);
            end;
        end;
        OnAfterUpdateSubscriptionLine(Rec);
    end;

    internal procedure EditDimensionSet()
    var
        OldDimSetID: Integer;
    begin
        OnBeforeValidateDimensionSetID(Rec, xRec);

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimMgt.EditDimensionSet(
            "Dimension Set ID", "Subscription Header No." + '' + Format("Entry No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            UpdateRelatedVendorServiceCommDimensions(OldDimSetID, "Dimension Set ID");
        end;
        OnAfterValidateDimensionSetID(Rec, xRec);
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if OldDimSetID <> "Dimension Set ID" then
            Modify();

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    internal procedure SetDefaultDimensions(UseSource: Boolean)
    var
        ServiceObject: Record "Subscription Header";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        if Rec."Invoicing Item No." <> '' then
            DimMgt.AddDimSource(DefaultDimSource, Database::Item, Rec."Invoicing Item No.");

        if UseSource then begin
            ServiceObject.Get("Subscription Header No.");
            case ServiceObject.Type of
                ServiceObject.Type::Item:
                    DimMgt.AddDimSource(DefaultDimSource, Database::Item, ServiceObject."Source No.");
                ServiceObject.Type::"G/L Account":
                    DimMgt.AddDimSource(DefaultDimSource, Database::"G/L Account", ServiceObject."Source No.");
            end;
        end;

        "Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    internal procedure GetCombinedDimensionSetID(DimSetID1: Integer; DimSetID2: Integer)
    var
        DimSetIDArr: array[10] of Integer;
    begin
        DimSetIDArr[1] := DimSetID1;
        DimSetIDArr[2] := DimSetID2;
        "Dimension Set ID" := DimMgt.GetCombinedDimensionSetID(DimSetIDArr, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        OnAfterGetCombinedDimensionSetID(Rec);
    end;

    internal procedure UpdateRelatedVendorServiceCommDimensions(OldDimSetID: Integer; NewDimSetID: Integer)
    var
        VendorServiceCommitment: Record "Subscription Line";
    begin
        if Rec."Subscription Contract No." = '' then
            exit;
        if OldDimSetID = NewDimSetID then
            exit;
        VendorServiceCommitment.FilterOnServiceObjectAndPackage(Rec."Subscription Header No.", Rec.Template, Rec."Subscription Package Code", Enum::"Service Partner"::Vendor);
        if VendorServiceCommitment.FindSet() then
            repeat
                VendorServiceCommitment."Dimension Set ID" := DimMgt.GetDeltaDimSetID(VendorServiceCommitment."Dimension Set ID", NewDimSetID, OldDimSetID);
                DimMgt.UpdateGlobalDimFromDimSetID(
                 VendorServiceCommitment."Dimension Set ID", VendorServiceCommitment."Shortcut Dimension 1 Code", VendorServiceCommitment."Shortcut Dimension 2 Code");
                VendorServiceCommitment.Modify(false);
            until VendorServiceCommitment.Next() = 0;
    end;

    internal procedure FilterOnServiceObjectAndTemplate(ServiceObjectNo: Code[20]; ServiceTemplate: Code[20]; ServicePartner: Enum "Service Partner")
    begin
        Rec.SetRange(Partner, ServicePartner);
        Rec.SetRange("Subscription Header No.", ServiceObjectNo);
        Rec.SetRange(Template, ServiceTemplate);
    end;

    local procedure DeleteContractLine()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        VendorContractLine: Record "Vend. Sub. Contract Line";
    begin
        if not (Rec."Invoicing via" = Rec."Invoicing via"::Contract) then
            exit;

        case Partner of
            Enum::"Service Partner"::Customer:
                if CustomerContractLine.Get(Rec."Subscription Contract No.", Rec."Subscription Contract Line No.") then
                    if CustomerContractLine.Closed then
                        CustomerContractLine.Delete(false);

            Enum::"Service Partner"::Vendor:
                if VendorContractLine.Get(Rec."Subscription Contract No.", Rec."Subscription Contract Line No.") then
                    if VendorContractLine.Closed then
                        VendorContractLine.Delete(false);
        end;
    end;

    internal procedure FilterOnServiceObjectAndPackage(ServiceObjectNo: Code[20]; ServiceTemplate: Code[20]; PackageCode: Code[20]; ServicePartner: Enum "Service Partner")
    begin
        Rec.FilterOnServiceObjectAndTemplate(ServiceObjectNo, ServiceTemplate, ServicePartner);
        Rec.SetRange("Subscription Package Code", PackageCode);
    end;

    internal procedure NewLineForServiceObject()
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceContractSetup.CheckPrerequisitesForCreatingManualContractLine();
        ServiceObject.Get(Rec.GetFilter("Subscription Header No."));
        ServiceObject.TestField("Source No.");
        ServiceCommitment.Init();
        ServiceCommitment."Entry No." := 0;
        ServiceCommitment."Subscription Header No." := ServiceObject."No.";
        ServiceCommitment.Description := ServiceObject.Description;
        ServiceCommitment."Invoicing via" := ServiceCommitment."Invoicing via"::Contract;
        ServiceCommitment.Partner := ServiceCommitment.Partner::Customer;
        ServiceCommitment."Customer Price Group" := ServiceObject."Customer Price Group";
        ServiceCommitment.Validate("Subscription Line Start Date", WorkDate());
        ServiceCommitment."Billing Base Period" := ServiceContractSetup."Default Billing Base Period";
        ServiceCommitment."Billing Rhythm" := ServiceContractSetup."Default Billing Rhythm";
        ServiceCommitment."Period Calculation" := ServiceContractSetup."Default Period Calculation";
        ServiceCommitment.SetDefaultDimensions(true);
        ServiceCommitment.Insert(false);
    end;

    internal procedure InitForServiceObject(ServiceObject: Record "Subscription Header"; ServicePartner: enum "Service Partner")
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
        ItemManagement: Codeunit "Sub. Contracts Item Management";
    begin
        ServiceContractSetup.CheckPrerequisitesForCreatingManualContractLine();
        Init();
        "Subscription Header No." := ServiceObject."No.";
        "Entry No." := 0;
        Description := ServiceObject.Description;
        "Invoicing via" := "Invoicing via"::Contract;
        Partner := ServicePartner;
        "Customer Price Group" := ServiceObject."Customer Price Group";
        Validate("Subscription Line Start Date", ServiceObject."Provision Start Date");
        "Billing Base Period" := ServiceContractSetup."Default Billing Base Period";
        "Billing Rhythm" := ServiceContractSetup."Default Billing Rhythm";
        "Renewal Term" := "Initial Term";
        "Period Calculation" := ServiceContractSetup."Default Period Calculation";
        if ServiceObject.IsItem() then
            if ItemManagement.IsServiceCommitmentItem(ServiceObject."Source No.") then
                "Invoicing Item No." := ServiceObject."Source No.";
        SetDefaultDimensions(true);
    end;

    internal procedure UpdateFromCustomerContract(CustomerContract: Record "Customer Subscription Contract")
    begin
        "Currency Code" := CustomerContract."Currency Code";
        InitCurrencyData();
        GetCombinedDimensionSetID("Dimension Set ID", CustomerContract."Dimension Set ID");
        "Exclude from Price Update" := CustomerContract.DefaultExcludeFromPriceUpdate;
    end;

    internal procedure UpdateFromVendorContract(VendorContract: Record "Vendor Subscription Contract")
    begin
        "Currency Code" := VendorContract."Currency Code";
        InitCurrencyData();
        GetCombinedDimensionSetID("Dimension Set ID", VendorContract."Dimension Set ID");
        "Exclude from Price Update" := VendorContract.DefaultExcludeFromPriceUpdate;
    end;

    internal procedure CopyFromSalesServiceCommitment(SalesServiceCommitment: Record "Sales Subscription Line")
    begin
        Rec."Subscription Package Code" := SalesServiceCommitment."Subscription Package Code";
        Rec.Template := SalesServiceCommitment.Template;
        Rec.Partner := SalesServiceCommitment.Partner;
        Rec.Description := SalesServiceCommitment.Description;
        Rec."Invoicing via" := SalesServiceCommitment."Invoicing via";
        Rec."Invoicing Item No." := SalesServiceCommitment."Item No.";
        Rec."Price" := SalesServiceCommitment."Price";
        Rec.Amount := SalesServiceCommitment.Amount;
        Rec."Calculation Base Amount" := SalesServiceCommitment."Calculation Base Amount";
        Rec."Calculation Base %" := SalesServiceCommitment."Calculation Base %";
        Rec."Unit Cost" := SalesServiceCommitment."Unit Cost";
        Rec."Discount %" := SalesServiceCommitment."Discount %";
        Rec."Discount Amount" := SalesServiceCommitment."Discount Amount";
        Rec."Billing Base Period" := SalesServiceCommitment."Billing Base Period";
        Rec."Billing Rhythm" := SalesServiceCommitment."Billing Rhythm";
        Rec."Initial Term" := SalesServiceCommitment."Initial Term";
        Rec."Extension Term" := SalesServiceCommitment."Extension Term";
        Rec."Notice Period" := SalesServiceCommitment."Notice Period";
        Rec.Discount := SalesServiceCommitment.Discount;
        Rec."Price Binding Period" := SalesServiceCommitment."Price Binding Period";
        Rec."Period Calculation" := SalesServiceCommitment."Period Calculation";
        Rec."Usage Based Billing" := SalesServiceCommitment."Usage Based Billing";
        Rec."Usage Based Pricing" := SalesServiceCommitment."Usage Based Pricing";
        Rec."Pricing Unit Cost Surcharge %" := SalesServiceCommitment."Pricing Unit Cost Surcharge %";
        Rec."Create Contract Deferrals" := SalesServiceCommitment."Create Contract Deferrals";
        OnAfterCopyFromSalesSubscriptionLine(Rec, SalesServiceCommitment);
    end;

    local procedure UpdateCurrencyFactorAndRecalculateAmountsFromExchRate()
    var
        UpdateCurrencyExchangeRates: Codeunit "Update Currency Exchange Rates";
    begin
        if "Currency Code" <> '' then begin
            if UpdateCurrencyExchangeRates.ExchangeRatesForCurrencyExist("Currency Factor Date", "Currency Code") then begin
                // note: Currency Factor will be filled from OpenExchangeSelectionPage
                if "Currency Code" <> xRec."Currency Code" then
                    RecalculateAmountsFromCurrencyData();
            end else
                UpdateCurrencyExchangeRates.ShowMissingExchangeRatesNotification("Currency Code");
        end else begin
            "Currency Factor" := 0;
            "Currency Factor Date" := 0D;
            if "Currency Code" <> xRec."Currency Code" then
                RecalculateAmountsFromCurrencyData();
        end;
    end;

    local procedure RecalculateHarmonizedBillingFieldsOnCustomerContract()
    var
        CustomerContract: Record "Customer Subscription Contract";
    begin
        if Rec.IsPartnerVendor() then
            exit;
        if "Subscription Contract No." = '' then
            exit;
        CustomerContract.Get(Rec."Subscription Contract No.");
        CustomerContract.RecalculateHarmonizedBillingFieldsBasedOnNextBillingDate(0);
    end;

    internal procedure TestServiceCommitmentsCurrencyCode(var ServiceCommitment: Record "Subscription Line" temporary)
    var
        PreviousCurrencyCode: Code[10];
    begin
        if ServiceCommitment.FindSet() then begin
            PreviousCurrencyCode := ServiceCommitment."Currency Code";
            repeat
                if ServiceCommitment."Currency Code" <> PreviousCurrencyCode then
                    Error(DifferentCurrenciesInSerCommitmentErr);

                PreviousCurrencyCode := ServiceCommitment."Currency Code"
            until ServiceCommitment.Next() = 0;
        end;
    end;

    internal procedure OpenExchangeSelectionPage(var NewCurrencyFactorDate: Date; var NewCurrencyFactor: Decimal; CurrencyCode: Code[10]; NewMessageTxt: Text; CalledFromServiceObject: Boolean): Boolean
    var
        ExchangeRateSelectionPage: Page "Exchange Rate Selection";
    begin
        if not GuiAllowed then
            exit(false);
        Commit(); // Save changes before opening the page
        ExchangeRateSelectionPage.SetData(WorkDate(), CurrencyCode, NewMessageTxt);
        ExchangeRateSelectionPage.SetIsCalledFromServiceObject(CalledFromServiceObject);
        if ExchangeRateSelectionPage.RunModal() = Action::Ok then begin
            ExchangeRateSelectionPage.GetData(NewCurrencyFactorDate, NewCurrencyFactor);
            if NewCurrencyFactor = 0 then
                Error(ZeroExchangeRateErr);
            exit(true);
        end;
    end;

    internal procedure ResetServiceCommitmentCurrencyLCYFromContract(PartnerType: Enum "Service Partner"; ContractNo: Code[20])
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceCommitment.FilterOnContract(PartnerType, ContractNo);
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment.ResetAmountsAndCurrencyFromLCY();
                ServiceCommitment.Modify(true);
            until ServiceCommitment.Next() = 0;
    end;

    internal procedure UpdateAndRecalculateServCommCurrencyFromContract(PartnerType: Enum "Service Partner"; ContractNo: Code[20];
                                                                                         CurrencyFactor: Decimal;
                                                                                         CurrencyFactorDate: Date;
                                                                                         CurrencyCode: Code[10])
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceCommitment.FilterOnContract(PartnerType, ContractNo);
        UpdateCurrencyDataOnServiceCommitments(ServiceCommitment, CurrencyFactor, CurrencyFactorDate, CurrencyCode, true);
    end;

    internal procedure UpdateCurrencyDataOnServiceCommitments(var ServiceCommitment: Record "Subscription Line"; CurrencyFactor: Decimal; CurrencyFactorDate: Date; CurrencyCode: Code[10]; UpdateCurrencyCodeOnServiceCommitment: Boolean)
    begin
        if ServiceCommitment.FindSet() then
            repeat
                if not UpdateCurrencyCodeOnServiceCommitment then
                    CurrencyCode := ServiceCommitment."Currency Code";
                ServiceCommitment.SetCurrencyData(CurrencyFactor, CurrencyFactorDate, CurrencyCode);
                ServiceCommitment.RecalculateAmountsFromCurrencyData();
                ServiceCommitment.Modify(true);
            until ServiceCommitment.Next() = 0;
    end;

    internal procedure FilterOnContract(PartnerType: Enum "Service Partner"; ContractNo: Code[20])
    begin
        Rec.SetRange(Partner, PartnerType);
        Rec.SetRange("Subscription Contract No.", ContractNo);
    end;

    local procedure InitCurrencyData()
    var
        Currency: Record Currency;
    begin
        if Rec."Currency Code" = '' then begin
            "Currency Factor" := 0;
            "Currency Factor Date" := 0D;
        end else begin
            Currency.Get("Currency Code");
            if "Currency Factor Date" = 0D then
                "Currency Factor Date" := WorkDate();
            if (Rec."Currency Factor Date" <> xRec."Currency Factor Date") or (Rec."Currency Code" <> xRec."Currency Code") then
                "Currency Factor" := CurrExchRate.ExchangeRate("Currency Factor Date", "Currency Code");
        end
    end;

    internal procedure SetCurrencyData(CurrencyFactor: Decimal; CurrencyFactorDate: Date; CurrencyCode: Code[10])
    begin
        Rec."Currency Factor" := CurrencyFactor;
        Rec."Currency Factor Date" := CurrencyFactorDate;
        Rec."Currency Code" := CurrencyCode;
    end;

    internal procedure ErrorIfBillingLineForServiceCommitmentExist()
    begin
        if BillingLineExists() then
            Error(BillingLineForServiceCommitmentExistErr);
    end;

    internal procedure GetPartnerNoFromContract(): Code[20]
    var
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
    begin
        case Rec.Partner of
            Rec.Partner::Customer:
                begin
                    CustomerContract.Get(Rec."Subscription Contract No.");
                    exit(CustomerContract."Sell-to Customer No.");
                end;
            Rec.Partner::Vendor:
                begin
                    VendorContract.Get(Rec."Subscription Contract No.");
                    exit(VendorContract."Buy-from Vendor No.");
                end;
        end;
    end;

    internal procedure ErrorIfBillingLineArchiveForServiceCommitmentExist()
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        BillingLineArchive.FilterBillingLineArchiveOnServiceCommitment(Rec."Entry No.");
        BillingLineArchive.CalcSums(Amount);
        if BillingLineArchive.Amount <> 0 then
            Error(BillingLineArchiveForServiceCommitmentExistErr);
    end;

    internal procedure ArchiveServiceCommitment()
    begin
        ArchiveServiceCommitment(0D, "Type Of Price Update"::None);
    end;

    internal procedure ArchiveServiceCommitment(PerformUpdateOn: Date; TypeOfPriceUpdate: Enum "Type Of Price Update")
    var
        ServiceCommitmentArchive: Record "Subscription Line Archive";
    begin
        if SkipArchiving then
            exit;

        xRec.Get(Rec."Entry No."); //Modify trigger has changed value in xRec.
        if (xRec."Calculation Base %" <> Rec."Calculation Base %") or
            (xRec."Calculation Base Amount" <> Rec."Calculation Base Amount") or
            (xRec.Price <> Rec.Price) or
            (xRec."Discount %" <> Rec."Discount %") or
            (xRec."Discount Amount" <> Rec."Discount Amount") or
            (xRec.Amount <> Rec.Amount) or
            (xRec."Billing Base Period" <> Rec."Billing Base Period") or
            (xRec."Billing Rhythm" <> Rec."Billing Rhythm") or
            (xRec."Unit Cost" <> Rec."Unit Cost") or
            (xRec."Unit Cost (LCY)" <> Rec."Unit Cost (LCY)")
        then
            CreateServiceCommitmentArchive(ServiceCommitmentArchive, xRec, PerformUpdateOn, TypeOfPriceUpdate);
    end;

    internal procedure ArchiveServiceCommitmentFromServiceObject(xServiceObject: Record "Subscription Header"; ServiceObject: Record "Subscription Header")
    var
        ServiceCommitmentArchive: Record "Subscription Line Archive";
    begin
        if (xServiceObject.Quantity <> ServiceObject.Quantity) or
           (xServiceObject."Serial No." <> ServiceObject."Serial No.") or
           (xServiceObject."Variant Code" <> ServiceObject."Variant Code")
        then begin
            CreateServiceCommitmentArchive(ServiceCommitmentArchive, Rec, 0D, "Type Of Price Update"::None);
            ServiceCommitmentArchive."Quantity (Sub. Header)" := xServiceObject.Quantity;
            ServiceCommitmentArchive."Serial No. (Sub. Header)" := xServiceObject."Serial No.";
            ServiceCommitmentArchive.Modify(false);
        end;
    end;

    internal procedure CreateServiceCommitmentArchive(var ServiceCommitmentArchive: Record "Subscription Line Archive"; xServiceCommitment: Record "Subscription Line"; PerformUpdateOn: Date; TypeOfPriceUpdate: Enum "Type Of Price Update")
    begin
        if FindServiceCommitmentArchiveCreatedInLessThanMinute(ServiceCommitmentArchive) then begin
            ServiceCommitmentArchive.CopyFromServiceCommitment(xServiceCommitment);
            ServiceCommitmentArchive."Perform Update On" := PerformUpdateOn;
            ServiceCommitmentArchive."Type Of Update" := TypeOfPriceUpdate;
            ServiceCommitmentArchive.Modify(false);
        end else begin
            ServiceCommitmentArchive.Init();
            ServiceCommitmentArchive.CopyFromServiceCommitment(xServiceCommitment);
            ServiceCommitmentArchive."Perform Update On" := PerformUpdateOn;
            ServiceCommitmentArchive."Type Of Update" := TypeOfPriceUpdate;
            ServiceCommitmentArchive."Entry No." := 0;
            ServiceCommitmentArchive.Insert(true);
        end;
    end;

    local procedure FindServiceCommitmentArchiveCreatedInLessThanMinute(var ServiceCommitmentArchive: Record "Subscription Line Archive"): Boolean
    begin
        ServiceCommitmentArchive.FilterOnServiceCommitment(Rec."Entry No.");
        ServiceCommitmentArchive.SetRange(SystemModifiedAt, CurrentDateTime() - 60000, CurrentDateTime());
        exit(ServiceCommitmentArchive.FindLast());
    end;

    internal procedure IsPartnerCustomer(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Customer);
    end;

    internal procedure IsPartnerVendor(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Vendor);
    end;

    internal procedure CalculateCalculationBaseAmount()
    var
        ServiceObject: Record "Subscription Header";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        ContractsItemManagement: Codeunit "Sub. Contracts Item Management";
    begin
        ServiceObject.Get(Rec."Subscription Header No.");
        case Rec.Partner of
            "Service Partner"::Customer:
                begin
                    ContractsItemManagement.CreateTempSalesHeader(TempSalesHeader, TempSalesHeader."Document Type"::Order, ServiceObject."End-User Customer No.", ServiceObject."Bill-to Customer No.", Rec."Subscription Line Start Date", Rec."Currency Code");
                    ContractsItemManagement.CreateTempSalesLine(TempSalesLine, TempSalesHeader, ServiceObject.Type, ServiceObject."Source No.", ServiceObject.Quantity, Rec."Subscription Line Start Date", ServiceObject."Variant Code");
                    Rec."Calculation Base Amount" := ContractsItemManagement.CalculateUnitPrice(TempSalesHeader, TempSalesLine);
                end;
            "Service Partner"::Vendor:
                if ServiceObject.IsItem() then
                    Rec."Calculation Base Amount" := ContractsItemManagement.CalculateUnitCost(ServiceObject."Source No.");
        end;
    end;

    local procedure RefreshRenewalTerm()
    var
        BlankDateFormula: DateFormula;
    begin
        if Rec."Subscription Line End Date" = 0D then
            Rec.Validate("Renewal Term", BlankDateFormula)
        else
            if Rec."Renewal Term" = BlankDateFormula then
                Rec.Validate("Renewal Term", "Initial Term");
    end;

    local procedure ErrorIfPlannedServiceCommitmentExists()
    var
        PlannedServiceCommitmentExistsErr: Label 'The Subscription Line End Date cannot be changed as long as there is a Planned Subscription Line.';
    begin
        if not Rec."Planned Sub. Line exists" then
            Rec.CalcFields("Planned Sub. Line exists");
        if "Planned Sub. Line exists" then
            Error(PlannedServiceCommitmentExistsErr);
    end;

    internal procedure IsFullyInvoiced(): Boolean
    begin
        if Rec.BillingLineExists() then
            exit(false);
        if (Rec."Next Billing Date" = 0D) then
            exit(false);

        exit(Rec."Subscription Line End Date" = CalcDate('<-1D>', Rec."Next Billing Date"));
    end;

    internal procedure SetSkipArchiving(NewSkipArchiving: Boolean)
    begin
        SkipArchiving := NewSkipArchiving;
    end;

    local procedure DisconnectBillingLineArchive()
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        BillingLineArchive.FilterBillingLineArchiveOnServiceCommitment(Rec."Entry No.");
        if BillingLineArchive.FindSet(true) then
            repeat
                BillingLineArchive."Subscription Header No." := '';
                BillingLineArchive."Subscription Line Entry No." := 0;
                BillingLineArchive.Modify(false);
            until BillingLineArchive.Next() = 0;
    end;

    internal procedure UpdateNextPriceUpdate()
    begin
        if Format(Rec."Price Binding Period") = '' then
            exit;
        Rec."Next Price Update" := CalcDate(Rec."Price Binding Period", Rec."Subscription Line Start Date");
    end;

    internal procedure SetSkipTestPackageCode(NewSkipTestPackageCode: Boolean)
    begin
        SkipTestPackageCode := NewSkipTestPackageCode;
    end;

    internal procedure ModifyExcludeFromPriceUpdateInAllRelatedServiceCommitments(ServicePartner: Enum "Service Partner"; ContractNo: Code[20];
                                                                                                      NewExcludeFromPriceUpdate: Boolean)
    var
        ServiceCommitment: Record "Subscription Line";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponse(GetChangeExcludeFromPriceUpdateQst(NewExcludeFromPriceUpdate), true) then
            exit;
        ServiceCommitment.FilterOnContract(ServicePartner, ContractNo);
        ServiceCommitment.ModifyAll("Exclude from Price Update", NewExcludeFromPriceUpdate, false);
    end;

    local procedure GetChangeExcludeFromPriceUpdateQst(NewExcludeFromPriceUpdate: Boolean): Text
    var
        ChangeExcludeFromPriceUpdateToYesQst: Label 'Do you want to include all contract lines in potential price updates? Click Yes to allow price updates for all contracts lines. Click No to keep the value in the contract lines.';
        ChangeExcludeFromPriceUpdateToNoQst: Label 'Do you want to exclude all contract lines from potential price updates? Click Yes to ban price updates for all contracts lines. Click No to keep the value in the contract lines.';
    begin
        if NewExcludeFromPriceUpdate then
            exit(ChangeExcludeFromPriceUpdateToNoQst)
        else
            exit(ChangeExcludeFromPriceUpdateToYesQst);
    end;

    internal procedure CalculateUnitCost()
    var
        ServiceObject: Record "Subscription Header";
        ContractsItemManagement: Codeunit "Sub. Contracts Item Management";
    begin
        case Rec.Partner of
            Partner::Customer:
                begin
                    ServiceObject.Get("Subscription Header No.");
                    if ServiceObject.Type = ServiceObject.Type::Item then
                        Rec.Validate("Unit Cost (LCY)", ContractsItemManagement.CalculateUnitCost(ServiceObject."Source No.") * Rec."Calculation Base %" / 100);
                end;
            Partner::Vendor:
                if Rec."Currency Code" <> '' then begin
                    Currency.Initialize(Rec."Currency Code");
                    Currency.TestField("Unit-Amount Rounding Precision");
                    Rec.Validate("Unit Cost (LCY)",
                                 Round(
                                    CurrExchRate.ExchangeAmtFCYToLCY(
                                        Rec."Currency Factor Date", Rec."Currency Code",
                                        Rec.Price, Rec."Currency Factor"),
                                    Currency."Unit-Amount Rounding Precision"));
                end else
                    Rec.Validate("Unit Cost (LCY)", Rec.Price);
        end;
    end;

    local procedure DeleteContractPriceUpdateLines()
    var
        ContractPriceUpdateLine: Record "Sub. Contr. Price Update Line";
    begin
        ContractPriceUpdateLine.FilterOnServiceCommitment(Rec."Entry No.");
        ContractPriceUpdateLine.DeleteAll(false);
    end;

    internal procedure UpdateServiceCommitmentFromContractPriceUpdateLine(ContractPriceUpdateLine: Record "Sub. Contr. Price Update Line")
    var
        ServiceCommitmentArchive: Record "Subscription Line Archive";
        xServiceCommitment: Record "Subscription Line";
        PriceUpdateTemplate: Record "Price Update Template";
    begin
        xServiceCommitment := Rec;
        Rec.Validate("Calculation Base %", ContractPriceUpdateLine."New Calculation Base %");
        Rec.Validate("Calculation Base Amount", ContractPriceUpdateLine."New Calculation Base");
        Rec.Validate(Price, ContractPriceUpdateLine."New Price");
        Rec.Validate(Amount, ContractPriceUpdateLine."New Amount");
        Rec.Validate("Discount %", ContractPriceUpdateLine."Discount %");
        Rec."Next Price Update" := ContractPriceUpdateLine."Next Price Update";
        if PriceUpdateTemplate.Get(ContractPriceUpdateLine."Price Update Template Code") then
            Rec."Price Binding Period" := PriceUpdateTemplate."Price Binding Period";

        //Archiving has to be skipped in OnModify trigger and called afterward in order to set proper Type of Price Update
        Rec.SetSkipArchiving(true);
        Rec.Modify(true);
        Rec.SetSkipArchiving(false);
        Rec.CreateServiceCommitmentArchive(ServiceCommitmentArchive, xServiceCommitment, CalcDate('<-1D>', ContractPriceUpdateLine."Perform Update On"), Enum::"Type Of Price Update"::"Price Update");
    end;

    internal procedure ServiceCommitmentArchiveExistsForPeriodExists(var ServiceCommitmentArchive: Record "Subscription Line Archive"; RecurringBillingFrom: Date; RecurringBillingTo: Date): Boolean
    begin
        ServiceCommitmentArchive.SetCurrentKey("Entry No.");
        ServiceCommitmentArchive.SetAscending("Entry No.", true);
        ServiceCommitmentArchive.SetRange("Subscription Header No.", Rec."Subscription Header No.");
        ServiceCommitmentArchive.SetRange("Original Entry No.", Rec."Entry No.");
        ServiceCommitmentArchive.SetRange("Perform Update On", RecurringBillingFrom, RecurringBillingTo);
        ServiceCommitmentArchive.SetRange("Type Of Update", Enum::"Type Of Price Update"::"Price Update");
        exit(ServiceCommitmentArchive.FindLast());
    end;

    internal procedure UpdateServiceCommitmentFromServiceCommitmentArchive(ServiceCommitmentArchive: Record "Subscription Line Archive")
    begin
        Rec.Price := ServiceCommitmentArchive.Price;
        Rec."Calculation Base %" := ServiceCommitmentArchive."Calculation Base %";
        Rec."Calculation Base Amount" := ServiceCommitmentArchive."Calculation Base Amount";
        Rec.Amount := ServiceCommitmentArchive.Amount;
        Rec."Discount Amount" := ServiceCommitmentArchive."Discount Amount";
        Rec."Discount %" := ServiceCommitmentArchive."Discount %";
        Rec."Price (LCY)" := ServiceCommitmentArchive."Price (LCY)";
        Rec."Calculation Base Amount (LCY)" := ServiceCommitmentArchive."Calculation Base Amount (LCY)";
        Rec."Amount (LCY)" := ServiceCommitmentArchive."Amount (LCY)";
        Rec."Discount Amount (LCY)" := ServiceCommitmentArchive."Discount Amount (LCY)";
        Rec."Next Price Update" := ServiceCommitmentArchive."Next Price Update";
        Rec.Closed := ServiceCommitmentArchive.Closed;
        Rec.Modify(false);
    end;

    internal procedure SetPerformUpdateForContractPriceUpdate(var PerformUpdate: Boolean; TypeOfPriceUpdate: Enum "Type Of Price Update"; PerformUpdateOn: Date)
    begin
        if TypeOfPriceUpdate <> Enum::"Type Of Price Update"::"Price Update" then
            exit;
        PerformUpdate := PerformUpdateOn <= Rec."Next Billing Date";
    end;

    internal procedure UnpostedDocumentExists(): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnContractLine(Rec.Partner, Rec."Subscription Contract No.", Rec."Subscription Contract Line No.");
        BillingLine.SetRange("Document Type", "Rec. Billing Document Type"::Invoice, "Rec. Billing Document Type"::"Credit Memo");
        exit(not BillingLine.IsEmpty());
    end;

    internal procedure BillingLineExists(): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnContractLine(Rec.Partner, Rec."Subscription Contract No.", Rec."Subscription Contract Line No.");
        exit(not BillingLine.IsEmpty());
    end;

    internal procedure DisconnectContractLine(EntryNo: Integer)
    begin
        if EntryNo <> 0 then
            if Get(EntryNo) then begin
                "Subscription Contract No." := '';
                "Subscription Contract Line No." := 0;
                Modify(false);
            end;
    end;

    internal procedure DeleteOrDisconnectServiceCommitment(EntryNo: Integer)
    var
        ServiceObject: Record "Subscription Header";
    begin
        if EntryNo <> 0 then
            if Get(EntryNo) then
                if "Created in Contract line" then begin
                    Delete();
                    DeleteContractPriceUpdateLines();
                    if ServiceObject.Get("Subscription Header No.") then
                        ServiceObject.DeleteServiceObjectFromContract();
                end else
                    DisconnectContractLine(EntryNo);
    end;

    internal procedure IsUsageDataBillingFound(var UsageDataBilling: Record "Usage Data Billing"; BillingFromDate: Date; BillingToDate: Date): Boolean
    begin
        SetUsageDataBillingFilters(UsageDataBilling, BillingFromDate, BillingToDate);
        exit(not UsageDataBilling.IsEmpty());
    end;

    local procedure SetUsageDataBillingFilters(var UsageDataBilling: Record "Usage Data Billing"; BillingFromDate: Date; BillingToDate: Date)
    begin
        UsageDataBilling.SetRange("Subscription Header No.", Rec."Subscription Header No.");
        UsageDataBilling.SetRange("Subscription Line Entry No.", Rec."Entry No.");
        UsageDataBilling.SetRange(Partner, Rec.Partner);
        UsageDataBilling.SetRange("Usage Base Pricing", Enum::"Usage Based Pricing"::"Usage Quantity", Enum::"Usage Based Pricing"::"Unit Cost Surcharge");
        UsageDataBilling.SetRange("Document Type", "Usage Based Billing Doc. Type"::None);
        UsageDataBilling.SetFilter("Charge Start Date", '>=%1', BillingFromDate);
        UsageDataBilling.SetFilter("Charge End Date", '<=%1', CalcDate('<1D>', BillingToDate));
    end;

    internal procedure IsUsageBasedBillingValid(): Boolean
    begin
        exit(Rec."Usage Based Billing" and (Rec."Subscription Header No." <> ''));
    end;

    local procedure GetOriginalInvoicedToDateIfRebillingMetadataExist() OriginalInvoicedToDate: Date
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        if not Rec."Usage Based Billing" then
            exit;
        UsageDataBillingMetadata.FilterOnServiceCommitment(Rec."Entry No.");
        UsageDataBillingMetadata.SetRange(Invoiced, false);
        UsageDataBillingMetadata.SetRange(Rebilling, true);
        UsageDataBillingMetadata.SetFilter("Supplier Charge Start Date", '>=%1', Rec."Next Billing Date");
        if UsageDataBillingMetadata.FindFirst() then
            OriginalInvoicedToDate := CalcDate('<+1D>', UsageDataBillingMetadata."Original Invoiced to Date");
    end;

    internal procedure GetSupplierChargeEndDateIfRebillingMetadataExist(FromDate: Date) SupplierChargeEndDate: Date
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        if not Rec."Usage Based Billing" then
            exit;
        UsageDataBillingMetadata.FilterOnServiceCommitment(Rec."Entry No.");
        UsageDataBillingMetadata.SetRange(Invoiced, false);
        UsageDataBillingMetadata.SetRange(Rebilling, true);
        UsageDataBillingMetadata.SetFilter("Supplier Charge Start Date", '>=%1', FromDate);
        if UsageDataBillingMetadata.FindFirst() then
            SupplierChargeEndDate := UsageDataBillingMetadata."Supplier Charge End Date";
    end;

    internal procedure GetLastSupplierChargeEndDateIfMetadataExist() SupplierChargeEndDate: Date
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        UsageDataBillingMetadata.FilterOnServiceCommitment(Rec."Entry No.");
        if UsageDataBillingMetadata.FindLast() then
            exit(UsageDataBillingMetadata."Supplier Charge End Date");
    end;

    internal procedure GetSupplierChargeStartDateIfRebillingMetadataExist(FromDate: Date) SupplierChargeStartDate: Date
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        if not Rec."Usage Based Billing" then
            exit;
        UsageDataBillingMetadata.FilterOnServiceCommitment(Rec."Entry No.");
        UsageDataBillingMetadata.SetRange(Invoiced, false);
        UsageDataBillingMetadata.SetRange(Rebilling, true);
        if FromDate <> 0D then
            UsageDataBillingMetadata.SetFilter("Supplier Charge Start Date", '>=%1', FromDate);
        if UsageDataBillingMetadata.FindFirst() then
            SupplierChargeStartDate := UsageDataBillingMetadata."Supplier Charge Start Date";
    end;

    internal procedure ShowUsageDataBillingMetadata()
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
    begin
        UsageDataBillingMetadata.SetRange("Subscription Line Entry No.", Rec."Entry No.");
        Page.RunModal(Page::"Usage Data Billing Metadata", UsageDataBillingMetadata);
    end;

    internal procedure UnitPriceForPeriod(ChargePeriodStart: Date; ChargePeriodEnd: Date) UnitPrice: Decimal
    var
        UnitCost: Decimal;
        UnitCostLCY: Decimal;
    begin
        Rec.UnitPriceAndCostForPeriod(Rec."Billing Rhythm", ChargePeriodStart, ChargePeriodEnd, UnitPrice, UnitCost, UnitCostLCY);
    end;

    internal procedure UnitPriceAndCostForPeriod(BillingRhythm: DateFormula; ChargePeriodStart: Date; ChargePeriodEnd: Date; var UnitPrice: Decimal; var UnitCost: Decimal; var UnitCostLCY: Decimal)
    var
        PeriodFormula: DateFormula;
        BillingPeriodRatio: Decimal;
        PeriodPrice, PeriodUnitCost, PeriodUnitCostLCY : Decimal;
        DayPrice, DayUnitCost, DayUnitCostLCY : Decimal;
        FollowUpDays: Integer;
        Periods: Integer;
        FollowUpPeriodDays: Integer;
    begin
        BillingPeriodRatio := Rec.GetBillingPeriodRatio(BillingRhythm, Rec."Billing Base Period");
        if BillingPeriodRatio > 1 then begin
            PeriodPrice := Rec.Price;
            PeriodUnitCost := Rec."Unit Cost";
            PeriodUnitCostLCY := Rec."Unit Cost (LCY)";
            PeriodFormula := Rec."Billing Base Period";
        end else begin
            PeriodPrice := Rec.Price * BillingPeriodRatio;
            PeriodUnitCost := Rec."Unit Cost" * BillingPeriodRatio;
            PeriodUnitCostLCY := Rec."Unit Cost (LCY)" * BillingPeriodRatio;
            PeriodFormula := Rec."Billing Rhythm";
        end;
        Rec.CalculatePeriodCountAndDaysCount(PeriodFormula, ChargePeriodStart, ChargePeriodEnd, Periods, FollowUpDays, FollowUpPeriodDays);
        if FollowUpPeriodDays <> 0 then begin
            DayPrice := PeriodPrice / FollowUpPeriodDays;
            DayUnitCost := PeriodUnitCost / FollowUpPeriodDays;
            DayUnitCostLCY := PeriodUnitCostLCY / FollowUpPeriodDays;
        end;
        UnitPrice := PeriodPrice * Periods + DayPrice * FollowUpDays;
        UnitCost := PeriodUnitCost * Periods + DayUnitCost * FollowUpDays;
        UnitCostLCY := PeriodUnitCostLCY * Periods + DayUnitCostLCY * FollowUpDays;
    end;

    internal procedure CalculatePeriodCountAndDaysCount(PeriodFormula: DateFormula; StartDate: Date; EndDate: Date; var Periods: Integer; var FollowUpDays: Integer; var FollowUpPeriodDays: Integer)
    var
        LastDayInPreviousPeriod: Date;
        LastDayInNextPeriod: Date;
        FollowUpDaysExist: Boolean;
        PeriodFormulaInteger: Integer;
        Letter: Char;
    begin
        Periods := 0;
        FollowUpDays := 0;
        FollowUpPeriodDays := 0;
        FollowUpDaysExist := true;

        LastDayInNextPeriod := StartDate - 1;
        DateFormulaManagement.FindDateFormulaType(PeriodFormula, PeriodFormulaInteger, Letter);
        repeat
            Evaluate(PeriodFormula, '<' + Format((Periods + 1) * PeriodFormulaInteger) + Letter + '>');
            LastDayInPreviousPeriod := LastDayInNextPeriod;
            LastDayInNextPeriod := Rec.CalculateNextToDate(PeriodFormula, StartDate);
            if LastDayInNextPeriod <= EndDate then
                Periods += 1;
            FollowUpDaysExist := LastDayInNextPeriod <> EndDate;
        until LastDayInNextPeriod >= EndDate;
        if FollowUpDaysExist then begin
            FollowUpDays := EndDate - LastDayInPreviousPeriod;
            FollowUpPeriodDays := LastDayInNextPeriod - LastDayInPreviousPeriod;
        end;
    end;

    internal procedure GetBillingPeriodRatio(BillingRhythm: DateFormula; BillingBaseRhytm: DateFormula) BillingPeriodRatio: Decimal
    var
        BillingPeriodCount: Integer;
        BillingBasePeriodCount: Integer;
    begin
        if (Format(BillingRhythm) = '') or (Format(BillingBaseRhytm) = '') then
            exit(0);
        DateFormulaManagement.FindDateFormulaTypeForComparison(BillingRhythm, BillingPeriodCount);
        DateFormulaManagement.FindDateFormulaTypeForComparison(BillingBaseRhytm, BillingBasePeriodCount);
        BillingPeriodRatio := BillingPeriodCount / BillingBasePeriodCount;
    end;

    internal procedure CalculateNextToDate(PeriodFormula: DateFormula; FromDate: Date) NextToDate: Date
    var
        DistanceToEndOfMonth: Integer;
        LastDateInLastMonth: Date;
    begin
        case Rec."Period Calculation" of
            Rec."Period Calculation"::"Align to Start of Month":
                NextToDate := CalcDate(PeriodFormula, FromDate) - 1;
            Rec."Period Calculation"::"Align to End of Month":
                begin
                    DistanceToEndOfMonth := CalcDate('<CM>', Rec."Subscription Line Start Date") - Rec."Subscription Line Start Date";
                    if DistanceToEndOfMonth > 2 then
                        NextToDate := CalcDate(PeriodFormula, FromDate) - 1
                    else begin
                        LastDateInLastMonth := CalcDate(PeriodFormula, FromDate);
                        LastDateInLastMonth := CalcDate('<CM>', LastDateInLastMonth);
                        NextToDate := LastDateInLastMonth - DistanceToEndOfMonth - 1;
                    end;
                end;
        end;
    end;

    local procedure NoManualEntryOfUnitCostLCYForVendorServCommError(CurrentFieldNo: Integer)
    begin
        if Rec.IsPartnerVendor() and (CurrentFieldNo = Rec.FieldNo("Unit Cost (LCY)")) then
            Error(NoManualEntryOfUnitCostLCYForVendorServCommErr);
    end;

    internal procedure OpenDeferralsExist(): Boolean
    var
        CustSubContractDeferral: Record "Cust. Sub. Contract Deferral";
        VendSubContractDeferral: Record "Vend. Sub. Contract Deferral";
    begin
        if "Subscription Contract No." = '' then
            exit(false);
        case Partner of
            Enum::"Service Partner"::Customer:
                begin
                    CustSubContractDeferral.SetRange(Released, false);
                    CustSubContractDeferral.SetRange("Subscription Contract No.", "Subscription Contract No.");
                    exit(not CustSubContractDeferral.IsEmpty());
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    VendSubContractDeferral.SetRange(Released, false);
                    VendSubContractDeferral.SetRange("Subscription Contract No.", "Subscription Contract No.");
                    exit(not VendSubContractDeferral.IsEmpty());
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateNextBillingDate(var SubscriptionLine: Record "Subscription Line"; LastBillingToDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateServiceAmount(var SubscriptionLine: Record "Subscription Line"; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSubscriptionLine(var SubscriptionLine: Record "Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCombinedDimensionSetID(var SubscriptionLine: Record "Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var SubscriptionLine: Record "Subscription Line"; xSubscriptionLine: Record "Subscription Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var SubscriptionLine: Record "Subscription Line"; xSubscriptionLine: Record "Subscription Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateDimensionSetID(var SubscriptionLine: Record "Subscription Line"; xSubscriptionLine: Record "Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateDimensionSetID(var SubscriptionLine: Record "Subscription Line"; xSubscriptionLine: Record "Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromSalesSubscriptionLine(var SubscriptionLine: Record "Subscription Line"; SalesSubscriptionLine: Record "Sales Subscription Line")
    begin
    end;
}