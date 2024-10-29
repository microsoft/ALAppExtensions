codeunit 139628 "Shpfy Tax Id Mapping Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestGetTaxRegistrationIdForRegistrationNo()
    var
        Customer: Record Customer;
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        RegistrationNo: Text[50];
        RegistrationNoResult: Text[50];
    begin
        // [SCENARIO] GetTaxRegistrationId for Tax Registration No. implementation of mapping
        Initialize();

        // [GIVEN] Customer record with Tax Registration No.
        RegistrationNo := Any.AlphanumericText(50);
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer."Registration Number" := RegistrationNo;
        Customer.Insert(false);
        // [GIVEN] TaxRegistrationIdMapping interface is "Registration No."
        TaxRegistrationIdMapping := Enum::"Shpfy Comp. Tax Id Mapping"::"Registration No.";

        // [WHEN] GetTaxRegistrationId is called
        RegistrationNoResult := TaxRegistrationIdMapping.GetTaxRegistrationId(Customer);

        // [THEN] The result is the same as the Registration No. field of the Customer record
        LibraryAssert.AreEqual(RegistrationNo, RegistrationNoResult, 'Registration No.');
    end;

    [Test]
    procedure UnitTestGetTaxRegistrationIdForVATRegistrationNo()
    var
        Customer: Record Customer;
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        VATRegistrationNo: Text[20];
        VATRegistrationNoResult: Text[50];
    begin
        // [SCENARIO] GetTaxRegistrationId for VAT Registration No. implementation of mapping
        Initialize();

        // [GIVEN] Customer record with VAT Registration No.
        VATRegistrationNo := Any.AlphanumericText(20);
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer."VAT Registration No." := VATRegistrationNo;
        Customer.Insert(false);
        // [GIVEN] TaxRegistrationIdMapping interface is "VAT Registration No."
        TaxRegistrationIdMapping := Enum::"Shpfy Comp. Tax Id Mapping"::"VAT Registration No.";

        // [WHEN] GetTaxRegistrationId is called
        VATRegistrationNoResult := TaxRegistrationIdMapping.GetTaxRegistrationId(Customer);

        // [THEN] The result is the same as the VAT Registration No. field of the Customer record
        LibraryAssert.AreEqual(VATRegistrationNo, VATRegistrationNoResult, 'VAT Registration No.');
    end;

    [Test]
    procedure UnitTestSetMappingFiltersForCustomersWithRegistrationNo()
    var
        Customer: Record Customer;
        CompanyLocation: Record "Shpfy Company Location";
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        RegistrationNo: Text[50];
    begin
        // [SCENARIO] SetMappingFiltersForCustomers for Tax Registration Id implementation of mapping
        Initialize();

        // [GIVEN] Registration No. 
        RegistrationNo := Any.AlphanumericText(50);
        // [GIVEN] Customer record with Registration No.
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer."Registration Number" := RegistrationNo;
        Customer.Insert(false);
        // [GIVEN] CompanyLocation record with Tax Registration Id
        CompanyLocation.Init();
        CompanyLocation.Id := Any.IntegerInRange(10000, 99999);
        CompanyLocation."Tax Registration Id" := RegistrationNo;
        CompanyLocation.Insert(false);
        // [GIVEN] TaxRegistrationIdMapping interface is "Registration No."
        TaxRegistrationIdMapping := Enum::"Shpfy Comp. Tax Id Mapping"::"Registration No.";

        // [WHEN] SetMappingFiltersForCustomers is called
        TaxRegistrationIdMapping.SetMappingFiltersForCustomers(Customer, CompanyLocation);

        // [THEN] The range of the Customer record is set to the Tax Registration Id of the CompanyLocation record
        LibraryAssert.AreEqual(RegistrationNo, Customer.GetFilter("Registration Number"), 'Registration No. filter is not set correctly.');
    end;

    [Test]
    procedure UnitTestSetMappingFiltersForCustomersWithVATRegistrationNo()
    var
        Customer: Record Customer;
        CompanyLocation: Record "Shpfy Company Location";
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        VATRegistrationNo: Text[20];
    begin
        // [SCENARIO] SetMappingFiltersForCustomers for VAT Registration No. implementation of mapping
        Initialize();

        // [GIVEN] VAT Registration No.
        VATRegistrationNo := Any.AlphanumericText(20);
        // [GIVEN] Customer record with VAT Registration No.
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer."VAT Registration No." := VATRegistrationNo;
        Customer.Insert(false);
        // [GIVEN] CompanyLocation record with Tax Registration Id
        CompanyLocation.Init();
        CompanyLocation.Id := Any.IntegerInRange(10000, 99999);
        CompanyLocation."Tax Registration Id" := VATRegistrationNo;
        CompanyLocation.Insert(false);
        // [GIVEN] TaxRegistrationIdMapping interface is "VAT Registration No."
        TaxRegistrationIdMapping := Enum::"Shpfy Comp. Tax Id Mapping"::"VAT Registration No.";

        // [WHEN] SetMappingFiltersForCustomers is called
        TaxRegistrationIdMapping.SetMappingFiltersForCustomers(Customer, CompanyLocation);

        // [THEN] The range of the Customer record is set to the Tax Registration Id of the CompanyLocation record
        LibraryAssert.AreEqual(VATRegistrationNo, Customer.GetFilter("VAT Registration No."), 'VAT Registration No. filter is not set correctly.');
    end;


    local procedure Initialize()
    begin
        Any.SetDefaultSeed();

        if IsInitialized then
            exit;

        IsInitialized := true;

        Commit();
    end;


}
