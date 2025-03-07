namespace Microsoft.SubscriptionBilling;

codeunit 8111 "Create Sub. Bill. Packages"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertServiceCommitmentPackages();
        InsertItemServiceCommitmentPackages();
    end;

    local procedure InsertServiceCommitmentPackages()
    var
        CreateSubBillItem: Codeunit "Create Sub. Bill. Item";
        CreateSubBillSTemplate: Codeunit "Create Sub. Bill. S. Template";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        Evaluate(OneMonthDateFormula, '<1M>');
        Evaluate(TwelveMonthDateFormula, '<12M>');
        Evaluate(TwentyFourMonthDateFormula, '<24M>');

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(MaintenanceBronze(), MaintenanceBronzeLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(MaintenanceBronze(), "Service Partner"::Customer, CreateSubBillSTemplate.Maintenance(), Enum::"Invoicing Via"::Contract, CreateSubBillItem.SB1104(),
            Enum::"Calculation Base Type"::"Document Price", 10, TwelveMonthDateFormula, TwelveMonthDateFormula, EmptyDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(MaintenanceBronze(), "Service Partner"::Vendor, CreateSubBillSTemplate.Maintenance(), Enum::"Invoicing Via"::Contract, CreateSubBillItem.SB1104(),
            Enum::"Calculation Base Type"::"Item Price", 5, TwelveMonthDateFormula, TwelveMonthDateFormula, EmptyDateFormula, false, Enum::"Usage Based Pricing"::None, 0);

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(MaintenanceSilver(), MaintenanceSilverLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(MaintenanceSilver(), "Service Partner"::Customer, CreateSubBillSTemplate.Maintenance(), Enum::"Invoicing Via"::Contract, CreateSubBillItem.SB1104(),
            Enum::"Calculation Base Type"::"Document Price", 12, TwelveMonthDateFormula, TwelveMonthDateFormula, EmptyDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(MaintenanceSilver(), "Service Partner"::Vendor, CreateSubBillSTemplate.Maintenance(), Enum::"Invoicing Via"::Contract, CreateSubBillItem.SB1104(),
            Enum::"Calculation Base Type"::"Item Price", 7, TwelveMonthDateFormula, TwelveMonthDateFormula, EmptyDateFormula, false, Enum::"Usage Based Pricing"::None, 0);

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(MaintenanceGold(), MaintenanceGoldLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(MaintenanceGold(), "Service Partner"::Customer, CreateSubBillSTemplate.Maintenance(), Enum::"Invoicing Via"::Contract, CreateSubBillItem.SB1104(),
            Enum::"Calculation Base Type"::"Document Price", 15, TwelveMonthDateFormula, TwelveMonthDateFormula, EmptyDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(MaintenanceGold(), "Service Partner"::Vendor, CreateSubBillSTemplate.Maintenance(), Enum::"Invoicing Via"::Contract, CreateSubBillItem.SB1104(),
            Enum::"Calculation Base Type"::"Item Price", 10, TwelveMonthDateFormula, TwelveMonthDateFormula, EmptyDateFormula, false, Enum::"Usage Based Pricing"::None, 0);

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(MonthlySubscription(), MonthlySubscriptionLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(MonthlySubscription(), "Service Partner"::Customer, CreateSubBillSTemplate.MonthlySubscription(), Enum::"Invoicing Via"::Contract, '',
           Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, OneMonthDateFormula, EmptyDateFormula, false, Enum::"Usage Based Pricing"::None, 0);

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(YearlySubscription(), YearlySubscriptionLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(YearlySubscription(), "Service Partner"::Customer, CreateSubBillSTemplate.YearlySubscription(), Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, TwelveMonthDateFormula, TwelveMonthDateFormula, EmptyDateFormula, false, Enum::"Usage Based Pricing"::None, 0);

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(UDFixed(), UDFixedLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(UDFixed(), "Service Partner"::Vendor, CreateSubBillSTemplate.UDFixed(), Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, OneMonthDateFormula, EmptyDateFormula, true, Enum::"Usage Based Pricing"::"Fixed Quantity", 0);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(UDFixed(), "Service Partner"::Customer, CreateSubBillSTemplate.UDFixed(), Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, OneMonthDateFormula, EmptyDateFormula, true, Enum::"Usage Based Pricing"::"Fixed Quantity", 0);

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(UDSurcharge(), UDSurchargeLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(UDSurcharge(), "Service Partner"::Vendor, CreateSubBillSTemplate.UDSurcharge(), Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, OneMonthDateFormula, EmptyDateFormula, true, Enum::"Usage Based Pricing"::"Unit Cost Surcharge", 0);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(UDSurcharge(), "Service Partner"::Customer, CreateSubBillSTemplate.UDSurcharge(), Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, OneMonthDateFormula, EmptyDateFormula, true, Enum::"Usage Based Pricing"::"Unit Cost Surcharge", 20);

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(UDUsage(), UDUsageLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(UDUsage(), "Service Partner"::Vendor, CreateSubBillSTemplate.UDUsage(), Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, OneMonthDateFormula, EmptyDateFormula, true, Enum::"Usage Based Pricing"::"Usage Quantity", 0);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(UDUsage(), "Service Partner"::Customer, CreateSubBillSTemplate.UDUsage(), Enum::"Invoicing Via"::Contract, '',
            Enum::"Calculation Base Type"::"Item Price", 100, OneMonthDateFormula, OneMonthDateFormula, EmptyDateFormula, true, Enum::"Usage Based Pricing"::"Usage Quantity", 0);

        ContosoSubscriptionBilling.InsertServiceCommitmentPackage(Warranty(), WarrantyLbl);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(Warranty(), "Service Partner"::Customer, CreateSubBillSTemplate.Warranty(), Enum::"Invoicing Via"::Sales, '',
            Enum::"Calculation Base Type"::"Item Price", 0, TwentyFourMonthDateFormula, TwentyFourMonthDateFormula, TwentyFourMonthDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
        ContosoSubscriptionBilling.InsertServiceCommitmentPackageLine(Warranty(), "Service Partner"::Vendor, CreateSubBillSTemplate.Warranty(), Enum::"Invoicing Via"::Sales, '',
            Enum::"Calculation Base Type"::"Item Price", 0, TwentyFourMonthDateFormula, TwentyFourMonthDateFormula, TwentyFourMonthDateFormula, false, Enum::"Usage Based Pricing"::None, 0);
    end;

    local procedure InsertItemServiceCommitmentPackages()
    var
        CreateSubBillItem: Codeunit "Create Sub. Bill. Item";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1100(), MonthlySubscription(), true);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1101(), YearlySubscription(), true);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1102(), MonthlySubscription(), true);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1103(), MaintenanceBronze(), false);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1103(), MaintenanceSilver(), false);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1103(), MaintenanceGold(), false);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1103(), Warranty(), true);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1105(), UDUsage(), true);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1106(), UDSurcharge(), true);
        ContosoSubscriptionBilling.InsertItemServiceCommitmentPackage(CreateSubBillItem.SB1107(), UDFixed(), true);
    end;

    var
        EmptyDateFormula: DateFormula;
        OneMonthDateFormula: DateFormula;
        TwelveMonthDateFormula: DateFormula;
        TwentyFourMonthDateFormula: DateFormula;
        MaintenanceBronzeTok: Label 'MAINTENANCE-1-BRONZE', MaxLength = 20;
        MaintenanceBronzeLbl: Label 'Maintenance - Bronze', MaxLength = 100;
        MaintenanceSilverTok: Label 'MAINTENANCE-2-SILVER', MaxLength = 20;
        MaintenanceSilverLbl: Label 'Maintenance - Silver', MaxLength = 100;
        MaintenanceGoldTok: Label 'MAINTENANCE-3-GOLD', MaxLength = 20;
        MaintenanceGoldLbl: Label 'Maintenance - Gold', MaxLength = 100;
        MonthlySubscriptionTok: Label 'SUBSCRIPTION-1M', MaxLength = 20;
        MonthlySubscriptionLbl: Label 'Subscription (month)', MaxLength = 100;
        YearlySubscriptionTok: Label 'SUBSCRIPTION-1Y', MaxLength = 20;
        YearlySubscriptionLbl: Label 'Subscription (annual)', MaxLength = 100;
        UDFixedTok: Label 'UD-FIXED', MaxLength = 20;
        UDFixedLbl: Label 'Usage data - Fixed Qty.', MaxLength = 100;
        UDSurchargeTok: Label 'UD-SURCHARGE', MaxLength = 20;
        UDSurchargeLbl: Label 'Usage data - Surcharge', MaxLength = 100;
        UDUsageTok: Label 'UD-USAGE', MaxLength = 20;
        UDUsageLbl: Label 'Usage data - Usage Qty.', MaxLength = 100;
        WarrantyTok: Label 'WARRANTY', MaxLength = 20;
        WarrantyLbl: Label 'Warranty', MaxLength = 100;

    procedure MaintenanceBronze(): Code[20]
    begin
        exit(MaintenanceBronzeTok);
    end;

    procedure MaintenanceSilver(): Code[20]
    begin
        exit(MaintenanceSilverTok);
    end;

    procedure MaintenanceGold(): Code[20]
    begin
        exit(MaintenanceGoldTok);
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