namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;

codeunit 8026 "Process Usage Data Billing"
{
    TableNo = "Usage Data Import";

    var
        UsageDataImport: Record "Usage Data Import";
        UsageDataSupplier: Record "Usage Data Supplier";
        DateTimeManagement: Codeunit "Date Time Management";
        ContractItemMgt: Codeunit "Sub. Contracts Item Management";
        DoesNotExistErr: Label 'No data found for processing step %1.', Comment = '%1=Name of the processing step';
        ProcessServiceCommitmentProcedureNameLbl: Label 'ProcessServiceCommitment', Locked = true;
        UsageBasedPricingOptionNotImplementedErr: Label 'Unknown option %1 for %2.\\Object Type: %3 Object Name: %4, Procedure: %5', Comment = '%1=Format("Calculation Base Type"), %2 = Fieldcaption for "Calculation Base Type", %3 = Object Type, %4 = Object Name, %5 = Procedure Name';
        CalculateCustomerUsageDataBillingPriceProcedureNameLbl: Label 'CalculateCustomerUsageDataBillingPrice', Locked = true;
        CodeunitObjectLbl: Label 'Codeunit', Locked = true;
        CurrentCodeunitNameLbl: Label 'Process Usage Data Billing', Locked = true;
        NoContractFoundInUsageDataBillingErr: Label 'No contract (for Subscription %1) found for processing step %2.';

    trigger OnRun()
    begin
        UsageDataImport.Copy(Rec);
        Code();
        Rec := UsageDataImport;
    end;

    local procedure Code()
    var
        UsageDataBilling: Record "Usage Data Billing";
        SubscriptionLineEntryNoList: List of [Integer];
    begin
        OnBeforeProcessUsageDataBilling(UsageDataImport);
        if UsageDataImport."Processing Status" = Enum::"Processing Status"::Closed then
            exit;
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBilling.SetRange("Document No.", '');
        UsageDataBilling.SetFilter("Subscription Contract No.", '<>%1', '');
        if not UsageDataBilling.IsEmpty then begin

            UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
            if UsageDataBilling.FindSet(true) then
                repeat
                    CalculateCustomerUsageDataBillingPrice(UsageDataBilling);
                until UsageDataBilling.Next() = 0;

            UsageDataBilling.SetRange(Partner);
            if UsageDataBilling.FindSet() then
                repeat
                    if SubscriptionLineEntryNoList.IndexOf(UsageDataBilling."Subscription Line Entry No.") = 0 then begin
                        SubscriptionLineEntryNoList.Add(UsageDataBilling."Subscription Line Entry No.");
                        ProcessServiceCommitment(UsageDataBilling);
                    end;

                    if UsageDataBilling.Partner = "Service Partner"::Customer then
                        HandleGracePeriod(UsageDataBilling);
                until UsageDataBilling.Next() = 0;
        end else begin
            UsageDataBilling.SetRange("Subscription Contract No.");
            if UsageDataBilling.FindFirst() then begin
                UsageDataImport.SetErrorReason(StrSubstNo(NoContractFoundInUsageDataBillingErr, UsageDataBilling."Subscription Header No.", UsageDataImport."Processing Step"));
                UsageDataBilling.SetReason(StrSubstNo(NoContractFoundInUsageDataBillingErr, UsageDataBilling."Subscription Header No.", UsageDataImport."Processing Step"));
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
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
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
                        Amount := ServiceCommitment.Amount;
                        ServiceObject.Get(ServiceCommitment."Subscription Header No.");
                        ServiceObject.TestField(Type, ServiceObject.Type::Item);
                        ContractItemMgt.GetSalesPriceForItem(UnitPrice, ServiceObject."Source No.", Abs(UsageDataBilling.Quantity), CustomerContract."Currency Code", CustomerContract."Sell-to Customer No.", CustomerContract."Bill-to Customer No.");
                        Amount := UnitPrice * Abs(UsageDataBilling.Quantity);
                        CalculateUsageDataPrices(Amount, UnitPrice, ServiceCommitment, UsageDataBilling, Abs(UsageDataBilling.Quantity));
                    end;
                "Usage Based Pricing"::"Fixed Quantity":
                    begin
                        Amount := ServiceCommitment.Amount;
                        ServiceCommitment.CalcFields("Quantity");
                        CalculateUsageDataPrices(Amount, UnitPrice, ServiceCommitment, UsageDataBilling, ServiceCommitment."Quantity");
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

    local procedure ProcessServiceCommitment(var UsageDataBilling: Record "Usage Data Billing")
    var
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
        LastUsageDataBilling: Record "Usage Data Billing";
        NewServiceObjectQuantity: Decimal;
        CurrencyCode: Code[10];
        UnitPrice: Decimal;
        UnitCost: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeProcessSubscriptionLine(ServiceCommitment);

        if UsageDataBilling."Subscription Line Entry No." = 0 then
            exit;
        if not ServiceCommitment.Get(UsageDataBilling."Subscription Line Entry No.") then
            exit;

        ServiceObject.Get(ServiceCommitment."Subscription Header No.");
        ServiceObject.TestField(Type, ServiceObject.Type::Item);
        NewServiceObjectQuantity := ServiceObject.Quantity;
        UnitPrice := ServiceCommitment.Price;
        UnitCost := ServiceCommitment."Unit Cost";

        FindUsageDataBilling(LastUsageDataBilling, false, UsageDataImport."Entry No.", ServiceCommitment);
        CurrencyCode := LastUsageDataBilling."Currency Code";

        case ServiceCommitment."Usage Based Pricing" of
            "Usage Based Pricing"::"Usage Quantity":
                begin
                    NewServiceObjectQuantity := CalculateTotalUsageBillingQuantity(LastUsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment);
                    UnitCost := CalculateSumCostAmountFromUsageDataBilling(LastUsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment) / NewServiceObjectQuantity;
                    if ServiceCommitment.IsPartnerCustomer() then
                        UnitPrice := CalculateSumAmountFromUsageDataBilling(LastUsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment) / NewServiceObjectQuantity;
                    if LastUsageDataBilling.Rebilling then
                        NewServiceObjectQuantity += ServiceObject."Quantity";
                end;
            "Usage Based Pricing"::"Fixed Quantity":
                ;
            "Usage Based Pricing"::"Unit Cost Surcharge":
                begin
                    UnitCost := CalculateSumCostAmountFromUsageDataBilling(LastUsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment) / NewServiceObjectQuantity;
                    if ServiceCommitment.IsPartnerCustomer() then
                        UnitPrice := CalculateSumAmountFromUsageDataBilling(LastUsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment) / NewServiceObjectQuantity;
                end;
            else begin
                IsHandled := false;
                OnUsageBasedPricingElseCaseOnProcessSubscriptionLine(UnitCost, NewServiceObjectQuantity, ServiceCommitment, LastUsageDataBilling, IsHandled);
                if not IsHandled then
                    Error(UsageBasedPricingOptionNotImplementedErr, Format(ServiceCommitment."Usage Based Pricing"), ServiceCommitment.FieldCaption("Usage Based Pricing"), CodeunitObjectLbl,
                                                                    CurrentCodeunitNameLbl, ProcessServiceCommitmentProcedureNameLbl);
            end;
        end;

        if ServiceCommitment.IsPartnerVendor() then
            UnitPrice := UnitCost;

        UpdateServiceObjectQuantity(ServiceCommitment."Subscription Header No.", NewServiceObjectQuantity);
        //Note: Service commitment will be recalculated if the quantity in service object changes
        Commit();
        ServiceCommitment.Get(ServiceCommitment."Entry No.");
        UpdateServiceCommitment(LastUsageDataBilling, ServiceCommitment, UnitPrice, UnitCost, CurrencyCode);
        if UsageDataBilling.Rebilling then begin
            ServiceCommitment."Next Billing Date" := UsageDataBilling."Charge Start Date";
            ServiceCommitment.Modify();
        end;

        OnAfterProcessSubscriptionLine(ServiceCommitment);
    end;

    local procedure CalculateSumCostAmountFromUsageDataBilling(LastUsageDataBilling: Record "Usage Data Billing"; UsageDataImportEntryNo: Integer; ServiceCommitment: Record "Subscription Line"): Decimal
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.FilterOnUsageDataImportAndServiceCommitment(UsageDataImportEntryNo, ServiceCommitment);
        UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::None);
        UsageDataBilling.SetRange("Charge End Date", LastUsageDataBilling."Charge End Date");
        UsageDataBilling.CalcSums("Cost Amount");
        exit(UsageDataBilling."Cost Amount");
    end;

    local procedure UpdateServiceObjectQuantity(ServiceObjectNo: Code[20]; NewQuantity: Decimal)
    var
        ServiceObject: Record "Subscription Header";
    begin
        if not ServiceObject.Get(ServiceObjectNo) then
            exit;
        if (ServiceObject.Quantity = NewQuantity) then
            exit;
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate(Quantity, NewQuantity);
        ServiceObject.Modify(false);
    end;

    local procedure UpdateServiceCommitment(LastUsageDataBilling: Record "Usage Data Billing"; var ServiceCommitment: Record "Subscription Line"; UnitPrice: Decimal; UnitCost: Decimal; CurrencyCode: Code[10])
    var
        Currency: Record Currency;
        CurrencyExchRate: Record "Currency Exchange Rate";
        ServiceCommitmentUnitPrice: Decimal;
        ServiceCommitmentUnitCost: Decimal;
        ServiceCommitmentUnitCostLCY: Decimal;
        RoundingPrecision: Decimal;
        ServiceCommitmentUpdated: Boolean;
    begin
        if UnitPrice = 0 then
            exit;
        SetCurrency(Currency, ServiceCommitment."Currency Code");

        ServiceCommitment.UnitPriceAndCostForPeriod(ServiceCommitment."Billing Rhythm", LastUsageDataBilling."Charge Start Date", LastUsageDataBilling."Charge End Date", ServiceCommitmentUnitPrice, ServiceCommitmentUnitCost, ServiceCommitmentUnitCostLCY);

        SetRoundingPrecision(RoundingPrecision, UnitPrice, Currency);
        if Round(ServiceCommitmentUnitPrice, RoundingPrecision) <> UnitPrice then begin
            ServiceCommitment.Price := UnitPrice;
            if ServiceCommitment."Currency Code" <> CurrencyCode then
                ServiceCommitment.Price := CurrencyExchRate.ExchangeAmtFCYToFCY(LastUsageDataBilling."Charge End Date", CurrencyCode, ServiceCommitment."Currency Code", ServiceCommitment.Price);

            ServiceCommitment.Validate(Price, ServiceCommitment.Price);
            ServiceCommitment.Validate("Calculation Base Amount", ServiceCommitment.Price / (ServiceCommitment."Calculation Base %" / 100));
            ServiceCommitmentUpdated := true;
        end;

        if ServiceCommitment.Partner = ServiceCommitment.Partner::Customer then begin
            SetRoundingPrecision(RoundingPrecision, UnitCost, Currency);
            if (Round(ServiceCommitmentUnitCost, RoundingPrecision) <> UnitCost) and (ServiceCommitment.Partner = ServiceCommitment.Partner::Customer) then begin
                ServiceCommitment."Unit Cost" := UnitCost;
                if ServiceCommitment."Currency Code" = CurrencyCode then
                    ServiceCommitment."Unit Cost (LCY)" := ServiceCommitment."Unit Cost"
                else
                    ServiceCommitment."Unit Cost (LCY)" := CurrencyExchRate.ExchangeAmtFCYToLCY(LastUsageDataBilling."Charge End Date", CurrencyCode, ServiceCommitment."Unit Cost", CurrencyExchRate.ExchangeRate(LastUsageDataBilling."Charge End Date", CurrencyCode));
                ServiceCommitmentUpdated := true;
            end;
        end;

        if not ServiceCommitmentUpdated then
            exit;

        ServiceCommitment.Modify(false);
    end;

    local procedure HandleGracePeriod(var UsageDataBilling: Record "Usage Data Billing")
    var
        UsageDataBilling2: Record "Usage Data Billing";
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
    begin
        CustomerContractLine.Get(UsageDataBilling."Subscription Contract No.", UsageDataBilling."Subscription Contract Line No.");
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);

        if not ServiceObject.Get(ServiceCommitment."Subscription Header No.") then
            exit;
        if ServiceObject.Quantity <> 0 then
            exit;

        UsageDataBilling2.SetRange(Partner, UsageDataBilling2.Partner::Customer);
        UsageDataBilling2.SetRange("Subscription Line Entry No.", UsageDataBilling."Subscription Line Entry No.");
        UsageDataBilling2.SetRange("Document Type", UsageDataBilling2."Document Type"::"Posted Invoice");
        if not UsageDataBilling2.IsEmpty then
            exit;

        UsageDataBilling."Unit Price" := 0;
        UsageDataBilling.Amount := 0;
        UsageDataBilling.Modify(false);
    end;

    local procedure GetCustomerContractData(var CustomerContract: Record "Customer Subscription Contract"; var CustomerContractLine: Record "Cust. Sub. Contract Line"; var ServiceCommitment: Record "Subscription Line"; UsageDataBilling: Record "Usage Data Billing")
    begin
        CustomerContract.Get(UsageDataBilling."Subscription Contract No.");
        CustomerContractLine.Get(UsageDataBilling."Subscription Contract No.", UsageDataBilling."Subscription Contract Line No.");
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
    end;

    local procedure SetCurrency(var Currency: Record Currency; CurrencyCode: Code[10])
    begin
        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else
            Currency.InitRoundingPrecision();
    end;

    local procedure FindUsageDataBilling(var FoundUsageDataBilling: Record "Usage Data Billing"; SortAscending: Boolean; UsageDataImportEntryNo: Integer; ServiceCommitment: Record "Subscription Line")
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.SetCurrentKey("Charge End Date");
        UsageDataBilling.SetAscending("Charge End Date", SortAscending);
        UsageDataBilling.FilterOnUsageDataImportAndServiceCommitment(UsageDataImportEntryNo, ServiceCommitment);
        UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::None);
        if UsageDataBilling.FindFirst() then
            FoundUsageDataBilling := UsageDataBilling;
    end;

    local procedure CalculateUsageDataPrices(var Amount: Decimal; var UnitPrice: Decimal; ServiceCommitment: Record "Subscription Line"; var UsageDataBilling: Record "Usage Data Billing"; Quantity: Decimal)
    begin
        if (ServiceCommitment."Discount %" = 100) or (Quantity = 0) then begin
            UnitPrice := 0;
            Amount := 0;
            exit;
        end;
        UnitPrice := ServiceCommitment.UnitPriceForPeriod(UsageDataBilling."Charge Start Date", UsageDataBilling."Charge End Date");
        Amount := UnitPrice * Quantity;
    end;

    local procedure CalculateTotalUsageBillingQuantity(LastUsageDataBilling: Record "Usage Data Billing"; UsageDataImportEntryNo: Integer; var ServiceCommitment: Record "Subscription Line"): Decimal
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.FilterOnUsageDataImportAndServiceCommitment(UsageDataImportEntryNo, ServiceCommitment);
        UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::None);
        UsageDataBilling.SetRange("Charge End Date", LastUsageDataBilling."Charge End Date");
        UsageDataBilling.CalcSums(Quantity);
        exit(UsageDataBilling.Quantity);
    end;

    local procedure CalculateSumAmountFromUsageDataBilling(LastUsageDataBilling: Record "Usage Data Billing"; UsageDataImportEntryNo: Integer; ServiceCommitment: Record "Subscription Line"): Decimal
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.FilterOnUsageDataImportAndServiceCommitment(UsageDataImportEntryNo, ServiceCommitment);
        UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::None);
        UsageDataBilling.SetRange("Charge End Date", LastUsageDataBilling."Charge End Date");
        UsageDataBilling.CalcSums(Amount);
        exit(UsageDataBilling.Amount);
    end;

    internal procedure SetRoundingPrecision(var RoundingPrecision: Decimal; UnitPrice: Decimal; Currency: Record Currency)
    begin
        RoundingPrecision := DateTimeManagement.GetRoundingPrecision(DateTimeManagement.GetNumberOfDecimals(UnitPrice));
        if RoundingPrecision = 1 then begin
            Currency.InitRoundingPrecision();
            RoundingPrecision := Currency."Unit-Amount Rounding Precision";
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessUsageDataBilling(UsageDataImport: Record "Usage Data Import")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessUsageDataBilling(UsageDataImport: Record "Usage Data Import")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUsageBasedPricingElseCaseOnProcessSubscriptionLine(var UnitCost: Decimal; var NewServiceObjectQuantity: Decimal; var SubscriptionLine: Record "Subscription Line"; LastUsageDataBilling: Record "Usage Data Billing"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUsageBasedPricingElseCaseOnCalculateCustomerUsageDataBillingPrice(var UnitPrice: Decimal; var Amount: Decimal; var UsageDataBilling: Record "Usage Data Billing"; CustomerSubscriptionContract: Record "Customer Subscription Contract"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessSubscriptionLine(var SubscriptionLine: Record "Subscription Line")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessSubscriptionLine(var SubscriptionLine: Record "Subscription Line")
    begin
    end;
}
