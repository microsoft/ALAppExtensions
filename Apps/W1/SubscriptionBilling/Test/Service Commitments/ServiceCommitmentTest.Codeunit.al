namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

codeunit 148156 "Service Commitment Test"
{
    Subtype = Test;
    Access = Internal;

    var
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitment: Record "Service Commitment";
        Item: Record Item;
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        ServiceObject: Record "Service Object";
        CustomerContractLine: Record "Customer Contract Line";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;

    local procedure Setup()
    begin
        ClearAll();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
    end;

    [Test]
    procedure CheckItemNoEntryOnServiceCommitmentTemplate()
    begin
        Setup();
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
    procedure CheckItemNoEntryOnPackageLine()
    begin
        Setup();
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
    procedure CheckServiceCommitmentTemplateAssignmentOnPackageLine()
    begin
        Setup();
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
    procedure ExpectErrorDuringCommitmentTemplateDeletion()
    begin
        Setup();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommitmentTemplate.Delete(true);
    end;

    [Test]
    procedure CheckPackageDeletion()
    begin
        Setup();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.SetRange("Package Code", ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.Delete(true);
        asserterror ServiceCommPackageLine.FindFirst();
    end;

    [Test]
    procedure CheckCalculationBaseDateFormulaEntry()
    begin
        Setup();
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

    local procedure ValidateDateFormulaCombinations(DateFormulaText1: Text; DateFormulaText2: Text)
    var
        DateFormula1: DateFormula;
    begin
        ServiceCommPackageLine.Get(ServiceCommPackageLine."Package Code", ServiceCommPackageLine."Line No.");
        Evaluate(DateFormula1, DateFormulaText1);
        ServiceCommPackageLine."Billing Base Period" := DateFormula1;
        Evaluate(DateFormula1, DateFormulaText2);
        ServiceCommPackageLine."Billing Rhythm" := DateFormula1;
        ServiceCommPackageLine.Modify(true);
    end;

    [Test]
    procedure CheckIfDateFormulasAreNegative()
    var
        NegativeDateFormula: DateFormula;
        PositiveDateFormula: DateFormula;
    begin
        Setup();
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
        ServiceCommPackageLine.Validate("Service Comm. Start Formula", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Initial Term", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Extension Term", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Notice Period", PositiveDateFormula);
    end;

    [Test]
    procedure CheckIfExtensionTermEnteredBeforeNoticePeriod()
    var
        PositiveDateFormula: DateFormula;
    begin
        Setup();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        Commit(); // retain data after asserterror

        Evaluate(PositiveDateFormula, '<1M>');
        asserterror ServiceCommPackageLine.Validate("Notice Period", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Extension Term", PositiveDateFormula);
        ServiceCommPackageLine.Validate("Notice Period", PositiveDateFormula);
    end;

    [Test]
    [HandlerFunctions('SendNotificationHandler')]
    procedure CheckCalculationBaseTypeChangeForVendorOnServiceCommitmentPackageLine()
    begin
        Setup();
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

    [SendNotificationHandler]
    procedure SendNotificationHandler(var Notification: Notification): Boolean
    begin
    end;

    [Test]
    procedure CheckServiceCommitmentPackageLineDefaultAndAssignedInvoiceViaValue()
    begin
        Setup();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.TestField("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitmentTemplate.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
        ServiceCommitmentTemplate.Modify(false);
        ServiceCommPackageLine.Validate(Template, ServiceCommitmentTemplate.Code);
        ServiceCommPackageLine.TestField("Invoicing via", Enum::"Invoicing Via"::Sales);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenDeleteServiceCommitment()
    var
    begin
        Setup();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', true);
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        asserterror ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckDeleteServiceCommitmentAfterDeleteCustomerContractLine()
    begin
        Setup();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', true);
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.DeleteAll(true);
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorDeleteServiceCommitmentAfterCustomerContractLineSetToClosed()
    var
    begin
        Setup();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', true);
        UpdateServiceDatesAndCloseCustomerContractLines();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(true);
    end;


    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckDeleteServiceCommitmentAfterDeleteVendorContractLine()
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        Setup();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '', true);
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.DeleteAll(true);
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectDeleteServiceCommitmentAfterVendorContractLineSetToClosed()
    var
    begin
        Setup();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '', true);
        UpdateServiceDatesAndCloseCustomerContractLines();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyClosedServiceCommitment()
    var
    begin
        Setup();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', true);
        UpdateServiceDatesAndCloseCustomerContractLines();

        ServiceCommitment."Next Billing Date" := CalcDate('<1D>', ServiceCommitment."Next Billing Date");
        asserterror ServiceCommitment.Modify(true);
    end;

    local procedure UpdateServiceDatesAndCloseCustomerContractLines()
    begin
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Service Start Date" := CalcDate('<-2D>', Today());
                ServiceCommitment."Service End Date" := CalcDate('<-1D>', Today());
                ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Service End Date");
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        ServiceObject.UpdateServicesDates();
    end;

    [Test]
    procedure TestServiceCommitmentPackageCopy()
    var
        CopiedServiceCommPackage: Record "Service Commitment Package";
        CopiedServiceCommPackageLines: Record "Service Comm. Package Line";
        NewPackageFilter: Code[20];
    begin
        Setup();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);

        NewPackageFilter := ServiceCommitmentPackage.Code;
        ServiceCommitmentPackage.CreateNewCodeForServiceCommPackageCopy(NewPackageFilter);

        ServiceCommitmentPackage.CopyServiceCommitmentPackage();
        CopiedServiceCommPackage.Get(NewPackageFilter);
        CopiedServiceCommPackageLines.SetRange("Package Code", CopiedServiceCommPackage.Code);
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
        CopiedServiceCommPackageLines.TestField("Service Comm. Start Formula", ServiceCommPackageLine."Service Comm. Start Formula");
        CopiedServiceCommPackageLines.TestField("Notice Period", ServiceCommPackageLine."Notice Period");
        CopiedServiceCommPackageLines.TestField("Extension Term", ServiceCommPackageLine."Extension Term");
        CopiedServiceCommPackageLines.TestField("Initial Term", ServiceCommPackageLine."Initial Term");
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestOverdueServiceCommitments()
    var
        OverdueServiceCommitments: Record "Overdue Service Commitments";
        ServiceContractSetup: Record "Service Contract Setup";
        i: Integer;
        InsertCounter: Integer;
        MaxInsertCount: Integer;
    begin
        ContractTestLibrary.InitContractsApp();
        Setup();
        ServiceContractSetup.Get();
        Evaluate(ServiceContractSetup."Overdue Date Formula", '<1M>');
        ServiceContractSetup.Modify(false);

        // Create closed service commitments that should not be considered
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', true); // ExchangeRateSelectionModalPageHandler,MessageHandler
        UpdateServiceDatesAndCloseCustomerContractLines();

        // Create service commitments to consider
        MaxInsertCount := LibraryRandom.RandIntInRange(2, 9);
        InsertCounter := 0;
        for i := 1 to MaxInsertCount do begin
            InsertServiceCommitment(ServiceCommitment.Partner::Customer, InsertCounter);
            if i mod 2 = 0 then
                InsertServiceCommitment(ServiceCommitment.Partner::Vendor, InsertCounter);
        end;

        Assert.AreEqual(InsertCounter, OverdueServiceCommitments.FillAndCountOverdueServiceCommitments(), 'Only service commitments that are open and within the correct date range should be counted.');
    end;

    local procedure InsertServiceCommitment(ServicePartner: Enum "Service Partner"; var InsertCounter: Integer)
    begin
        ServiceCommitment.Init();
        ServiceCommitment.Partner := ServicePartner;
        ServiceCommitment."Service Object No." := ServiceObject."No.";
        ServiceCommitment."Entry No." := 0;
        ServiceCommitment."Next Billing Date" := CalcDate('<-1M>', WorkDate());
        ServiceCommitment.Insert(false);
        InsertCounter += 1;
    end;
}