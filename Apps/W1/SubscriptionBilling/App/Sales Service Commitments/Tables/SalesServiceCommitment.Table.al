namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.Finance.Currency;
using Microsoft.Finance.SalesTax;
table 8068 "Sales Service Commitment"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Service Commitment';
    DrillDownPageId = "Sales Service Commitments";
    LookupPageId = "Sales Service Commitments";
    Access = Internal;

    fields
    {
        field(1; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Sales Header"."No." where("Document Type" = field("Document Type"));
        }
        field(3; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            AutoIncrement = true;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            Editable = false;

            trigger OnValidate()
            begin
                if Rec."Invoicing via" = Rec."Invoicing via"::Contract then
                    TestField("Item No.");
            end;
        }
        field(11; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Line".Description where("Document Type" = field("Document Type"), "Document No." = field("Document No."), "Line No." = field("Document Line No.")));
            Editable = false;
        }
        field(12; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
            Editable = false;
        }
        field(13; Description; Text[100])
        {
            Caption = 'Description';
            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
            end;
        }
        field(14; "Calculation Base Type"; Enum "Calculation Base Type")
        {
            Caption = 'Calculation Base Type';
            Editable = false;

            trigger OnValidate()
            var
                ServiceCommPackageLine: Record "Service Comm. Package Line";
            begin
                ServiceCommPackageLine.CheckCalculationBaseTypeAgainstVendorError(Partner, "Calculation Base Type");
            end;
        }
        field(15; "Calculation Base Amount"; Decimal)
        {
            Caption = 'Calculation Base Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 2;

            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
                CalculatePrice();
            end;
        }
        field(16; "Calculation Base %"; Decimal)
        {
            Caption = 'Calculation Base %';
            MinValue = 0;
            BlankZero = true;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
                CalculatePrice();
            end;
        }
        field(17; "Price"; Decimal)
        {
            Caption = 'Price';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;

            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
            begin
                GetSalesHeader(SalesHeader);
                Currency.Initialize(SalesHeader."Currency Code");
                "Price" := Round("Price", Currency."Unit-Amount Rounding Precision");
                TestIfSalesOrderIsReleased();
                Validate("Discount %");
            end;
        }
        field(18; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            MinValue = 0;
            MaxValue = 100;
            BlankZero = true;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CalculateServiceAmount(FieldNo("Discount %"));
            end;
        }
        field(19; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 1;

            trigger OnValidate()
            begin
                CalculateServiceAmount(FieldNo("Discount Amount"));
            end;
        }
        field(20; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
            BlankZero = true;
            AutoFormatType = 1;

            trigger OnValidate()
            begin
                CalculateServiceAmount(FieldNo("Service Amount"));
            end;
        }
        field(21; "Service Comm. Start Formula"; DateFormula)
        {
            Caption = 'Service Commitment Start Formula';
            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
            end;
        }
        field(22; "Agreed Serv. Comm. Start Date"; Date)
        {
            Caption = 'Agreed Serv. Comm. Start Date';
        }
        field(23; "Initial Term"; DateFormula)
        {
            Caption = 'Initial Term';
            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
                DateFormulaManagement.ErrorIfDateFormulaNegative("Initial Term");
            end;
        }
        field(24; "Notice Period"; DateFormula)
        {
            Caption = 'Notice Period';
            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
                DateFormulaManagement.ErrorIfDateFormulaNegative("Notice Period");
            end;
        }
        field(25; "Extension Term"; DateFormula)
        {
            Caption = 'Subsequent Term';
            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
                if Format("Extension Term") = '' then
                    TestField("Notice Period", "Extension Term");
                DateFormulaManagement.ErrorIfDateFormulaNegative("Extension Term");
            end;
        }
        field(26; "Billing Base Period"; DateFormula)
        {
            Caption = 'Billing Base Period';
            Editable = false;

            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
                DateFormulaManagement.ErrorIfDateFormulaEmpty("Billing Base Period", FieldCaption("Billing Base Period"));
                DateFormulaManagement.ErrorIfDateFormulaNegative("Billing Base Period");
            end;
        }
        field(27; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
            Editable = false;

            trigger OnValidate()
            begin
                TestIfSalesOrderIsReleased();
                DateFormulaManagement.ErrorIfDateFormulaEmpty("Billing Rhythm", FieldCaption("Billing Rhythm"));
                DateFormulaManagement.ErrorIfDateFormulaNegative("Billing Rhythm");
            end;
        }
        field(28; "Invoicing via"; Enum "Invoicing Via")
        {
            Caption = 'Invoicing via';
            Editable = false;
        }
        field(30; Template; Code[20])
        {
            Caption = 'Template';
            TableRelation = "Service Commitment Template";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(31; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            TableRelation = "Service Commitment Package";
            Editable = false;
            trigger OnValidate()
            var
                ServiceCommitmentTemplate: Record "Service Commitment Template";
            begin
                if ServiceCommitmentTemplate.Get(Template) then begin
                    Rec."Usage Based Billing" := ServiceCommitmentTemplate."Usage Based Billing";
                    Rec."Usage Based Pricing" := ServiceCommitmentTemplate."Usage Based Pricing";
                    Rec."Pricing Unit Cost Surcharge %" := ServiceCommitmentTemplate."Pricing Unit Cost Surcharge %";
                    Rec.Modify(false);
                end;
            end;
        }
        field(32; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(33; Discount; Boolean)
        {
            Caption = 'Discount';
            Editable = false;
        }
        field(50; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            Editable = false;
            TableRelation = "Service Object";
        }
        field(51; "Service Commitment Entry No."; Integer)
        {
            Caption = 'Service Commitment Entry No.';
            Editable = false;
            TableRelation = "Service Commitment"."Entry No.";
        }
        field(54; "Price Binding Period"; DateFormula)
        {
            Caption = 'Price Binding Period';
        }
        field(59; "Period Calculation"; enum "Period Calculation")
        {
            Caption = 'Period Calculation';
        }
        field(60; "Linked to No."; Code[20])
        {
            Caption = 'Linked to No.';
            Editable = false;
        }
        field(61; "Linked to Line No."; Integer)
        {
            Caption = 'Linked to Line No.';
            Editable = false;
        }
        field(62; Process; Enum Process)
        {
            Caption = 'Process';
            Editable = false;
            trigger OnValidate()
            begin
                UpdateHeaderFromContractRenewal();
            end;

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
        key(PK; "Line No.")
        {
            Clustered = true;
        }
        key(SK1; "Document Type", "Document No.", "Document Line No.", "Package Code")
        {
        }
    }

    trigger OnModify()
    begin
        TestIfSalesOrderIsReleased();
        xRec.Get(xRec."Line No.");
        if ((xRec."Billing Base Period" <> Rec."Billing Base Period") or (xRec."Billing Rhythm" <> Rec."Billing Rhythm")) then
            DateFormulaManagement.CheckIntegerRatioForDateFormulas("Billing Base Period", FieldCaption("Billing Base Period"), "Billing Rhythm", FieldCaption("Billing Rhythm"));
    end;

    trigger OnDelete()
    var
        SalesServiceCommitmentCannotBeDeletedErr: Label 'The Sales Service Commitment cannot be deleted, because it is the last line with Process Contract Renewal. Please delete the Sales line in order to delete the Sales Service Commitment.';
    begin
        TestIfSalesOrderIsReleased();
        if Rec.IsOnlyRemainingLineForContractRenewalInDocument() then
            Error(SalesServiceCommitmentCannotBeDeletedErr);
    end;

    local procedure TestIfSalesOrderIsReleased()
    var
        SalesHeader: Record "Sales Header";
    begin
        GetSalesHeader(SalesHeader);
        if not SalesHeader.TestStatusIsNotReleased() then
            Error(ReleasedSalesOrderExistsErr);
    end;

    internal procedure FilterOnSalesLine(SourceSalesLine: Record "Sales Line")
    begin
        Rec.SetRange("Document Type", SourceSalesLine."Document Type");
        Rec.SetRange("Document No.", SourceSalesLine."Document No.");
        Rec.SetRange("Document Line No.", SourceSalesLine."Line No.");
    end;

    internal procedure InitRecord(SourceSalesLine: Record "Sales Line")
    begin
        Rec.Init();
        SetDocumentFields(SourceSalesLine."Document Type", SourceSalesLine."Document No.", SourceSalesLine."Line No.");
        Rec."Line No." := 0;
    end;

    internal procedure SetDocumentFields(DocType: Enum "Sales Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    begin
        Rec."Document Type" := DocType;
        Rec."Document No." := DocNo;
        Rec."Document Line No." := DocLineNo;
    end;

    local procedure CalculateServiceAmount(CalledByFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
        MaxServiceAmount: Decimal;
    begin
        TestIfSalesOrderIsReleased();
        GetSalesHeader(SalesHeader);
        SalesLine.Get("Document Type", "Document No.", "Document Line No.");

        MaxServiceAmount := Round((Price * SalesLine.Quantity), Currency."Amount Rounding Precision");
        if CalledByFieldNo = FieldNo("Service Amount") then begin
            "Service Amount" := Round("Service Amount", Currency."Amount Rounding Precision");
            if "Service Amount" > MaxServiceAmount then
                Error(ServiceAmountIncreaseErr, FieldCaption("Service Amount"), Format(MaxServiceAmount));
            "Discount Amount" := Round(MaxServiceAmount - "Service Amount", Currency."Amount Rounding Precision");
            "Discount %" := Round(100 - ("Service Amount" / MaxServiceAmount * 100), 0.00001);
        end else begin
            "Service Amount" := Round((Price * SalesLine.Quantity), Currency."Amount Rounding Precision");
            if CalledByFieldNo = FieldNo("Discount %") then
                "Discount Amount" := Round("Service Amount" * "Discount %" / 100, Currency."Amount Rounding Precision");
            if CalledByFieldNo = FieldNo("Discount Amount") then
                "Discount %" := Round("Discount Amount" / "Service Amount" * 100, 0.00001);
            "Service Amount" := Round((Price * SalesLine.Quantity) - "Discount Amount", Currency."Amount Rounding Precision");
            if "Service Amount" > MaxServiceAmount then
                Error(ServiceAmountIncreaseErr, FieldCaption("Service Amount"), Format(MaxServiceAmount));
        end;
    end;

    procedure CalculateCalculationBaseAmount()
    begin
        SalesLine.Get("Document Type", "Document No.", "Document Line No.");
        if SalesLine.Type <> Enum::"Sales Line Type"::Item then
            exit;
        case Partner of
            Partner::Customer:
                CalculateCalculationBaseAmountCustomer();
            Partner::Vendor:
                CalculateCalculationBaseAmountVendor();
        end;
    end;

    local procedure CalculateCalculationBaseAmountCustomer()
    var
        TempSalesLine: Record "Sales Line" temporary;
        CalculatedBaseAmount: Decimal;
        IsHandled: Boolean;
    begin
        case "Calculation Base Type" of
            "Calculation Base Type"::"Item Price":
                begin
                    TempSalesLine := SalesLine;
                    TempSalesLine.UpdateUnitPrice(TempSalesLine.FieldNo("No."));
                    CalculatedBaseAmount := TempSalesLine."Unit Price";
                end;
            "Calculation Base Type"::"Document Price",
            "Calculation Base Type"::"Document Price And Discount":
                CalculatedBaseAmount := SalesLine."Unit Price";
            else begin
                IsHandled := false;
                OnCalculateBaseTypeElseCaseOnCalculateCalculationBaseAmountCustomer(Rec, SalesLine, CalculatedBaseAmount, IsHandled);
                if not IsHandled then
                    Error(CalculateBaseTypeOptionNotImplementedErr, Format("Calculation Base Type"), FieldCaption("Calculation Base Type"),
                                         Rec.TableCaption, CalculateCalculationBaseAmountCustomerProcedureNameLbl);
            end;
        end;
        Validate("Calculation Base Amount", CalculatedBaseAmount);
        if "Calculation Base Type" = "Calculation Base Type"::"Document Price And Discount" then
            Validate("Discount %", SalesLine."Line Discount %");
        Modify();
    end;

    local procedure CalculateCalculationBaseAmountVendor()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyDate: Date;
        CalculatedBaseAmount: Decimal;
        IsHandled: Boolean;
    begin
        case "Calculation Base Type" of
            "Calculation Base Type"::"Item Price":
                begin
                    SalesLine.TestField(Type, SalesLine.Type::Item);
                    Item.Get(SalesLine."No.");
                    CalculatedBaseAmount := Item."Last Direct Cost";
                    if SalesLine."Currency Code" <> '' then begin
                        GetSalesHeader(SalesHeader);
                        if SalesHeader."Posting Date" <> 0D then
                            CurrencyDate := SalesHeader."Posting Date"
                        else
                            CurrencyDate := WorkDate();
                        CalculatedBaseAmount := CurrExchRate.ExchangeAmtLCYToFCY(CurrencyDate, SalesHeader."Currency Code", CalculatedBaseAmount, SalesHeader."Currency Factor");
                    end;
                end;
            "Calculation Base Type"::"Document Price":
                CalculatedBaseAmount := SalesLine."Unit Cost";
            else begin
                IsHandled := false;
                OnCalculateBaseTypeElseCaseOnCalculateCalculationBaseAmountVendor(Rec, SalesLine, CalculatedBaseAmount, IsHandled);
                if not IsHandled then
                    Error(CalculateBaseTypeOptionNotImplementedErr, Format("Calculation Base Type"), FieldCaption("Calculation Base Type"),
                                                                    Rec.TableCaption, CalculateCalculationBaseAmountVendorProcedureNameLbl);
            end;
        end;
        Validate("Calculation Base Amount", CalculatedBaseAmount);
        Modify();
    end;

    local procedure CalculatePrice()
    begin
        if "Calculation Base Amount" <> 0 then begin
            if Discount then
                "Calculation Base Amount" := "Calculation Base Amount" * -1;
            Validate(Price, "Calculation Base Amount" * "Calculation Base %" / 100);
        end else
            Validate(Price, 0);
    end;

    procedure GetSalesHeader(var OutSalesHeader: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        TestField("Document No.");
        if ("Document Type" <> SalesHeader."Document Type") or ("Document No." <> SalesHeader."No.") then
            if SalesHeader.Get("Document Type", "Document No.") then
                if SalesHeader."Currency Code" = '' then
                    Currency.InitRoundingPrecision()
                else begin
                    SalesHeader.TestField("Currency Factor");
                    Currency.Get(SalesHeader."Currency Code");
                    Currency.TestField("Amount Rounding Precision");
                end
            else
                Clear(SalesHeader);

        OutSalesHeader := SalesHeader;
    end;

    internal procedure CalcVATAmountLines(var SalesHeader: Record "Sales Header"; var TempSalesServiceCommitmentBuff: Record "Sales Service Commitment Buff." temporary; var UniqueRhythmDictionary: Dictionary of [Code[20], Text])
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        BasePeriodCount: Integer;
        RhythmPeriodCount: Integer;
    begin
        BasePeriodCount := 1;
        RhythmPeriodCount := 1;

        if SalesHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(SalesHeader."Currency Code");

        TempSalesServiceCommitmentBuff.DeleteAll(false);

        SalesServiceCommitment.SetRange("Document Type", SalesHeader."Document Type");
        SalesServiceCommitment.SetRange("Document No.", SalesHeader."No.");
        SalesServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        SalesServiceCommitment.SetRange("Invoicing via", SalesServiceCommitment."Invoicing via"::Contract);
        if SalesServiceCommitment.Find('-') then
            repeat
                CreateTempSalesServiceCommitmentBuffForSalesServiceCommitment(SalesServiceCommitment, TempSalesServiceCommitmentBuff, UniqueRhythmDictionary, BasePeriodCount, RhythmPeriodCount);
            until SalesServiceCommitment.Next() = 0;

        if TempSalesServiceCommitmentBuff.Find('-') then
            repeat
                case TempSalesServiceCommitmentBuff."VAT Calculation Type" of
                    TempSalesServiceCommitmentBuff."VAT Calculation Type"::"Normal VAT",
                    TempSalesServiceCommitmentBuff."VAT Calculation Type"::"Reverse Charge VAT":
                        if SalesHeader."Prices Including VAT" then begin
                            TempSalesServiceCommitmentBuff."VAT Base" :=
                                Round(TempSalesServiceCommitmentBuff."Line Amount" / (1 + TempSalesServiceCommitmentBuff."VAT %" / 100), Currency."Amount Rounding Precision");
                            TempSalesServiceCommitmentBuff."VAT Amount" :=
                                Round(
                                    TempSalesServiceCommitmentBuff."Line Amount" - TempSalesServiceCommitmentBuff."VAT Base",
                                    Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                            TempSalesServiceCommitmentBuff."Amount Including VAT" := TempSalesServiceCommitmentBuff."VAT Base" + TempSalesServiceCommitmentBuff."VAT Amount";
                        end else begin
                            TempSalesServiceCommitmentBuff."VAT Base" := TempSalesServiceCommitmentBuff."Line Amount";
                            TempSalesServiceCommitmentBuff."VAT Amount" :=
                                Round(
                                    TempSalesServiceCommitmentBuff."VAT Base" * TempSalesServiceCommitmentBuff."VAT %" / 100,
                                    Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                            TempSalesServiceCommitmentBuff."Amount Including VAT" := TempSalesServiceCommitmentBuff."Line Amount" + TempSalesServiceCommitmentBuff."VAT Amount";
                        end;
                    TempSalesServiceCommitmentBuff."VAT Calculation Type"::"Full VAT":
                        begin
                            TempSalesServiceCommitmentBuff."VAT Base" := 0;
                            TempSalesServiceCommitmentBuff."VAT Amount" := TempSalesServiceCommitmentBuff."Line Amount";
                            TempSalesServiceCommitmentBuff."Amount Including VAT" := TempSalesServiceCommitmentBuff."VAT Amount";
                        end;
                    TempSalesServiceCommitmentBuff."VAT Calculation Type"::"Sales Tax":
                        begin
                            if SalesHeader."Prices Including VAT" then begin
                                TempSalesServiceCommitmentBuff."Amount Including VAT" := TempSalesServiceCommitmentBuff."Line Amount";
                                TempSalesServiceCommitmentBuff."VAT Base" :=
                                    Round(
                                        SalesTaxCalculate.ReverseCalculateTax(
                                            SalesHeader."Tax Area Code", TempSalesServiceCommitmentBuff."Tax Group Code", SalesHeader."Tax Liable",
                                            SalesHeader."Posting Date", TempSalesServiceCommitmentBuff."Amount Including VAT", TempSalesServiceCommitmentBuff.Quantity, SalesHeader."Currency Factor"),
                                    Currency."Amount Rounding Precision");
                                TempSalesServiceCommitmentBuff."VAT Amount" := TempSalesServiceCommitmentBuff."Amount Including VAT" - TempSalesServiceCommitmentBuff."VAT Base";
                            end else begin
                                TempSalesServiceCommitmentBuff."VAT Base" := TempSalesServiceCommitmentBuff."Line Amount";
                                TempSalesServiceCommitmentBuff."VAT Amount" :=
                                    SalesTaxCalculate.CalculateTax(
                                        SalesHeader."Tax Area Code", TempSalesServiceCommitmentBuff."Tax Group Code", SalesHeader."Tax Liable",
                                        SalesHeader."Posting Date", TempSalesServiceCommitmentBuff."VAT Base", TempSalesServiceCommitmentBuff.Quantity, SalesHeader."Currency Factor");
                                TempSalesServiceCommitmentBuff."VAT Amount" :=
                                    Round(TempSalesServiceCommitmentBuff."VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                                TempSalesServiceCommitmentBuff."Amount Including VAT" := TempSalesServiceCommitmentBuff."VAT Base" + TempSalesServiceCommitmentBuff."VAT Amount";
                            end;
                            if TempSalesServiceCommitmentBuff."VAT Base" = 0 then
                                TempSalesServiceCommitmentBuff."VAT %" := 0
                            else
                                TempSalesServiceCommitmentBuff."VAT %" := Round(100 * TempSalesServiceCommitmentBuff."VAT Amount" / TempSalesServiceCommitmentBuff."VAT Base", 0.00001);
                        end;
                end;
                TempSalesServiceCommitmentBuff.Modify(false);
            until TempSalesServiceCommitmentBuff.Next() = 0;
    end;

    local procedure CreateTempSalesServiceCommitmentBuffForSalesServiceCommitment(SalesServiceCommitment: Record "Sales Service Commitment";
                                                                 var TempSalesServiceCommitmentBuff: Record "Sales Service Commitment Buff." temporary;
                                                                 var UniqueRhythmDictionary: Dictionary of [Code[20], Text];
                                                                 var BasePeriodCount: Integer;
                                                                 var RhythmPeriodCount: Integer)
    var
        SalesLineVAT: Record "Sales Line";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
        DateFormulaManagement: Codeunit "Date Formula Management";
        IsHandled: Boolean;
        RhythmIdentifier: Code[20];
        ContractRenewalPriceCalculationRatio: Decimal;
        VatPercent: Decimal;
        DateFormulaType: Enum "Date Formula Type";
        ContractRenewalLbl: Label 'Contract Renewal';
        RhythmTextLbl: Label '%1 %2', Comment = '%1 = Billing Rhythm Period Count,%2 = Billing Rhythm Text';
        RhythmText: Text;
    begin
        OnBeforeCreateVATAmountLineForSalesServiceCommitment(SalesServiceCommitment, IsHandled);
        if IsHandled then
            exit;

        SalesLineVAT.Get(SalesServiceCommitment."Document Type", SalesServiceCommitment."Document No.", SalesServiceCommitment."Document Line No.");
        // Get Rhythm and Base period count
        if SalesLineVAT.IsContractRenewal() then begin
            ContractRenewalPriceCalculationRatio := DateFormulaManagement.CalculateRenewalTermRatioByBillingRhythm(SalesServiceCommitment."Agreed Serv. Comm. Start Date", SalesServiceCommitment."Initial Term", SalesServiceCommitment."Billing Rhythm");
            RhythmIdentifier := ContractRenewalMgt.GetContractRenewalIdentifierLabel();
            RhythmText := ContractRenewalLbl;
        end else begin
            DateFormulaType := DateFormulaManagement.FindDateFormulaTypeForComparison(SalesServiceCommitment."Billing Rhythm", RhythmPeriodCount);
            DateFormulaManagement.FindDateFormulaTypeForComparison(SalesServiceCommitment."Billing Base Period", BasePeriodCount);

            if (DateFormulaType = DateFormulaType::Quarter) or (DateFormulaType = DateFormulaType::Year) then
                DateFormulaType := DateFormulaType::Month;
            RhythmIdentifier := Format(RhythmPeriodCount) + Format(DateFormulaType);
        end;

        if not UniqueRhythmDictionary.ContainsKey(RhythmIdentifier) then begin
            if not SalesLineVAT.IsContractRenewal() then
                if ((RhythmPeriodCount > 1) and (DateFormulaType.AsInteger() <= Enum::"Date Formula Type"::Year.AsInteger())) then
                    // Use plural for more then 1
                    RhythmText := StrSubstNo(RhythmTextLbl, RhythmPeriodCount, Enum::"Date Formula Type".FromInteger((DateFormulaType.AsInteger() + 100)))
                else
                    RhythmText := Format(DateFormulaType);
            UniqueRhythmDictionary.Add(RhythmIdentifier, RhythmText);
        end;

        if (SalesLineVAT.Type <> Enum::"Sales Line Type"::" ") and (SalesLineVAT.Quantity <> 0) then begin
            if SalesLineVAT."VAT Calculation Type" in
               [SalesLineVAT."VAT Calculation Type"::"Reverse Charge VAT", SalesLineVAT."VAT Calculation Type"::"Sales Tax"]
            then
                VatPercent := 0
            else
                VatPercent := SalesLineVAT."VAT %";
            TempSalesServiceCommitmentBuff.Reset();
            TempSalesServiceCommitmentBuff.SetRange("Rhythm Identifier", RhythmIdentifier);
            TempSalesServiceCommitmentBuff.SetRange("VAT Calculation Type", SalesLineVAT."VAT Calculation Type");
            TempSalesServiceCommitmentBuff.SetRange("VAT %", VatPercent);
            TempSalesServiceCommitmentBuff.SetRange("Tax Group Code", SalesLineVAT."Tax Group Code");
            if TempSalesServiceCommitmentBuff.IsEmpty() then begin
                TempSalesServiceCommitmentBuff."Entry No." := TempSalesServiceCommitmentBuff.GetNextEntryNo();
                TempSalesServiceCommitmentBuff.Init();
                TempSalesServiceCommitmentBuff."Rhythm Identifier" := RhythmIdentifier;
                TempSalesServiceCommitmentBuff."VAT Calculation Type" := SalesLineVAT."VAT Calculation Type";
                TempSalesServiceCommitmentBuff."Tax Group Code" := SalesLineVAT."Tax Group Code";
                TempSalesServiceCommitmentBuff."VAT %" := VatPercent;
                TempSalesServiceCommitmentBuff.Insert(false);
            end;
            TempSalesServiceCommitmentBuff.Reset();
            TempSalesServiceCommitmentBuff.Quantity += SalesLineVAT."Quantity (Base)";
            if SalesLineVAT.IsContractRenewal() then
                TempSalesServiceCommitmentBuff."Line Amount" += SalesServiceCommitment."Service Amount" * ContractRenewalPriceCalculationRatio
            else
                TempSalesServiceCommitmentBuff."Line Amount" += SalesServiceCommitment."Service Amount" / BasePeriodCount * RhythmPeriodCount;
            TempSalesServiceCommitmentBuff.Modify(false);
        end;
    end;

    internal procedure IsOnlyRemainingLineForContractRenewalInDocument(): Boolean
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
    begin
        if Process <> Process::"Contract Renewal" then
            exit(false);

        SalesServiceCommitment.SetRange("Document Type", Rec."Document Type");
        SalesServiceCommitment.SetRange("Document No.", Rec."Document No.");
        SalesServiceCommitment.SetRange(Process, Process::"Contract Renewal");
        SalesServiceCommitment.SetFilter("Line No.", '<>%1', Rec."Line No.");
        exit(SalesServiceCommitment.IsEmpty());
    end;

    local procedure UpdateHeaderFromContractRenewal()
    begin
        if not (Rec."Document Type" in [Rec."Document Type"::Quote, Rec."Document Type"::Order]) then
            FieldError(Rec."Document Type");
        SalesLine.Get(Rec."Document Type", Rec."Document No.", Rec."Document Line No.");
        SalesLine.SetExcludeFromDocTotal();
        SalesLine.UpdateUnitPrice(FieldNo(Rec.Process));
    end;

    [InternalEvent(false, false)]
    local procedure OnCalculateBaseTypeElseCaseOnCalculateCalculationBaseAmountCustomer(SalesServiceCommitment: Record "Sales Service Commitment"; SalesLine: Record "Sales Line"; var CalculatedBaseAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCalculateBaseTypeElseCaseOnCalculateCalculationBaseAmountVendor(SalesServiceCommitment: Record "Sales Service Commitment"; SalesLine: Record "Sales Line"; var CalculatedBaseAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateVATAmountLineForSalesServiceCommitment(SalesServiceCommitment: Record "Sales Service Commitment"; var IsHandled: Boolean)
    begin
    end;

    var
        Currency: Record Currency;
        SalesLine: Record "Sales Line";
        DateFormulaManagement: Codeunit "Date Formula Management";
        ServiceAmountIncreaseErr: Label '%1 cannot be greater than %2.', Comment = '%1 and %2 are numbers';
        ReleasedSalesOrderExistsErr: Label 'Service commitments cannot be edited on orders with status = Released.';
        CalculateBaseTypeOptionNotImplementedErr: Label 'Unknown option %1 for %2.\\ Object Name: %3, Procedure: %4', Comment = '%1=Format("Calculation Base Type"), %2 = Fieldcaption for "Calculation Base Type", %3 = Current object name, %4 = Current procedure name';
        CalculateCalculationBaseAmountVendorProcedureNameLbl: Label 'CalculateCalculationBaseAmountVendor', Locked = true;
        CalculateCalculationBaseAmountCustomerProcedureNameLbl: Label 'CalculateCalculationBaseAmountCustomer', Locked = true;
}
