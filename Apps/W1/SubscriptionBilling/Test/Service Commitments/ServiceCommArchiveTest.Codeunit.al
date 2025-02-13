namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;

codeunit 139916 "Service Comm. Archive Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        CustomerContractLine: Record "Customer Contract Line";
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentArchive: Record "Service Commitment Archive";
        ServiceObject: Record "Service Object";
        VendorContract: Record "Vendor Contract";
        VendorContractLine: Record "Vendor Contract Line";
        xServiceCommitment: Record "Service Commitment";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";

    #region Tests

    [Test]
    procedure ExpectSingleServiceCommitmentArchiveOnModifyMultipleFields()
    var
        ServiceCommitmentSubPage: TestPage "Service Commitments";
    begin
        // Expect only one service commitment archive if multiple fields are modified in less then a minute
        SetupServiceObjectWithServiceCommitment(false, false);
        xServiceCommitment := ServiceCommitment;
        // in the end Service Commitment Archive should look the same as initially
        ServiceCommitmentSubPage.OpenEdit();
        ServiceCommitmentSubPage.GoToRecord(ServiceCommitment);

        ServiceCommitmentSubPage."Calculation Base %".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Calculation Base %"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        ServiceCommitmentSubPage."Calculation Base Amount".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Calculation Base Amount"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        ServiceCommitmentSubPage.Price.SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName(Price));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        ServiceCommitmentSubPage."Billing Base Period".SetValue('2Y');
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Billing Base Period"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        ServiceCommitmentSubPage."Billing Rhythm".SetValue('2M');
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Billing Rhythm"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        ServiceCommitmentSubPage."Service Amount".SetValue(LibraryRandom.RandDecInDecimalRange(0, ServiceCommitment.Price, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Service Amount"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        ServiceCommitmentSubPage."Discount %".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Discount %"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        ServiceCommitmentSubPage."Discount Amount".SetValue(LibraryRandom.RandDecInDecimalRange(0, ServiceCommitment.Price, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Discount Amount"));
        FindAndTestServiceCommitmentArchive();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectSingleServiceCommitmentArchiveOnModifyMultipleFieldsOnCustomerContractLine()
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
        CustomerContractLineSubPage: TestPage "Customer Contract Line Subp.";
    begin
        // Expect only one service commitment archive if multiple fields are modified in less then a minute
        SetupServiceObjectWithServiceCommitment(false, false);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
        CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);

        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindFirst();
        // in the end Service Commitment Archive should look the same as initially
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        xServiceCommitment := ServiceCommitment;
        CustomerContractLineSubPage.OpenEdit();
        CustomerContractLineSubPage.GoToRecord(CustomerContractLine);

        CustomerContractLineSubPage."Calculation Base %".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Calculation Base %"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        CustomerContractLineSubPage."Calculation Base Amount".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Calculation Base Amount"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        CustomerContractLineSubPage."Billing Base Period".SetValue('2Y');
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Billing Base Period"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        CustomerContractLineSubPage."Billing Rhythm".SetValue('2M');
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Billing Rhythm"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        CustomerContractLineSubPage."Service Amount".SetValue(LibraryRandom.RandDecInDecimalRange(0, ServiceCommitment.Price, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Service Amount"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        CustomerContractLineSubPage."Discount %".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Discount %"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        CustomerContractLineSubPage."Discount Amount".SetValue(LibraryRandom.RandDecInDecimalRange(0, ServiceCommitment.Price, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Discount Amount"));
        FindAndTestServiceCommitmentArchive();
    end;

    [Test]
    procedure ExpectSingleServiceCommitmentArchiveOnModifyMultipleFieldsOnVendorContractLine()
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
        VendorContractLineSubPage: TestPage "Vendor Contract Line Subpage";
    begin
        // Expect only one service commitment archive if multiple fields are modified in less then a minute
        SetupServiceObjectWithServiceCommitment(false, true);

        ContractTestLibrary.CreateVendorContract(VendorContract, '');
        ContractTestLibrary.FillTempServiceCommitmentForVendor(TempServiceCommitment, ServiceObject, VendorContract);
        VendorContract.CreateVendorContractLineFromServiceCommitment(TempServiceCommitment);

        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.FindFirst();
        // in the end Service Commitment Archive should look the same as initial service commitment
        VendorContractLine.GetServiceCommitment(ServiceCommitment);
        xServiceCommitment := ServiceCommitment;
        VendorContractLineSubPage.OpenEdit();
        VendorContractLineSubPage.GoToRecord(VendorContractLine);

        VendorContractLineSubPage."Calculation Base %".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Calculation Base %"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        VendorContractLineSubPage."Calculation Base Amount".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Calculation Base Amount"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        VendorContractLineSubPage."Billing Rhythm".SetValue('2M');
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Billing Rhythm"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        VendorContractLineSubPage."Service Amount".SetValue(LibraryRandom.RandDecInDecimalRange(0, ServiceCommitment.Price, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Service Amount"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        VendorContractLineSubPage."Discount %".SetValue(LibraryRandom.RandDec(10, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Discount %"));
        FindAndTestServiceCommitmentArchive();

        FetchPreviousServiceCommitment();
        VendorContractLineSubPage."Discount Amount".SetValue(LibraryRandom.RandDecInDecimalRange(0, ServiceCommitment.Price, 2));
        CheckServiceCommitmentArchive(ServiceCommitment.FieldName("Discount Amount"));
        FindAndTestServiceCommitmentArchive();
    end;

    #endregion Tests

    #region Procedures

    local procedure SetupServiceObjectWithServiceCommitment(SNSpecificTracking: Boolean; CreateWithAdditionalVendorServCommLine: Boolean)
    begin
        ClearAll();
        ServiceCommitmentArchive.Reset();
        ServiceCommitmentArchive.DeleteAll(false);
        ContractTestLibrary.InitContractsApp();
        if CreateWithAdditionalVendorServCommLine then
            ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, SNSpecificTracking, Item, 1, 1)
        else
            ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, SNSpecificTracking, Item, 1, 0);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
    end;

    local procedure CheckServiceCommitmentArchive(FieldName: Text)
    begin
        ServiceCommitmentArchive.FilterOnServiceCommitment(ServiceCommitment."Entry No.");
        Assert.AreEqual(1, ServiceCommitmentArchive.Count, 'Service commitment was not archived properly from field: ' + FieldName);
    end;

    local procedure FetchPreviousServiceCommitment()
    begin
        ServiceCommitment.Get(ServiceCommitment."Entry No.");
        xServiceCommitment := ServiceCommitment;
    end;

    local procedure FindAndTestServiceCommitmentArchive()
    begin
        ServiceCommitmentArchive.FindLast();
        TestServiceCommitmentArchive(xServiceCommitment);
    end;

    local procedure TestServiceCommitmentArchive(SourceServiceCommitment: Record "Service Commitment")
    begin
        ServiceCommitmentArchive.TestField("Service Object No.", SourceServiceCommitment."Service Object No.");
        ServiceObject.Get(ServiceCommitment."Service Object No.");
        ServiceCommitmentArchive.TestField("Quantity Decimal (Service Ob.)", ServiceObject."Quantity Decimal");
        ServiceCommitmentArchive.TestField("Original Entry No.", SourceServiceCommitment."Entry No.");
        ServiceCommitmentArchive.TestField("Package Code", SourceServiceCommitment."Package Code");
        ServiceCommitmentArchive.TestField("Template", SourceServiceCommitment."Template");
        ServiceCommitmentArchive.TestField("Description", SourceServiceCommitment."Description");
        ServiceCommitmentArchive.TestField("Service Start Date", SourceServiceCommitment."Service Start Date");
        ServiceCommitmentArchive.TestField("Service End Date", SourceServiceCommitment."Service End Date");
        ServiceCommitmentArchive.TestField("Next Billing Date", SourceServiceCommitment."Next Billing Date");
        ServiceCommitmentArchive.TestField("Calculation Base Amount", SourceServiceCommitment."Calculation Base Amount");
        ServiceCommitmentArchive.TestField("Calculation Base %", SourceServiceCommitment."Calculation Base %");
        ServiceCommitmentArchive.TestField("Price", SourceServiceCommitment."Price");
        ServiceCommitmentArchive.TestField("Billing Base Period", SourceServiceCommitment."Billing Base Period");
        ServiceCommitmentArchive.TestField("Invoicing via", SourceServiceCommitment."Invoicing via");
        ServiceCommitmentArchive.TestField("Invoicing Item No.", SourceServiceCommitment."Invoicing Item No.");
        ServiceCommitmentArchive.TestField("Partner", SourceServiceCommitment."Partner");
        ServiceCommitmentArchive.TestField("Contract No.", SourceServiceCommitment."Contract No.");
        ServiceCommitmentArchive.TestField("Notice Period", SourceServiceCommitment."Notice Period");
        ServiceCommitmentArchive.TestField("Initial Term", SourceServiceCommitment."Initial Term");
        ServiceCommitmentArchive.TestField("Extension Term", SourceServiceCommitment."Extension Term");
        ServiceCommitmentArchive.TestField("Billing Rhythm", SourceServiceCommitment."Billing Rhythm");
        ServiceCommitmentArchive.TestField("Cancellation Possible Until", SourceServiceCommitment."Cancellation Possible Until");
        ServiceCommitmentArchive.TestField("Term Until", SourceServiceCommitment."Term Until");
        ServiceCommitmentArchive.TestField("Service Object Customer No.", SourceServiceCommitment."Service Object Customer No.");
        ServiceCommitmentArchive.TestField("Contract Line No.", SourceServiceCommitment."Contract Line No.");
        ServiceCommitmentArchive.TestField("Customer Price Group", SourceServiceCommitment."Customer Price Group");
        ServiceCommitmentArchive.TestField("Shortcut Dimension 1 Code", SourceServiceCommitment."Shortcut Dimension 1 Code");
        ServiceCommitmentArchive.TestField("Shortcut Dimension 2 Code", SourceServiceCommitment."Shortcut Dimension 2 Code");
        ServiceCommitmentArchive.TestField("Price (LCY)", SourceServiceCommitment."Price (LCY)");
        ServiceCommitmentArchive.TestField("Discount Amount (LCY)", SourceServiceCommitment."Discount Amount (LCY)");
        ServiceCommitmentArchive.TestField("Service Amount (LCY)", SourceServiceCommitment."Service Amount (LCY)");
        ServiceCommitmentArchive.TestField("Currency Code", SourceServiceCommitment."Currency Code");
        ServiceCommitmentArchive.TestField("Currency Factor", SourceServiceCommitment."Currency Factor");
        ServiceCommitmentArchive.TestField("Currency Factor Date", SourceServiceCommitment."Currency Factor Date");
        ServiceCommitmentArchive.TestField("Calculation Base Amount (LCY)", SourceServiceCommitment."Calculation Base Amount (LCY)");
        ServiceCommitmentArchive.TestField("Dimension Set ID", SourceServiceCommitment."Dimension Set ID");
        ServiceCommitmentArchive.TestField("Discount %", SourceServiceCommitment."Discount %");
        ServiceCommitmentArchive.TestField("Discount Amount", SourceServiceCommitment."Discount Amount");
        ServiceCommitmentArchive.TestField("Service Amount", SourceServiceCommitment."Service Amount");
    end;

    #endregion Procedures

    #region Handlers

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    #endregion Handlers
}
