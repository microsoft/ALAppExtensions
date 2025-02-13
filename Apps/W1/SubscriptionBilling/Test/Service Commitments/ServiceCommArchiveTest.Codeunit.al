namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;

codeunit 139916 "Service Comm. Archive Test"
{
    Subtype = Test;
    Access = Internal;

    [Test]
    procedure ExpectSingleServiceCommitmentArchiveOnModifyMultipleFields()
    var
        ServiceCommitmentSubPage: TestPage "Service Commitments";
    begin
        //Expect only one service commitment archive if multiple fields are modified in less then a minute
        SetupServiceObjectWithServiceCommitment(false, false);
        xServiceCommitment := ServiceCommitment;
        //in the end Service Commitment Archive should look the same as initially
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
        //Expect only one service commitment archive if multiple fields are modified in less then a minute
        SetupServiceObjectWithServiceCommitment(false, false);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
        CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);

        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindFirst();
        //in the end Service Commitment Archive should look the same as initially
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
        //Expect only one service commitment archive if multiple fields are modified in less then a minute
        SetupServiceObjectWithServiceCommitment(false, true);

        ContractTestLibrary.CreateVendorContract(VendorContract, '');
        ContractTestLibrary.FillTempServiceCommitmentForVendor(TempServiceCommitment, ServiceObject, VendorContract);
        VendorContract.CreateVendorContractLineFromServiceCommitment(TempServiceCommitment);

        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.FindFirst();
        //in the end Service Commitment Archive should look the same as initial service commitment
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

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    procedure SetupServiceObjectWithServiceCommitment(SNSpecificTracking: Boolean; CreateWithAdditionalVendorServCommLine: Boolean)
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

    local procedure TestServiceCommitmentArchive(SourcexServiceCommitment: Record "Service Commitment")
    begin
        ServiceCommitmentArchive.TestField("Service Object No.", SourcexServiceCommitment."Service Object No.");
        ServiceObject.Get(ServiceCommitment."Service Object No.");
        ServiceCommitmentArchive.TestField("Quantity Decimal (Service Ob.)", ServiceObject."Quantity Decimal");
        ServiceCommitmentArchive.TestField("Original Entry No.", SourcexServiceCommitment."Entry No.");
        ServiceCommitmentArchive.TestField("Package Code", SourcexServiceCommitment."Package Code");
        ServiceCommitmentArchive.TestField("Template", SourcexServiceCommitment."Template");
        ServiceCommitmentArchive.TestField("Description", SourcexServiceCommitment."Description");
        ServiceCommitmentArchive.TestField("Service Start Date", SourcexServiceCommitment."Service Start Date");
        ServiceCommitmentArchive.TestField("Service End Date", SourcexServiceCommitment."Service End Date");
        ServiceCommitmentArchive.TestField("Next Billing Date", SourcexServiceCommitment."Next Billing Date");
        ServiceCommitmentArchive.TestField("Calculation Base Amount", SourcexServiceCommitment."Calculation Base Amount");
        ServiceCommitmentArchive.TestField("Calculation Base %", SourcexServiceCommitment."Calculation Base %");
        ServiceCommitmentArchive.TestField("Price", SourcexServiceCommitment."Price");
        ServiceCommitmentArchive.TestField("Billing Base Period", SourcexServiceCommitment."Billing Base Period");
        ServiceCommitmentArchive.TestField("Invoicing via", SourcexServiceCommitment."Invoicing via");
        ServiceCommitmentArchive.TestField("Invoicing Item No.", SourcexServiceCommitment."Invoicing Item No.");
        ServiceCommitmentArchive.TestField("Partner", SourcexServiceCommitment."Partner");
        ServiceCommitmentArchive.TestField("Contract No.", SourcexServiceCommitment."Contract No.");
        ServiceCommitmentArchive.TestField("Notice Period", SourcexServiceCommitment."Notice Period");
        ServiceCommitmentArchive.TestField("Initial Term", SourcexServiceCommitment."Initial Term");
        ServiceCommitmentArchive.TestField("Extension Term", SourcexServiceCommitment."Extension Term");
        ServiceCommitmentArchive.TestField("Billing Rhythm", SourcexServiceCommitment."Billing Rhythm");
        ServiceCommitmentArchive.TestField("Cancellation Possible Until", SourcexServiceCommitment."Cancellation Possible Until");
        ServiceCommitmentArchive.TestField("Term Until", SourcexServiceCommitment."Term Until");
        ServiceCommitmentArchive.TestField("Service Object Customer No.", SourcexServiceCommitment."Service Object Customer No.");
        ServiceCommitmentArchive.TestField("Contract Line No.", SourcexServiceCommitment."Contract Line No.");
        ServiceCommitmentArchive.TestField("Customer Price Group", SourcexServiceCommitment."Customer Price Group");
        ServiceCommitmentArchive.TestField("Shortcut Dimension 1 Code", SourcexServiceCommitment."Shortcut Dimension 1 Code");
        ServiceCommitmentArchive.TestField("Shortcut Dimension 2 Code", SourcexServiceCommitment."Shortcut Dimension 2 Code");
        ServiceCommitmentArchive.TestField("Price (LCY)", SourcexServiceCommitment."Price (LCY)");
        ServiceCommitmentArchive.TestField("Discount Amount (LCY)", SourcexServiceCommitment."Discount Amount (LCY)");
        ServiceCommitmentArchive.TestField("Service Amount (LCY)", SourcexServiceCommitment."Service Amount (LCY)");
        ServiceCommitmentArchive.TestField("Currency Code", SourcexServiceCommitment."Currency Code");
        ServiceCommitmentArchive.TestField("Currency Factor", SourcexServiceCommitment."Currency Factor");
        ServiceCommitmentArchive.TestField("Currency Factor Date", SourcexServiceCommitment."Currency Factor Date");
        ServiceCommitmentArchive.TestField("Calculation Base Amount (LCY)", SourcexServiceCommitment."Calculation Base Amount (LCY)");
        ServiceCommitmentArchive.TestField("Dimension Set ID", SourcexServiceCommitment."Dimension Set ID");
        ServiceCommitmentArchive.TestField("Discount %", SourcexServiceCommitment."Discount %");
        ServiceCommitmentArchive.TestField("Discount Amount", SourcexServiceCommitment."Discount Amount");
        ServiceCommitmentArchive.TestField("Service Amount", SourcexServiceCommitment."Service Amount");
    end;

    local procedure CheckServiceCommitmentArchive(FieldName: Text)
    begin
        ServiceCommitmentArchive.FilterOnServiceCommitment(ServiceCommitment."Entry No.");
        AssertThat.AreEqual(1, ServiceCommitmentArchive.Count, 'Service commitment was not archived properly from field: ' + FieldName);
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

    var
        ServiceCommitment: Record "Service Commitment";
        xServiceCommitment: Record "Service Commitment";
        Item: Record Item;
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        ServiceObject: Record "Service Object";
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitmentArchive: Record "Service Commitment Archive";
        Customer: Record Customer;
        VendorContractLine: Record "Vendor Contract Line";
        AssertThat: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
}
