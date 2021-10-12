codeunit 148051 "Update from ARES CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [Registration No.] [ARES]
        isInitialized := false;
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryRandom: Codeunit "Library - Random";
        isInitialized: Boolean;

    local procedure Initialize();
    var
        RegistrationLogCZL: Record "Registration Log CZL";
        RegistrationLogDetailCZL: Record "Registration Log Detail CZL";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Update from ARES CZL");

        RegistrationLogCZL.Reset();
        RegistrationLogCZL.DeleteAll();
        RegistrationLogDetailCZL.Reset();
        RegistrationLogDetailCZL.DeleteAll();
        LibraryRandom.Init();

        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Update from ARES CZL");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Update from ARES CZL");
    end;

    [Test]
    [HandlerFunctions('RegistrationLogDetailsModalPageHandler,MessageHandler')]
    procedure UpdateCustomerFromRegistrationLog()
    var
        Customer: Record Customer;
        RegistrationLogCZL: Record "Registration Log CZL";
    begin
        // [SCENARIO] Update Customer from Registration Log Entry
        Initialize();

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] Registration Log Entry has been created
        RegistrationLogCZL := CreateRegistrationLog(Enum::"Reg. Log Account Type CZL"::Customer, Customer."No.");
        Commit();

        // [GIVEN] Registration Log Details have been created
        RegistrationLogCZL.LogDetails();

        // [WHEN] Run Registration Log Details page and accept all fields
        RegistrationLogCZL.OpenModifyDetails();

        // [THEN] Customer will be updated
        Customer.Get(Customer."No.");
        Customer.Testfield(Name, CopyStr(RegistrationLogCZL."Verified Name", 1, MaxStrLen(Customer.Name)));
        Customer.Testfield(Address, CopyStr(RegistrationLogCZL."Verified Address", 1, MaxStrLen(Customer.Address)));
        Customer.Testfield(City, CopyStr(RegistrationLogCZL."Verified City", 1, MaxStrLen(Customer.City)));
        Customer.Testfield("Post Code", CopyStr(RegistrationLogCZL."Verified Post Code", 1, MaxStrLen(Customer."Post Code")));
        Customer.Testfield("VAT Registration No.", CopyStr(RegistrationLogCZL."Verified VAT Registration No.", 1, MaxStrLen(Customer."VAT Registration No.")));
    end;

    [Test]
    [HandlerFunctions('RegistrationLogDetailsModalPageHandler,MessageHandler')]
    procedure UpdateVendorFromRegistrationLog()
    var
        Vendor: Record Vendor;
        RegistrationLogCZL: Record "Registration Log CZL";
    begin
        // [SCENARIO] Update Vendor from Registration Log Entry
        Initialize();

        // [GIVEN] New Vendor created
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Registration Log Entry has been created
        RegistrationLogCZL := CreateRegistrationLog(Enum::"Reg. Log Account Type CZL"::Vendor, Vendor."No.");
        Commit();

        // [GIVEN] Registration Log Details have been created
        RegistrationLogCZL.LogDetails();

        // [WHEN] Run Registration Log Details page and accept all fields
        RegistrationLogCZL.OpenModifyDetails();

        // [THEN] Vendor will be updated
        Vendor.Get(Vendor."No.");
        Vendor.Testfield(Name, CopyStr(RegistrationLogCZL."Verified Name", 1, MaxStrLen(Vendor.Name)));
        Vendor.Testfield(Address, CopyStr(RegistrationLogCZL."Verified Address", 1, MaxStrLen(Vendor.Address)));
        Vendor.Testfield(City, CopyStr(RegistrationLogCZL."Verified City", 1, MaxStrLen(Vendor.City)));
        Vendor.Testfield("Post Code", CopyStr(RegistrationLogCZL."Verified Post Code", 1, MaxStrLen(Vendor."Post Code")));
        Vendor.Testfield("VAT Registration No.", CopyStr(RegistrationLogCZL."Verified VAT Registration No.", 1, MaxStrLen(Vendor."VAT Registration No.")));
    end;

    [Test]
    [HandlerFunctions('RegistrationLogDetailsModalPageHandler,MessageHandler')]
    procedure UpdateContactFromRegistrationLog()
    var
        Contact: Record Contact;
        RegistrationLogCZL: Record "Registration Log CZL";
    begin
        // [SCENARIO] Update Contact from Registration Log Entry
        Initialize();

        // [GIVEN] New contact created
        LibraryMarketing.CreateCompanyContact(Contact);

        // [GIVEN] Registration Log Entry has been created
        RegistrationLogCZL := CreateRegistrationLog(Enum::"Reg. Log Account Type CZL"::Contact, Contact."No.");
        Commit();

        // [GIVEN] Registration Log Details have been created
        RegistrationLogCZL.LogDetails();

        // [WHEN] Run Registration Log Details page and accept all fields
        RegistrationLogCZL.OpenModifyDetails();

        // [THEN] Contact will be updated
        Contact.Get(Contact."No.");
        Contact.Testfield(Name, CopyStr(RegistrationLogCZL."Verified Name", 1, MaxStrLen(Contact.Name)));
        Contact.Testfield(Address, CopyStr(RegistrationLogCZL."Verified Address", 1, MaxStrLen(Contact.Address)));
        Contact.Testfield(City, CopyStr(RegistrationLogCZL."Verified City", 1, MaxStrLen(Contact.City)));
        Contact.Testfield("Post Code", CopyStr(RegistrationLogCZL."Verified Post Code", 1, MaxStrLen(Contact."Post Code")));
        Contact.Testfield("VAT Registration No.", CopyStr(RegistrationLogCZL."Verified VAT Registration No.", 1, MaxStrLen(Contact."VAT Registration No.")));
    end;

    local procedure CreateRegistrationLog(AccountType: Enum "Reg. Log Account Type CZL"; AccountNo: Code[20]) RegistrationLogCZL: Record "Registration Log CZL"
    begin
        RegistrationLogCZL.Init();
        RegistrationLogCZL."Entry No." := LibraryRandom.RandInt(1000);
        RegistrationLogCZL."Registration No." := '12345678';
        RegistrationLogCZL."Account Type" := AccountType;
        RegistrationLogCZL."Account No." := AccountNo;
        RegistrationLogCZL.Status := RegistrationLogCZL.Status::Valid;
        RegistrationLogCZL."Verified Name" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified Name"));
        RegistrationLogCZL."Verified Address" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified Address"));
        RegistrationLogCZL."Verified City" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified City"));
        RegistrationLogCZL."Verified Post Code" := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(RegistrationLogCZL."Verified Post Code"));
        RegistrationLogCZL."Verified VAT Registration No." := 'CZ12345678';
        RegistrationLogCZL.Insert();
    end;

    [ModalPageHandler]
    procedure RegistrationLogDetailsModalPageHandler(var RegistrationLogDetailsCZL: TestPage "Registration Log Details CZL")
    begin
        RegistrationLogDetailsCZL.AcceptAll.Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;
}
