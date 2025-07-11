codeunit 18078 "GST Preparations Sales"
{
    Subtype = Test;

    var
        LibraryGST: Codeunit "Library GST";
        LibraryERM: Codeunit "Library - ERM";
        UnregisteredCustomerSetupErr: Label 'Unregistered Customer not created';
        GSTCustomerSetupErr: Label 'Registered Customer not created';
        ExportCustomerSetupErr: Label 'Export Customer not created';

    [Test]
    procedure GSTPrepartionUnregisteredCustomer()
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [358466]	[GST Preparation - Unregistered Customer]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);

        // [WHEN] Updated Customer with State Code and GST Customer Type
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::Unregistered);
        Customer.Modify(true);

        // [THEN] Unregistered Customer Verified
        VerifyUnregisteredCustomer(Customer);
    end;

    [Test]
    procedure GSTPrepartionRegisteredCustomer()
    var
        Customer: Record Customer;
        State: Record State;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [358462] [GST Preparations - Registered Customers]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);

        // [WHEN] Updated Customer with State Code,P.A.N. No.,GST Registration No. and GST Customer Type 
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        State.Get(Customer."State Code");
        Customer.Validate("P.A.N. No.", LibraryGST.CreatePANNos());
        Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", Customer."P.A.N. No."));
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::Registered);
        Customer.Modify(true);

        // [THEN] Registered Customer Verified
        VerifyGSTCustomer(Customer);
    end;

    [Test]
    procedure GSTPrepartionExportCustomer()
    var
        Customer: Record Customer;
        Country: Record "Country/Region";
        Currency: Record Currency;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [358511]	[GST Preparations - Export Customers]
        // [GIVEN] Create Customer Setup,Country Region and Currency
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);
        LibraryERM.CreateCountryRegion(Country);
        LibraryERM.CreateCurrency(Currency);

        // [WHEN] Updated Customer with Country Code,Currency Code and GST Customer Type
        Customer.Validate("Country/Region Code", Country.Code);
        Customer.Validate("Currency Code", Currency.Code);
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::Export);
        Customer.Modify(true);

        // [WHEN] Export Customer Verified
        VerifyExportCustomer(Customer);
    end;

    [Test]
    procedure GSTPrepartionSEZCustomer()
    var
        Customer: Record Customer;
        State: Record State;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [358771]	[GST Preparations - SEZ Unit Customer]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);

        // [WHEN] Updated Customer with State Code,P.A.N. No.,GST Registration No. and GST Customer Type
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        State.Get(Customer."State Code");
        Customer.Validate("P.A.N. No.", LibraryGST.CreatePANNos());
        Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", Customer."P.A.N. No."));
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::"SEZ Unit");
        Customer.Modify(true);

        // [THEN] SEZ Customer Verified
        VerifyGSTCustomer(Customer);
    end;

    [Test]
    procedure GSTPrepartionSEZDevelopmentCustomer()
    var
        Customer: Record Customer;
        State: Record State;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [358772]	[GST Preparations - SEZ Development Customer]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);

        // [WHEN] Updated Customer with State Code,P.A.N. No.,GST Registration No. and GST Customer Type
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        State.Get(Customer."State Code");
        Customer.Validate("P.A.N. No.", LibraryGST.CreatePANNos());
        Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", Customer."P.A.N. No."));
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::"SEZ Development");
        Customer.Modify(true);

        // [THEN] SEZDevelopment Customer Verified
        VerifyGSTCustomer(Customer);
    end;

    [Test]
    procedure GSTPrepartionDeemedExportCustomer()
    var
        Customer: Record Customer;
        State: Record State;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [358775]	[GST Preparations - Deemed Export Customers]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);

        // [WHEN] Updated Customer with State Code,P.A.N. No.,GST Registration No. and GST Customer Type
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        State.Get(Customer."State Code");
        Customer.Validate("P.A.N. No.", LibraryGST.CreatePANNos());
        Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", Customer."P.A.N. No."));
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::"Deemed Export");
        Customer.Modify(true);

        // [THEN] Deemed Export Customer Verified
        VerifyGSTCustomer(Customer);
    end;

    [Test]
    procedure GSTPrepartionExemptedCustomer()
    var
        Customer: Record Customer;
        State: Record State;
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [358776]	[GST Preparations - Exempted Customer]
        // [GIVEN] Created Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);

        // [WHEN] Updated Customer with State Code,P.A.N. No.,GST Registration No. and GST Customer Type
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        State.Get(Customer."State Code");
        Customer.Validate("P.A.N. No.", LibraryGST.CreatePANNos());
        Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", Customer."P.A.N. No."));
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::Exempted);
        Customer.Modify(true);

        // [THEN] Exempted Customer Verified
        VerifyGSTCustomer(Customer);
    end;

    local procedure VerifyUnregisteredCustomer(var Customer: Record Customer)
    begin
        Customer.SetFilter("State Code", '<>%1', '');
        Customer.SetFilter("GST Customer Type", '<>%1', Customer."GST Customer Type"::" ");
        if Customer.IsEmpty then
            Error(UnregisteredCustomerSetupErr);
    end;

    local procedure VerifyGSTCustomer(var Customer: Record Customer)
    begin
        Customer.SetFilter("State Code", '<>%1', '');
        Customer.SetFilter("P.A.N. No.", '<>%1', '');
        Customer.SetFilter("GST Registration No.", '<>%1', '');
        Customer.SetFilter("GST Customer Type", '<>%1', Customer."GST Customer Type"::" ");
        if Customer.IsEmpty then
            Error(GSTCustomerSetupErr);
    end;

    local procedure VerifyExportCustomer(var Customer: Record Customer)
    begin
        Customer.SetFilter("Country/Region Code", '<>%1', '');
        Customer.SetFilter("Currency Code", '<>%1', '');
        Customer.SetFilter("GST Customer Type", '<>%1', Customer."GST Customer Type"::" ");
        if Customer.IsEmpty then
            Error(ExportCustomerSetupErr);
    end;
}