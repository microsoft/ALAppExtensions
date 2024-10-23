namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;

codeunit 8026 "Process Usage Data Billing"
{
    Access = Internal;
    TableNo = "Usage Data Import";

    trigger OnRun()
    begin
        UsageDataImport.Copy(Rec);
        Code();
        Rec := UsageDataImport;
    end;

    local procedure Code()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        OnBeforeProcessUsageDataBilling(UsageDataImport);
        if UsageDataImport."Processing Status" = Enum::"Processing Status"::Closed then
            exit;
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBilling.SetRange("Document No.", '');
        UsageDataBilling.SetFilter("Contract No.", '<>%1', '');
        if UsageDataBilling.FindSet(true) then
            repeat
                case UsageDataBilling.Partner of
                    "Service Partner"::Customer:
                        begin
                            CalculateCustomerUsageDataBillingPrice(UsageDataBilling);
                            ProcessCustomerContractLineAndConnectedServiceCommitment(UsageDataBilling);
                            HandleGracePeriod(UsageDataBilling);
                        end;
                    "Service Partner"::Vendor:
                        ProcessVendorContractLineAndConnectedServiceCommitment(UsageDataBilling);
                end;
            until UsageDataBilling.Next() = 0
        else begin
            UsageDataBilling.SetRange("Contract No.");
            if UsageDataBilling.FindFirst() then begin
                UsageDataImport.SetErrorReason(StrSubstNo(NoContractFoundInUsageDataBillingErr, UsageDataBilling."Service Object No.", UsageDataImport."Processing Step"));
                UsageDataBilling.SetReason(StrSubstNo(NoContractFoundInUsageDataBillingErr, UsageDataBilling."Service Object No.", UsageDataImport."Processing Step"));
                UsageDataBilling."Processing Status" := Enum::"Processing Status"::Error;
                UsageDataBilling.Modify(false);
            end
            else
                UsageDataImport.SetErrorReason(StrSubstNo(DoesNotExistErr, UsageDataImport."Processing Step"));
            UsageDataImport.Modify(false);
        end;
        OnAfterProcessUsageDataBilling(UsageDataImport);
    end;

    local procedure CalculateCustomerUsageDataBillingPrice(var UsageDataBilling: Record "Usage Data Billing")
    var
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CustomerContract: Record "Customer Contract";
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        IsHandled: Boolean;
        Amount: Decimal;
        UnitPrice: Decimal;
    begin
        if not UsageDataBilling.IsPartnerCustomer() then
            exit;
        GetCustomerContractData(CustomerContract, CustomerContractLine, ServiceCommitment, UsageDataBilling);
        SetCurrency(Currency, UsageDataBilling."Currency Code");
        UsageDataSupplier.Get(UsageDataImport."Supplier No.");

        if UsageDataSupplier."Unit Price from Import" then begin
            UnitPrice := UsageDataBilling."Unit Price";
            Amount := UsageDataBilling.Amount;
        end else
            case UsageDataBilling."Usage Base Pricing" of
                "Usage Based Pricing"::"Usage Quantity":
                    begin
                        Amount := ServiceCommitment."Service Amount";
                        ServiceObject.Get(ServiceCommitment."Service Object No.");
                        ContractItemMgt.GetSalesPriceForItem(UnitPrice, ServiceObject."Item No.", Abs(UsageDataBilling.Quantity), CustomerContract."Currency Code", CustomerContract."Sell-to Customer No.", CustomerContract."Bill-to Customer No.");
                        Amount := UnitPrice * Abs(UsageDataBilling.Quantity);
                        CalculateProRatedAmount(Amount, UnitPrice, ServiceCommitment, UsageDataBilling, CurrencyExchangeRate, Abs(UsageDataBilling.Quantity));
                    end;
                "Usage Based Pricing"::"Fixed Quantity":
                    begin
                        Amount := ServiceCommitment."Service Amount";
                        CalculateProRatedAmount(Amount, UnitPrice, ServiceCommitment, UsageDataBilling, CurrencyExchangeRate, Abs(UsageDataBilling.Quantity));
                    end;
                "Usage Based Pricing"::"Unit Cost Surcharge":
                    begin
                        UnitPrice := UsageDataBilling."Unit Cost" * (1 + UsageDataBilling."Pricing Unit Cost Surcharge %" / 100);
                        Amount := UnitPrice * UsageDataBilling.Quantity;
                    end;
                else begin
                    IsHandled := false;
                    OnUsageBasedPricingElseCaseOnCalculateCustomerUsageDataBillingPrice(UnitPrice, Amount, UsageDataBilling, CustomerContract, IsHandled);
                    if not IsHandled then
                        Error(UsageBasedPricingOptionNotImplementedErr, Format(ServiceCommitment."Usage Based Pricing"), ServiceCommitment.FieldCaption("Usage Based Pricing"), CodeunitObjectLbl,
                                                                        CurrentCodeunitNameLbl, CalculateCustomerUsageDataBillingPriceProcedureNameLbl);
                end;

            end;

        if UsageDataBilling.Amount <> Round(Amount, Currency."Unit-Amount Rounding Precision") then begin
            UsageDataBilling."Unit Price" := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
            UsageDataBilling.Amount := Round(Amount, Currency."Unit-Amount Rounding Precision");
            if UsageDataBilling.Quantity < 0 then
                UsageDataBilling.Amount *= -1;
            UsageDataBilling.Modify(true);
        end;
    end;

    local procedure ProcessServiceCommitment(var ServiceCommitment: Record "Service Commitment")
    var
        ServiceObject: Record "Service Object";
        LastUsageDataBilling: Record "Usage Data Billing";
        NewServiceObjectQuantity: Decimal;
        ChargeDate: Date;
        CurrencyCode: Code[10];
        UnitPrice: Decimal;
        UnitCost: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeProcessServiceCommitment(ServiceCommitment);

        ServiceObject.Get(ServiceCommitment."Service Object No.");
        NewServiceObjectQuantity := ServiceObject."Quantity Decimal";
        UnitPrice := ServiceCommitment.Price;

        FindUsageDataBilling(LastUsageDataBilling, false, ServiceCommitment);
        CurrencyCode := LastUsageDataBilling."Currency Code";
        ChargeDate := CalculateChargeDateFromLastUsageDataBilling(LastUsageDataBilling);

        case ServiceCommitment."Usage Based Pricing" of
            "Usage Based Pricing"::"Usage Quantity":
                begin
                    NewServiceObjectQuantity := CalculateTotalUsageBillingQuantity(LastUsageDataBilling, ServiceCommitment);
                    if ServiceCommitment.Partner = Enum::"Service Partner"::Vendor then
                        UnitCost := CalculateSumCostAmountFromUsageDataBilling(ServiceCommitment) / NewServiceObjectQuantity
                    else
                        UnitPrice := CalculateSumAmountFromUsageDataBilling(ServiceCommitment) / NewServiceObjectQuantity
                end;
            "Usage Based Pricing"::"Fixed Quantity",
            "Usage Based Pricing"::"Unit Cost Surcharge":
                if ServiceCommitment.Partner = Enum::"Service Partner"::Vendor then
                    UnitCost := CalculateSumCostAmountFromUsageDataBilling(ServiceCommitment) / NewServiceObjectQuantity
                else
                    if ServiceCommitment.Partner = Enum::"Service Partner"::Customer then
                        UnitPrice := CalculateSumAmountFromUsageDataBilling(ServiceCommitment) / NewServiceObjectQuantity;
            else begin
                IsHandled := false;
                OnUsageBasedPricingElseCaseOnProcessServiceCommitment(UnitCost, NewServiceObjectQuantity, ServiceCommitment, LastUsageDataBilling, IsHandled);
                if not IsHandled then
                    Error(UsageBasedPricingOptionNotImplementedErr, Format(ServiceCommitment."Usage Based Pricing"), ServiceCommitment.FieldCaption("Usage Based Pricing"), CodeunitObjectLbl,
                                                                    CurrentCodeunitNameLbl, ProcessServiceCommitmentProcedureNameLbl);
            end;
        end;

        if ServiceCommitment.IsPartnerVendor() then
            UnitPrice := UnitCost;

        UpdateServiceObjectQuantity(ServiceCommitment."Service Object No.", NewServiceObjectQuantity);
        //Note: Service commitment will be recalculated if the quantity in service object changes
        Commit();
        ServiceCommitment.Get(ServiceCommitment."Entry No.");
        UpdateServiceCommitment(ServiceCommitment, NewServiceObjectQuantity, UnitPrice, CurrencyCode, ChargeDate, LastUsageDataBilling."Charge End Time");

        OnAfterProcessServiceCommitment(ServiceCommitment);
    end;

    local procedure CalculateChargeDateFromLastUsageDataBilling(LastUsageDataBilling: Record "Usage Data Billing"): Date
    begin
        if LastUsageDataBilling."Charge End Time" = 0T then
            exit(CalcDate('<-1D>', LastUsageDataBilling."Charge End Date"));
        exit(LastUsageDataBilling."Charge End Date");
    end;

    internal procedure CalculateAmount(BillingBasePeriod: DateFormula; BaseAmount: Decimal; FromDate: Date; FromTime: Time; ToDate: Date; ToTime: Time) Amount: Decimal
    begin
        Amount := EssDateTimeMgt.CalculateProRatedAmount(BaseAmount, FromDate, FromTime, ToDate, ToTime, BillingBasePeriod);
    end;

    internal procedure GetUnitValuePerMonth(LastUsageDataBilling: Record "Usage Data Billing"; ReferentValue: Decimal; BillingBasePeriod: Text) CalculatedValue: Decimal
    var
        PreviousMonth: Date;
        ChargeDuration: Duration;
        TotalDuration: Duration;
    begin
        SetDurationData(LastUsageDataBilling, PreviousMonth, TotalDuration, ChargeDuration, BillingBasePeriod);
        if ChargeDuration = TotalDuration then
            CalculatedValue := ReferentValue
        else
            CalculatedValue := ReferentValue / ChargeDuration * TotalDuration;
    end;

    local procedure CalculateSumCostAmountFromUsageDataBilling(ServiceCommitment: Record "Service Commitment"): Decimal
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.FilterOnUsageDataImportAndServiceCommitment(UsageDataImport, ServiceCommitment);
        UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::None);
        UsageDataBilling.CalcSums("Cost Amount");
        exit(UsageDataBilling."Cost Amount");
    end;

    local procedure UpdateServiceObjectQuantity(ServiceObjectNo: Code[20]; NewQuantity: Decimal)
    var
        ServiceObject: Record "Service Object";
    begin
        if not ServiceObject.Get(ServiceObjectNo) then
            exit;
        if (ServiceObject."Quantity Decimal" = NewQuantity) then
            exit;
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("Quantity Decimal", NewQuantity);
        ServiceObject.Modify(false);
    end;

    local procedure UpdateServiceCommitment(var ServiceCommitment: Record "Service Commitment"; ServiceObjectQuantity: Decimal; UnitPrice: Decimal; CurrencyCode: Code[10]; ChargeEndDate: Date; ChargeEndTime: Time)
    var
        Currency: Record Currency;
        CurrencyExchRate: Record "Currency Exchange Rate";
        FirstUsageDataBilling: Record "Usage Data Billing";
        DateTimeManagement: Codeunit "Date Time Management";
        ChargePeriodUnitPrice: Decimal;
        ServiceCommitmentDuration: Decimal;
        ChargePeriodDuration: Decimal;
        RoudingPrecision: Decimal;
    begin
        SetCurrency(Currency, ServiceCommitment."Currency Code");

        FindUsageDataBilling(FirstUsageDataBilling, true, ServiceCommitment);
        ChargePeriodUnitPrice := EssDateTimeMgt.CalculateProRatedAmount(ServiceCommitment.Price, FirstUsageDataBilling."Charge Start Date", FirstUsageDataBilling."Charge Start Time", ChargeEndDate, ChargeEndTime, ServiceCommitment."Billing Base Period");

        SetRoundingPrecision(RoudingPrecision, UnitPrice, Currency);
        if Round(ChargePeriodUnitPrice, RoudingPrecision) = UnitPrice then
            exit;
        if ServiceCommitment.Price = UnitPrice then
            exit;

        ServiceCommitmentDuration := DateTimeManagement.GetDurationForRange(ServiceCommitment."Next Billing Date", 0T, CalcDate(ServiceCommitment."Billing Base Period", ServiceCommitment."Next Billing Date"), 0T);
        ChargePeriodDuration := DateTimeManagement.GetDurationForRange(FirstUsageDataBilling."Charge Start Date", FirstUsageDataBilling."Charge Start Time", ChargeEndDate, ChargeEndTime);
        ChargePeriodUnitPrice := UnitPrice * ServiceCommitmentDuration / ChargePeriodDuration;
        ServiceCommitment.Price := ChargePeriodUnitPrice;

        if ServiceCommitment."Currency Code" <> CurrencyCode then begin
            ServiceCommitment.Price := CurrencyExchRate.ExchangeAmtFCYToFCY(ChargeEndDate, CurrencyCode, ServiceCommitment."Currency Code", ServiceCommitment.Price);
            ServiceCommitment.Validate(Price, ServiceCommitment.Price);
        end;
        ServiceCommitment."Service Amount" := Round(ServiceObjectQuantity * ServiceCommitment.Price, Currency."Amount Rounding Precision");
        OnUpdateServiceCommitment(ServiceCommitment, UsageDataImport."Entry No.", ServiceObjectQuantity, ServiceCommitmentDuration, ChargePeriodDuration, CurrencyCode);
        ServiceCommitment.Modify(false);
    end;

    local procedure HandleGracePeriod(var UsageDataBilling: Record "Usage Data Billing")
    var
        UsageDataBilling2: Record "Usage Data Billing";
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
        CustomerContractLine: Record "Customer Contract Line";
    begin
        CustomerContractLine.Get(UsageDataBilling."Contract No.", UsageDataBilling."Contract Line No.");
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);

        if not ServiceObject.Get(ServiceCommitment."Service Object No.") then
            exit;
        if ServiceObject."Quantity Decimal" <> 0 then
            exit;

        UsageDataBilling2.SetRange(Partner, UsageDataBilling2.Partner::Customer);
        UsageDataBilling2.SetRange("Service Commitment Entry No.", UsageDataBilling."Service Commitment Entry No.");
        UsageDataBilling2.SetRange("Document Type", UsageDataBilling2."Document Type"::"Posted Invoice");
        if not UsageDataBilling2.IsEmpty then
            exit;

        UsageDataBilling."Unit Price" := 0;
        UsageDataBilling.Amount := 0;
        UsageDataBilling.Modify(false);
    end;

    local procedure ProcessCustomerContractLineAndConnectedServiceCommitment(var UsageDataBilling: Record "Usage Data Billing")
    var
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitment: Record "Service Commitment";
    begin
        if UsageDataBilling."Contract No." = '' then
            exit;
        if UsageDataBilling."Contract Line No." = 0 then
            exit;
        CustomerContractLine.Get(UsageDataBilling."Contract No.", UsageDataBilling."Contract Line No.");
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        ProcessServiceCommitment(ServiceCommitment);
    end;

    local procedure ProcessVendorContractLineAndConnectedServiceCommitment(var UsageDataBilling: Record "Usage Data Billing")
    var
        VendorContractLine: Record "Vendor Contract Line";
        ServiceCommitment: Record "Service Commitment";
    begin
        if UsageDataBilling."Contract No." = '' then
            exit;
        if UsageDataBilling."Contract Line No." = 0 then
            exit;
        VendorContractLine.Get(UsageDataBilling."Contract No.", UsageDataBilling."Contract Line No.");
        ServiceCommitment.Get(VendorContractLine."Service Commitment Entry No.");
        ProcessServiceCommitment(ServiceCommitment);
    end;

    local procedure GetCustomerContractData(var CustomerContract: Record "Customer Contract"; var CustomerContractLine: Record "Customer Contract Line"; var ServiceCommitment: Record "Service Commitment"; UsageDataBilling: Record "Usage Data Billing")
    begin
        CustomerContract.Get(UsageDataBilling."Contract No.");
        CustomerContractLine.Get(UsageDataBilling."Contract No.", UsageDataBilling."Contract Line No.");
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
    end;

    local procedure SetCurrency(var Currency: Record Currency; CurrencyCode: Code[10])
    begin
        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else
            Currency.InitRoundingPrecision();
    end;

    local procedure FindUsageDataBilling(var FoundUsageDataBilling: Record "Usage Data Billing"; SortAscending: Boolean; ServiceCommitment: Record "Service Commitment")
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.SetCurrentKey("Charge End Date", "Charge End Time");
        UsageDataBilling.SetAscending("Charge End Date", SortAscending);
        UsageDataBilling.FilterOnUsageDataImportAndServiceCommitment(UsageDataImport, ServiceCommitment);
        UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::None);
        if UsageDataBilling.FindFirst() then
            FoundUsageDataBilling := UsageDataBilling;
    end;

    local procedure SetDurationData(LastUsageDataBilling: Record "Usage Data Billing"; var PreviousMonth: Date; var TotalDuration: Duration; var ChargeDuration: Duration; BillingBasePeriodText: Text)
    begin
        if BillingBasePeriodText <> '1M' then
            exit;
        if (not EssDateTimeMgt.IsFirstOfMonth(LastUsageDataBilling."Charge Start Date", LastUsageDataBilling."Charge Start Time")) or
           (not EssDateTimeMgt.IsFirstOfMonth(LastUsageDataBilling."Charge End Date", LastUsageDataBilling."Charge End Time"))
        then begin
            PreviousMonth := CalcDate('<-1M>', LastUsageDataBilling."Charge End Date");
            TotalDuration := EssDateTimeMgt.GetTotalDurationForMonth(PreviousMonth);
            ChargeDuration := EssDateTimeMgt.GetDurationForRange(LastUsageDataBilling."Charge Start Date", LastUsageDataBilling."Charge Start Time", LastUsageDataBilling."Charge End Date", LastUsageDataBilling."Charge End Time");
        end;
    end;

    local procedure CalculateProRatedAmount(var Amount: Decimal; var UnitPrice: Decimal; ServiceCommitment: Record "Service Commitment"; var UsageDataBilling: Record "Usage Data Billing"; CurrencyExchangeRate: Record "Currency Exchange Rate"; Quantity: Decimal)
    begin
        if (ServiceCommitment."Discount %" = 100) or (Quantity = 0) then begin
            UnitPrice := 0;
            Amount := 0;
        end else begin
            Amount := Amount / (1 - ServiceCommitment."Discount %" / 100);
            Amount := CurrencyExchangeRate.ExchangeAmount(Amount, ServiceCommitment."Currency Code", UsageDataBilling."Currency Code", UsageDataBilling."Charge Start Date");
            Amount := EssDateTimeMgt.CalculateProRatedAmount(Amount, UsageDataBilling."Charge Start Date", UsageDataBilling."Charge Start Time", UsageDataBilling."Charge End Date", UsageDataBilling."Charge End Time", ServiceCommitment."Billing Base Period");
            UnitPrice := Amount / Quantity;
        end;
    end;

    local procedure CalculateTotalUsageBillingQuantity(LastUsageDataBilling: Record "Usage Data Billing"; var ServiceCommitment: Record "Service Commitment"): Decimal
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.FilterOnUsageDataImportAndServiceCommitment(UsageDataImport, ServiceCommitment);
        UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::None);
        UsageDataBilling.SetRange("Charge End Date", LastUsageDataBilling."Charge End Date");
        UsageDataBilling.SetRange("Charge End Time", LastUsageDataBilling."Charge End Time");
        UsageDataBilling.CalcSums(Quantity);
        exit(UsageDataBilling.Quantity);
    end;

    local procedure CalculateSumAmountFromUsageDataBilling(ServiceCommitment: Record "Service Commitment"): Decimal
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.FilterOnUsageDataImportAndServiceCommitment(UsageDataImport, ServiceCommitment);
        UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::None);
        UsageDataBilling.CalcSums(Amount);
        exit(UsageDataBilling.Amount);
    end;

    local procedure SetRoundingPrecision(var RoudingPrecision: Decimal; UnitPrice: Decimal; Currency: Record Currency)
    begin
        RoudingPrecision := EssDateTimeMgt.GetRoundingPrecision(EssDateTimeMgt.GetNumberOfDecimals(UnitPrice));
        if RoudingPrecision = 1 then begin
            Currency.InitRoundingPrecision();
            RoudingPrecision := Currency."Unit-Amount Rounding Precision";
        end;
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeProcessUsageDataBilling(UsageDataImport: Record "Usage Data Import")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterProcessUsageDataBilling(UsageDataImport: Record "Usage Data Import")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUsageBasedPricingElseCaseOnProcessServiceCommitment(var UnitCost: Decimal; var NewServiceObjectQuantity: Decimal; var ServiceCommitment: Record "Service Commitment"; LastUsageDataBilling: Record "Usage Data Billing"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUsageBasedPricingElseCaseOnCalculateCustomerUsageDataBillingPrice(var UnitPrice: Decimal; var Amount: Decimal; var UsageDataBilling: Record "Usage Data Billing"; CustomerContract: Record "Customer Contract"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeProcessServiceCommitment(var ServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateServiceCommitment(var ServiceCommitment: Record "Service Commitment"; UsageDataImportEntryNo: Integer; ServiceObjectQuantity: Decimal; ServiceCommitmentDuration: Decimal; ChargePeriodDuration: Decimal; CurrencyCode: Code[10])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterProcessServiceCommitment(var ServiceCommitment: Record "Service Commitment")
    begin
    end;

    var
        UsageDataImport: Record "Usage Data Import";
        UsageDataSupplier: Record "Usage Data Supplier";
        EssDateTimeMgt: Codeunit "Date Time Management";
        ContractItemMgt: Codeunit "Contracts Item Management";
        DoesNotExistErr: Label 'No data found for processing step %1.', Comment = '%1=Name of the processing step';
        ProcessServiceCommitmentProcedureNameLbl: Label 'ProcessServiceCommitment', Locked = true;
        UsageBasedPricingOptionNotImplementedErr: Label 'Unknown option %1 for %2.\\Object Type: %3 Object Name: %4, Procedure: %5', Comment = '%1=Format("Calculation Base Type"), %2 = Fieldcaption for "Calculation Base Type", %3 = Object Type, %4 = Object Name, %5 = Procedure Name';
        CalculateCustomerUsageDataBillingPriceProcedureNameLbl: Label 'CalculateCustomerUsageDataBillingPrice', Locked = true;
        CodeunitObjectLbl: Label 'Codeunit', Locked = true;
        CurrentCodeunitNameLbl: Label 'Process Usage Data Billing', Locked = true;
        NoContractFoundInUsageDataBillingErr: Label 'No contract (for Service Object %1) found for processing step %2.';
}
