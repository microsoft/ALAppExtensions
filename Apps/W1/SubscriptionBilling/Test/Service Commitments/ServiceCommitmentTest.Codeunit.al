namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;

codeunit 148156 "Service Commitment Test"
{
    Subtype = Test;
    Access = Internal;

    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        Item: Record Item;
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        VendorContract: Record "Vendor Subscription Contract";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        PackageLineMissingInvoicingItemNoErr: Label 'The %1 %2 can not be used with Item %3, because at least one of the Service Commitment Package lines is missing an %4.', Locked = true;

    #region Tests

    [Test]
    procedure CheckCalculationBaseDateFormulaEntry()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        Commit(); // retain data after asserterror

        ValidateDateFormulaCombinations('<5D>', '<20D>');
        ValidateDateFormulaCombinations('<1W>', '<4W>');
        ValidateDateFormulaCombinations('<1M>', '<6Q>');
        ValidateDateFormulaCombinations('<1Q>', '<3Q>');
        ValidateDateFormulaCombinations('<1Y>', '<2Y>');
        ValidateDateFormulaCombinations('<3M>', '<1Y>');
        ValidateDateFormulaCombinations('<6M>', '<1Q>');

        asserterror ValidateDateFormulaCombinations('<1D>', '<1M>');
        asserterror ValidateDateFormulaCombinations('<1W>', '<1M>');
        asserterror ValidateDateFormulaCombinations('<2M>', '<7M>');
        asserterror ValidateDateFormulaCombinations('<2Q>', '<5Q>');
        asserterror ValidateDateFormulaCombinations('<2Y>', '<3Y>');
        asserterror ValidateDateFormulaCombinations('<CM>', '<1Y>');
        asserterror ValidateDateFormulaCombinations('<1M + 1Q>', '<1Y>');
    end;

    [Test]
    [HandlerFunctions('SendNotificationHandler')]
    procedure CheckCalculationBaseTypeChangeForVendorOnServiceCommitmentPackageLine()
    begin
        Initialize();
        ServiceCommitmentTemplate."Calculation Base Type" := Enum::"Calculation Base Type"::"Document Price And Discount";
        ServiceCommitmentTemplate.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Validate(Partner, ServiceCommPackageLine.Partner::Vendor);
        ServiceCommPackageLine.TestField("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price");

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, '', ServiceCommPackageLine);
        ServiceCommPackageLine.Validate(Partner, ServiceCommPackageLine.Partner::Vendor);
        ServiceCommPackageLine.Validate(Template, ServiceCommitmentTemplate.Code);
        ServiceCommPackageLine.TestField("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price");

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, '', ServiceCommPackageLine);
        ServiceCommPackageLine.Validate(Partner, ServiceCommPackageLine.Partner::Vendor);
        asserterror ServiceCommPackageLine.Validate("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price And Discount");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckDeleteServiceCommitmentAfterDeleteCustomerContractLine()
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.DeleteAll(true);
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckDeleteServiceCommitmentAfterDeleteVendorContractLine()
    var
        VendorContractLine: Record "Vend. Sub. Contract Line";
    begin
        Initialize();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', true);
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.DeleteAll(true);
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    procedure CheckItemNoEntryOnPackageLine()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Validate("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommPackageLine.Modify(false);
        ServiceCommPackageLine.Validate("Invoicing Item No.", Item."No.");
        ServiceCommPackageLine.TestField("Invoicing Item No.", Item."No.");
        ServiceCommPackageLine.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
        ServiceCommPackageLine.TestField("Invoicing Item No.", '');
        asserterror ServiceCommPackageLine.Validate("Invoicing Item No.", Item."No.");
    end;

    [Test]
    procedure CheckItemNoEntryOnServiceCommitmentTemplate()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        ServiceCommitmentTemplate.Validate("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitmentTemplate.Modify(false);
        ServiceCommitmentTemplate.Validate("Invoicing Item No.", Item."No.");
        ServiceCommitmentTemplate.TestField("Invoicing Item No.", Item."No.");
        ServiceCommitmentTemplate.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
        ServiceCommitmentTemplate.TestField("Invoicing Item No.", '');
        asserterror ServiceCommitmentTemplate.Validate("Invoicing Item No.", Item."No.");
    end;

    [Test]
    procedure CheckIfDateFormulasAreNegative()
    var
        NegativeDateFormula: DateFormula;
        PositiveDateFormula: DateFormula;
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        Commit(); // retain data after asserterror

        Evaluate(NegativeDateFormula, '<-1M>');
        asserterror ServiceCommPackageLine.Validate("Billing Base Period", NegativeDateFormula);
        asserterror ServiceCommPackageLine.Validate("Billing Rhythm", NegativeDateFormula);
        asserterror ServiceCommPackageLine.Validate("Initial Term", NegativeDateFormula);
        asserterror ServiceCommPackageLine.Validate("Extension Term", NegativeDateFormula);
        asserterror ServiceCommPackageLine.Validate("Notice Period", NegativeDateFormula);

        Evaluate(PositiveDateFormula, '<1M>');
        ServiceCommPackageLine.Validate("Billing Base Period", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Billing Rhythm", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Sub. Line Start Formula", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Initial Term", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Extension Term", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Notice Period", PositiveDateFormula);
    end;

    [Test]
    procedure CheckIfExtensionTermEnteredBeforeNoticePeriod()
    var
        PositiveDateFormula: DateFormula;
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        Commit(); // retain data after asserterror

        Evaluate(PositiveDateFormula, '<1M>');
        asserterror ServiceCommPackageLine.Validate("Notice Period", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Extension Term", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Notice Period", PositiveDateFormula);
    end;

    [Test]
    procedure CheckPackageDeletion()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.SetRange("Subscription Package Code", ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.Delete(true);
        Assert.RecordIsEmpty(ServiceCommPackageLine);
    end;

    [Test]
    procedure CheckServiceCommitmentPackageLineDefaultAndAssignedInvoiceViaValue()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.TestField("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitmentTemplate.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
        ServiceCommitmentTemplate.Modify(false);
        ServiceCommPackageLine.Validate(Template, ServiceCommitmentTemplate.Code);
        ServiceCommPackageLine.TestField("Invoicing via", Enum::"Invoicing Via"::Sales);
    end;

    [Test]
    procedure CheckServiceCommitmentTemplateAssignmentOnPackageLine()
    begin
        Initialize();
        ServiceCommitmentTemplate.Description += ' Temp';
        ServiceCommitmentTemplate."Calculation Base Type" := Enum::"Calculation Base Type"::"Document Price";
        ServiceCommitmentTemplate."Calculation Base %" := 10;
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.TestField(Description, ServiceCommitmentTemplate.Description);
        ServiceCommPackageLine.TestField("Calculation Base Type", ServiceCommitmentTemplate."Calculation Base Type");
        ServiceCommPackageLine.TestField("Calculation Base %", ServiceCommitmentTemplate."Calculation Base %");
        ServiceCommPackageLine.TestField("Billing Base Period", ServiceCommitmentTemplate."Billing Base Period");
        ServiceCommPackageLine.TestField("Invoicing via", ServiceCommitmentTemplate."Invoicing via");
        ServiceCommPackageLine.TestField("Invoicing Item No.", ServiceCommitmentTemplate."Invoicing Item No.");
        ServiceCommPackageLine.TestField(Discount, ServiceCommitmentTemplate.Discount);
    end;

    [Test]
    procedure CopyServiceCommitmentItemLineFromSalesQuoteToSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FromDocNo: Code[20];
    begin
        // [SCENARIO] When sales order is created from sales quote expect that qty to invoice is set to 0 in case of Subscription Items
        ContractTestLibrary.InitContractsApp();

        // [GIVEN]  Create Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");

        // [GIVEN] Create sales quote
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, "Sales Document Type"::Quote, '', Item."No.", LibraryRandom.RandInt(10), '', LibraryRandom.RandDate(12));
        FromDocNo := SalesHeader."No.";

        // [GIVEN] Set sales header for the order
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, SalesHeader."Sell-to Customer No.");

        // [WHEN] Copy lines from sales quote to sales order
        LibrarySales.CopySalesDocument(SalesHeader, "Sales Document Type"::Quote, FromDocNo, false, true);

        // [THEN] Qty to Invoice = 0 in sales order line
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, Enum::"Sales Line Type"::Item);
        SalesLine.SetRange("No.", Item."No.");
        SalesLine.FindFirst();
        SalesLine.TestField("Document Type", "Sales Document Type"::Order);
        SalesLine.TestField("Qty. to Invoice", 0);
    end;

    [Test]
    procedure ExpectErrorDuringCommitmentTemplateDeletion()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommitmentTemplate.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorDeleteServiceCommitmentAfterCustomerContractLineSetToClosed()
    var
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        UpdateServiceDatesAndCloseCustomerContractLines();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenDeleteServiceCommitment()
    var
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        asserterror ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectDeleteServiceCommitmentAfterVendorContractLineSetToClosed()
    var
    begin
        Initialize();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', true);
        UpdateServiceDatesAndCloseCustomerContractLines();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyClosedServiceCommitment()
    var
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        UpdateServiceDatesAndCloseCustomerContractLines();

        ServiceCommitment."Next Billing Date" := CalcDate('<1D>', ServiceCommitment."Next Billing Date");
        asserterror ServiceCommitment.Modify(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestOverdueServiceCommitments()
    var
        OverdueServiceCommitments: Record "Overdue Subscription Line";
        ServiceContractSetup: Record "Subscription Contract Setup";
        i: Integer;
        InsertCounter: Integer;
        MaxInsertCount: Integer;
    begin
        ContractTestLibrary.InitContractsApp();
        Initialize();
        ServiceContractSetup.Get();
        Evaluate(ServiceContractSetup."Overdue Date Formula", '<1M>');
        ServiceContractSetup.Modify(false);

        // Create closed Subscription Lines that should not be considered
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true); // ExchangeRateSelectionModalPageHandler,MessageHandler
        UpdateServiceDatesAndCloseCustomerContractLines();

        // Create Subscription Lines to consider
        MaxInsertCount := LibraryRandom.RandIntInRange(2, 9);
        InsertCounter := 0;
        for i := 1 to MaxInsertCount do begin
            InsertServiceCommitment(ServiceCommitment.Partner::Customer, InsertCounter);
            if i mod 2 = 0 then
                InsertServiceCommitment(ServiceCommitment.Partner::Vendor, InsertCounter);
        end;

        Assert.AreEqual(InsertCounter, OverdueServiceCommitments.CountOverdueServiceCommitments(), 'Only service commitments that are open and within the correct date range should be counted.');
    end;

    [Test]
    procedure TestServiceCommitmentPackageCopy()
    var
        CopiedServiceCommPackageLines: Record "Subscription Package Line";
        CopiedServiceCommPackage: Record "Subscription Package";
        NewPackageFilter: Code[20];
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);

        NewPackageFilter := ServiceCommitmentPackage.Code;
        ServiceCommitmentPackage.CreateNewCodeForServiceCommPackageCopy(NewPackageFilter);

        ServiceCommitmentPackage.CopyServiceCommitmentPackage();
        CopiedServiceCommPackage.Get(NewPackageFilter);
        CopiedServiceCommPackageLines.SetRange("Subscription Package Code", CopiedServiceCommPackage.Code);
        CopiedServiceCommPackageLines.FindFirst();
        CopiedServiceCommPackageLines.TestField(Partner, ServiceCommPackageLine.Partner);
        CopiedServiceCommPackageLines.TestField(Template, ServiceCommPackageLine.Template);
        CopiedServiceCommPackageLines.TestField(Description, ServiceCommPackageLine.Description);
        CopiedServiceCommPackageLines.TestField("Invoicing via", ServiceCommPackageLine."Invoicing via");
        CopiedServiceCommPackageLines.TestField("Invoicing Item No.", ServiceCommPackageLine."Invoicing Item No.");
        CopiedServiceCommPackageLines.TestField("Calculation Base Type", ServiceCommPackageLine."Calculation Base Type");
        CopiedServiceCommPackageLines.TestField("Calculation Base %", ServiceCommPackageLine."Calculation Base %");
        CopiedServiceCommPackageLines.TestField("Billing Base Period", ServiceCommPackageLine."Billing Base Period");
        CopiedServiceCommPackageLines.TestField("Billing Rhythm", ServiceCommPackageLine."Billing Rhythm");
        CopiedServiceCommPackageLines.TestField("Sub. Line Start Formula", ServiceCommPackageLine."Sub. Line Start Formula");
        CopiedServiceCommPackageLines.TestField("Notice Period", ServiceCommPackageLine."Notice Period");
        CopiedServiceCommPackageLines.TestField("Extension Term", ServiceCommPackageLine."Extension Term");
        CopiedServiceCommPackageLines.TestField("Initial Term", ServiceCommPackageLine."Initial Term");
    end;

    [Test]
    procedure ExpectErrorWhenItemAssignedToServCommPackageWhenInvoicingItemIsEmptyForPackageLine()
    var
        SalesWithServCommItem: Record Item;
        ServCommPackage: Record "Subscription Package";
        ServCommPackageLine: Record "Subscription Package Line";
    begin
        // [SCENARIO] When Service Commitment Package has one line with "Invoice Via" = Contract and "Invoicing Item No." is empty, then the item cannot be assigned to the package

        // [GIVEN] Service Commitment Package with a line where Invoicing Item is empty and "Invoicing Via" = Contract
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServCommPackage, ServCommPackageLine);
        ServCommPackageLine.Validate("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServCommPackageLine.Modify(false);

        // [WHEN] Assigning an Item with Service Commitment Option = Sales with Service Commitment to the Service Commitment Package
        ContractTestLibrary.CreateItemForServiceObject(SalesWithServCommItem, false);
        asserterror ContractTestLibrary.AssignItemToServiceCommitmentPackage(SalesWithServCommItem."No.", ServCommPackage.Code, true, true);

        // [THEN] Error expected that the item cannot be used with a package while there is a package line with "Invoicing Via" = Contract and "Invoicing Item No." is blank
        Assert.ExpectedError(StrSubstNo(PackageLineMissingInvoicingItemNoErr, ServCommPackage.TableCaption, ServCommPackage.Code, SalesWithServCommItem."No.", ServCommPackageLine.FieldCaption("Invoicing Item No.")));
    end;

    [Test]
    procedure ExpectErrorOnChangeItemServiceCommTypeFromSrvCommToSalesWithSrvComm()
    var
        SrvCommItem: Record Item;
        ServCommPackage: Record "Subscription Package";
        ServCommPackageLine: Record "Subscription Package Line";
    begin
        // [SCENARIO] When changing the Service Commitment Option of an Item from "Service Commitment Item" to "Sales with Service Commitment", error is thrown if the item is assigned to a Service Commitment Package with "Invoicing via" = Contract and "Invoicing Item No." is blank

        // [GIVEN] Item with Service Commitment Option = Service Commitment Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(SrvCommItem, Enum::"Item Service Commitment Type"::"Service Commitment Item");

        // [GIVEN] Service Commitment Package with a line where "Invoicing Via" = Sales
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServCommPackage, ServCommPackageLine);
        ServCommPackageLine.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
        ServCommPackageLine.Modify(false);

        // [GIVEN] Assigning an Item to the Service Commitment Package
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(SrvCommItem, ServCommPackage.Code);

        // [GIVEN] Service Commitment Package Line has been updated in the meantime (mistakenly) to "Invoicing Via" = Contract with a blank "Invoicing Item No."
        ServCommPackageLine.Validate("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServCommPackageLine.Modify(false);

        // [WHEN] Changing the Service Commitment Option of the Item to "Sales with Service Commitment"
        asserterror SrvCommItem.Validate("Subscription Option", Enum::"Item Service Commitment Type"::"Sales with Service Commitment");

        // [THEN] Error expected that the item cannot be used with a package while there is a package line with "Invoicing Via" = Contract and "Invoicing Item No." is blank
        Assert.ExpectedError(StrSubstNo(PackageLineMissingInvoicingItemNoErr, ServCommPackage.TableCaption, ServCommPackage.Code, SrvCommItem."No.", ServCommPackageLine.FieldCaption("Invoicing Item No.")));
    end;
    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        ClearAll();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
    end;

    local procedure InsertServiceCommitment(ServicePartner: Enum "Service Partner"; var InsertCounter: Integer)
    begin
        ServiceCommitment.Init();
        ServiceCommitment.Partner := ServicePartner;
        ServiceCommitment."Subscription Header No." := ServiceObject."No.";
        ServiceCommitment."Entry No." := 0;
        ServiceCommitment."Next Billing Date" := CalcDate('<-1M>', WorkDate());
        ServiceCommitment.Insert(false);
        InsertCounter += 1;
    end;

    local procedure UpdateServiceDatesAndCloseCustomerContractLines()
    begin
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Subscription Line Start Date" := CalcDate('<-2D>', Today());
                ServiceCommitment."Subscription Line End Date" := CalcDate('<-1D>', Today());
                ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Subscription Line End Date");
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        ServiceObject.UpdateServicesDates();
    end;

    local procedure ValidateDateFormulaCombinations(DateFormulaText1: Text; DateFormulaText2: Text)
    var
        DateFormula1: DateFormula;
    begin
        ServiceCommPackageLine.Get(ServiceCommPackageLine."Subscription Package Code", ServiceCommPackageLine."Line No.");
        Evaluate(DateFormula1, DateFormulaText1);
        ServiceCommPackageLine."Billing Base Period" := DateFormula1;
        Evaluate(DateFormula1, DateFormulaText2);
        ServiceCommPackageLine."Billing Rhythm" := DateFormula1;
        ServiceCommPackageLine.Modify(true);
    end;

    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [SendNotificationHandler]
    procedure SendNotificationHandler(var Notification: Notification): Boolean
    begin
    end;

    #endregion Handlers
}
