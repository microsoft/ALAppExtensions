namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
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
        ContractType: Record "Contract Type";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitment1: Record "Service Commitment";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentTemplate2: Record "Service Commitment Template";
        NewServiceObject: Record "Service Object";
        ServiceObject: Record "Service Object";
        ServiceObject1: Record "Service Object";
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        VendorContract: Record "Vendor Contract";
        VendorContractLine: Record "Vendor Contract Line";
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
        VendorContractLine2: Record "Vendor Contract Line";
    begin
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler
        ContractTestLibrary.InsertVendorContractCommentLine(VendorContract, VendorContractLine2);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", VendorContract."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Service Start Date" := CalcDate('<-2D>', Today());
                ServiceCommitment."Service End Date" := CalcDate('<-1D>', Today());
                ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Service End Date");
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        VendorContract.UpdateServicesDates();
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", "Contract Line Type"::"Service Commitment");
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
    procedure CheckServiceCommitmentAssignmentToVendorContract()
    var
        InvoicingViaNotManagedErr: Label 'Invoicing via %1 not managed', Locked = true;
    begin
        // [SCENARIO] Check that proper Service Commitments are assigned to Vendor Contract Lines.
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);
        VendorContractPage.GetServiceCommitmentsAction.Invoke();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Vendor);
        ServiceCommitment.FindSet();
        repeat
            VendorContractLine.SetRange("Contract No.", VendorContract."No.");
            VendorContractLine.SetRange("Contract Line Type", VendorContractLine."Contract Line Type"::"Service Commitment");
            VendorContractLine.SetRange("Service Object No.", ServiceCommitment."Service Object No.");
            VendorContractLine.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
            case ServiceCommitment."Invoicing via" of
                Enum::"Invoicing Via"::Contract:
                    begin
                        AssertThat.IsTrue(VendorContractLine.FindFirst(), 'Service Commitment not assigned to expected Vendor Contract Line.');
                        VendorContractLine.TestField("Contract No.", ServiceCommitment."Contract No.");
                        VendorContractLine.TestField("Contract Line Type", VendorContractLine."Contract Line Type"::"Service Commitment");
                    end;
                Enum::"Invoicing Via"::Sales:
                    begin
                        AssertThat.IsTrue(VendorContractLine.IsEmpty(), 'Service Commitment is assigned to Vendor Contract Line but it is not expected.');
                        ServiceCommitment.TestField("Contract No.", '');
                    end;
                else
                    Error(InvoicingViaNotManagedErr, Format(ServiceCommitment."Invoicing via"));
            end;
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ServCommWOVendContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToVendorContractInFCY()
    begin
        SetupServiceObjectWithServiceCommitment(false);
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
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.", true);
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckValueChangesOnVendorContractLines()
    var
        OldServiceCommitment: Record "Service Commitment";
        ServCommFieldFromVendContrLineErr: Label 'Service Commitment field "%1" not transferred from Vendor Contract Line.', Locked = true;
        ServCommFieldFromCustContrLineErr: Label 'Service Commitment field "%1" not transferred from Customer Contract Line.', Locked = true;
        MaxServiceAmount: Decimal;
    begin
        // [SCENARIO] Assign Service Commitments to Vendor Contract Lines. Change values on Vendor Contract Lines and check that Service Commitment has changed values.
        Currency.InitRoundingPrecision();
        CreateVendorContractSetup();

        VendorContractPage.OpenEdit();
        VendorContractPage.GoToRecord(VendorContract);

        VendorContractLine.Reset();
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", VendorContractLine."Contract Line Type"::"Service Commitment");
        VendorContractLine.FindFirst();
        VendorContractPage.Lines.GoToRecord(VendorContractLine);

        DescriptionText := LibraryRandom.RandText(100);
        VendorContractPage.Lines."Service Object Description".SetValue(DescriptionText);
        ServiceObject.Get(VendorContractLine."Service Object No.");
        AssertThat.AreEqual(ServiceObject.Description, DescriptionText, 'Service Object Description not transferred from Vendor Contract Line.');

        OldServiceCommitment.Get(VendorContractLine."Service Commitment Entry No.");

        ExpectedDate := CalcDate('<-1D>', OldServiceCommitment."Service Start Date");
        VendorContractPage.Lines."Service Start Date".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDate, ServiceCommitment."Service Start Date", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Service Start Date")));

        ExpectedDate := CalcDate('<1D>', WorkDate());
        VendorContractPage.Lines."Service End Date".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDate, ServiceCommitment."Service End Date", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Service End Date")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Discount %" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        VendorContractPage.Lines."Discount %".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Discount %", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Discount %")));

        MaxServiceAmount := Round((OldServiceCommitment.Price * ServiceObject."Quantity Decimal"), Currency."Amount Rounding Precision");
        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Discount Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        VendorContractPage.Lines."Discount Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Discount Amount", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Discount Amount")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Service Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        VendorContractPage.Lines."Service Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Service Amount", StrSubstNo(ServCommFieldFromVendContrLineErr, ServiceCommitment.FieldCaption("Service Amount")));

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

        Evaluate(BillingRhythmValue, '<3M>');
        VendorContractPage.Lines."Billing Rhythm".SetValue(BillingRhythmValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(BillingRhythmValue, ServiceCommitment."Billing Rhythm", StrSubstNo(ServCommFieldFromCustContrLineErr, ServiceCommitment.FieldCaption("Billing Rhythm")));
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ContractLineDisconnectServiceOnTypeChange()
    begin
        // Test: Service Commitment should be disconnected from the contract when the line type changes
        ClearAll();
        SetupNewContract(false);

        VendorContractLine.Reset();
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", VendorContractLine."Contract Line Type"::"Service Commitment");
        VendorContractLine.SetFilter("Service Object No.", '<>%1', '');
        VendorContractLine.SetFilter("Service Commitment Entry No.", '<>%1', 0);
        VendorContractLine.FindFirst();
        asserterror VendorContractLine.Validate("Contract Line Type", VendorContractLine."Contract Line Type"::Comment);
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
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
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
        CreateContractCommentLine(500);
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
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.", true);
        CreateAndPostBillingProposal();

        asserterror UpdateServiceStartDateFromVendorContractSubpage();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyServiceStartDateWhenBillingLineExist()
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.", true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);

        asserterror UpdateServiceStartDateFromVendorContractSubpage();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectNoClosedVendorContractLines()
    var
        VendorContractLine2: Record "Vendor Contract Line";
    begin
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.");
        ContractTestLibrary.InsertVendorContractCommentLine(VendorContract, VendorContractLine2);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", VendorContract."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Service Start Date" := CalcDate('<1D>', Today);
                ServiceCommitment."Service End Date" := CalcDate('<2D>', Today);
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        VendorContract.UpdateServicesDates();
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", "Contract Line Type"::"Service Commitment");
        VendorContractLine.SetRange(Closed, false);
        VendorContractLine.FindFirst();
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
        // Test: A closed Contract Line is deleted when deleting the Service Commitment
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", VendorContract."No.");
        ServiceCommitment.FindFirst();

        VendorContractLine.Get(ServiceCommitment."Contract No.", ServiceCommitment."Contract Line No.");
        VendorContractLine.TestField(Closed, false);
        VendorContractLine.Closed := true;
        VendorContractLine.Modify(false);
        ServiceCommitment.Delete(true);

        asserterror VendorContractLine.Get(VendorContractLine."Contract No.", VendorContractLine."Line No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDeleteServiceCommitmentLinkedToContractLineNotClosed()
    begin
        // Test: Service Commitment cannot be deleted if an open contract line exists
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", VendorContract."No.");
        ServiceCommitment.FindFirst();

        VendorContractLine.Get(ServiceCommitment."Contract No.", ServiceCommitment."Contract Line No.");
        VendorContractLine.TestField(Closed, false);
        asserterror ServiceCommitment.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestEqualServiceStartDateAndNextBillingDate()
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.", true);

        UpdateServiceStartDateFromVendorContractSubpage();

        VendorContractLine.GetServiceCommitment(ServiceCommitment);
        ServiceCommitment.TestField("Next Billing Date", ServiceCommitment."Service Start Date");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectVendorContractLinePageHandler')]
    procedure TestMergeVendorContractLines()
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
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
        ServiceCommitment.SetRange("Service Object No.", NewServiceObject."No.");
        AssertThat.AreEqual(1, ServiceCommitment.Count(), 'Service Commitments not created correctly');
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        // Expect two closed Vendor Contract Lines
        VendorContractLine.Reset();
        VendorContractLine.SetRange(Closed, true);
        AssertThat.AreEqual(2, VendorContractLine.Count(), 'Merged Vendor Contract lines are not closed');

        // Expect one open Vendor Contract Line created from New service object
        VendorContractLine.Reset();
        VendorContractLine.SetRange(Closed, false);
        AssertThat.AreEqual(1, VendorContractLine.Count(), 'Merged Vendor Contract line is not created properly');
        VendorContractLine.FindFirst();
        VendorContractLine.TestField("Service Object No.", NewServiceObject."No.");
        VendorContractLine.TestField("Service Commitment Entry No.");
    end;

    [Test]
    [HandlerFunctions('ServCommWOVendContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestRecalculateServiceCommitmentsOnChangeCurrencyCode()
    begin
        SetupServiceObjectWithServiceCommitment(false);
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
        SetupServiceObjectWithServiceCommitment(false);
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
    procedure TestTransferOfDefaultWithoutContractDeferralsFromContractType()
    begin
        // Create VendorContract with contract type
        // Create new Contract Type with field "Def. Without Contr. Deferrals" = true
        // Check that the field value has been transferred
        ClearAll();
        ContractTestLibrary.CreateVendorContractWithContractType(VendorContract, ContractType);
        VendorContract.TestField("Without Contract Deferrals", ContractType."Def. Without Contr. Deferrals");
        ContractTestLibrary.CreateContractType(ContractType);
        ContractType."Def. Without Contr. Deferrals" := true;
        ContractType.Modify(false);
        VendorContract.Validate("Contract Type", ContractType.Code);
        VendorContract.Modify(false);
        VendorContract.TestField("Without Contract Deferrals", ContractType."Def. Without Contr. Deferrals");
        // allow manually changing the value of the field
        VendorContract.Validate("Without Contract Deferrals", false);
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

    local procedure CreateContractCommentLine(LineNo: Integer)
    begin
        VendorContractLine.Init();
        VendorContractLine."Line No." := LineNo;
        VendorContractLine."Contract No." := VendorContract."No.";
        VendorContractLine."Contract Line Type" := VendorContractLine."Contract Line Type"::Comment;
        VendorContractLine.Insert(true);
    end;

    local procedure CreateTwoEqualServiceObjectsWithServiceCommitments()
    begin
        ServiceObject1 := ServiceObject;
        ServiceObject1."No." := IncStr(ServiceObject."No.");
        ServiceObject1.Insert(false);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then begin
            ServiceCommitment."Service Start Date" := CalcDate('<-2M>', Today);
            ServiceCommitment."Next Billing Date" := ServiceCommitment."Service Start Date";
            ServiceCommitment.Validate("Service Start Date");
            ServiceCommitment.Modify(false);
            repeat
                ServiceCommitment1 := ServiceCommitment;
                ServiceCommitment1."Entry No." := 0;
                ServiceCommitment1."Contract No." := '';
                ServiceCommitment1."Service Object No." := ServiceObject1."No.";
                ServiceCommitment1.Insert(false);
            until ServiceCommitment.Next() = 0;
        end;
    end;

    local procedure CreateVendorContractSetup()
    begin
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.");
    end;

    local procedure GetTotalServiceAmountFromServiceCommitments(): Decimal
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.", ServiceObject1."No.");
        ServiceCommitment.FindFirst();
        exit(Round(ServiceCommitment.Price * ServiceObject1."Quantity Decimal" * 2, Currency."Amount Rounding Precision"));
    end;

    local procedure SetupNewContract(CreateAdditionalLine: Boolean)
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '', CreateAdditionalLine);
    end;

    local procedure SetupServiceObjectWithServiceCommitment(SNSpecificTracking: Boolean)
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitmentPackage: Record "Service Commitment Package";
    begin
        ClearAll();
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, SNSpecificTracking);
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
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer; // added to mix line nos. between service and contract lines
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
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer; // added to mix line nos. between service and contract lines
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
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
    end;

    local procedure TestNewServiceObject()
    begin
        NewServiceObject.Get(VendorContractLine."Service Object No.");
        NewServiceObject.TestField(Description, ServiceObject.Description);
        NewServiceObject.TestField("Item No.", ServiceObject."Item No.");
        NewServiceObject.TestField("End-User Customer No.", ServiceObject."End-User Customer No.");
        NewServiceObject.TestField("Quantity Decimal", ServiceObject."Quantity Decimal" + ServiceObject1."Quantity Decimal");
    end;

    local procedure TestServiceCommitmentUpdateOnCurrencyChange(CurrencyFactorDate: Date; CurrencyFactor: Decimal; RecalculatePrice: Boolean)
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", VendorContract."No.");
        ServiceCommitment.FindFirst();
        repeat
            ServiceCommitment.TestField("Currency Code", VendorContract."Currency Code");
            ServiceCommitment.TestField("Currency Factor Date", CurrencyFactorDate);
            ServiceCommitment.TestField("Currency Factor", CurrencyFactor);

            if RecalculatePrice then begin // if currency code is changed to '', amounts and amounts in lcy in service commitments should be the same
                ServiceCommitment.TestField(Price,
                Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Vendor."Currency Code", ServiceCommitment."Price (LCY)", CurrencyFactor), Currency."Unit-Amount Rounding Precision"));

                ServiceCommitment.TestField("Service Amount",
                Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Vendor."Currency Code", ServiceCommitment."Service Amount (LCY)", CurrencyFactor), Currency."Amount Rounding Precision"));

                ServiceCommitment.TestField("Discount Amount",
                Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Vendor."Currency Code", ServiceCommitment."Discount Amount (LCY)", CurrencyFactor), Currency."Amount Rounding Precision"));
            end
            else begin
                ServiceCommitment.TestField(Price, ServiceCommitment."Price (LCY)");
                ServiceCommitment.TestField("Service Amount", ServiceCommitment."Service Amount (LCY)");
                ServiceCommitment.TestField("Discount Amount", ServiceCommitment."Discount Amount (LCY)");
            end;
        until ServiceCommitment.Next() = 0;
    end;

    local procedure TestVendorContractLinesServiceObjectDescription(VendorContractNo: Code[20]; ServiceObjectDescription: Text[100])
    begin
        VendorContractLine.SetRange("Contract No.", VendorContractNo);
        VendorContractLine.FindSet();
        repeat
            VendorContractLine.TestField("Service Object Description", ServiceObjectDescription);
        until VendorContractLine.Next() = 0;
    end;

    local procedure UpdateServiceStartDateFromVendorContractSubpage()
    var
        NewServiceStartDate: Date;
        VendorContractSubpage: TestPage "Vendor Contract Line Subpage";
    begin
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.FindFirst();
        VendorContractLine.GetServiceCommitment(ServiceCommitment);
        NewServiceStartDate := CalcDate('<1D>', ServiceCommitment."Service Start Date");

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

