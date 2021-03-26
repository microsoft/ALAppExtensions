#pragma warning disable AL0432
codeunit 148051 "Registration No. CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        RegistrationLogCZL: Record "Registration Log CZL";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryRandom: Codeunit "Library - Random";
        isInitialized: Boolean;

    local procedure Initialize();
    begin
        RegistrationLogCZL.Reset();
        RegistrationLogCZL.DeleteAll();
        LibraryRandom.Init();

        if isInitialized then
            exit;

        isInitialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('HandleAresReport')]
    procedure UpdateCustomerFromRegistrationLog()
    var
        Customer: Record Customer;
        ARESUpdateCZL: Report "ARES Update CZL";
        RecordRef: RecordRef;
    begin
        // [FEATURE] ARES
        Initialize();

        // [GIVEN] New Customer created
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Registration Log entry exists
        RegistrationLogCZL.Init();
        RegistrationLogCZL."Entry No." := LibraryRandom.RandInt(1000);
        RegistrationLogCZL."Registration No." := '12345678';
        RegistrationLogCZL."Account Type" := RegistrationLogCZL."Account Type"::Customer;
        RegistrationLogCZL."Account No." := Customer."No.";
        RegistrationLogCZL.Status := RegistrationLogCZL.Status::Valid;
        RegistrationLogCZL."Verified Name" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified Name"));
        RegistrationLogCZL."Verified Address" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified Address"));
        RegistrationLogCZL."Verified City" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified City"));
        RegistrationLogCZL."Verified Post Code" := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(RegistrationLogCZL."Verified Post Code"));
        RegistrationLogCZL."Verified VAT Registration No." := 'CZ12345678';
        RegistrationLogCZL.Insert();
        Commit();

        // [WHEN] Run ARES update
        ARESUpdateCZL.InitializeReport(Customer, RegistrationLogCZL);
        ARESUpdateCZL.UseRequestPage(true);
        ARESUpdateCZL.RunModal();
        ARESUpdateCZL.GetRecord(RecordRef);
        RecordRef.SetTable(Customer);

        // [THEN] Customer is updated
        Customer.Testfield(Name, CopyStr(RegistrationLogCZL."Verified Name", 1, MaxStrLen(Customer.Name)));
        Customer.Testfield(Address, CopyStr(RegistrationLogCZL."Verified Address", 1, MaxStrLen(Customer.Address)));
        Customer.Testfield(City, CopyStr(RegistrationLogCZL."Verified City", 1, MaxStrLen(Customer.City)));
        Customer.Testfield("Post Code", CopyStr(RegistrationLogCZL."Verified Post Code", 1, MaxStrLen(Customer."Post Code")));
        Customer.Testfield("VAT Registration No.", CopyStr(RegistrationLogCZL."Verified VAT Registration No.", 1, MaxStrLen(Customer."VAT Registration No.")));
    end;

    [Test]
    [HandlerFunctions('HandleAresReport')]
    procedure UpdateVendorFromRegistrationLog()
    var
        Vendor: Record Vendor;
        ARESUpdateCZL: Report "ARES Update CZL";
        RecordRef: RecordRef;
    begin
        // [FEATURE] ARES
        Initialize();

        // [GIVEN] New Vendor created
        LibraryPurchase.CreateVendor(Vendor);
        // [GIVEN] Registration Log entry exists
        RegistrationLogCZL.Init();
        RegistrationLogCZL."Entry No." := LibraryRandom.RandInt(1000);
        RegistrationLogCZL."Registration No." := '12345678';
        RegistrationLogCZL."Account Type" := RegistrationLogCZL."Account Type"::Vendor;
        RegistrationLogCZL."Account No." := Vendor."No.";
        RegistrationLogCZL.Status := RegistrationLogCZL.Status::Valid;
        RegistrationLogCZL."Verified Name" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified Name"));
        RegistrationLogCZL."Verified Address" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified Address"));
        RegistrationLogCZL."Verified City" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified City"));
        RegistrationLogCZL."Verified Post Code" := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(RegistrationLogCZL."Verified Post Code"));
        RegistrationLogCZL."Verified VAT Registration No." := 'CZ12345678';
        RegistrationLogCZL.Insert();
        Commit();

        // [WHEN] Run ARES update
        ARESUpdateCZL.InitializeReport(Vendor, RegistrationLogCZL);
        ARESUpdateCZL.UseRequestPage(true);
        ARESUpdateCZL.RunModal();
        ARESUpdateCZL.GetRecord(RecordRef);
        RecordRef.SetTable(Vendor);

        // [THEN] Vendor is updated
        Vendor.Testfield(Name, CopyStr(RegistrationLogCZL."Verified Name", 1, MaxStrLen(Vendor.Name)));
        Vendor.Testfield(Address, CopyStr(RegistrationLogCZL."Verified Address", 1, MaxStrLen(Vendor.Address)));
        Vendor.Testfield(City, CopyStr(RegistrationLogCZL."Verified City", 1, MaxStrLen(Vendor.City)));
        Vendor.Testfield("Post Code", CopyStr(RegistrationLogCZL."Verified Post Code", 1, MaxStrLen(Vendor."Post Code")));
        Vendor.Testfield("VAT Registration No.", CopyStr(RegistrationLogCZL."Verified VAT Registration No.", 1, MaxStrLen(Vendor."VAT Registration No.")));
    end;

    [Test]
    [HandlerFunctions('HandleAresReport')]
    procedure UpdateContactFromRegistrationLog()
    var
        Contact: Record Contact;
        ARESUpdateCZL: Report "ARES Update CZL";
        RecordRef: RecordRef;
    begin
        // [FEATURE] ARES
        Initialize();

        // [GIVEN] New contact created
        LibraryMarketing.CreateCompanyContact(Contact);
        // [GIVEN] Registration Log entry exists
        RegistrationLogCZL.Init();
        RegistrationLogCZL."Entry No." := LibraryRandom.RandInt(1000);
        RegistrationLogCZL."Registration No." := '12345678';
        RegistrationLogCZL."Account Type" := RegistrationLogCZL."Account Type"::Contact;
        RegistrationLogCZL."Account No." := Contact."No.";
        RegistrationLogCZL.Status := RegistrationLogCZL.Status::Valid;
        RegistrationLogCZL."Verified Name" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified Name"));
        RegistrationLogCZL."Verified Address" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified Address"));
        RegistrationLogCZL."Verified City" := CopyStr(LibraryRandom.RandText(150), 1, MaxStrLen(RegistrationLogCZL."Verified City"));
        RegistrationLogCZL."Verified Post Code" := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(RegistrationLogCZL."Verified Post Code"));
        RegistrationLogCZL."Verified VAT Registration No." := 'CZ12345678';
        RegistrationLogCZL.Insert();
        Commit();

        // [WHEN] Run ARES update
        ARESUpdateCZL.InitializeReport(Contact, RegistrationLogCZL);
        ARESUpdateCZL.UseRequestPage(true);
        ARESUpdateCZL.RunModal();
        ARESUpdateCZL.GetRecord(RecordRef);
        RecordRef.SetTable(Contact);

        // [THEN] Contact is updated
        Contact.Testfield(Name, CopyStr(RegistrationLogCZL."Verified Name", 1, MaxStrLen(Contact.Name)));
        Contact.Testfield(Address, CopyStr(RegistrationLogCZL."Verified Address", 1, MaxStrLen(Contact.Address)));
        Contact.Testfield(City, CopyStr(RegistrationLogCZL."Verified City", 1, MaxStrLen(Contact.City)));
        Contact.Testfield("Post Code", CopyStr(RegistrationLogCZL."Verified Post Code", 1, MaxStrLen(Contact."Post Code")));
        Contact.Testfield("VAT Registration No.", CopyStr(RegistrationLogCZL."Verified VAT Registration No.", 1, MaxStrLen(Contact."VAT Registration No.")));
    end;

    [RequestPageHandler]
    procedure HandleAresReport(var ARESUpdateCZL: TestRequestPage "ARES Update CZL")
    begin
        ARESUpdateCZL."FieldUpdateMask[FieldType::All]".SetValue(true);
        ARESUpdateCZL.OK().Invoke();
    end;
}
