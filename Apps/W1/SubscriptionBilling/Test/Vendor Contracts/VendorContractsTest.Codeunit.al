namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;

codeunit 148154 "Vendor Contracts Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var

        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        ContractType: Record "Subscription Contract Type";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitment1: Record "Subscription Line";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceCommitmentTemplate2: Record "Sub. Package Line Template";
        NewServiceObject: Record "Subscription Header";
        ServiceObject: Record "Subscription Header";
        ServiceObject1: Record "Subscription Header";
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        AssertThat: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryERM: Codeunit "Library - ERM";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        BillingRhythmValue: DateFormula;
        ExpectedDate: Date;
        ExpectedDecimalValue: Decimal;
        VendorContractPage: TestPage "Vendor Contract";
        DescriptionText: Text;

    #region Tests

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckClosedVendorContractLines()
    var
        VendorContractLine2: Record "Vend. Sub. Contract Line";
    begin
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler
        ContractTestLibrary.InsertVendorContractCommentLine(VendorContract, VendorContractLine2);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", VendorContract."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Subscription Line Start Date" := CalcDate('<-2D>', Today());
                ServiceCommitment."Subscription Line End Date" := CalcDate('<-1D>', Today());
                ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Subscription Line End Date");
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        VendorContract.UpdateServicesDates();
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        VendorContractLine.SetRange(Closed, false);
        asserterror VendorContractLine.FindFirst();
    end;

    [Test]
    procedure CheckContractInitValues()
    begin
        ClearAll();

        ContractTestLibrary.CreateVendorContract(VendorContract, '');

        VendorContract.TestField(Active, true);
        VendorContract.TestField("Assigned User ID", UserId());
    end;

    [Test]
    procedure CheckNewContractFromVendor()
    begin
        ClearAll();

        ContractTestLibrary.CreateVendor(Vendor);
        VendorContract.Init();
        VendorContract.Validate("Buy-from Vendor No.", Vendor."No.");
        VendorContract.Insert(true);
    end;

    [Test]
    [HandlerFunctions('ServCommWOVendContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToVendorContractForServiceObjectWithItem()
    var
        InvoicingViaNotManagedErr: Label 'Invoicing via %1 not managed', Locked = true;
    begin
        // [SCENARIO] Check that proper Subscription Lines are assigned to Vendor Subscription Contract Lines.
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);
        VendorContractPage.GetServiceCommitmentsAction.Invoke();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Vendor);
        ServiceCommitment.FindSet();
        repeat
            VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
            VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
            VendorContractLine.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
            VendorContractLine.SetRange("Subscription Line Entry No.", ServiceCommitment."Entry No.");
            case ServiceCommitment."Invoicing via" of
                Enum::"Invoicing Via"::Contract:
                    begin
                        AssertThat.IsTrue(VendorContractLine.FindFirst(), 'Service Commitment not assigned to expected Vendor Subscription Contract Line.');
                        VendorContractLine.TestField("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
                        VendorContractLine.TestField("Contract Line Type", Enum::"Contract Line Type"::Item);
                    end;
                Enum::"Invoicing Via"::Sales:
                    begin
                        AssertThat.IsTrue(VendorContractLine.IsEmpty(), 'Service Commitment is assigned to Vendor Subscription Contract Line but it is not expected.');
                        ServiceCommitment.TestField("Subscription Contract No.", '');
                    end;
                else
                    Error(InvoicingViaNotManagedErr, Format(ServiceCommitment."Invoicing via"));
            end;
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ServCommWOVendContractPageHandler')]
    procedure CheckServiceCommitmentAssignmentToVendorContractForServiceObjectWithGLAccount()
    begin
        // [SCENARIO] Create a Subscription for G/L Account and make sure that its Subscription Lines can be assigned to a contract

        // [GIVEN] A Subscription for G/L Account has been created with Subscription Lines included
        SetupServiceObjectForNewGLAccountWithServiceCommitment();

        // [WHEN] A Contract has been created and Subscription Lines are assigned on a contract
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);
        VendorContractPage.GetServiceCommitmentsAction.Invoke();

        // [THEN] A new Contract Line has been created for previously created Subscription Line
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::"G/L Account");
        VendorContractLine.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        VendorContractLine.SetRange("Subscription Line Entry No.", ServiceCommitment."Entry No.");
        AssertThat.IsTrue(VendorContractLine.FindFirst(), 'Service Commitment not assigned to expected Vendor Subscription Contract Line.');
        VendorContractLine.TestField("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
        VendorContractLine.TestField("Contract Line Type", Enum::"Contract Line Type"::"G/L Account");
        VendorContractLine.TestField("No.", ServiceObject."Source No.");
    end;

    [Test]
    [HandlerFunctions('ServCommWOVendContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToVendorContractInFCY()
    begin
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);
        VendorContractPage.GetServiceCommitmentsAction.Invoke();

        TestServiceCommitmentUpdateOnCurrencyChange(WorkDate(), CurrExchRate.ExchangeRate(WorkDate(), VendorContract."Currency Code"), true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceObjectDescriptionInVendorContractLines()
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", true);
        TestVendorContractLinesServiceObjectDescription(VendorContract."No.", ServiceObject.Description);

        ServiceObject.Description := CopyStr(LibraryRandom.RandText(100), 1, MaxStrLen(ServiceObject.Description));
        ServiceObject.Modify(true);
        TestVendorContractLinesServiceObjectDescription(VendorContract."No.", ServiceObject.Description);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckTransferDefaultsFromVendorToVendorContract()
    begin
        ClearAll();

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendor(Vendor2);
        ContractTestLibrary.CreateVendorContract(VendorContract, '');
        VendorContract.Validate("Buy-from Vendor Name", Vendor.Name);
        VendorContract.TestField("Buy-from Vendor No.", Vendor."No.");
        VendorContract.TestField("Purchaser Code", Vendor."Purchaser Code");
        VendorContract.Validate("Pay-to Name", Vendor2.Name);
        VendorContract.TestField("Pay-to Vendor No.", Vendor2."No.");
        VendorContract.TestField("Payment Method Code", Vendor2."Payment Method Code");
        VendorContract.TestField("Payment Terms Code", Vendor2."Payment Terms Code");
        VendorContract.TestField("Currency Code", Vendor2."Currency Code");
        VendorContract.TestField("Purchaser Code", Vendor2."Purchaser Code");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,ConfirmHandler,MessageHandler')]
    procedure CheckValueChangesOnVendorContractLines()
    var
        OldServiceCommitment: Record "Subscription Line";
        BillingBasePeriod: DateFormula;
        ServCommFieldFromVendContrLineErr: Label 'Subscription Line field "%1" not transferred from Vendor Subscription Contract Line.', Locked = true;
        ServCommFieldFromCustContrLineErr: Label 'Subscription Line field "%1" not transferred from Customer Subscription Contract Line.', Locked = true;
        NotTransferredMisspelledTok: Label 'Subscription Line field "%1" not transfered from Customer Subscription Contract Line.', Locked = true;
        MaxServiceAmount: Decimal;
        ServiceObjectQuantity: Decimal;
    begin
        // [SCENARIO] Assign Subscription Lines to Vendor Subscription Contract Lines. Change values on Vendor Subscription Contract Lines and check that Subscription Line has changed values.
        Currency.InitRoundingPrecision();
        CreateVendorContractSetup();

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);

        VendorContractLine.Reset();
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        VendorContractLine.FindFirst();
        VendorContractPage.Lines.GoToRecord(VendorContractLine);

        ServiceObjectQuantity := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        VendorContractPage.Lines."Service Object Quantity".SetValue(ServiceObjectQuantity);
        ServiceObject.Get(VendorContractLine."Subscription Header No.");
        AssertThat.AreEqual(ServiceObject.Quantity, ServiceObjectQuantity, 'Service Object Quantity not transferred from Customer Subscription Contract Line.');


        DescriptionText := LibraryRandom.RandText(100);
        VendorContractPage.Lines."Service Object Description".SetValue(DescriptionText);
        ServiceObject.Get(VendorContractLine."Subscription Header No.");
        AssertThat.AreEqual(ServiceObject.Description, DescriptionText, 'Service Object Description not transferred from Vendor Subscription Contract Line.');

        OldServiceCommitment.Get(VendorContractLine."Subscription Line Entry No.");

        ExpectedDate := CalcDate('<-1D>', OldServiceCommitment."Subscription Line Start Date");
        VendorContractPage.Lines."Service Start Date".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDate, ServiceCommitment."Subscription Line Start Date", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Subscription Line Start Date")));

        ExpectedDate := CalcDate('<1D>', WorkDate());
        VendorContractPage.Lines."Service End Date".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDate, ServiceCommitment."Subscription Line End Date", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Subscription Line End Date")));

        ExpectedDate := CalcDate('<1D>', WorkDate());
        VendorContractPage.Lines."Cancellation Possible Until".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDate, ServiceCommitment."Cancellation Possible Until", StrSubstNo(NotTransferredMisspelledTok, ServiceCommitment.FieldCaption("Cancellation Possible Until")));

        ExpectedDate := CalcDate('<1D>', WorkDate());
        VendorContractPage.Lines."Term Until".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDate, ServiceCommitment."Term Until", StrSubstNo(NotTransferredMisspelledTok, ServiceCommitment.FieldCaption("Term Until")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Discount %" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        VendorContractPage.Lines."Discount %".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Discount %", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Discount %")));

        MaxServiceAmount := Round((OldServiceCommitment.Price * ServiceObject.Quantity), Currency."Amount Rounding Precision");
        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Discount Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        VendorContractPage.Lines."Discount Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Discount Amount", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Discount Amount")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        while ExpectedDecimalValue = OldServiceCommitment.Amount do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        VendorContractPage.Lines."Service Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment.Amount, StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption(Amount)));

        ExpectedDecimalValue := LibraryRandom.RandDec(10000, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Calculation Base Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDec(10000, 2);
        VendorContractPage.Lines."Calculation Base Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Calculation Base Amount", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Calculation Base Amount")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Calculation Base Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        VendorContractPage.Lines."Calculation Base %".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Calculation Base %", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Calculation Base %")));

        DescriptionText := LibraryRandom.RandText(100);
        VendorContractPage.Lines."Service Commitment Description".SetValue(DescriptionText);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(DescriptionText, ServiceCommitment.Description, StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption(Description)));

        Evaluate(BillingBasePeriod, '<3M>');
        VendorContractPage.Lines."Billing Base Period".SetValue(BillingBasePeriod);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(BillingBasePeriod, ServiceCommitment."Billing Base Period", StrSubstNo(NotTransferredMisspelledTok, ServiceCommitment.FieldCaption("Billing Base Period")));

        Evaluate(BillingRhythmValue, '<3M>');
        VendorContractPage.Lines."Billing Rhythm".SetValue(BillingRhythmValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(BillingRhythmValue, ServiceCommitment."Billing Rhythm", StrSubstNo(ServCommFieldFromCustContrLineErr, ServiceCommitment.FieldCaption("Billing Rhythm")));
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ContractLineDisconnectServiceOnTypeChange()
    var
        EntryNo: Integer;
    begin
        // Test: Subscription Line should be disconnected from the contract when the line type changes
        ClearAll();
        SetupNewContract(false);

        VendorContractLine.Reset();
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        VendorContractLine.SetFilter("Subscription Header No.", '<>%1', '');
        VendorContractLine.SetFilter("Subscription Line Entry No.", '<>%1', 0);
        VendorContractLine.FindFirst();
        EntryNo := VendorContractLine."Subscription Line Entry No.";
        VendorContractLine.Validate("Contract Line Type", VendorContractLine."Contract Line Type"::Comment);
        ServiceCommitment.Get(EntryNo);
        ServiceCommitment.TestField("Subscription Contract No.", '');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure CurrencyCodeRemainsSameWhenPayToVendorChanges()
    var
        CurrencyCode: Code[10];
    begin
        //[SCENARIO]: Create Subscription Header with Subscription Lines
        //[SCENARIO]: Create two vendors with same Currency Code; When Pay-to Vendor is changed in Vendor contract
        //[SCENARIO]: Currency code should remain the same

        //[GIVEN]: Setup Service Object with Service Commitment
        //[GIVEN] Create Vendor Contract with Contract Lines from Service Commitments
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.InitContractsApp();

        //[GIVEN]: Create two vendors with same Currency Code
        CurrencyCode := LibraryERM.CreateCurrencyWithRandomExchRates();
        ContractTestLibrary.CreateVendor(Vendor, CurrencyCode);
        ContractTestLibrary.CreateVendor(Vendor2, CurrencyCode);

        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", false);

        //[WHEN]: Change Pay-to Vendor in Vendor Contract
        VendorContract.Validate("Pay-to Vendor No.", Vendor2."No.");
        VendorContract.Modify(true);

        //[THEN]: Check that Currency Code is the same as in Vendor - no change has been made
        VendorContract.Get(VendorContract."No.");
        VendorContract.TestField("Currency Code", CurrencyCode);
    end;

    [Test]
    procedure DeleteAssignedContractTypeError()
    begin
        ClearAll();

        ContractTestLibrary.CreateVendorContractWithContractType(VendorContract, ContractType);
        asserterror ContractType.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ServCommWOVendContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnAssignServiceCommitmentsWithMultipleCurrencies()
    begin
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
            ServiceCommitment."Currency Code" := Currency.Code;
        until ServiceCommitment.Next() = 0;

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);
        VendorContractPage.GetServiceCommitmentsAction.Invoke();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeOneVendorContractLine()
    begin
        SetupNewContract(false);
        asserterror VendorContractLine.MergeContractLines(VendorContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeTextLine()
    begin
        SetupNewContract(false);
        ContractTestLibrary.InsertVendorContractCommentLine(VendorContract, VendorContractLine);
        VendorContractLine.Reset();
        asserterror VendorContractLine.MergeContractLines(VendorContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeVendorContractLineWithBillingProposal()
    begin
        SetupNewContract(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor, Today());
        asserterror VendorContractLine.MergeContractLines(VendorContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateVendorBillingDocsContractPageHandler')]
    procedure ExpectErrorOnModifyServiceStartDateWhenBillingLineArchiveExist()
    begin
        ClearAll();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", true);
        CreateAndPostBillingProposal();

        asserterror UpdateServiceStartDateFromVendorContractSubpage();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyServiceStartDateWhenBillingLineExist()
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);

        asserterror UpdateServiceStartDateFromVendorContractSubpage();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectNoClosedVendorContractLines()
    var
        VendorContractLine2: Record "Vend. Sub. Contract Line";
    begin
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.");
        ContractTestLibrary.InsertVendorContractCommentLine(VendorContract, VendorContractLine2);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", VendorContract."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Subscription Line Start Date" := CalcDate('<1D>', Today);
                ServiceCommitment."Subscription Line End Date" := CalcDate('<2D>', Today);
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        VendorContract.UpdateServicesDates();
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        VendorContractLine.SetRange(Closed, false);
        VendorContractLine.FindFirst();
    end;

    [Test]
    procedure ManuallyCreateContractLineForItem()
    begin
        // [SCENARIO] Manually create contract lines for Item and expect Subscription to be created

        // [GIVEN] A Vendor Subscription Contract has been created
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        // [WHEN] A Vendor Subscription Contract Line has been manually created and Item No. is entered.
        ContractTestLibrary.InsertVendorContractItemLine(VendorContract, VendorContractLine);

        // [THEN] Subscription has been created with a single Subscription Line
        ServiceObject.Get(VendorContractLine."Subscription Header No.");
        ServiceObject.TestField(Quantity, 1);
        ServiceObject.TestField(ServiceObject.Type, ServiceObject.Type::Item);
        ServiceObject.TestField("Created in Contract line", true);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        AssertThat.RecordCount(ServiceCommitment, 1);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Invoicing via", ServiceCommitment."Invoicing via"::Contract);
        ServiceCommitment.TestField("Created in Contract line", true);
        ServiceCommitment.TestField("Subscription Contract No.", VendorContractLine."Subscription Contract No.");
        ServiceCommitment.TestField("Subscription Contract Line No.", VendorContractLine."Line No.");
    end;

    [Test]
    procedure ManuallyCreateContractLineForGLAccount()
    begin
        // [SCENARIO] Manually create contract lines for G/L Account and expect Subscription to be created

        // [GIVEN] A Vendor Subscription Contract has been created
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        // [WHEN] A Vendor Subscription Contract Line has been manually created and G/L Account No. is entered.
        ContractTestLibrary.InsertVendorContractGLAccountLine(VendorContract, VendorContractLine);

        // [THEN] Subscription has been created with a single Subscription Line
        ServiceObject.Get(VendorContractLine."Subscription Header No.");
        ServiceObject.TestField(Quantity, 1);
        ServiceObject.TestField(ServiceObject.Type, ServiceObject.Type::"G/L Account");
        ServiceObject.TestField("Created in Contract line", true);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        AssertThat.RecordCount(ServiceCommitment, 1);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Invoicing via", ServiceCommitment."Invoicing via"::Contract);
        ServiceCommitment.TestField("Created in Contract line", true);
        ServiceCommitment.TestField("Subscription Contract No.", VendorContractLine."Subscription Contract No.");
        ServiceCommitment.TestField("Subscription Contract Line No.", VendorContractLine."Line No.");
    end;

    [Test]
    procedure RemoveAndDeleteAssignedContractType()
    begin
        ClearAll();

        ContractTestLibrary.CreateVendorContractWithContractType(VendorContract, ContractType);

        VendorContract.Validate("Contract Type", '');
        VendorContract.Modify(false);

        ContractType.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDeleteServiceCommitmentLinkedToContractLineIsClosed()
    begin
        // Test: A closed Contract Line is deleted when deleting the Subscription Line
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", VendorContract."No.");
        ServiceCommitment.FindFirst();

        VendorContractLine.Get(ServiceCommitment."Subscription Contract No.", ServiceCommitment."Subscription Contract Line No.");
        VendorContractLine.TestField(Closed, false);
        VendorContractLine.Closed := true;
        VendorContractLine.Modify(false);
        ServiceCommitment.Delete(true);

        asserterror VendorContractLine.Get(VendorContractLine."Subscription Contract No.", VendorContractLine."Line No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDeleteServiceCommitmentLinkedToContractLineNotClosed()
    begin
        // Test: Subscription Line cannot be deleted if an open contract line exists
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", VendorContract."No.");
        ServiceCommitment.FindFirst();

        VendorContractLine.Get(ServiceCommitment."Subscription Contract No.", ServiceCommitment."Subscription Contract Line No.");
        VendorContractLine.TestField(Closed, false);
        asserterror ServiceCommitment.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestEqualServiceStartDateAndNextBillingDate()
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", true);

        UpdateServiceStartDateFromVendorContractSubpage();

        VendorContractLine.GetServiceCommitment(ServiceCommitment);
        ServiceCommitment.TestField("Next Billing Date", ServiceCommitment."Subscription Line Start Date");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectVendorContractLinePageHandler')]
    procedure TestMergeVendorContractLines()
    var
        TempServiceCommitment: Record "Subscription Line" temporary;
        ExpectedServiceAmount: Decimal;
    begin
        SetupNewContract(false);
        CreateTwoEqualServiceObjectsWithServiceCommitments();
        ExpectedServiceAmount := GetTotalServiceAmountFromServiceCommitments();
        ContractTestLibrary.FillTempServiceCommitmentForVendor(TempServiceCommitment, ServiceObject1, VendorContract);
        VendorContract.CreateVendorContractLinesFromServiceCommitments(TempServiceCommitment);

        VendorContractLine.Reset();
        VendorContractLine.MergeContractLines(VendorContractLine);
        VendorContractLine.FindLast();
        TestNewServiceObject();
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", NewServiceObject."No.");
        AssertThat.AreEqual(1, ServiceCommitment.Count(), 'Service Commitments not created correctly');
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);

        // Expect two closed Vendor Subscription Contract Lines
        VendorContractLine.Reset();
        VendorContractLine.SetRange(Closed, true);
        AssertThat.AreEqual(2, VendorContractLine.Count(), 'Merged Vendor Subscription Contract lines are not closed');

        // Expect one open Vendor Subscription Contract Line created from New Subscription
        VendorContractLine.Reset();
        VendorContractLine.SetRange(Closed, false);
        AssertThat.AreEqual(1, VendorContractLine.Count(), 'Merged Vendor Subscription Contract line is not created properly');
        VendorContractLine.FindFirst();
        VendorContractLine.TestField("Subscription Header No.", NewServiceObject."No.");
        VendorContractLine.TestField("Subscription Line Entry No.");
    end;

    [Test]
    [HandlerFunctions('ServCommWOVendContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestRecalculateServiceCommitmentsOnChangeCurrencyCode()
    begin
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);
        VendorContractPage.GetServiceCommitmentsAction.Invoke();

        Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
        VendorContract.Validate("Currency Code", Currency.Code);
        VendorContract.Modify(false);

        TestServiceCommitmentUpdateOnCurrencyChange(WorkDate(), CurrExchRate.ExchangeRate(WorkDate(), VendorContract."Currency Code"), true);
    end;

    [Test]
    [HandlerFunctions('ServCommWOVendContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestResetServiceCommitmentsOnCurrencyCodeDelete()
    begin
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);
        VendorContractPage.GetServiceCommitmentsAction.Invoke();

        Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
        VendorContract.Validate("Currency Code", '');
        VendorContract.Modify(false);

        TestServiceCommitmentUpdateOnCurrencyChange(0D, 0, false);
    end;

    [Test]
    procedure TransferCreateContractDeferralsFromContractType()
    begin
        // Create Vendor Contract with contract type
        // Create new Contract Type with field "Def. Without Contr. Deferrals" = true
        // Check that the field value has been transferred
        ClearAll();
        ContractTestLibrary.CreateVendorContractWithContractType(VendorContract, ContractType);
        ContractType.TestField("Create Contract Deferrals", true);
        VendorContract.TestField("Create Contract Deferrals", true);
        ContractTestLibrary.CreateContractType(ContractType);
        ContractType."Create Contract Deferrals" := false;
        ContractType.Modify(false);
        VendorContract.Validate("Contract Type", ContractType.Code);
        VendorContract.Modify(false);
        VendorContract.TestField("Create Contract Deferrals", false);

        // allow manually changing the value of the field
        VendorContract.Validate("Create Contract Deferrals", true);
        VendorContract.Modify(false);
        VendorContract.TestField("Contract Type", ContractType.Code);
    end;

    #endregion Tests

    #region Procedures

    local procedure CreateAndPostBillingProposal()
    begin
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor, WorkDate());
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Vendor);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        // Post Purchase Document
        BillingLine.FindFirst();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CreateTwoEqualServiceObjectsWithServiceCommitments()
    begin
        ServiceObject1 := ServiceObject;
        ServiceObject1."No." := IncStr(ServiceObject."No.");
        ServiceObject1.Insert(false);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then begin
            ServiceCommitment."Subscription Line Start Date" := CalcDate('<-2M>', Today);
            ServiceCommitment."Next Billing Date" := ServiceCommitment."Subscription Line Start Date";
            ServiceCommitment.Validate("Subscription Line Start Date");
            ServiceCommitment.Modify(false);
            repeat
                ServiceCommitment1 := ServiceCommitment;
                ServiceCommitment1."Entry No." := 0;
                ServiceCommitment1."Subscription Contract No." := '';
                ServiceCommitment1."Subscription Header No." := ServiceObject1."No.";
                ServiceCommitment1.Insert(false);
            until ServiceCommitment.Next() = 0;
        end;
    end;

    local procedure CreateVendorContractSetup()
    begin
        SetupServiceObjectForNewItemWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.");
    end;

    local procedure GetTotalServiceAmountFromServiceCommitments(): Decimal
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.", ServiceObject1."No.");
        ServiceCommitment.FindFirst();
        exit(Round(ServiceCommitment.Price * ServiceObject1.Quantity * 2, Currency."Amount Rounding Precision"));
    end;

    local procedure SetupNewContract(CreateAdditionalLine: Boolean)
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', CreateAdditionalLine);
    end;

    local procedure SetupServiceObjectForNewItemWithServiceCommitment(SNSpecificTracking: Boolean)
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitmentPackage: Record "Subscription Package";
    begin
        ClearAll();
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, SNSpecificTracking);
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate2);
        ServiceCommitmentTemplate2."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate2."Invoicing via" := Enum::"Invoicing Via"::Sales;
        ServiceCommitmentTemplate2.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer; // added to mix line nos. between Subscription Line and contract lines
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate2.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer; // added to mix line nos. between Subscription Line and contract lines
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate2.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
    end;

    local procedure SetupServiceObjectForNewGLAccountWithServiceCommitment()
    var
        GLAccount: Record "G/L Account";
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForGLAccountWithServiceCommitments(ServiceObject, GLAccount, 0, 1, '<1Y>', '<1M>');
        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject.Modify(false);
    end;

    local procedure TestNewServiceObject()
    begin
        NewServiceObject.Get(VendorContractLine."Subscription Header No.");
        NewServiceObject.TestField(Description, ServiceObject.Description);
        NewServiceObject.TestField(Type, ServiceObject.Type);
        NewServiceObject.TestField("Source No.", ServiceObject."Source No.");
        NewServiceObject.TestField("End-User Customer No.", ServiceObject."End-User Customer No.");
        NewServiceObject.TestField(Quantity, ServiceObject.Quantity + ServiceObject1.Quantity);
    end;

    local procedure TestServiceCommitmentUpdateOnCurrencyChange(CurrencyFactorDate: Date; CurrencyFactor: Decimal; RecalculatePrice: Boolean)
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", VendorContract."No.");
        ServiceCommitment.FindFirst();
        repeat
            ServiceCommitment.TestField("Currency Code", VendorContract."Currency Code");
            ServiceCommitment.TestField("Currency Factor Date", CurrencyFactorDate);
            ServiceCommitment.TestField("Currency Factor", CurrencyFactor);

            if RecalculatePrice then begin // if currency code is changed to '', amounts and amounts in lcy in Subscription Lines should be the same
                Currency.Get(Vendor."Currency Code");
                ServiceCommitment.TestField(Price,
                Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Vendor."Currency Code", ServiceCommitment."Price (LCY)", CurrencyFactor), Currency."Unit-Amount Rounding Precision"));

                ServiceCommitment.TestField(Amount,
                Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Vendor."Currency Code", ServiceCommitment."Amount (LCY)", CurrencyFactor), Currency."Amount Rounding Precision"));

                ServiceCommitment.TestField("Discount Amount",
                Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Vendor."Currency Code", ServiceCommitment."Discount Amount (LCY)", CurrencyFactor), Currency."Amount Rounding Precision"));
            end
            else begin
                ServiceCommitment.TestField(Price, ServiceCommitment."Price (LCY)");
                ServiceCommitment.TestField(Amount, ServiceCommitment."Amount (LCY)");
                ServiceCommitment.TestField("Discount Amount", ServiceCommitment."Discount Amount (LCY)");
            end;
        until ServiceCommitment.Next() = 0;
    end;

    local procedure TestVendorContractLinesServiceObjectDescription(VendorContractNo: Code[20]; ServiceObjectDescription: Text[100])
    begin
        VendorContractLine.SetRange("Subscription Contract No.", VendorContractNo);
        VendorContractLine.FindSet();
        repeat
            VendorContractLine.TestField("Subscription Description", ServiceObjectDescription);
        until VendorContractLine.Next() = 0;
    end;

    local procedure UpdateServiceStartDateFromVendorContractSubpage()
    var
        NewServiceStartDate: Date;
        VendorContractSubpage: TestPage "Vendor Contract Line Subpage";
    begin
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.FindFirst();
        VendorContractLine.GetServiceCommitment(ServiceCommitment);
        NewServiceStartDate := CalcDate('<1D>', ServiceCommitment."Subscription Line Start Date");

        VendorContractSubpage.OpenEdit();
        VendorContractSubpage.GoToRecord(VendorContractLine);
        VendorContractSubpage."Service Start Date".SetValue(NewServiceStartDate);
        VendorContractSubpage.Close();
    end;
    #endregion Procedures

    #region Handlers

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsContractPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
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

    [ModalPageHandler]
    procedure SelectVendorContractLinePageHandler(var SelectVendContractLines: TestPage "Select Vend. Contract Lines")
    begin
        SelectVendContractLines.OK().Invoke();
    end;

    [PageHandler]
    procedure ServCommWOVendContractPageHandler(var ServCommWOVendContractPage: TestPage "Serv. Comm. WO Vend. Contract")
    begin
        ServCommWOVendContractPage.AssignAllServiceCommitmentsAction.Invoke();
    end;

    #endregion Handlers

}

