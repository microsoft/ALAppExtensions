codeunit 148092 "Identification Numbers CZL"
{
    // [FEATURE] [Registration No.] [Tax Registration No.]
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        CheckMustBeFalseTxt: Label 'Result of check must be false.';
        CheckMustBeTrueTxt: Label 'Result of check must be true.';
        RegNoEnteredCustMsg: Label 'This %1 has already been entered for the following customers:\ %2.', Comment = '%1=fieldcaption, %2=customer number list';
        RegNoEnteredVendMsg: Label 'This %1 has already been entered for the following vendors:\ %2.', Comment = '%1=fieldcaption, %2=vendor number list';
        RegNoEnteredContMsg: Label 'This %1 has already been entered for the following contacts:\ %2.', Comment = '%1=fieldcaption, %2=contact number list';

    [Test]
    procedure CheckingEmptyRegistrationNo()
    begin
        // [FEATURE] [UT]
        // [SCENARIO] Check empty Registration No.
        CheckingEmptyIdentificationNo(false);
    end;

    [Test]
    procedure CheckingEmptyTaxRegistrationNo()
    begin
        // [FEATURE] [UT]
        // [SCENARIO] Check empty Tax Registration No.
        CheckingEmptyIdentificationNo(true)
    end;

    local procedure CheckingEmptyIdentificationNo(IsTax: Boolean)
    var
        CheckResult: Boolean;
    begin
        Initialize();

        // [WHEN] Registration No. or Tax Registratio No. is empty
        if IsTax then
            CheckResult := CheckTaxRegistrationNo('', '', 0)
        else
            CheckResult := CheckRegistrationNo('', '', 0);

        // [THEN] Result of check must be FALSE
        Assert.IsFalse(CheckResult, CheckMustBeFalseTxt);
    end;

    [Test]
    procedure CheckingRegistrationNoOnContact()
    begin
        // [FEATURE] [UT] [Contact]
        // [SCENARIO] Check Registration No. which is not duplicated
        CheckingIdentificationNo(Database::Contact, false);
    end;

    [Test]
    procedure CheckingRegistrationNoOnCustomer()
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO] Check Registration No. which is not duplicated
        CheckingIdentificationNo(Database::Customer, false);
    end;

    [Test]
    procedure CheckingRegistrationNoOnVendor()
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO] Check Registration No. which is not duplicated
        CheckingIdentificationNo(Database::Vendor, false);
    end;

    [Test]
    procedure CheckingTaxRegistrationNoOnContact()
    begin
        // [FEATURE] [UT] [Contact]
        // [SCENARIO] Check Tax Registration No. which is not duplicated
        CheckingIdentificationNo(Database::Contact, true);
    end;

    [Test]
    procedure CheckingTaxRegistrationNoOnCustomer()
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO] Check Tax Registration No. which is not duplicated
        CheckingIdentificationNo(Database::Customer, true);
    end;

    [Test]
    procedure CheckingTaxRegistrationNoOnVendor()
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO] Check Tax Registration No. which is not duplicated
        CheckingIdentificationNo(Database::Vendor, true);
    end;

    local procedure CheckingIdentificationNo(TableID: Integer; IsTax: Boolean)
    var
        Contact: Record Contact;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Number: Code[20];
        RegNo: Text[20];
        TaxRegNo: Text[20];
        CheckResult: Boolean;
    begin
        Initialize();

        // [GIVEN] Generate unique Registration No. and Tax Registration No.
        RegNo := GenerateRegistrationNo();
        TaxRegNo := GenerateTaxRegistrationNo();

        // [GIVEN] Create Contact, Customer or Vendor with generated identification no.
        case TableID of
            Database::Contact:
                begin
                    CreateContact(Contact, RegNo, TaxRegNo);
                    Number := Contact."No.";
                end;
            Database::Customer:
                begin
                    CreateCustomer(Customer, RegNo, TaxRegNo);
                    Number := Customer."No.";
                end;
            Database::Vendor:
                begin
                    CreateVendor(Vendor, RegNo, TaxRegNo);
                    Number := Vendor."No.";
                end;
        end;

        // [WHEN] Registration No. or Tax Registration No. are not duplicated
        if IsTax then
            CheckResult := CheckTaxRegistrationNo(TaxRegNo, Number, TableID)
        else
            CheckResult := CheckRegistrationNo(RegNo, Number, TableID);

        // [THEN] Result of check must be TRUE without the popup message dialog
        Assert.IsTrue(CheckResult, CheckMustBeTrueTxt);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckingDuplicityRegistrationNoOnContact()
    begin
        // [FEATURE] [UT] [Contact]
        // [SCENARIO] Check Registration No. which is duplicated
        CheckingDuplicityIdentificationNo(Database::Contact, false);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckingDuplicityRegistrationNoOnCustomer()
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO] Check Registration No. which is duplicated
        CheckingDuplicityIdentificationNo(Database::Customer, false);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckingDuplicityRegistrationNoOnVendor()
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO] Check Registration No. which is duplicated
        CheckingDuplicityIdentificationNo(Database::Vendor, false);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckingDuplicityTaxRegistrationNoOnContact()
    begin
        // [FEATURE] [UT] [Contact]
        // [SCENARIO] Check Tax Registration No. which is duplicated
        CheckingDuplicityIdentificationNo(Database::Contact, true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckingDuplicityTaxRegistrationNoOnCustomer()
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO] Check Tax Registration No. which is duplicated
        CheckingDuplicityIdentificationNo(Database::Customer, true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckingDuplicityTaxRegistrationNoOnVendor()
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO] Check Tax Registration No. which is duplicated
        CheckingDuplicityIdentificationNo(Database::Vendor, true);
    end;

    local procedure CheckingDuplicityIdentificationNo(TableID: Integer; IsTax: Boolean)
    var
        Contact1: Record Contact;
        Contact2: Record Contact;
        Customer1: Record Customer;
        Customer2: Record Customer;
        Vendor1: Record Vendor;
        Vendor2: Record Vendor;
        ExpectedMessage: Text;
        Number: Code[20];
        RegNo: Text[20];
        TaxRegNo: Text[20];
        CheckResult: Boolean;
    begin
        Initialize();

        // [GIVEN] Generate unique Registration No. and Tax Registration No.
        RegNo := GenerateRegistrationNo();
        TaxRegNo := GenerateTaxRegistrationNo();

        // [GIVEN] Create Contact, Customer or Vendor with generated identification no.
        case TableID of
            Database::Contact:
                begin
                    CreateContact(Contact1, RegNo, TaxRegNo);
                    CreateContact(Contact2, RegNo, TaxRegNo); // Contact with duplicity identification no.
                    Number := Contact2."No.";
                    ExpectedMessage :=
                      StrSubstNo(RegNoEnteredContMsg, GetFieldCaption(TableID, IsTax), Contact1."No.")
                end;
            Database::Customer:
                begin
                    CreateCustomer(Customer1, RegNo, TaxRegNo);
                    CreateCustomer(Customer2, RegNo, TaxRegNo); // Customer with duplicity identification no.
                    Number := Customer2."No.";
                    ExpectedMessage :=
                      StrSubstNo(RegNoEnteredCustMsg, GetFieldCaption(TableID, IsTax), Customer1."No.")
                end;
            Database::Vendor:
                begin
                    CreateVendor(Vendor1, RegNo, TaxRegNo);
                    CreateVendor(Vendor2, RegNo, TaxRegNo); // Vendor with duplicity identification no.
                    Number := Vendor2."No.";
                    ExpectedMessage :=
                      StrSubstNo(RegNoEnteredVendMsg, GetFieldCaption(TableID, IsTax), Vendor1."No.")
                end;
        end;

        // [WHEN] Registration No. or Tax Registration No. are duplicated
        LibraryVariableStorage.Enqueue(ExpectedMessage);
        if IsTax then
            CheckResult := CheckTaxRegistrationNo(TaxRegNo, Number, TableID)
        else
            CheckResult := CheckRegistrationNo(RegNo, Number, TableID);

        // [THEN] Result of check must be TRUE with the popup message dialog
        // check of the message dialog is in MessageHandler
        Assert.IsTrue(CheckResult, CheckMustBeTrueTxt);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Identification Numbers CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Identification Numbers CZL");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Identification Numbers CZL");
    end;

    local procedure CheckRegistrationNo(RegNo: Text[20]; Number: Code[20]; TableID: Integer): Boolean
    var
        RegistrationNoMgtCZL: Codeunit "Registration No. Mgt. CZL";
    begin
        exit(RegistrationNoMgtCZL.CheckRegistrationNo(RegNo, Number, TableID));
    end;

    local procedure CheckTaxRegistrationNo(RegNo: Text[20]; Number: Code[20]; TableID: Integer): Boolean
    var
        RegistrationNoMgtCZL: Codeunit "Registration No. Mgt. CZL";
    begin
        exit(RegistrationNoMgtCZL.CheckTaxRegistrationNo(RegNo, Number, TableID));
    end;

    local procedure CreateContact(var Contact: Record Contact; RegNo: Text[20]; TaxRegNo: Text[20])
    begin
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact."Registration Number" := RegNo;
        Contact."Tax Registration No. CZL" := TaxRegNo;
        Contact.Modify();
    end;

    local procedure CreateCustomer(var Customer: Record Customer; RegNo: Text[20]; TaxRegNo: Text[20])
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer."Registration Number" := RegNo;
        Customer."Tax Registration No. CZL" := TaxRegNo;
        Customer.Modify();
    end;

    local procedure CreateVendor(var Vendor: Record Vendor; RegNo: Text[20]; TaxRegNo: Text[20])
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."Registration Number" := RegNo;
        Vendor."Tax Registration No. CZL" := TaxRegNo;
        Vendor.Modify();
    end;

    local procedure GetFieldCaption(TableID: Integer; IsTax: Boolean): Text
    var
        Contact: Record Contact;
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        case TableID of
            Database::Contact:
                begin
                    if IsTax then
                        exit(Contact.FieldCaption("Tax Registration No. CZL"));
                    exit(Contact.FieldCaption("Registration Number"));
                end;
            Database::Customer:
                begin
                    if IsTax then
                        exit(Customer.FieldCaption("Tax Registration No. CZL"));
                    exit(Customer.FieldCaption("Registration Number"));
                end;
            Database::Vendor:
                begin
                    if IsTax then
                        exit(Vendor.FieldCaption("Tax Registration No. CZL"));
                    exit(Vendor.FieldCaption("Registration Number"));
                end;
        end;
    end;

    local procedure GenerateRegistrationNo(): Text[20]
    begin
        exit(CopyStr(LibraryRandom.RandText(20), 1, 20));
    end;

    local procedure GenerateTaxRegistrationNo(): Text[20]
    begin
        exit(CopyStr(LibraryRandom.RandText(20), 1, 20));
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    var
        ExpectedMessage: Text;
    begin
        ExpectedMessage := LibraryVariableStorage.DequeueText();
        Assert.AreEqual(ExpectedMessage, Message, '');
    end;
}
