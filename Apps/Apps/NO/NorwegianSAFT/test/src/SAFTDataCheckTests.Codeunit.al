codeunit 148107 "SAF-T Data Check Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        SAFTTestHelper: Codeunit "SAF-T Test Helper";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        SAFTMappingType: Enum "SAF-T Mapping Type";
        IsInitialized: Boolean;
        MissedValueErr: Label 'A field value missed';
        CompanyInformationMissedFieldListTxt: Label 'Name,Address,City,VAT Registration No.,Post Code,Country/Region Code,SAF-T Contact No.,Bank Name or Bank Branch No. or Bank Account No. or IBAN';
        CompanyInformationLimitedMissedFieldListTxt: Label 'Name,City,VAT Registration No.,Country/Region Code,SAF-T Contact No.,Bank Name or Bank Branch No. or Bank Account No. or IBAN';
        BankAccountMissedFieldListTxt: Label 'Name or Bank Account No. or Bank Branch No. or IBAN';
        CustvendBankAccountMissedFieldListTxt: Label 'Name or Bank Branch No. or Bank Account No. or IBAN';

    [Test]
    procedure DataCheckShowNoErrors()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTMappingRange: Record "SAF-T Mapping Range";
    begin
        // [SCENARIO 352458] Stan can see the status of the successfull data check run

        Initialize();
        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", 1);
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        Codeunit.Run(Codeunit::"SAF-T Data Check", SAFTExportHeader);
        SAFTExportHeader.TestField("Latest Data Check Date/Time");
        SAFTExportHeader.TestField("Data check status", SAFTExportHeader."Data check status"::Passed);
    end;

    [Test]
    [HandlerFunctions('ErrorLogPageHandler')]
    procedure DataCheckShowErrors()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTMappingRange: Record "SAF-T Mapping Range";
    begin
        // [SCENARIO 352458] Stan can see the errors when running the data check

        Initialize();
        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", 1);
        ClearCityInFirstCustomer();
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        LibraryVariableStorage.Enqueue(MissedValueErr);
        Codeunit.Run(Codeunit::"SAF-T Data Check", SAFTExportHeader);
        SAFTExportHeader.TestField("Latest Data Check Date/Time");
        SAFTExportHeader.TestField("Data check status", SAFTExportHeader."Data check status"::Failed);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseCustomerCardWithMissingDateAndNotificationDisabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        Customer: Record Customer;
        CustomerCardPage: TestPage "Customer Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Customer Card page with missing date and "Check Customer" disabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Customer", false);
        SAFTSetup.Modify(true);
        Customer.Init();
        Customer.Insert(true);
        CustomerCardPage.OpenEdit();
        CustomerCardPage.Filter.SetFilter("No.", Customer."No.");
        CustomerCardPage.City.SetValue('');
        CustomerCardPage.Close();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseCustomerCardWithFullDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        Customer: Record Customer;
        CustomerCardPage: TestPage "Customer Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Customer Card page with full date and "Check Customer" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Customer", true);
        SAFTSetup.Modify(true);
        CreateCustomerWithFullData(Customer);
        CustomerCardPage.OpenEdit();
        CustomerCardPage.Filter.SetFilter("No.", Customer."No.");
        CustomerCardPage.Close();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure ConfirmationShownWhenCloseCustomerCardWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        Customer: Record Customer;
        CustomerCardPage: TestPage "Customer Card";
    begin
        // [SCENARIO 352458] A confirmation page shown when close the Customer Card page with missing date and "Check Customer" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Customer", true);
        // TFS ID 397908:  Street address is not mandatory
        SAFTSetup.Validate("Check Address", true);
        // TFS ID 397143: Post code is not mandatory
        SAFTSetup.Validate("Check Post Code", true);
        SAFTSetup.Modify(true);
        Customer.Init();
        Customer.Insert(true);
        // TFS ID 389723: Contact field is not mandatory for the SAF-T functionality        
        LibraryVariableStorage.Enqueue('Name,Address,City,Post Code'); // a list of the fields with missing values 
        CustomerCardPage.OpenEdit();
        CustomerCardPage.Filter.SetFilter("No.", Customer."No.");
        CustomerCardPage.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseVendorCardWithMissingDateAndNotificationDisabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        Vendor: Record Vendor;
        VendorCardPage: TestPage "Vendor Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Vendor Card page with missing date and "Check Vendor" disabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Vendor", false);
        SAFTSetup.Modify(true);
        Vendor.Init();
        Vendor.Insert(true);
        VendorCardPage.OpenEdit();
        VendorCardPage.Filter.SetFilter("No.", Vendor."No.");
        VendorCardPage.City.SetValue('');
        VendorCardPage.Close();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseVendorCardWithFullDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        Vendor: Record Vendor;
        VendorCardPage: TestPage "Vendor Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Vendor Card page with full date and "Check Vendor" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Vendor", true);
        SAFTSetup.Modify(true);
        CreateVendorWithFullData(Vendor);
        VendorCardPage.OpenEdit();
        VendorCardPage.Filter.SetFilter("No.", Vendor."No.");
        VendorCardPage.Close();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure ConfirmationShownWhenCloseVendorCardWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        Vendor: Record Vendor;
        VendorCardPage: TestPage "Vendor Card";
    begin
        // [SCENARIO 352458] A confirmation page shown when close the Vendor Card page with missing date and "Check Vendor" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Vendor", true);
        // TFS ID 397908:  Street address is not mandatory
        SAFTSetup.Validate("Check Address", true);
        // TFS ID 397143: Post code is not mandatory
        SAFTSetup.Validate("Check Post Code", true);
        SAFTSetup.Modify(true);
        Vendor.Init();
        Vendor.Insert(true);
        // TFS ID 389723: Contact field is not mandatory for the SAF-T functionality        
        LibraryVariableStorage.Enqueue('Name,Address,City,Post Code'); // a list of the fields with missing values 
        VendorCardPage.OpenEdit();
        VendorCardPage.Filter.SetFilter("No.", Vendor."No.");
        VendorCardPage.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseCompanyInformationWithMissingDateAndNotificationDisabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        CompanyInformation: Record "Company Information";
        CompanyInformationCard: TestPage "Company Information";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Company Information page with missing date and "Check Company Information" disabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Company Information", false);
        SAFTSetup.Modify(true);
        CompanyInformation.Init();
        CompanyInformation.Modify();
        CompanyInformationCard.OpenEdit();
        CompanyInformationCard."VAT Registration No.".SetValue('');
        CompanyInformationCard.Close();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseCompanyInformationWithFullDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        CompanyInformationCard: TestPage "Company Information";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Company Information page with full date and "Check Company Information" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Company Information", true);
        SAFTSetup.Modify(true);
        SetFullDateForCompanyInformation();
        CompanyInformationCard.OpenEdit();
        CompanyInformationCard.Close();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure ConfirmationShownWhenCloseCompanyInformationWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        CompanyInformation: Record "Company Information";
        CompanyInformationCard: TestPage "Company Information";
    begin
        // [SCENARIO 352458] A confirmation page shown when close Company Information page with missing date and "Check Company Information" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Company Information", true);
        // TFS ID 397908:  Street address is not mandatory
        SAFTSetup.Validate("Check Address", true);
        // TFS ID 397143: Post code is not mandatory
        SAFTSetup.Validate("Check Post Code", true);
        SAFTSetup.Modify(true);
        CompanyInformation.Init();
        CompanyInformation.Modify(true);
        LibraryVariableStorage.Enqueue(CompanyInformationMissedFieldListTxt); // a list of the fields with missing values 
        CompanyInformationCard.OpenEdit();
        CompanyInformationCard.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseBankAccountCardWithMissingDateAndNotificationDisabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        BankAccount: Record "Bank Account";
        BankAccountCardPage: TestPage "Bank Account Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Bank Account Card page with missing date and "Check Bank Account" disabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", false);
        SAFTSetup.Modify(true);
        BankAccount.Init();
        BankAccount.Insert(true);
        BankAccountCardPage.OpenEdit();
        BankAccountCardPage.Filter.SetFilter("No.", BankAccount."No.");
        BankAccountCardPage.City.SetValue('');
        BankAccountCardPage.Close();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseBankAccountCardWithFullDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        BankAccount: Record "Bank Account";
        BankAccountCardPage: TestPage "Bank Account Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Bank Account Card page with full date and "Check Bank Account" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", true);
        SAFTSetup.Modify(true);
        CreateBankAccountWithFullData(BankAccount);
        BankAccountCardPage.OpenEdit();
        BankAccountCardPage.Filter.SetFilter("No.", BankAccount."No.");
        BankAccountCardPage.Close();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure ConfirmationShownWhenCloseBankAccountCardWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        BankAccount: Record "Bank Account";
        BankAccountCardPage: TestPage "Bank Account Card";
    begin
        // [SCENARIO 352458] A confirmation page shown when close the Bank Account Card page with missing date and "Check Bank Account" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", true);
        SAFTSetup.Modify(true);
        BankAccount.Init();
        BankAccount.Insert(true);
        LibraryVariableStorage.Enqueue(BankAccountMissedFieldListTxt); // a list of the fields with missing values 
        BankAccountCardPage.OpenEdit();
        BankAccountCardPage.Filter.SetFilter("No.", BankAccount."No.");
        BankAccountCardPage.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseCustomerBankAccountCardWithMissingDateAndNotificationDisabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        CustomerBankAccount: Record "Customer Bank Account";
        CustomerBankAccountCardPage: TestPage "Customer Bank Account Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Customer Bank Account Card page with missing date and "Check Bank Account" disabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", false);
        SAFTSetup.Modify(true);
        CreateCustomerBankAccount(CustomerBankAccount);
        CustomerBankAccountCardPage.OpenEdit();
        CustomerBankAccountCardPage.Filter.SetFilter(Code, CustomerBankAccount.Code);
        CustomerBankAccountCardPage.City.SetValue('');
        CustomerBankAccountCardPage.Close();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseCustomerBankAccountCardWithFullDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        CustomerBankAccount: Record "Customer Bank Account";
        CustomerBankAccountCardPage: TestPage "Customer Bank Account Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Customer Bank Account Card page with full date and "Check Bank Account" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", true);
        SAFTSetup.Modify(true);
        CreateCustomerBankAccountWithFullData(CustomerBankAccount);
        CustomerBankAccountCardPage.OpenEdit();
        CustomerBankAccountCardPage.Filter.SetFilter(Code, CustomerBankAccount.Code);
        CustomerBankAccountCardPage.Close();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure ConfirmationShownWhenCloseCustomerBankAccountCardWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        CustomerBankAccount: Record "Customer Bank Account";
        CustomerBankAccountCardPage: TestPage "Customer Bank Account Card";
    begin
        // [SCENARIO 352458] A confirmation page shown when close the Customer Bank Account Card page with missing date and "Check Bank Account" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", true);
        SAFTSetup.Modify(true);
        CustomerBankAccount.Init();
        CustomerBankAccount.Insert(true);
        LibraryVariableStorage.Enqueue(CustvendBankAccountMissedFieldListTxt); // a list of the fields with missing values 
        CustomerBankAccountCardPage.OpenEdit();
        CustomerBankAccountCardPage.Filter.SetFilter(Code, CustomerBankAccount.Code);
        CustomerBankAccountCardPage.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseVendorBankAccountCardWithMissingDateAndNotificationDisabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        VendorBankAccount: Record "Vendor Bank Account";
        VendorBankAccountCardPage: TestPage "Vendor Bank Account Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Vendor Bank Account Card page with missing date and "Check Bank Account" disabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", false);
        SAFTSetup.Modify(true);
        CreateVendorBankAccount(VendorBankAccount);
        VendorBankAccountCardPage.OpenEdit();
        VendorBankAccountCardPage.Filter.SetFilter(Code, VendorBankAccount.Code);
        VendorBankAccountCardPage.City.SetValue('');
        VendorBankAccountCardPage.Close();
    end;

    [Test]
    procedure NoConfirmationShownWhenCloseVendorBankAccountCardWithFullDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        VendorBankAccount: Record "Vendor Bank Account";
        VendorBankAccountCardPage: TestPage "Vendor Bank Account Card";
    begin
        // [SCENARIO 352458] No confirmation page shown when close the Vendor Bank Account Card page with full date and "Check Bank Account" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", true);
        SAFTSetup.Modify(true);
        CreateVendorBankAccountWithFullData(VendorBankAccount);
        VendorBankAccountCardPage.OpenEdit();
        VendorBankAccountCardPage.Filter.SetFilter(Code, VendorBankAccount.Code);
        VendorBankAccountCardPage.Close();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure ConfirmationShownWhenCloseVendorBankAccountCardWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        VendorBankAccount: Record "Vendor Bank Account";
        VendorBankAccountCardPage: TestPage "Vendor Bank Account Card";
    begin
        // [SCENARIO 352458] A confirmation page shown when close the Vendor Bank Account Card page with missing date and "Check Bank Account" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Bank Account", true);
        SAFTSetup.Modify(true);
        CreateVendorBankAccount(VendorBankAccount);
        LibraryVariableStorage.Enqueue(CustvendBankAccountMissedFieldListTxt); // a list of the fields with missing values 
        VendorBankAccountCardPage.OpenEdit();
        VendorBankAccountCardPage.Filter.SetFilter(Code, VendorBankAccount.Code);
        VendorBankAccountCardPage.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure PartialConfirmationShownWhenCloseCustomerCardWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        Customer: Record Customer;
        CustomerCardPage: TestPage "Customer Card";
    begin
        // [SCENARIO 352458] A confirmation page with only Name and City shown when close the Customer Card page with missing data and "Check Customer" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Customer", true);
        SAFTSetup.Modify(true);
        Customer.Init();
        Customer.Insert(true);
        LibraryVariableStorage.Enqueue('Name,City'); // a list of the fields with missing values 
        CustomerCardPage.OpenEdit();
        CustomerCardPage.Filter.SetFilter("No.", Customer."No.");
        CustomerCardPage.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure ParialConfirmationShownWhenCloseVendorCardWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        Vendor: Record Vendor;
        VendorCardPage: TestPage "Vendor Card";
    begin
        // [SCENARIO 352458] A confirmation page with only Name and City shown when close the Vendor Card page with missing date and "Check Vendor" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Vendor", true);
        SAFTSetup.Modify(true);
        Vendor.Init();
        Vendor.Insert(true);
        LibraryVariableStorage.Enqueue('Name,City'); // a list of the fields with missing values 
        VendorCardPage.OpenEdit();
        VendorCardPage.Filter.SetFilter("No.", Vendor."No.");
        VendorCardPage.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DataCheckModalPageHandler')]
    procedure PartialConfirmationShownWhenCloseCompanyInformationWithMissingDataAndNotificationEnabled()
    var
        SAFTSetup: Record "SAF-T Setup";
        CompanyInformation: Record "Company Information";
        CompanyInformationCard: TestPage "Company Information";
    begin
        // [SCENARIO 352458] A confirmation page with only name and city shown when close Company Information page with missing date and "Check Company Information" enabled in the SAF-T Setup

        Initialize();
        SAFTSetup.Get();
        SAFTSetup.Validate("Check Company Information", true);
        SAFTSetup.Modify(true);
        CompanyInformation.Init();
        CompanyInformation.Modify(true);
        LibraryVariableStorage.Enqueue(CompanyInformationLimitedMissedFieldListTxt); // a list of the fields with missing values 
        CompanyInformationCard.OpenEdit();
        CompanyInformationCard.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    var
        SAFTSetup: Record "SAF-T Setup";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T Data Check Tests");
        LibrarySetupStorage.Restore();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T Data Check Tests");
        SAFTSetup.DeleteAll();
        SAFTSetup.Init();
        SAFTSetup.Insert();
        LibrarySetupStorage.Save(Database::"SAF-T Setup");
        LibrarySetupStorage.Save(Database::"Company Information");
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T Data Check Tests");
    end;

    local procedure CreateCustomerWithFullData(var Customer: Record Customer)
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.CreatePostCode(PostCode);
        Customer.Init();
        Customer."No." := LibraryUtility.GenerateGUID();
        Customer.Name := LibraryUtility.GenerateGUID();
        Customer.Address := LibraryUtility.GenerateGUID();
        Customer.City := PostCode.City;
        Customer."Post Code" := PostCode.Code;
        Customer.Insert();
    end;

    local procedure CreateVendorWithFullData(var Vendor: Record Vendor)
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.CreatePostCode(PostCode);
        Vendor.Init();
        Vendor."No." := LibraryUtility.GenerateGUID();
        Vendor.Name := LibraryUtility.GenerateGUID();
        Vendor.Address := LibraryUtility.GenerateGUID();
        Vendor.City := PostCode.City;
        Vendor."Post Code" := PostCode.Code;
        Vendor.Insert();
    end;

    local procedure CreateBankAccountWithFullData(var BankAccount: Record "Bank Account")
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.CreatePostCode(PostCode);
        BankAccount.Init();
        BankAccount.IBAN := LibraryUtility.GenerateGUID();
        BankAccount."Bank Account No." := LibraryUtility.GenerateGUID();
        BankAccount.Name := LibraryUtility.GenerateGUID();
        BankAccount."Bank Branch No." := LibraryUtility.GenerateGUID();
        BankAccount.Insert();
    end;

    local procedure CreateCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account")
    var
        Customer: Record Customer;
    begin
        Customer.Insert(true);
        CustomerBankAccount.Init();
        CustomerBankAccount."Customer No." := Customer."No.";
        CustomerBankAccount.Code := LibraryUtility.GenerateGUID();
        CustomerBankAccount.Insert();
    end;

    local procedure CreateCustomerBankAccountWithFullData(var CustomerBankAccount: Record "Customer Bank Account")
    begin
        CreateCustomerBankAccount(CustomerBankAccount);
        CustomerBankAccount.IBAN := LibraryUtility.GenerateGUID();
        CustomerBankAccount."Bank Account No." := LibraryUtility.GenerateGUID();
        CustomerBankAccount.Name := LibraryUtility.GenerateGUID();
        CustomerBankAccount."Bank Branch No." := LibraryUtility.GenerateGUID();
        CustomerBankAccount.Modify();
    end;

    local procedure CreateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account")
    var
        Vendor: Record Vendor;
    begin
        Vendor.Insert(true);
        VendorBankAccount.Init();
        VendorBankAccount."Vendor No." := Vendor."No.";
        VendorBankAccount.Code := LibraryUtility.GenerateGUID();
        VendorBankAccount.Insert();
    end;

    local procedure CreateVendorBankAccountWithFullData(var VendorBankAccount: Record "Vendor Bank Account")
    begin
        CreateVendorBankAccount(VendorBankAccount);
        VendorBankAccount.IBAN := LibraryUtility.GenerateGUID();
        VendorBankAccount."Bank Account No." := LibraryUtility.GenerateGUID();
        VendorBankAccount.Name := LibraryUtility.GenerateGUID();
        VendorBankAccount."Bank Branch No." := LibraryUtility.GenerateGUID();
        VendorBankAccount.Modify();
    end;

    local procedure ClearCityInFirstCustomer()
    var
        Customer: Record "Customer";
    begin
        Customer.FindFirst();
        Customer.City := '';
        Customer.Modify();
    end;

    local procedure SetFullDateForCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        PostCode: Record "Post Code";
        Employee: Record Employee;
        CountryRegion: Record "Country/Region";
    begin
        CompanyInformation.Get();
        CompanyInformation.Name := LibraryUtility.GenerateGUID();
        CompanyInformation.Address := LibraryUtility.GenerateGUID();
        LibraryERM.CreatePostCode(PostCode);
        CompanyInformation.City := PostCode.City;
        CompanyInformation."Post Code" := PostCode.Code;
        CompanyInformation."VAT Registration No." := LibraryUtility.GenerateGUID();
        LibraryHumanResource.CreateEmployee(Employee);
        CompanyInformation."SAF-T Contact No." := Employee."No.";
        LibraryERM.CreateCountryRegion(CountryRegion);
        CompanyInformation."Country/Region Code" := CountryRegion.Code;
        CompanyInformation.IBAN := LibraryUtility.GenerateGUID();
        CompanyInformation.Modify();
    end;

    [PageHandler]
    procedure ErrorLogPageHandler(var ErrorMessages: TestPage "Error Messages")
    begin
        ErrorMessages.Description.AssertEquals(LibraryVariableStorage.DequeueText());
    end;

    [ModalPageHandler]
    procedure DataCheckModalPageHandler(var SAFTDataCheck: TestPage "SAF-T Data Check")
    begin
        SAFTDataCheck.MissedValuesListControl.AssertEquals(LibraryVariableStorage.DequeueText());
        SAFTDataCheck.Yes().Invoke();
    end;
}
