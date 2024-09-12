namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Foundation.Calendar;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;

table 8059 "Service Commitment"
{
    DataClassification = CustomerContent;
    Caption = 'Service Commitment';
    DrillDownPageId = "Service Commitments List";
    LookupPageId = "Service Commitments List";
    Access = Internal;
    fields
    {
        field(1; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
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

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateEmpty("Service Start Date", FieldCaption("Service Start Date"));
                UpdateNextBillingDate("Service Start Date" - 1);
                CheckServiceDates();
                RecalculateHarmonizedBillingFieldsOnCustomerContract();
                UpdateNextPriceUpdate();
            end;
        }
        field(7; "Service End Date"; Date)
        {
            Caption = 'Service End Date';

            trigger OnValidate()
            begin
                DateFormulaManagement.ErrorIfDateEmpty("Service Start Date", FieldCaption("Service Start Date"));
                ErrorIfPlannedServiceCommitmentExists();
                CheckServiceDates();
                ClearTerminationPeriodsWhenServiceEnded();
                RefresheRenewalTerm();
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
        field(14; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
            BlankZero = true;
            AutoFormatType = 1;

            trigger OnValidate()
            begin
                CalculateServiceAmount(FieldNo("Service Amount"));
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
            TableRelation = if (Partner = const(Customer)) "Customer Contract" where("Sell-to Customer No." = field("Service Object Customer No.")) else
            if (Partner = const(Vendor)) "Vendor Contract";
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
                RefresheRenewalTerm();
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
        field(26; "Service Object Customer No."; Code[20])
        {
            Caption = 'Service Object Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object"."End-User Customer No." where("No." = field("Service Object No.")));
            Editable = false;
        }
        field(27; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract Line"."Line No." where("Contract No." = field("Contract No."));
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
        field(39; "Quantity Decimal"; Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object"."Quantity Decimal" where("No." = field("Service Object No.")));
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
        field(200; "Planned Serv. Comm. exists"; Boolean)
        {
            Caption = 'Planned Service Commitment exists';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Planned Service Commitment" where("Entry No." = field("Entry No.")));
        }
        field(202; "Renewal Term"; DateFormula)
        {
            Caption = 'Renewal Term';

            trigger OnValidate()
            var
                BlankDateFormula: DateFormula;
            begin
                if Rec."Renewal Term" <> BlankDateFormula then
                    Rec.TestField("Service End Date");
                DateFormulaManagement.ErrorIfDateFormulaNegative("Renewal Term");
            end;
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
        field(8009; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object"."Item No." where("No." = field("Service Object No.")));
        }
        field(8010; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object".Description where("No." = field("Service Object No.")));
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
        key(Contract; "Contract No.", "Contract Line No.") { }
    }

    trigger OnInsert()
    begin
        if not SkipTestPackageCode then
            TestField("Package Code");
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
        NegativeDateFormula: DateFormula;
        SkipArchiving: Boolean;
        SkipTestPackageCode: Boolean;
        DateBeforeDateErr: Label '%1 cannot be before %2.';
        OnlyOneDayBeforeErr: Label 'The %1 is only allowed to be 1 day before the %2.', Comment = '%1 = Service End Date; %2 = Next Billing Date';
        CannotBeGreaterThanErr: Label '%1 cannot be greater than %2.';
        CannotBeLessThanErr: Label '%1 cannot be less than %2.';
        OpenContractLinesExistErr: Label 'The service cannot be deleted because it is linked to a contract line which is not yet marked as "Closed".';
        ClosedContractLineExistErr: Label 'Services for closed contract lines may not be edited. Remove the "Finished" indicator in the contract to be able to edit the service.';
        DifferentCurrenciesInSerCommitmentErr: Label 'The selected services must be converted into different currencies. Please select only services with the same currency.';
        ZeroExchangeRateErr: Label 'The price could not be updated because the exchange rate is 0.';
        BillingLineForServiceCommitmentExistErr: Label 'The contract line is in the current billing. Delete the billing line to be able to adjust the service start date.';
        BillingLineArchiveForServiceCommitmentExistErr: Label 'The contract line has already been billed. The service start date can no longer be changed.';

    local procedure CheckServiceDates()
    begin
        CheckServiceDates(Rec."Service Start Date", Rec."Service End Date", Rec."Next Billing Date");
    end;

    internal procedure CheckServiceDates(ServiceStartDate: Date; ServiceEndDate: Date; NextBillingDate: Date)
    begin
        if (ServiceStartDate <> 0D) and (ServiceEndDate <> 0D) then
            if ServiceStartDate > ServiceEndDate then
                Error(DateBeforeDateErr, Rec.FieldCaption("Service End Date"), Rec.FieldCaption("Service Start Date"));
        if NextBillingDate <> 0D then begin
            if (ServiceStartDate <> 0D) and (NextBillingDate < ServiceStartDate) then
                Error(DateBeforeDateErr, Rec.FieldCaption("Next Billing Date"), Rec.FieldCaption("Service Start Date"));
            if (ServiceEndDate <> 0D) and (CalcDate('<-1D>', NextBillingDate) > ServiceEndDate) then
                Error(OnlyOneDayBeforeErr, Rec.FieldCaption("Service End Date"), Rec.FieldCaption("Next Billing Date"));
        end;
    end;

    internal procedure DisplayErrorIfContractLinesExist(ErrorTxt: Text; CheckContractLineClosed: Boolean)
    var
        CustomerContractLine: Record "Customer Contract Line";
        VendorContractLine: Record "Vendor Contract Line";
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
        if ("Service End Date" <> 0D) and ("Service End Date" < WorkDate()) then begin
            Clear("Term Until");
            Clear("Cancellation Possible Until");
        end;
    end;

    procedure CalculateInitialServiceEndDate()
    begin
        if IsInitialTermEmpty() then
            exit;
        if not IsExtensionTermEmpty() then
            exit;

        TestField("Service Start Date");
        "Service End Date" := CalcDate("Initial Term", "Service Start Date");
        "Service End Date" := CalcDate('<-1D>', "Service End Date");
        RefresheRenewalTerm();
    end;

    procedure CalculateInitialCancellationPossibleUntilDate()
    begin
        if IsExtensionTermEmpty() then
            exit;
        if IsNoticePeriodEmpty() then
            exit;
        if IsInitialTermEmpty() then
            exit;

        TestField("Service Start Date");
        "Cancellation Possible Until" := CalcDate("Initial Term", "Service Start Date");
        CalendarManagement.ReverseDateFormula(NegativeDateFormula, "Notice Period");
        "Cancellation Possible Until" := CalcDate(NegativeDateFormula, "Cancellation Possible Until");
        "Cancellation Possible Until" := CalcDate('<-1D>', "Cancellation Possible Until");
    end;

    procedure CalculateInitialTermUntilDate()
    begin
        if "Service End Date" <> 0D then begin
            "Term Until" := "Service End Date";
            exit;
        end;

        if IsExtensionTermEmpty() then
            exit;
        if IsNoticePeriodEmpty() and IsInitialTermEmpty() then
            exit;

        TestField("Service Start Date");
        if IsInitialTermEmpty() then begin
            "Term Until" := CalcDate("Notice Period", "Service Start Date");
            "Term Until" := CalcDate('<-1D>', "Term Until");
            UpdateCancellationPossibleUntil();
        end else begin
            "Term Until" := CalcDate("Initial Term", "Service Start Date");
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
            "Service Start Date" <> 0D:
                exit("Service Start Date");
        end;
    end;

    internal procedure UpdateTermUntilUsingExtensionTerm(): Boolean
    begin
        if (IsExtensionTermEmpty() or
            (("Term Until" = 0D) and ("Service Start Date" = 0D))) then
            exit(false);
        if "Term Until" <> 0D then begin
            if IsDateLastDayOfMonth("Term Until") then begin
                "Term Until" := CalcDate("Extension Term", "Term Until");
                MoveDateToLastDayOfMonth("Term Until");
            end else
                "Term Until" := CalcDate("Extension Term", "Term Until");
        end else begin
            "Term Until" := CalcDate("Extension Term", "Service Start Date");
            if IsDateLastDayOfMonth("Service Start Date") then
                MoveDateToLastDayOfMonth("Term Until");
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

        if IsDateLastDayOfMonth("Cancellation Possible Until") then
            MoveDateToLastDayOfMonth("Term Until");
    end;

    internal procedure UpdateCancellationPossibleUntil(): Boolean
    begin
        if IsNoticePeriodEmpty() then
            exit(false);
        CalendarManagement.ReverseDateFormula(NegativeDateFormula, "Notice Period");
        "Cancellation Possible Until" := CalcDate(NegativeDateFormula, "Term Until");
        if IsDateLastDayOfMonth("Term Until") then
            MoveDateToLastDayOfMonth("Cancellation Possible Until");

        exit(true);
    end;

    internal procedure CalculatePrice()
    begin
        if "Calculation Base Amount" <> 0 then
            Validate(Price, "Calculation Base Amount" * "Calculation Base %" / 100)
        else
            Validate(Price, 0);
    end;

    local procedure CalculateServiceAmount(CalledByFieldNo: Integer)
    var
        ServiceObject: Record "Service Object";
        MaxServiceAmount: Decimal;
    begin
        ServiceObject.Get("Service Object No.");
        Currency.Initialize("Currency Code");
        MaxServiceAmount := Price * ServiceObject."Quantity Decimal";
        if not "Usage Based Billing" then
            MaxServiceAmount := Round(MaxServiceAmount, Currency."Amount Rounding Precision");
        if CalledByFieldNo = FieldNo("Service Amount") then begin
            if "Service Amount" > MaxServiceAmount then
                Error(CannotBeGreaterThanErr, FieldCaption("Service Amount"), Format(MaxServiceAmount));
            if "Service Amount" < 0 then
                Error(CannotBeLessThanErr, FieldCaption("Service Amount"), 0);
            "Discount Amount" := Round(MaxServiceAmount - "Service Amount", Currency."Amount Rounding Precision");
            if MaxServiceAmount <> 0 then
                "Discount %" := Round(100 - ("Service Amount" / MaxServiceAmount * 100), 0.00001);
        end else begin
            ServiceObject.TestField("Quantity Decimal");
            "Service Amount" := Price * ServiceObject."Quantity Decimal";
            if not "Usage Based Billing" then
                "Service Amount" := Round("Service Amount", Currency."Amount Rounding Precision");
            if CalledByFieldNo = FieldNo("Discount %") then
                "Discount Amount" := Round("Service Amount" * "Discount %" / 100, Currency."Amount Rounding Precision");
            if CalledByFieldNo = FieldNo("Discount Amount") then
                "Discount %" := Round("Discount Amount" / "Service Amount" * 100, 0.00001);
            if ("Discount Amount" > MaxServiceAmount) and ("Discount Amount" <> 0) then
                Error(CannotBeGreaterThanErr, FieldCaption("Discount Amount"), Format(MaxServiceAmount));
            "Service Amount" := "Service Amount" - "Discount Amount";
            if "Service Amount" > MaxServiceAmount then
                Error(CannotBeGreaterThanErr, FieldCaption("Service Amount"), Format(MaxServiceAmount));
        end;
        SetLCYFields("Price", "Service Amount", "Discount Amount", "Calculation Base Amount");
        OnAfterCalculateServiceAmount(Rec, CalledByFieldNo);
    end;

    local procedure SetUpdateRequiredOnBillingLines()
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Service Object No.", "Service Object No.");
        BillingLine.SetRange("Service Commitment Entry No.", "Entry No.");
        if BillingLine.FindSet() then
            repeat
                BillingLine.Validate("Update Required", true);
                BillingLine.Modify(false);
            until BillingLine.Next() = 0;
    end;

    internal procedure UpdateNextBillingDate(LastBillingToDate: Date)
    var
        NewNextBillingDate: Date;
    begin
        if ("Service End Date" >= LastBillingToDate) or ("Service End Date" = 0D) then
            NewNextBillingDate := CalcDate('<+1D>', LastBillingToDate)
        else
            NewNextBillingDate := CalcDate('<+1D>', "Service End Date");
        "Next Billing Date" := NewNextBillingDate;
        OnAfterUpdateNextBillingDate(Rec, LastBillingToDate);
    end;

    local procedure UpdateCustomerContractLineServiceCommitmentDescription()
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        if Description = xRec.Description then
            exit;
        CustomerContractLine.SetRange("Service Object No.", Rec."Service Object No.");
        CustomerContractLine.SetRange("Service Commitment Entry No.", Rec."Entry No.");
        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        CustomerContractLine.ModifyAll("Service Commitment Description", Rec.Description, false);
    end;

    internal procedure RecalculateAmountsFromCurrencyData()
    begin
        if ((Rec."Currency Factor" = 0) and (Rec."Currency Code" = '')) then
            exit;
        Rec.Price := CurrExchRate.ExchangeAmtLCYToFCY("Currency Factor Date", "Currency Code", "Price (LCY)", "Currency Factor");
        Rec."Service Amount" := CurrExchRate.ExchangeAmtLCYToFCY("Currency Factor Date", "Currency Code", "Service Amount (LCY)", "Currency Factor");
        Rec."Discount Amount" := CurrExchRate.ExchangeAmtLCYToFCY("Currency Factor Date", "Currency Code", "Discount Amount (LCY)", "Currency Factor");
        Rec."Calculation Base Amount" := CurrExchRate.ExchangeAmtLCYToFCY("Currency Factor Date", "Currency Code", "Calculation Base Amount (LCY)", "Currency Factor");
    end;

    internal procedure ResetAmountsAndCurrencyFromLCY()
    begin
        Rec.Price := Rec."Price (LCY)";
        Rec."Service Amount" := Rec."Service Amount (LCY)";
        Rec."Discount Amount" := Rec."Discount Amount (LCY)";
        Rec."Calculation Base Amount" := Rec."Calculation Base Amount (LCY)";
        Rec.SetCurrencyData(0, 0D, '');
    end;

    internal procedure SetLCYFields(NewPriceLCY: Decimal; NewServiceAmountLCY: Decimal; NewDiscountAmountLCY: Decimal; NewCalculationBaseAmountLCY: Decimal)
    begin
        if "Currency Code" = '' then begin
            Rec."Price (LCY)" := NewPriceLCY;
            Rec."Service Amount (LCY)" := NewServiceAmountLCY;
            Rec."Discount Amount (LCY)" := NewDiscountAmountLCY;
            Rec."Calculation Base Amount (LCY)" := NewCalculationBaseAmountLCY;
        end else begin
            Rec."Price (LCY)" := CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", NewPriceLCY, "Currency Factor");
            Rec."Service Amount (LCY)" := CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", NewServiceAmountLCY, "Currency Factor");
            Rec."Discount Amount (LCY)" := CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", NewDiscountAmountLCY, "Currency Factor");
            Rec."Calculation Base Amount (LCY)" := CurrExchRate.ExchangeAmtFCYToLCY("Currency Factor Date", "Currency Code", NewCalculationBaseAmountLCY, "Currency Factor");
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

    local procedure IsNoticePeriodEmpty(): Boolean
    begin
        exit(Format("Notice Period") = '');
    end;

    internal procedure UpdateServiceCommitment(CalledByFieldNo: Integer)
    begin
        case CalledByFieldNo of
            FieldNo("Service Start Date"):
                begin
                    Rec.ErrorIfBillingLineArchiveForServiceCommitmentExist();
                    Rec.ErrorIfBillingLineForServiceCommitmentExist();
                    Validate("Service Start Date", "Service Start Date");
                end;
            FieldNo("Service End Date"):
                Validate("Service End Date", "Service End Date");
            FieldNo("Discount %"):
                Validate("Discount %", "Discount %");
            FieldNo("Discount Amount"):
                Validate("Discount Amount", "Discount Amount");
            FieldNo("Service Amount"):
                Validate("Service Amount", "Service Amount");
            FieldNo("Calculation Base Amount"):
                Validate("Calculation Base Amount", "Calculation Base Amount");
            FieldNo("Calculation Base %"):
                Validate("Calculation Base %", "Calculation Base %");
            FieldNo("Billing Rhythm"):
                Validate("Billing Rhythm", "Billing Rhythm");
            FieldNo("Currency Code"):
                Validate("Currency Code", "Currency Code");
            FieldNo("Exclude from Price Update"):
                Validate("Exclude from Price Update", "Exclude from Price Update");
            FieldNo("Next Price Update"):
                Validate("Next Price Update", "Next Price Update");
            FieldNo("Period Calculation"):
                Validate("Period Calculation", "Period Calculation");
        end;
        Modify(true);
        OnAfterUpdateServiceCommitment(Rec);
    end;

    internal procedure EditDimensionSet()
    var
        OldDimSetID: Integer;
    begin
        OnBeforeValidateDimensionSetID(Rec, xRec);

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimMgt.EditDimensionSet(
            "Dimension Set ID", "Service Object No." + '' + Format("Entry No."),
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

    procedure SetDefaultDimensionFromItem(ServiceObjectItemNo: Code[20]; AppendDimFromInvoicingItem: Boolean)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        if AppendDimFromInvoicingItem then
            DimMgt.AddDimSource(DefaultDimSource, Database::Item, Rec."Invoicing Item No.");

        DimMgt.AddDimSource(DefaultDimSource, Database::Item, ServiceObjectItemNo);

        "Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    internal procedure SetDefaultDimensionFromItem(ItemNo: Code[20])
    begin
        SetDefaultDimensionFromItem(ItemNo, true);
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
        VendorServiceCommitment: Record "Service Commitment";
    begin
        if Rec."Contract No." = '' then
            exit;
        if OldDimSetID = NewDimSetID then
            exit;
        VendorServiceCommitment.FilterOnServiceObjectAndPackage(Rec."Service Object No.", Rec.Template, Rec."Package Code", Enum::"Service Partner"::Vendor);
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
        Rec.SetRange("Service Object No.", ServiceObjectNo);
        Rec.SetRange(Template, ServiceTemplate);
    end;

    local procedure DeleteContractLine()
    var
        CustomerContractLine: Record "Customer Contract Line";
        VendorContractLine: Record "Vendor Contract Line";
    begin
        if not (Rec."Invoicing via" = Rec."Invoicing via"::Contract) then
            exit;

        case Partner of
            Enum::"Service Partner"::Customer:
                if CustomerContractLine.Get(Rec."Contract No.", Rec."Contract Line No.") then
                    if CustomerContractLine.Closed then
                        CustomerContractLine.Delete(false);

            Enum::"Service Partner"::Vendor:
                if VendorContractLine.Get(Rec."Contract No.", Rec."Contract Line No.") then
                    if VendorContractLine.Closed then
                        VendorContractLine.Delete(false);
        end;
    end;

    internal procedure FilterOnServiceObjectAndPackage(ServiceObjectNo: Code[20]; ServiceTemplate: Code[20]; PackageCode: Code[20]; ServicePartner: Enum "Service Partner")
    begin
        Rec.FilterOnServiceObjectAndTemplate(ServiceObjectNo, ServiceTemplate, ServicePartner);
        Rec.SetRange("Package Code", PackageCode);
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var ServiceCommitment: Record "Service Commitment"; xServiceCommitment: Record "Service Commitment"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var ServiceCommitment: Record "Service Commitment"; xServiceCommitment: Record "Service Commitment"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateDimensionSetID(var ServiceCommitment: Record "Service Commitment"; xServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterValidateDimensionSetID(var ServiceCommitment: Record "Service Commitment"; xServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyFromSalesServiceCommitment(var Rec: Record "Service Commitment"; SalesServiceCommitment: Record "Sales Service Commitment")
    begin
    end;

    procedure CopyFromSalesServiceCommitment(SalesServiceCommitment: Record "Sales Service Commitment")
    begin
        Rec."Package Code" := SalesServiceCommitment."Package Code";
        Rec.Template := SalesServiceCommitment.Template;
        Rec.Partner := SalesServiceCommitment.Partner;
        Rec.Description := SalesServiceCommitment.Description;
        Rec."Invoicing via" := SalesServiceCommitment."Invoicing via";
        Rec."Invoicing Item No." := SalesServiceCommitment."Item No.";
        Rec."Price" := SalesServiceCommitment."Price";
        Rec."Service Amount" := SalesServiceCommitment."Service Amount";
        Rec."Calculation Base Amount" := SalesServiceCommitment."Calculation Base Amount";
        Rec."Calculation Base %" := SalesServiceCommitment."Calculation Base %";
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
        OnAfterCopyFromSalesServiceCommitment(Rec, SalesServiceCommitment);
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

    local procedure IsDateLastDayOfMonth(ReferenceDate: Date): Boolean
    begin
        exit(ReferenceDate = CalcDate('<CM>', ReferenceDate));
    end;

    local procedure MoveDateToLastDayOfMonth(var ReferenceDate: Date)
    begin
        ReferenceDate := CalcDate('<CM>', ReferenceDate);
    end;

    local procedure RecalculateHarmonizedBillingFieldsOnCustomerContract()
    var
        CustomerContract: Record "Customer Contract";
    begin
        if Rec.IsPartnerVendor() then
            exit;
        if "Contract No." = '' then
            exit;
        CustomerContract.Get(Rec."Contract No.");
        CustomerContract.RecalculateHarmonizedBillingFieldsBasedOnNextBillingDate(0);
    end;

    internal procedure TestServiceCommitmentsCurrencyCode(var ServiceCommitment: Record "Service Commitment" temporary)
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
        ServiceCommitment: Record "Service Commitment";
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
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.FilterOnContract(PartnerType, ContractNo);
        UpdateCurrencyDataOnServiceCommitments(ServiceCommitment, CurrencyFactor, CurrencyFactorDate, CurrencyCode, true);
    end;

    internal procedure UpdateCurrencyDataOnServiceCommitments(var ServiceCommitment: Record "Service Commitment"; CurrencyFactor: Decimal; CurrencyFactorDate: Date; CurrencyCode: Code[10]; UpdateCurrencyCodeOnServiceCommitment: Boolean)
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
        Rec.SetRange("Contract No.", ContractNo);
    end;

    internal procedure SetCurrencyData(CurrencyFactor: Decimal; CurrencyFactorDate: Date; CurrencyCode: Code[10])
    begin
        Rec."Currency Factor" := CurrencyFactor;
        Rec."Currency Factor Date" := CurrencyFactorDate;
        Rec."Currency Code" := CurrencyCode;
    end;

    internal procedure IsClosed(): Boolean
    var
        CustomerContractLine: Record "Customer Contract Line";
        VendorContractLine: Record "Vendor Contract Line";
    begin
        if Rec."Contract No." = '' then
            exit;
        if Rec."Contract Line No." = 0 then
            exit;
        case Partner of
            Enum::"Service Partner"::Customer:
                begin
                    CustomerContractLine.Get(Rec."Contract No.", Rec."Contract Line No.");
                    exit(CustomerContractLine.Closed);
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    VendorContractLine.Get(Rec."Contract No.", Rec."Contract Line No.");
                    exit(VendorContractLine.Closed);
                end;
        end;
    end;

    internal procedure ErrorIfBillingLineForServiceCommitmentExist()
    begin
        if BillingLineExists() then
            Error(BillingLineForServiceCommitmentExistErr);
    end;

    internal procedure GetPartnerNoFromContract(): Code[20]
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
    begin
        case Rec.Partner of
            Rec.Partner::Customer:
                begin
                    CustomerContract.Get(Rec."Contract No.");
                    exit(CustomerContract."Sell-to Customer No.");
                end;
            Rec.Partner::Vendor:
                begin
                    VendorContract.Get(Rec."Contract No.");
                    exit(VendorContract."Buy-from Vendor No.");
                end;
        end;
    end;

    internal procedure ErrorIfBillingLineArchiveForServiceCommitmentExist()
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        BillingLineArchive.FilterBillingLineArchiveOnServiceCommitment(Rec."Entry No.");
        BillingLineArchive.CalcSums("Service Amount");
        if BillingLineArchive."Service Amount" <> 0 then
            Error(BillingLineArchiveForServiceCommitmentExistErr);
    end;

    internal procedure ArchiveServiceCommitment()
    begin
        ArchiveServiceCommitment(0D, "Type Of Price Update"::None);
    end;

    internal procedure ArchiveServiceCommitment(PerformUpdateOn: Date; TypeOfPriceUpdate: Enum "Type Of Price Update")
    var
        ServiceCommitmentArchive: Record "Service Commitment Archive";
    begin
        if SkipArchiving then
            exit;

        xRec.Get(Rec."Entry No."); //Modify trigger has changed value in xRec.
        if (xRec."Calculation Base %" <> Rec."Calculation Base %") or
            (xRec."Calculation Base Amount" <> Rec."Calculation Base Amount") or
            (xRec.Price <> Rec.Price) or
            (xRec."Discount %" <> Rec."Discount %") or
            (xRec."Discount Amount" <> Rec."Discount Amount") or
            (xRec."Service Amount" <> Rec."Service Amount") or
            (xRec."Billing Base Period" <> Rec."Billing Base Period") or
            (xRec."Billing Rhythm" <> Rec."Billing Rhythm")
        then
            CreateServiceCommitmentArchive(ServiceCommitmentArchive, xRec, PerformUpdateOn, TypeOfPriceUpdate);
    end;

    internal procedure ArchiveServiceCommitmentFromServiceObject(xServiceObject: Record "Service Object"; ServiceObject: Record "Service Object")
    var
        ServiceCommitmentArchive: Record "Service Commitment Archive";
    begin
        if (xServiceObject."Quantity Decimal" <> ServiceObject."Quantity Decimal") or
           (xServiceObject."Serial No." <> ServiceObject."Serial No.")
        then begin
            CreateServiceCommitmentArchive(ServiceCommitmentArchive, Rec, 0D, "Type Of Price Update"::None);
            ServiceCommitmentArchive."Quantity Decimal (Service Ob.)" := xServiceObject."Quantity Decimal";
            ServiceCommitmentArchive."Serial No. (Service Object)" := xServiceObject."Serial No.";
            ServiceCommitmentArchive.Modify(false);
        end;
    end;

    internal procedure CreateServiceCommitmentArchive(var ServiceCommitmentArchive: Record "Service Commitment Archive"; xServiceCommitment: Record "Service Commitment"; PerformUpdateOn: Date; TypeOfPriceUpdate: Enum "Type Of Price Update")
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

    local procedure FindServiceCommitmentArchiveCreatedInLessThanMinute(var ServiceCommitmentArchive: Record "Service Commitment Archive"): Boolean
    begin
        ServiceCommitmentArchive.FilterOnServiceCommitment(Rec."Entry No.");
        ServiceCommitmentArchive.SetRange(SystemModifiedAt, CurrentDateTime - 60000, CurrentDateTime);
        exit(ServiceCommitmentArchive.FindLast());
    end;

    internal procedure GetTotalServiceAmountFromVendContractLines(var VendorContractLine: Record "Vendor Contract Line") TotalServiceAmount: Decimal
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        if VendorContractLine.FindSet() then
            repeat
                VendorContractLine.GetServiceCommitment(ServiceCommitment);
                TotalServiceAmount += ServiceCommitment."Service Amount";
            until VendorContractLine.Next() = 0;
    end;

    internal procedure GetTotalServiceAmountFromCustContractLines(var CustomerContractLine: Record "Customer Contract Line") TotalServiceAmount: Decimal
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.GetServiceCommitment(ServiceCommitment);
                TotalServiceAmount += ServiceCommitment."Service Amount";
            until CustomerContractLine.Next() = 0;
    end;

    internal procedure IsPartnerCustomer(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Customer);
    end;

    internal procedure IsPartnerVendor(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Vendor);
    end;

    procedure CalculateCalculationBaseAmount()
    var
        ServiceObject: Record "Service Object";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        ContractsItemManagement: Codeunit "Contracts Item Management";
    begin
        ServiceObject.Get(Rec."Service Object No.");
        case Rec.Partner of
            "Service Partner"::Customer:
                begin
                    ContractsItemManagement.CreateTempSalesHeader(TempSalesHeader, TempSalesHeader."Document Type"::Order, ServiceObject."End-User Customer No.", ServiceObject."Bill-to Customer No.", Rec."Service Start Date", Rec."Currency Code");
                    ContractsItemManagement.CreateTempSalesLine(TempSalesLine, TempSalesHeader, ServiceObject."Item No.", ServiceObject."Quantity Decimal", Rec."Service Start Date");
                    Rec."Calculation Base Amount" := ContractsItemManagement.CalculateUnitPrice(TempSalesHeader, TempSalesLine);
                end;
            "Service Partner"::Vendor:
                Rec."Calculation Base Amount" := ContractsItemManagement.CalculateUnitCost(ServiceObject."Item No.");
        end;
    end;

    local procedure RefresheRenewalTerm()
    var
        BlankDateFormula: DateFormula;
    begin
        if Rec."Service End Date" = 0D then
            Rec.Validate("Renewal Term", BlankDateFormula)
        else
            if Rec."Renewal Term" = BlankDateFormula then
                Rec.Validate("Renewal Term", "Initial Term");
    end;

    local procedure ErrorIfPlannedServiceCommitmentExists()
    var
        PlannedServiceCommitmentExistsErr: Label 'The Service End Date cannot be changed as long as there is a Planned Service Commitment.';
    begin
        if not Rec."Planned Serv. Comm. exists" then
            Rec.CalcFields("Planned Serv. Comm. exists");
        if "Planned Serv. Comm. exists" then
            Error(PlannedServiceCommitmentExistsErr);
    end;

    internal procedure IsFullyInvoiced(): Boolean
    begin
        if Rec.BillingLineExists() then
            exit(false);
        if (Rec."Next Billing Date" = 0D) then
            exit(false);

        exit(Rec."Service End Date" = CalcDate('<-1D>', Rec."Next Billing Date"));
    end;

    procedure SetSkipArchiving(NewSkipArchiving: Boolean)
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
                BillingLineArchive."Service Object No." := '';
                BillingLineArchive."Service Commitment Entry No." := 0;
                BillingLineArchive.Modify(false);
            until BillingLineArchive.Next() = 0;
    end;

    local procedure UpdateNextPriceUpdate()
    begin
        if Format(Rec."Price Binding Period") = '' then
            exit;
        Rec."Next Price Update" := CalcDate(Rec."Price Binding Period", Rec."Service Start Date");
    end;

    procedure SetSkipTestPackageCode(NewSkipTestPackageCode: Boolean)
    begin
        SkipTestPackageCode := NewSkipTestPackageCode;
    end;

    internal procedure ModifyExcludeFromPriceUpdateInAllRelatedServiceCommitments(ServicePartner: Enum "Service Partner"; ContractNo: Code[20];
                                                                                                      NewExcludeFromPriceUpdate: Boolean)
    var
        ServiceCommitment: Record "Service Commitment";
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

    internal procedure MarkOpenServiceCommitments()
    begin
        if Rec.FindSet() then begin
            repeat
                if Rec.IsClosed() then
                    Rec.Mark(false)
                else
                    Rec.Mark(true)
            until Rec.Next() = 0;
            Rec.MarkedOnly(true);
        end;
    end;

    internal procedure DeleteContractPriceUpdateLines()
    var
        ContractPriceUpdateLine: Record "Contract Price Update Line";
    begin
        ContractPriceUpdateLine.FilterOnServiceCommitment(Rec."Entry No.");
        ContractPriceUpdateLine.DeleteAll(false);
    end;

    internal procedure UpdateServiceCommitmentFromContractPriceUpdateLine(ContractPriceUpdateLine: Record "Contract Price Update Line")
    var
        ServiceCommitmentArchive: Record "Service Commitment Archive";
        xServiceCommitment: Record "Service Commitment";
        PriceUpdateTemplate: Record "Price Update Template";
    begin
        xServiceCommitment := Rec;
        Rec.Validate("Calculation Base %", ContractPriceUpdateLine."New Calculation Base %");
        Rec.Validate("Calculation Base Amount", ContractPriceUpdateLine."New Calculation Base");
        Rec.Validate(Price, ContractPriceUpdateLine."New Price");
        Rec.Validate("Service Amount", ContractPriceUpdateLine."New Service Amount");
        Rec."Next Price Update" := ContractPriceUpdateLine."Next Price Update";
        if PriceUpdateTemplate.Get(ContractPriceUpdateLine."Price Update Template Code") then
            Rec."Price Binding Period" := PriceUpdateTemplate."Price Binding Period";

        //Archiving has to be skipped in OnModify trigger and called afterward in order to set proper Type of Price Update
        Rec.SetSkipArchiving(true);
        Rec.Modify(true);
        Rec.SetSkipArchiving(false);
        Rec.CreateServiceCommitmentArchive(ServiceCommitmentArchive, xServiceCommitment, CalcDate('<-1D>', ContractPriceUpdateLine."Perform Update On"), Enum::"Type Of Price Update"::"Price Update");
    end;

    internal procedure ServiceCommitmentArchiveExistsForPeriodExists(var ServiceCommitmentArchive: Record "Service Commitment Archive"; RecurringBillingfrom: Date; RecurringBillingto: Date): Boolean
    begin
        ServiceCommitmentArchive.SetCurrentKey("Entry No.");
        ServiceCommitmentArchive.SetAscending("Entry No.", true);
        ServiceCommitmentArchive.SetRange("Service Object No.", Rec."Service Object No.");
        ServiceCommitmentArchive.SetRange("Original Entry No.", Rec."Entry No.");
        ServiceCommitmentArchive.SetRange("Perform Update On", RecurringBillingfrom, RecurringBillingto);
        ServiceCommitmentArchive.SetRange("Type Of Update", Enum::"Type Of Price Update"::"Price Update");
        exit(ServiceCommitmentArchive.FindLast());
    end;

    internal procedure UpdateServiceCommitmentFromServiceCommitmentArchive(ServiceCommitmentArchive: Record "Service Commitment Archive")
    begin
        Rec.Price := ServiceCommitmentArchive.Price;
        Rec."Calculation Base %" := ServiceCommitmentArchive."Calculation Base %";
        Rec."Calculation Base Amount" := ServiceCommitmentArchive."Calculation Base Amount";
        Rec."Service Amount" := ServiceCommitmentArchive."Service Amount";
        Rec."Discount Amount" := ServiceCommitmentArchive."Discount Amount";
        Rec."Discount %" := ServiceCommitmentArchive."Discount %";
        Rec."Price (LCY)" := ServiceCommitmentArchive."Price (LCY)";
        Rec."Calculation Base Amount (LCY)" := ServiceCommitmentArchive."Calculation Base Amount (LCY)";
        Rec."Service Amount (LCY)" := ServiceCommitmentArchive."Service Amount (LCY)";
        Rec."Discount Amount (LCY)" := ServiceCommitmentArchive."Discount Amount (LCY)";
        Rec."Next Price Update" := ServiceCommitmentArchive."Next Price Update";
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
        BillingLine.FilterBillingLineOnContractLine(Rec.Partner, Rec."Contract No.", Rec."Contract Line No.");
        BillingLine.SetRange("Document Type", "Rec. Billing Document Type"::Invoice, "Rec. Billing Document Type"::"Credit Memo");
        exit(not BillingLine.IsEmpty());
    end;

    internal procedure BillingLineExists(): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnContractLine(Rec.Partner, Rec."Contract No.", Rec."Contract Line No.");
        exit(not BillingLine.IsEmpty());
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateNextBillingDate(var ServiceCommitment: Record "Service Commitment"; LastBillingToDate: Date)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCalculateServiceAmount(var ServiceCommitment: Record "Service Commitment"; CalledByFieldNo: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateServiceCommitment(var ServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterGetCombinedDimensionSetID(var ServiceCommitment: Record "Service Commitment")
    begin
    end;

}