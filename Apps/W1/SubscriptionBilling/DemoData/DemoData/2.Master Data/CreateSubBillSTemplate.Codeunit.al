namespace Microsoft.SubscriptionBilling;

codeunit 8112 "Create Sub. Bill. S. Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateSubBillItem: Codeunit "Create Sub. Bill. Item";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        Evaluate(OneMonthDateFormula, '<1M>');
        Evaluate(TwelveMonthDateFormula, '<12M>');
        Evaluate(TwentyFourMonthDateFormula, '<24M>');

        ContosoSubscriptionBilling.InsertBillingServCommTemplate(Maintenance(), MaintenanceLbl, Enum::"Invoicing Via"::Contract, CreateSubBillItem.SB1104(),
            Enum::"Calculation Base Type"::"Item Price", 0, TwelveMonthDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
        ContosoSubscriptionBilling.InsertBillingServCommTemplate(MonthlySubscription(), MonthlySubscriptionLbl, Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
        ContosoSubscriptionBilling.InsertBillingServCommTemplate(YearlySubscription(), YearlySubscriptionLbl, Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, TwelveMonthDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
        ContosoSubscriptionBilling.InsertBillingServCommTemplate(UDFixed(), UDFixedLbl, Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, true, Enum::"Usage Based Pricing"::"Fixed Quantity", 0);
        ContosoSubscriptionBilling.InsertBillingServCommTemplate(UDSurcharge(), UDSurchargeLbl, Enum::"Invoicing Via"::Contract, '',
           Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, true, Enum::"Usage Based Pricing"::"Unit Cost Surcharge", 20);
        ContosoSubscriptionBilling.InsertBillingServCommTemplate(UDUsage(), UDUsageLbl, Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, true, Enum::"Usage Based Pricing"::"Usage Quantity", 0);
        ContosoSubscriptionBilling.InsertBillingServCommTemplate(Warranty(), WarrantyLbl, Enum::"Invoicing Via"::Sales, '',
           Enum::"Calculation Base Type"::"Item Price", 0, TwentyFourMonthDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
    end;


    var
        OneMonthDateFormula: DateFormula;
        TwelveMonthDateFormula: DateFormula;
        TwentyFourMonthDateFormula: DateFormula;
        MaintenanceTok: Label 'MAINTENANCE', MaxLength = 20;
        MaintenanceLbl: Label 'Maintenance', MaxLength = 50;
        MonthlySubscriptionTok: Label 'SUBSCRIPTION-1M', MaxLength = 20;
        MonthlySubscriptionLbl: Label 'Subscription (month)', MaxLength = 50;
        YearlySubscriptionTok: Label 'SUBSCRIPTION-1Y', MaxLength = 20;
        YearlySubscriptionLbl: Label 'Subscription (annual)', MaxLength = 50;
        UDFixedTok: Label 'UD-FIXED', MaxLength = 20;
        UDFixedLbl: Label 'Usage data - Fixed Qty.', MaxLength = 50;
        UDSurchargeTok: Label 'UD-SURCHARGE', MaxLength = 20;
        UDSurchargeLbl: Label 'Usage data - Surcharge', MaxLength = 50;
        UDUsageTok: Label 'UD-USAGE', MaxLength = 20;
        UDUsageLbl: Label 'Usage data - Usage Qty.', MaxLength = 50;
        WarrantyTok: Label 'WARRANTY', MaxLength = 20;
        WarrantyLbl: Label 'Warranty', MaxLength = 50;

    procedure Maintenance(): Code[20]
    begin
        exit(MaintenanceTok);
    end;

    procedure MonthlySubscription(): Code[20]
    begin
        exit(MonthlySubscriptionTok);
    end;

    procedure YearlySubscription(): Code[20]
    begin
        exit(YearlySubscriptionTok);
    end;

    procedure UDFixed(): Code[20]
    begin
        exit(UDFixedTok);
    end;

    procedure UDSurcharge(): Code[20]
    begin
        exit(UDSurchargeTok);
    end;

    procedure UDUsage(): Code[20]
    begin
        exit(UDUsageTok);
    end;

    procedure Warranty(): Code[20]
    begin
        exit(WarrantyTok);
    end;
}