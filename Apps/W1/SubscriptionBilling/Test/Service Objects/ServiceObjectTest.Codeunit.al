namespace Microsoft.SubscriptionBilling;


using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.CRM.Contact;
using Microsoft.Finance.Currency;
using Microsoft.Pricing.Source;
using Microsoft.Pricing.Asset;
using Microsoft.Pricing.PriceList;

codeunit 139886 "Service Object Test"
{
    Subtype = Test;
    Access = Internal;

    var
        ServiceObject: Record "Service Object";
        Item: Record Item;
        Customer: Record Customer;
        Customer2: Record Customer;
        CustomerPriceGroup1: Record "Customer Price Group";
        Contact: Record Contact;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitmentPackage1: Record "Service Commitment Package";
        ServiceCommPackageLine1: Record "Service Comm. Package Line";
        ServiceCommitment: Record "Service Commitment";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        Currency: Record Currency;
        CustomerPriceGroup: Record "Customer Price Group";
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        ItemAttribute: Record "Item Attribute";
        ItemAttribute2: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValue2: Record "Item Attribute Value";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        AssertThat: Codeunit Assert;
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        ConfirmOption: Boolean;

    trigger OnRun()
    begin
        ContractTestLibrary.EnableNewPricingExperience();
    end;

    local procedure SetupServiceObjectWithServiceCommitment(SNSpecificTracking: Boolean; CreateWithAdditionalVendorServCommLine: Boolean)
    begin
        ClearAll();
        if CreateWithAdditionalVendorServCommLine then
            ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, SNSpecificTracking, Item, 1, 1)
        else
            ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, SNSpecificTracking, Item, 1, 0);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
    end;

    procedure SetupServiceObjectTemplatePackageAndAssignItemToPackage()
    begin
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
    end;

    [Test]
    procedure CheckCreateServiceObject()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateServiceObject(ServiceObject, '');

        ServiceObject.TestField("No.");
        ServiceObject.TestField("Quantity Decimal");
        asserterror ServiceObject.Validate("Quantity Decimal", -1);
    end;

    [Test]
    procedure CheckCreateServiceObjectWithCustomerPriceGroup()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateServiceObject(ServiceObject, '');
        ServiceObject.TestField("Customer Price Group", '');
        ContractTestLibrary.CreateCustomer(Customer);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        Customer."Customer Price Group" := CustomerPriceGroup.Code;
        Customer.Modify(false);
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);
        ServiceObject.TestField("Customer Price Group", Customer."Customer Price Group");
    end;

    [Test]
    procedure CheckCreateServiceObjectWithItemNo()
    begin
        ClearAll();
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ServiceObject.TestField("Item No.", Item."No.");
        ServiceObject.TestField(Description, Item.Description);
    end;

    [Test]
    procedure CheckServiceObjectQtyForSerialNo()
    begin
        ClearAll();
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, true);

        ServiceObject.TestField("Quantity Decimal", 1);
        ServiceObject.Validate("Serial No.", 'S1');
        Commit(); // retain data after asserterror

        asserterror ServiceObject.Validate("Quantity Decimal", 2);
        ServiceObject.Validate("Serial No.", '');
        ServiceObject.Validate("Quantity Decimal", 2);
        asserterror ServiceObject.Validate("Serial No.", 'S2');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckTransferDefaultsFromCustomerToServiceObject()
    begin
        ClearAll();

        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateServiceObject(ServiceObject, '');

        ConfirmOption := true;
        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject.TestField("End-User Customer No.", Customer."No.");
        ServiceObject.Validate("Bill-to Name", Customer2.Name);
        ServiceObject.TestField("Bill-to Customer No.", Customer2."No.");
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        case ConfirmOption of
            true:
                Reply := true;
            false:
                Reply := false;
        end;
    end;

    [Test]
    procedure CheckTransferDefaultsFromContactToServiceObject()
    begin
        ClearAll();

        ContractTestLibrary.CreateContactsWithCustomerAndGetContactPerson(Contact, Customer);
        ContractTestLibrary.CreateServiceObject(ServiceObject, '');
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Contact No.", Contact."No.");
        ServiceObject.TestField("End-User Customer No.", Customer."No.");
        ServiceObject.TestField("End-User Customer Name", Customer.Name);
    end;

    [Test]
    procedure CheckCannotDeleteServiceObjectWhileServiceCommitmentExist()
    begin
        SetupServiceObjectWithServiceCommitment(false, true);
        asserterror ServiceObject.Delete(true);
    end;

    [Test]

    procedure CheckServiceObjectsServiceCommitmentStandardPackagesAssignment()
    begin
        ClearAll();
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.CreateServiceObjectItem(Item, false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Standard := true;
        ItemServCommitmentPackage.Modify(false);
        ContractTestLibrary.CreateServiceObject(ServiceObject, Item."No.");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Template, ServiceCommitmentTemplate.Code);
        ServiceCommitment.FindFirst();
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]

    procedure CheckServiceObjectsServiceCommitmentAssignment()
    var
        ServiceObjectPage: TestPage "Service Object";
    begin
        ClearAll();
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);

        ServiceCommitmentTemplate.Description += ' Temp';
        ServiceCommitmentTemplate."Calculation Base Type" := Enum::"Calculation Base Type"::"Document Price";
        ServiceCommitmentTemplate."Calculation Base %" := 10;
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        Evaluate(ServiceCommPackageLine."Extension Term", '<1M>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1M>');
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<12M>');
        ServiceCommPackageLine.Modify(false);

        ServiceObjectPage.OpenEdit();
        ServiceObjectPage.GoToRecord(ServiceObject);
        ServiceObjectPage.AssignServices.Invoke();

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();

        ServiceCommitment.TestField("Package Code", ServiceCommPackageLine."Package Code");
        ServiceCommitment.TestField(Template, ServiceCommPackageLine.Template);
        ServiceCommitment.TestField(Description, ServiceCommPackageLine.Description);
        ServiceCommitment.TestField("Service Start Date", WorkDate());
        ServiceCommitment.TestField("Extension Term", ServiceCommPackageLine."Extension Term");
        ServiceCommitment.TestField("Notice Period", ServiceCommPackageLine."Notice Period");
        ServiceCommitment.TestField("Initial Term", ServiceCommPackageLine."Initial Term");
        ServiceCommitment.TestField(Partner, ServiceCommPackageLine.Partner);
        ServiceCommitment.TestField("Calculation Base %", ServiceCommPackageLine."Calculation Base %");
        ServiceCommitment.TestField("Billing Base Period", ServiceCommPackageLine."Billing Base Period");
        ServiceCommitment.TestField("Invoicing via", ServiceCommPackageLine."Invoicing via");
        ServiceCommitment.TestField("Invoicing Item No.", ServiceCommPackageLine."Invoicing Item No.");
        ServiceCommitment.TestField("Billing Rhythm", ServiceCommPackageLine."Billing Rhythm");
        ServiceCommitment.TestField("Price (LCY)", ServiceCommitment.Price);
        ServiceCommitment.TestField("Service Amount (LCY)", ServiceCommitment."Service Amount");
        ServiceCommitment.TestField("Discount Amount (LCY)", ServiceCommitment."Discount Amount");
        ServiceCommitment.TestField("Currency Code", '');
        ServiceCommitment.TestField("Currency Factor", 0);
        ServiceCommitment.TestField("Currency Factor Date", 0D);
        ServiceCommitment.TestField(Discount, false);
    end;

    [ModalPageHandler]
    procedure AssignServiceCommitmentsModalPageHandler(var AssignServiceCommitments: TestPage "Assign Service Commitments")
    begin
        AssignServiceCommitments.FieldServiceAndCalculationStartDate.SetValue(WorkDate());
        AssignServiceCommitments.First();
        AssignServiceCommitments.OK().Invoke();
    end;

    [Test]
    procedure CheckServiceCommitmentBaseAmountAssignment()
    begin
        SetupServiceObjectWithServiceCommitment(true, true);
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");

        ServiceCommitment.Next();
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Cost");
    end;

    [Test]
    procedure CheckServiceCommitmentPriceCalculation()
    var
        ExpectedPrice: Decimal;
    begin
        SetupServiceObjectWithServiceCommitment(true, true);

        Currency.InitRoundingPrecision();
        ExpectedPrice := Round(Item."Unit Price" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ServiceCommitment.TestField(Price, ExpectedPrice);

        ServiceCommitment.Next();
        ExpectedPrice := Round(Item."Unit Cost" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ServiceCommitment.TestField(Price, ExpectedPrice);
    end;

    [Test]
    procedure CheckServiceCommitmentServiceAmountCalculation()
    var
        ExpectedServiceAmount: Decimal;
        ChangedCalculationBaseAmount: Decimal;
        DiscountPercent: Decimal;
        ServiceAmountBiggerThanPrice: Decimal;
        NegativeServiceAmount: Decimal;
        MaxServiceAmount: Decimal;
        Price: Decimal;
    begin
        SetupServiceObjectWithServiceCommitment(false, false);

        Currency.InitRoundingPrecision();
        Price := Round(Item."Unit Price" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(ServiceObject."Quantity Decimal" * Price, Currency."Amount Rounding Precision");
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        ChangedCalculationBaseAmount := LibraryRandom.RandDec(1000, 2);
        ServiceCommitment.Validate("Calculation Base Amount", ChangedCalculationBaseAmount);

        ExpectedServiceAmount := Round((ServiceCommitment.Price * ServiceObject."Quantity Decimal"), Currency."Amount Rounding Precision");
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        DiscountPercent := LibraryRandom.RandDec(100, 2);
        ServiceCommitment.Validate("Discount %", DiscountPercent);

        ExpectedServiceAmount := Round((ServiceCommitment.Price * ServiceObject."Quantity Decimal") - (ServiceCommitment.Price * ServiceObject."Quantity Decimal" * DiscountPercent / 100), Currency."Amount Rounding Precision");
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);
        Commit(); // retain data after asserterror

        ServiceAmountBiggerThanPrice := Round(ServiceCommitment.Price * (ServiceObject."Quantity Decimal" + 1), Currency."Amount Rounding Precision");
        asserterror ServiceCommitment.Validate("Service Amount", ServiceAmountBiggerThanPrice);
        NegativeServiceAmount := -1 * LibraryRandom.RandDec(100, 2);
        asserterror ServiceCommitment.Validate("Service Amount", NegativeServiceAmount);
        MaxServiceAmount := Round((ServiceCommitment.Price * ServiceObject."Quantity Decimal"), Currency."Amount Rounding Precision");
        asserterror ServiceCommitment.Validate("Discount Amount", MaxServiceAmount + LibraryRandom.RandDec(100, 2));
    end;

    [Test]
    procedure CheckServiceCommitmentDiscountCalculation()
    var
        DiscountPercent: Decimal;
        ExpectedDiscountAmount: Decimal;
        DiscountAmount: Decimal;
        ExpectedDiscountPercent: Decimal;
        ServiceAmountInt: Integer;
    begin
        SetupServiceObjectWithServiceCommitment(false, false);

        ServiceCommitment.TestField("Discount %", 0);
        ServiceCommitment.TestField("Discount Amount", 0);
        Currency.InitRoundingPrecision();

        DiscountPercent := LibraryRandom.RandDec(50, 2);
        ExpectedDiscountAmount := Round(ServiceCommitment."Service Amount" * DiscountPercent / 100, Currency."Amount Rounding Precision");
        ServiceCommitment.Validate("Discount %", DiscountPercent);
        ServiceCommitment.TestField("Discount Amount", ExpectedDiscountAmount);

        Evaluate(ServiceAmountInt, Format(ServiceCommitment."Service Amount", 0, '<Integer>'));
        DiscountAmount := LibraryRandom.RandDec(ServiceAmountInt, 2);
        ExpectedDiscountPercent := Round(DiscountAmount / Round((ServiceCommitment.Price * ServiceObject."Quantity Decimal"), Currency."Amount Rounding Precision") * 100, 0.00001);
        ServiceCommitment.Validate("Discount Amount", DiscountAmount);
        ServiceCommitment.TestField("Discount %", ExpectedDiscountPercent);
    end;

    [Test]
    procedure CheckServiceCommitmentServiceInitialEndDateCalculation()
    var
        DateFormulaVariable: DateFormula;
        ExpectedServiceEndDate: Date;
    begin
        SetupServiceObjectWithServiceCommitment(false, false);
        ServiceCommitment.Validate("Service Start Date", WorkDate());

        Evaluate(DateFormulaVariable, '<1M>');

        Clear(ServiceCommitment."Extension Term");
        ServiceCommitment.Validate("Initial Term", DateFormulaVariable);
        ExpectedServiceEndDate := CalcDate(ServiceCommitment."Initial Term", ServiceCommitment."Service Start Date");
        ExpectedServiceEndDate := CalcDate('<-1D>', ExpectedServiceEndDate);
        ServiceCommitment.CalculateInitialServiceEndDate();
        ServiceCommitment.TestField("Service End Date", ExpectedServiceEndDate);

        Clear(ServiceCommitment."Service End Date");
        ServiceCommitment.Validate("Extension Term", DateFormulaVariable);
        ServiceCommitment.CalculateInitialServiceEndDate();
        ServiceCommitment.TestField("Service End Date", 0D);

        Clear(ServiceCommitment."Service End Date");
        Clear(ServiceCommitment."Extension Term");
        Clear(ServiceCommitment."Initial Term");
        ServiceCommitment.CalculateInitialServiceEndDate();
        ServiceCommitment.TestField("Service End Date", 0D);
    end;


    [Test]
    procedure CheckServiceCommitmentServiceInitialTerminationDatesCalculation()
    var
        ServiceAndCalculationStartDate: Date;
    begin
        ClearAll();
        ServiceAndCalculationStartDate := WorkDate();
        SetupServiceObjectTemplatePackageAndAssignItemToPackage();
        ModifyCurrentServiceCommPackageLine('<12M>', '<1M>', '<1M>');

        AddNewServiceCommPackageLine('<12M>', '<1M>', '');
        AddNewServiceCommPackageLine('<12M>', '', '');
        AddNewServiceCommPackageLine('', '<1M>', '<1M>');
        AddNewServiceCommPackageLine('', '<1M>', '');
        AddNewServiceCommPackageLine('', '', '');

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");

        ServiceCommitment.FindFirst();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
    end;

    local procedure TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate: Date; SourceServiceCommitment: Record "Service Commitment")
    var
        ExpectedDate: Date;
    begin
        if Format(SourceServiceCommitment."Initial Term") <> '' then
            ExpectedDate := GetCancellationPossibleUntilDate(ServiceAndCalculationStartDate, SourceServiceCommitment."Initial Term", SourceServiceCommitment."Extension Term", SourceServiceCommitment."Notice Period")
        else
            ExpectedDate := GetUpdatedCancellationPossibleUntilDate(SourceServiceCommitment."Term Until", SourceServiceCommitment);
        AssertThat.AreEqual(ExpectedDate, SourceServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" Date is not calculated correctly.');
        ExpectedDate := GetTermUntilDate(ServiceAndCalculationStartDate, SourceServiceCommitment."Service End Date", SourceServiceCommitment."Initial Term", SourceServiceCommitment."Extension Term", SourceServiceCommitment."Notice Period");
        AssertThat.AreEqual(ExpectedDate, SourceServiceCommitment."Term Until", '"Term Until" Date is not calculated correctly.');
    end;

    local procedure AddNewServiceCommPackageLine(InitialTermDateFormulaText: Text; ExtensionTermDateFormulaText: Text; NoticePeriodDateFormulaText: Text)
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ModifyCurrentServiceCommPackageLine(InitialTermDateFormulaText, ExtensionTermDateFormulaText, NoticePeriodDateFormulaText);
    end;

    local procedure ModifyCurrentServiceCommPackageLine(InitialTermDateFormulaText: Text; ExtensionTermDateFormulaText: Text; NoticePeriodDateFormulaText: Text)
    begin
        if InitialTermDateFormulaText <> '' then
            Evaluate(ServiceCommPackageLine."Initial Term", InitialTermDateFormulaText);
        if ExtensionTermDateFormulaText <> '' then
            Evaluate(ServiceCommPackageLine."Extension Term", ExtensionTermDateFormulaText);
        if NoticePeriodDateFormulaText <> '' then
            Evaluate(ServiceCommPackageLine."Notice Period", NoticePeriodDateFormulaText);
        if (InitialTermDateFormulaText <> '') or (ExtensionTermDateFormulaText <> '') or (NoticePeriodDateFormulaText <> '') then
            ServiceCommPackageLine.Modify(false);
    end;

    local procedure GetTermUntilDate(StartDate: Date; EndDate: Date; InitialTermDateFormula: DateFormula; ExtensionTermDateFormula: DateFormula; NoticePeriodDateFormula: DateFormula) TermUntil: Date
    begin
        if EndDate <> 0D then begin
            TermUntil := EndDate;
            exit;
        end;

        if Format(ExtensionTermDateFormula) = '' then
            exit;
        if (Format(NoticePeriodDateFormula) = '') and (Format(InitialTermDateFormula) = '') then
            exit;

        if StartDate = 0D then
            Error('Start Date is not entered.');
        if Format(InitialTermDateFormula) <> '' then begin
            TermUntil := CalcDate(InitialTermDateFormula, StartDate);
            TermUntil := CalcDate('<-1D>', TermUntil);
        end else begin
            TermUntil := CalcDate(NoticePeriodDateFormula, StartDate);
            TermUntil := CalcDate('<-1D>', TermUntil);
        end;
    end;

    local procedure GetCancellationPossibleUntilDate(StartDate: Date; InitialTermDateFormula: DateFormula; ExtensionTermDateFormula: DateFormula; NoticePeriodDateFormula: DateFormula) CancellationPossibleUntil: Date
    var
        NegativeDateFormula: DateFormula;
        DateFormulaLbl: Label '-%1', Locked = true;
    begin
        if Format(ExtensionTermDateFormula) = '' then
            exit;
        if Format(NoticePeriodDateFormula) = '' then
            exit;
        if Format(InitialTermDateFormula) = '' then
            exit;

        if StartDate = 0D then
            Error('Start Date is not entered.');
        CancellationPossibleUntil := CalcDate(InitialTermDateFormula, StartDate);
        Evaluate(NegativeDateFormula, StrSubstNo(DateFormulaLbl, NoticePeriodDateFormula));
        CancellationPossibleUntil := CalcDate(NegativeDateFormula, CancellationPossibleUntil);
        CancellationPossibleUntil := CalcDate('<-1D>', CancellationPossibleUntil);
    end;

    [Test]
    procedure CheckServiceCommitmentUpdateTerminationDatesCalculation()
    var
        ServiceCommitment2: Record "Service Commitment";
        ServiceAndCalculationStartDate: Date;
    begin
        ClearAll();
        ServiceAndCalculationStartDate := CalcDate('<-5Y>', WorkDate());
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        Evaluate(ServiceCommPackageLine."Initial Term", '<12M>');
        Evaluate(ServiceCommPackageLine."Extension Term", '<12M>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();

        repeat
            ServiceCommitment2 := ServiceCommitment;
            ServiceCommitment.UpdateTermUntilUsingExtensionTerm();
            ServiceCommitment.UpdateCancellationPossibleUntil();
            ServiceCommitment.Modify(false);
            TestServiceCommitmentUpdatedTerminationDates(ServiceCommitment2, ServiceCommitment);
        until WorkDate() <= ServiceCommitment."Cancellation Possible Until";
    end;

    local procedure TestServiceCommitmentUpdatedTerminationDates(ServiceCommitment2: Record "Service Commitment"; SourceServiceCommitment: Record "Service Commitment")
    var
        ExpectedDate: Date;
    begin
        ExpectedDate := GetUpdatedTermUntilDate(ServiceCommitment2."Term Until", SourceServiceCommitment);
        AssertThat.AreEqual(ExpectedDate, SourceServiceCommitment."Term Until", '"Term Until" Date is not calculated correctly.');
        ExpectedDate := GetUpdatedCancellationPossibleUntilDate(SourceServiceCommitment."Term Until", ServiceCommitment);
        AssertThat.AreEqual(ExpectedDate, SourceServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" Date is not calculated correctly.');
    end;

    local procedure GetUpdatedTermUntilDate(CalculationStartDate: Date; SourceServiceCommitment: Record "Service Commitment") TermUntil: Date
    begin
        if (Format(SourceServiceCommitment."Extension Term") = '') or (CalculationStartDate = 0D) then
            exit(0D);
        TermUntil := CalcDate(SourceServiceCommitment."Extension Term", CalculationStartDate);
    end;

    local procedure GetUpdatedCancellationPossibleUntilDate(CalculationStartDate: Date; SourceServiceCommitment: Record "Service Commitment") CancellationPossibleUntil: Date
    var
        NegativeDateFormula: DateFormula;
        DateFormulaLbl: Label '-%1', Locked = true;
    begin
        if Format(SourceServiceCommitment."Notice Period") = '' then
            exit(0D);
        Evaluate(NegativeDateFormula, StrSubstNo(DateFormulaLbl, SourceServiceCommitment."Notice Period"));
        CancellationPossibleUntil := CalcDate(NegativeDateFormula, CalculationStartDate);
    end;

    [Test]
    procedure CheckServiceCommitmentServiceDates()
    begin
        SetupServiceObjectWithServiceCommitment(false, false);

        ValidateServiceDateCombination(WorkDate(), WorkDate(), WorkDate());
        ValidateServiceDateCombination(WorkDate(), CalcDate('<+5D>', WorkDate()), CalcDate('<+3D>', WorkDate()));
        ValidateServiceDateCombination(WorkDate(), CalcDate('<+5D>', WorkDate()), CalcDate('<+6D>', WorkDate())); //allow setting the Service End Date one day before Next Billing Date
        asserterror ValidateServiceDateCombination(WorkDate(), CalcDate('<+5D>', WorkDate()), CalcDate('<-3D>', WorkDate()));
        asserterror ValidateServiceDateCombination(WorkDate(), CalcDate('<+4D>', WorkDate()), CalcDate('<+6D>', WorkDate())); //do not allow setting the Service End Date two or more days before Next Billing Date - because Service was invoiced up to Next Billing Date
    end;

    local procedure ValidateServiceDateCombination(StartDate: Date; EndDate: Date; NextCalcDate: Date)
    begin
        Clear(ServiceCommitment."Service Start Date");
        Clear(ServiceCommitment."Service End Date");
        Clear(ServiceCommitment."Next Billing Date");
        ServiceCommitment."Service Start Date" := StartDate;
        ServiceCommitment."Service End Date" := EndDate;
        ServiceCommitment."Next Billing Date" := NextCalcDate;
        ServiceCommitment.Validate("Service End Date");
    end;

    [Test]
    procedure ExpectErrorForNegativeServiceCommitmentDateFormulaFields()
    var
        NegativeDateFormula: DateFormula;
    begin
        SetupServiceObjectWithServiceCommitment(false, false);
        Commit(); // retain data after asserterror

        Evaluate(NegativeDateFormula, '<-1M>');
        asserterror ServiceCommitment.Validate("Billing Base Period", NegativeDateFormula);
        asserterror ServiceCommitment.Validate("Notice Period", NegativeDateFormula);
        asserterror ServiceCommitment.Validate("Initial Term", NegativeDateFormula);
        asserterror ServiceCommitment.Validate("Extension Term", NegativeDateFormula);
        asserterror ServiceCommitment.Validate("Billing Rhythm", NegativeDateFormula);
    end;

    [Test]
    procedure CheckCalculationDateFormulaEntry()
    begin
        SetupServiceObjectWithServiceCommitment(false, false);
        Commit();  // retain data after asserterror

        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<5D>', '<20D>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1W>', '<4W>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1M>', '<6Q>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1Q>', '<3Q>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1Y>', '<2Y>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<3M>', '<1Y>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<6M>', '<1Q>');
        ServiceCommitment.Modify(true);

        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1D>', '<1M>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1W>', '<1M>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<2M>', '<7M>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<2Q>', '<5Q>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<2Y>', '<3Y>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<CM>', '<1Y>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1M + 1Q>', '<1Y>');
        asserterror ServiceCommitment.Modify(true);
    end;

    [Test]
    procedure CheckServiceObjectQtyCannotBeBlank()
    begin
        ClearAll();

        ContractTestLibrary.CreateServiceObject(ServiceObject, '');
        asserterror ServiceObject.Validate("Quantity Decimal", 0);
    end;


    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckServiceObjectQtyRecalculation()
    var
        ExpectedServiceAmount: Decimal;
        Price: Decimal;
        Quantity2: Decimal;
        Quantity3: Decimal;
        ExpectedCalculationBaseAmount: Decimal;
    begin
        SetupServiceObjectWithServiceCommitment(false, false);

        Currency.InitRoundingPrecision();
        Price := Round(Item."Unit Price" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(ServiceObject."Quantity Decimal" * Price, Currency."Amount Rounding Precision");
        ServiceCommitment.TestField("Calculation Base Amount");
        ExpectedCalculationBaseAmount := ServiceCommitment."Calculation Base Amount";
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        Quantity2 := LibraryRandom.RandDec(10, 2);
        while Quantity2 = ServiceObject."Quantity Decimal" do
            Quantity2 := LibraryRandom.RandDec(10, 2);
        Price := Round(Item."Unit Price" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(Quantity2 * Price, Currency."Amount Rounding Precision");
        ConfirmOption := true;
        ServiceObject.Validate("Quantity Decimal", Quantity2);

        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);

        Commit(); // retain data after asserterror
        ConfirmOption := false;
        Quantity3 := LibraryRandom.RandDec(10, 2);
        while Quantity3 = Quantity2 do
            Quantity3 := LibraryRandom.RandDec(10, 2);
        asserterror ServiceObject.Validate("Quantity Decimal", Quantity3);
        ServiceObject.TestField("Quantity Decimal", Quantity2);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);

        asserterror ServiceObject.Validate("Quantity Decimal", 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckServiceCommitmentCalculationBaseAmountIsNotRecalculatedOnServiceObjectQuantityChange()
    var
        ExpectedServiceAmount: Decimal;
        Price: Decimal;
        Quantity2: Decimal;
        ExpectedCalculationBaseAmount: Decimal;
    begin
        // If Service Commitment field "Calculation Base Amount" is changed manually
        SetupServiceObjectWithServiceCommitment(false, false);
        ServiceCommitment.TestField("Calculation Base Amount");
        ExpectedCalculationBaseAmount := LibraryRandom.RandDec(100, 2);
        ServiceCommitment.Validate("Calculation Base Amount", ExpectedCalculationBaseAmount);
        ServiceCommitment.Modify(false);

        Currency.InitRoundingPrecision();
        Price := Round(ExpectedCalculationBaseAmount * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(ServiceObject."Quantity Decimal" * Price, Currency."Amount Rounding Precision");
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        // When Service Object Quantity is changed
        Quantity2 := LibraryRandom.RandDec(10, 2);
        while Quantity2 = ServiceObject."Quantity Decimal" do
            Quantity2 := LibraryRandom.RandDec(10, 2);
        Price := Round(ExpectedCalculationBaseAmount * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(Quantity2 * Price, Currency."Amount Rounding Precision");
        ConfirmOption := true;
        ServiceObject.Validate("Quantity Decimal", Quantity2);

        // then "Calculation Base Amount" field should not be recalculated
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);
    end;

    [Test]
    procedure CheckClearTerminationPeriods()
    var
        ServiceAndCalculationStartDate: Date;
        ServiceEndDate: Date;
    begin
        ClearAll();
        ServiceAndCalculationStartDate := CalcDate('<-1Y>', WorkDate());
        SetupServiceObjectTemplatePackageAndAssignItemToPackage();
        ModifyCurrentServiceCommPackageLine('<12M>', '<12M>', '<1M>');

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        AssertThat.AreEqual(0D, ServiceCommitment."Service End Date", '"Service End Date" is set.');
        AssertThat.AreNotEqual(0D, ServiceCommitment."Term Until", '"Term Until" not set.');
        AssertThat.AreNotEqual(0D, ServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" is not set.');

        ServiceEndDate := CalcDate('<-6M>', WorkDate());

        ServiceCommitment.Validate("Service End Date", ServiceEndDate);
        AssertThat.AreEqual(0D, ServiceCommitment."Term Until", '"Term Until" not cleared.');
        AssertThat.AreEqual(0D, ServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" is not cleared.');
    end;

    [Test]
    procedure CheckUpdatingTerminationDatesOnManualValidation()
    var
        NegativeDateFormula: DateFormula;
        ServiceAndCalculationStartDate: Date;
        DateFormulaLbl: Label '-%1', Locked = true;
    begin
        ClearAll();
        ServiceAndCalculationStartDate := WorkDate();
        SetupServiceObjectTemplatePackageAndAssignItemToPackage();
        ModifyCurrentServiceCommPackageLine('<12M>', '<12M>', '<1M>');

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        AssertThat.AreNotEqual(0D, ServiceCommitment."Term Until", '"Term Until" is not set.');
        AssertThat.AreNotEqual(0D, ServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" is not set.');
        AssertThat.AreNotEqual('', ServiceCommitment."Notice Period", '"Notice Period" is not set.');

        ServiceCommitment.Validate("Cancellation Possible Until", CalcDate('<+5D>', ServiceCommitment."Cancellation Possible Until"));
        AssertThat.AreEqual(CalcDate(ServiceCommitment."Notice Period", ServiceCommitment."Cancellation Possible Until"), ServiceCommitment."Term Until", '"Term Until" Date is not calculated correctly.');

        ServiceCommitment.Validate("Term Until", CalcDate('<-7D>', ServiceCommitment."Term Until"));
        Evaluate(NegativeDateFormula, StrSubstNo(DateFormulaLbl, ServiceCommitment."Notice Period"));
        AssertThat.AreEqual(CalcDate(NegativeDateFormula, ServiceCommitment."Term Until"), ServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" Date is not calculated correctly.');
    end;


    [Test]
    procedure CheckUpdatingProvisionEndDateOnAfterFinishContractLines()
    var
        i: Integer;
    begin
        ClearAll();
        i := -1;
        SetupServiceObjectTemplatePackageAndAssignItemToPackage();
        ModifyCurrentServiceCommPackageLine('<12M>', '<12M>', '<1M>');

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Service Start Date" := CalcDate('<-2D>', Today());
                ServiceCommitment."Service End Date" := Today() + i;
                ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Service End Date");
                ServiceCommitment.Modify(false);
                i -= 1;
            until ServiceCommitment.Next() = 0;
        ServiceObject.UpdateServicesDates();
        AssertThat.AreEqual(CalcDate('<-1D>', Today()), ServiceObject."Provision End Date", 'Provision End Date was not updated properly.');
    end;

    [Test]
    procedure ExpectErrorOnChangeEndUserIfServiceObjectIsLinkedToContract()
    begin
        SetupServiceObjectWithServiceCommitment(false, false);
        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomer(Customer2);
        asserterror ServiceObject.Validate("End-User Customer No.", Customer2."No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestRecreateServiceCommitmentsOnChangeEndUser()
    begin
        ClearAll();
        ConfirmOption := true;

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);

        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup1);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage1, ServiceCommPackageLine1);
        ServiceCommitmentPackage1."Price Group" := CustomerPriceGroup1.Code;
        ServiceCommitmentPackage1.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage1.Code, true);

        ContractTestLibrary.CreateCustomer(Customer);
        Customer."Customer Price Group" := CustomerPriceGroup1.Code;
        Customer.Modify(false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(true);

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Package Code", ServiceCommitmentPackage1.Code);
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure CheckCalculationBaseAmountAssignment()
    var
        CustomerPrice: array[4] of Decimal;
        FutureReferenceDate: Date;
        EndingDate: Date;
    begin
        // Create Service Object and Service Commitments - Unit Price from Item should be taken as Calculation Base Amount
        ClearAll();
        SetupServiceObjectWithServiceCommitment(false, false);
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");
        ServiceCommitmentPackage.SetRange(Code, ServiceCommitment."Package Code");
        ServiceCommitment.DeleteAll(false);

        // Assign End-User Customer No. Service Object with and create Service Commitments - Unit Price from Item should be taken as Calculation Base Amount
        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");
        ServiceCommitment.DeleteAll(false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);

        // Create different Sales Prices for Customer
        CustomerPrice[1] := LibraryRandom.RandDec(100, 2); // normal price
        CustomerPrice[2] := Round(CustomerPrice[1] * 0.9, 2); // discounted price for Qty = 10
        CustomerPrice[3] := LibraryRandom.RandDecInRange(101, 200, 2); // price used in future
        CustomerPrice[4] := Round(CustomerPrice[3] * 0.9, 2); // price used in future + discounted price for Qty = 10
        FutureReferenceDate := CalcDate('<1M>', WorkDate());
        EndingDate := CalcDate('<-1D>', FutureReferenceDate);
        CreateCustomerSalesPrice(Item, Customer, WorkDate(), 0, CustomerPrice[1], EndingDate);
        CreateCustomerSalesPrice(Item, Customer, WorkDate(), 10, CustomerPrice[2], EndingDate);
        CreateCustomerSalesPrice(Item, Customer, FutureReferenceDate, 0, CustomerPrice[3]);
        CreateCustomerSalesPrice(Item, Customer, FutureReferenceDate, 10, CustomerPrice[4]);
        // test - normal price
        TestCalculationBaseAmount(1, WorkDate(), CustomerPrice[1]);
        // test - discounted price for Qty = 10
        TestCalculationBaseAmount(10, WorkDate(), CustomerPrice[2]);
        // test - price used in future
        TestCalculationBaseAmount(1, FutureReferenceDate, CustomerPrice[3]);
        // test - price used in future + discounted price for Qty = 10
        TestCalculationBaseAmount(10, FutureReferenceDate, CustomerPrice[4]);
    end;

    local procedure TestCalculationBaseAmount(ServiceObjectQuantity: Decimal; ReferenceDate: Date; ExpectedPrice: Decimal)
    begin
        ServiceObject.Validate("Quantity Decimal", ServiceObjectQuantity);
        ServiceObject.Modify(false);
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ReferenceDate, ServiceCommitmentPackage);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedPrice);
        ServiceCommitment.DeleteAll(false);
    end;

    [Test]
    procedure CheckCalculationBaseAmountAssignmentForCustomerWithBillToCustomer()
    var
        CustomerPrice: array[4] of Decimal;
        Customer2Price: array[4] of Decimal;
        FutureReferenceDate: Date;
        EndingDate: Date;
    begin
        // Create Service Object and Service Commitments - Unit Price from Item should be taken as Calculation Base Amount
        ClearAll();
        SetupServiceObjectWithServiceCommitment(false, false);
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");
        ServiceCommitmentPackage.SetRange(Code, ServiceCommitment."Package Code");
        ServiceCommitment.DeleteAll(false);

        // Create Customer and Customer2 and assign Customer2 as "Bill-to Customer No."" to Customer
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomer(Customer2);
        Customer.Validate("Bill-to Customer No.", Customer2."No.");
        Customer.Modify(false);

        // Assign End-User Customer No. to Service Object and create Service Commitments - Unit Price from Item should be taken as Calculation Base Amount
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");
        ServiceCommitment.DeleteAll(false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);

        // Create different Sales Prices for Customer
        CustomerPrice[1] := LibraryRandom.RandDec(100, 2); // normal price
        CustomerPrice[2] := Round(CustomerPrice[1] * 0.9, 2); // discounted price for Qty = 10
        CustomerPrice[3] := LibraryRandom.RandDecInRange(101, 200, 2); // price used in future
        CustomerPrice[4] := Round(CustomerPrice[3] * 0.9, 2); // price used in future + discounted price for Qty = 10
        Customer2Price[1] := LibraryRandom.RandDec(100, 2); // normal price
        Customer2Price[2] := Round(Customer2Price[1] * 0.9, 2); // discounted price for Qty = 10
        Customer2Price[3] := LibraryRandom.RandDecInRange(101, 200, 2); // price used in future
        Customer2Price[4] := Round(Customer2Price[3] * 0.9, 2); // price used in future + discounted price for Qty = 10
        FutureReferenceDate := CalcDate('<1M>', WorkDate());
        EndingDate := CalcDate('<-1D>', FutureReferenceDate);
        CreateCustomerSalesPrice(Item, Customer2, WorkDate(), 0, Customer2Price[1], EndingDate);
        CreateCustomerSalesPrice(Item, Customer2, WorkDate(), 10, Customer2Price[2], EndingDate);
        CreateCustomerSalesPrice(Item, Customer2, FutureReferenceDate, 0, Customer2Price[3]);
        CreateCustomerSalesPrice(Item, Customer2, FutureReferenceDate, 10, Customer2Price[4]);
        CreateCustomerSalesPrice(Item, Customer, WorkDate(), 0, CustomerPrice[1], EndingDate);
        CreateCustomerSalesPrice(Item, Customer, WorkDate(), 10, CustomerPrice[2], EndingDate);
        CreateCustomerSalesPrice(Item, Customer, FutureReferenceDate, 0, CustomerPrice[3]);
        CreateCustomerSalesPrice(Item, Customer, FutureReferenceDate, 10, CustomerPrice[4]);

        // test - normal price
        TestCalculationBaseAmount(1, WorkDate(), Customer2Price[1]);
        // test - discounted price for Qty = 10
        TestCalculationBaseAmount(10, WorkDate(), Customer2Price[2]);
        // test - price used in future
        TestCalculationBaseAmount(1, FutureReferenceDate, Customer2Price[3]);
        // test - price used in future + discounted price for Qty = 10
        TestCalculationBaseAmount(10, FutureReferenceDate, Customer2Price[4]);
    end;

    [Test]
    procedure TestModifyCustomerAddress()
    var
    begin
        // Create Service Object with End-User
        ClearAll();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateServiceObject(ServiceObject, '');
        ServiceObject.Validate("End-User Customer No.");

        // Change in address fields should be possible without error
        ServiceObject.Validate("End-User Address", LibraryRandom.RandText(MaxStrLen(ServiceObject."End-User Address")));
        ServiceObject.Validate("End-User Address 2", LibraryRandom.RandText(MaxStrLen(ServiceObject."End-User Address 2")));
        ServiceObject.Modify(false);
    end;

    local procedure CreateCustomerSalesPrice(SourceItem: Record Item; SourceCustomer: Record Customer; StartingDate: Date; Quantity: Decimal; CustomerPrice: Decimal)
    begin
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::Customer, SourceCustomer."No.");
        PriceListHeader.Status := "Price Status"::Active;
        PriceListHeader."Allow Updating Defaults" := true;
        PriceListHeader."Currency Code" := '';
        PriceListHeader.Modify(true);

        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, "Price Amount Type"::Price, "Price Asset Type"::Item, SourceItem."No.");
        PriceListLine.Validate("Starting Date", StartingDate);
        PriceListLine.Validate("Minimum Quantity", Quantity);
        PriceListLine."Currency Code" := '';
        PriceListLine.Validate("Unit Price", CustomerPrice);
        PriceListLine.Status := "Price Status"::Active;
        PriceListLine.Modify(true);
    end;

    local procedure CreateCustomerSalesPrice(SourceItem: Record Item; SourceCustomer: Record Customer; StartingDate: Date; Quantity: Decimal; CustomerPrice: Decimal; EndingDate: Date)
    begin
        CreateCustomerSalesPrice(SourceItem, SourceCustomer, StartingDate, Quantity, CustomerPrice);
        PriceListLine.Status := "Price Status"::Draft;
        PriceListLine.Validate("Ending Date", EndingDate);
        PriceListLine.Status := "Price Status"::Active;
        PriceListLine.Modify(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ExpectErrorOnChangeEndUserIfCustomerPostingGroupEmpty()
    var
        EndUserCustomer: Record Customer;
    begin
        SetupServiceObjectWithServiceCommitment(false, false);
        ContractTestLibrary.CreateCustomer(EndUserCustomer);
        EndUserCustomer.Validate("Customer Posting Group", '');
        EndUserCustomer.Modify(false);

        ConfirmOption := true;
        asserterror ServiceObject.Validate("End-User Customer No.", EndUserCustomer."No."); // ConfirmHandler
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckChangeQuantityIfCustomerPostingGroupEmpty()
    var
        EndUserCustomer: Record Customer;
        CustomerWithPostingGroup: Record Customer;
        OldQuantity: Decimal;
    begin
        SetupServiceObjectWithServiceCommitment(false, false);

        ContractTestLibrary.CreateCustomer(EndUserCustomer);
        ContractTestLibrary.CreateCustomer(CustomerWithPostingGroup);
        EndUserCustomer.Validate("Customer Posting Group", '');
        EndUserCustomer.Validate("Bill-to Customer No.", CustomerWithPostingGroup."No.");
        EndUserCustomer.Modify(false);

        ConfirmOption := true;
        ServiceObject.Validate("End-User Customer No.", EndUserCustomer."No."); //ConfirmHandler
        ServiceObject.Modify(false);
        OldQuantity := ServiceObject."Quantity Decimal";
        ServiceObject.Validate("Quantity Decimal", ServiceObject."Quantity Decimal" + 1); //ConfirmHandler
        AssertThat.AreEqual(OldQuantity + 1, ServiceObject."Quantity Decimal", 'Service Object Quantity has to be changeable with "Customer Posting Group" filled for "Bill-to Customer No.".');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckDeleteServiceObjectWithArchivedServComm()
    var
        ServCommArchive: Record "Service Commitment Archive";
        ServComm: Record "Service Commitment";
    begin

        SetupServiceObjectWithServiceCommitment(false, true);
        ConfirmOption := true;
        // Change quantity to create entries in Service Commitment Archive
        ServiceObject.Validate("Quantity Decimal", LibraryRandom.RandDecInRange(2, 10, 2));  // ConfirmHandler
        ServiceObject.Modify(false);
        ServCommArchive.SetRange("Service Object No.", ServiceObject."No.");
        AssertThat.AreNotEqual(0, ServCommArchive.Count(), 'Entries in Service Commitment Archive should exist after changing quantity in Service Object.');

        // Delete Service Commitments & Service Objects to check if archive gets deleted
        ServComm.Reset();
        ServComm.SetRange("Service Object No.", ServiceObject."No.");
        ServComm.DeleteAll(false);

        ServiceObject.Delete(true);
        AssertThat.AreEqual(0, ServCommArchive.Count(), 'Entries in Service Commitment Archive should be deleted after deleting Service Object.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckArchivedServCommAmounts()
    var
        ServCommArchive: Record "Service Commitment Archive";
        ServComm: Record "Service Commitment";
        TempServComm: Record "Service Commitment" temporary;
        OldQuantity: Decimal;
    begin
        ClearAll();
        SetupServiceObjectWithServiceCommitment(false, true);

        // Save Service Commitments before changing quantity
        ServComm.SetRange("Service Object No.", ServiceObject."No.");
        ServComm.FindSet();
        repeat
            TempServComm := ServComm;
            TempServComm.Insert(false);
        until ServComm.Next() = 0;

        ConfirmOption := true;
        // Change quantity to create entries in Service Commitment Archive
        OldQuantity := ServiceObject."Quantity Decimal";
        ServiceObject.Validate("Quantity Decimal", LibraryRandom.RandDecInRange(2, 10, 2));  // ConfirmHandler
        ServiceObject.Modify(false);

        // Check if archive has saved the correct (old) Service Amount
        ServCommArchive.SetRange("Service Object No.", ServiceObject."No.");
        ServCommArchive.SetRange("Quantity Decimal (Service Ob.)", OldQuantity);
        ServCommArchive.FindSet();
        repeat
            TempServComm.Get(ServCommArchive."Original Entry No.");
            AssertThat.AreEqual(TempServComm."Service Amount", ServCommArchive."Service Amount", 'Service Amount in Service Commitment Archive should be the value of the Service Commitment before the quantity change.');
        until ServCommArchive.Next() = 0;
    end;

    [Test]
    procedure CheckChangeServiceObjectSN()
    var
        ServCommArchive: Record "Service Commitment Archive";
        ServiceObjectPage: TestPage "Service Object";
        SN: Code[50];
    begin
        ClearAll();
        SetupServiceObjectWithServiceCommitment(true, false);
        SN := ServiceObject."Serial No.";

        ServCommArchive.Reset();
        ServCommArchive.SetRange("Service Object No.", ServiceObject."No.");
        if not ServCommArchive.IsEmpty() then
            ServCommArchive.DeleteAll(false);

        Clear(ServiceObjectPage);
        ServiceObjectPage.OpenView();
        ServiceObjectPage.GoToRecord(ServiceObject);
        ServiceObjectPage."Serial No.".SetValue(LibraryRandom.RandText(MaxStrLen(ServiceObject."Serial No.")));
        ServiceObjectPage.Close();

        ServCommArchive.Reset();
        ServCommArchive.SetRange("Service Object No.", ServiceObject."No.");
        AssertThat.AreEqual(1, ServCommArchive.Count(), 'Expected one Serv. Comm. Archive Entry after changing the SN');
        ServCommArchive.FindFirst();
        AssertThat.AreEqual(SN, ServCommArchive."Serial No. (Service Object)", 'The original Serial No. should have been archived.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,AssignServiceCommitmentsModalPageHandler')]
    procedure TestPriceGroupFilterOnAssignServiceCommitments()
    var
        ServiceObjectPage: TestPage "Service Object";
    begin
        ClearAll();
        ConfirmOption := true;

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ServiceCommitmentPackage.FilterCodeOnPackageFilter(ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);

        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup1);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage1, ServiceCommPackageLine1);
        ServiceCommitmentPackage1."Price Group" := CustomerPriceGroup1.Code;
        ServiceCommitmentPackage1.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage1.Code, true);

        ContractTestLibrary.CreateCustomer(Customer);
        Customer."Customer Price Group" := CustomerPriceGroup1.Code;
        Customer.Modify(false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(true);

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(false); //Remove all servicecommitments assigned on Validate Item No. in Service Object

        ServiceObjectPage.OpenEdit();
        ServiceObjectPage.GoToRecord(ServiceObject);
        ServiceObjectPage.AssignServices.Invoke();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Package Code", ServiceCommitmentPackage1.Code); //Expect only Service commitments from Package 1 because of the Customer Price group
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestRecalculateServiceCommitmentsOnChangeBillToCustomer()
    var
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        ContractsItemManagement: Codeunit "Contracts Item Management";
        NewUnitPrice: Decimal;
    begin
        ClearAll();
        ConfirmOption := true;

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, Format(ServiceCommPackageLine."Billing Base Period"), ServiceCommPackageLine."Calculation Base %",
                                                               Format(ServiceCommPackageLine."Billing Rhythm"), Format(ServiceCommPackageLine."Extension Term"), "Service Partner"::Vendor, ServiceCommPackageLine."Invoicing Item No.");
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage1, ServiceCommPackageLine1);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage1.Code, true);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(true);

        ContractTestLibrary.CreateCustomer(Customer2);
        NewUnitPrice := LibraryRandom.RandDec(1000, 2);
        CreatePriceListForCustomer(Customer2."No.", NewUnitPrice);
        ServiceObject.Validate("Bill-to Customer No.", Customer2."No.");
        ServiceObject.Modify(true);

        ContractsItemManagement.CreateTempSalesHeader(TempSalesHeader, TempSalesHeader."Document Type"::Order, ServiceObject."End-User Customer No.", ServiceObject."Bill-to Customer No.", WorkDate(), '');
        ContractsItemManagement.CreateTempSalesLine(TempSalesLine, TempSalesHeader, ServiceObject."Item No.", ServiceObject."Quantity Decimal", WorkDate());

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, "Service Partner"::Customer);
        ServiceCommitment.FindSet();
        repeat
            NewUnitPrice := ContractsItemManagement.CalculateUnitPrice(TempSalesHeader, TempSalesLine);
            ServiceCommitment.TestField("Calculation Base Amount", NewUnitPrice);
        until ServiceCommitment.Next() = 0;

        ServiceCommitment.SetRange(Partner, "Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Calculation Base Amount", Item."Last Direct Cost");
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]

    procedure CheckInvoicingItemNoInServiceObjectWithServiceCommitmentItem()
    var
        ServiceObjectPage: TestPage "Service Object";
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);

        ServiceCommitmentTemplate.Description += ' Temp';
        ServiceCommitmentTemplate."Calculation Base Type" := Enum::"Calculation Base Type"::"Document Price";
        ServiceCommitmentTemplate."Calculation Base %" := 10;
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        Evaluate(ServiceCommPackageLine."Extension Term", '<1M>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1M>');
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<12M>');
        ServiceCommPackageLine.Modify(false);

        ServiceObjectPage.OpenEdit();
        ServiceObjectPage.GoToRecord(ServiceObject);
        ServiceObjectPage.AssignServices.Invoke();

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Invoicing Item No.", Item."No.");
    end;

    local procedure CreatePriceListForCustomer(CustomerNo: Code[20]; NewUnitPrice: Decimal)
    begin
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::Customer, CustomerNo);
        PriceListHeader.Status := "Price Status"::Active;
        PriceListHeader."Currency Code" := '';
        PriceListHeader.Modify(true);
        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, "Price Amount Type"::Price, "Price Asset Type"::Item, Item."No.");
        PriceListLine.Validate("Unit Price", NewUnitPrice);
    end;

    [Test]
    [HandlerFunctions('ServiceObjectAttributeValueEditorModalPageHandlerTestValues')]
    procedure CheckLoadServiceObjectAttributes()
    var
        ServiceObjectTestPage: TestPage "Service Object";
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceObjectAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute, ItemAttributeValue, false);
        ContractTestLibrary.CreateServiceObjectAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute2, ItemAttributeValue2, true);

        ServiceObjectTestPage.OpenEdit();
        ServiceObjectTestPage.GoToRecord(ServiceObject);
        ServiceObjectTestPage.Attributes.Invoke(); //ServiceObjectAttributeValueEditorModalPageHandlerTestValues
    end;

    [ModalPageHandler]
    procedure ServiceObjectAttributeValueEditorModalPageHandlerTestValues(var ServiceObjectAttributeValueEditor: TestPage "Serv. Object Attr. Values")
    begin
        ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.First();
        AssertThat.AreEqual(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList."Attribute Name".Value, ItemAttribute.Name, 'Unexpected Service Object Attribute Name');
        AssertThat.AreEqual(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Value.Value, ItemAttributeValue.Value, 'Unexpected Service Object Attribute Value');
        AssertThat.IsFalse(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Primary.AsBoolean(), 'Unexpected Service Object Attribute Primary value');
        ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Next();
        AssertThat.AreEqual(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList."Attribute Name".Value, ItemAttribute2.Name, 'Unexpected Service Object Attribute Name');
        AssertThat.AreEqual(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Value.Value, ItemAttributeValue2.Value, 'Unexpected Service Object Attribute Value');
        AssertThat.IsTrue(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Primary.AsBoolean(), 'Unexpected Service Object Attribute Primary value');
    end;

    [Test]
    [HandlerFunctions('ServiceObjectAttributeValueEditorModalPageHandlerExpectErrorOnPrimary')]
    procedure ExpectErrorOnDuplicatePrimaryServiceObjectAttribute()
    var
        ServiceObjectTestPage: TestPage "Service Object";
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceObjectAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute, ItemAttributeValue, false);
        ContractTestLibrary.CreateServiceObjectAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute2, ItemAttributeValue2, true);

        ServiceObjectTestPage.OpenEdit();
        ServiceObjectTestPage.GoToRecord(ServiceObject);
        ServiceObjectTestPage.Attributes.Invoke(); //ServiceObjectAttributeValueEditorModalPageHandlerExpectErrorOnPrimary
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestRecalculateServiceCommitmentsOnChangeServiceObjectQuantity()
    begin
        ClearAll();
        SetupServiceObjectWithServiceCommitment(false, true);
        ConfirmOption := true;
        ServiceObject.Validate("Quantity Decimal", LibraryRandom.RandDecInRange(11, 100, 2)); //In the library init value for Quantity is in the range from 0 to 10
        ServiceObject.Modify(true);

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, "Service Partner"::Customer);
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price")
        until ServiceCommitment.Next() = 0;

        ServiceCommitment.SetRange(Partner, "Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Cost")
        until ServiceCommitment.Next() = 0;
    end;

    [ModalPageHandler]
    procedure ServiceObjectAttributeValueEditorModalPageHandlerExpectErrorOnPrimary(var ServiceObjectAttributeValueEditor: TestPage "Serv. Object Attr. Values")
    begin
        ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.First();
        asserterror ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Primary.SetValue(true);
    end;

    [Test]
    procedure ExpectDocumentAttachmentsAreDeleted()
    var
        DocumentAttachment: Record "Document Attachment";
        i: Integer;
        RandomNoOfAttachments: Integer;
    begin
        // Service Object has Document Attachments created
        // when Service Object is deleted
        // expect that Document Attachments are deleted
        ContractTestLibrary.CreateServiceObject(ServiceObject, '');
        ServiceObject.TestField("No.");
        RandomNoOfAttachments := LibraryRandom.RandInt(10);
        for i := 1 to RandomNoOfAttachments do
            ContractTestLibrary.InsertDocumentAttachment(Database::"Service Object", ServiceObject."No.");

        DocumentAttachment.SetRange("Table ID", Database::"Service Object");
        DocumentAttachment.SetRange("No.", ServiceObject."No.");
        AssertThat.AreEqual(RandomNoOfAttachments, DocumentAttachment.Count(), 'Actual number of Document Attachment(s) is incorrect.');

        ServiceObject.Delete(true);
        AssertThat.AreEqual(0, DocumentAttachment.Count(), 'Document Attachment(s) should be deleted.');
    end;
}