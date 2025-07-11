codeunit 139871 "RM Cont/Todo Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    var
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryMarketing: Codeunit "Library - Marketing";

    [Test]
    [HandlerFunctions('NameDetailsModalPageHandler')]
    [Scope('OnPrem')]
    procedure NameAssistEditOnPersonContactCardWithoutModifyPermissions()
    var
        Contact: Record Contact;
        ContactBackup: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        // [FEATURE] [Permission] [Permission Set] [UI]
        // [SCENARIO 349009] Stan can't update person contact's name on name details page when Stan hasn't modify permissions
        LibraryVariableStorage.Clear();

        LibraryMarketing.CreatePersonContact(Contact);
        ContactBackup := Contact;

        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddRMCont();
        LibraryLowerPermissions.AddRMTodo();

        ContactCard.OpenEdit();
        ContactCard.FILTER.SetFilter("No.", Contact."No.");
        ContactCard.Name.AssistEdit();
        ContactCard.Name.AssertEquals(Contact.Name);
        ContactCard.Close();

        ContactBackup.TestField("First Name", LibraryVariableStorage.DequeueText());
        ContactBackup.TestField("Middle Name", LibraryVariableStorage.DequeueText());
        ContactBackup.TestField(Surname, LibraryVariableStorage.DequeueText());

        LibraryVariableStorage.AssertEmpty();
    end;

     [Test]
    [HandlerFunctions('CompanyDetailsModalPageHandler')]
    [Scope('OnPrem')]
    procedure NameAssistEditOnCompanyContactCardWithoutModifyPermissions()
    var
        Contact: Record Contact;
        ContactBackup: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        // [FEATURE] [Permission] [Permission Set] [UI]
        // [SCENARIO 349009] Stan can't update company contact's name on company details page when Stan hasn't modify permissions
        LibraryVariableStorage.Clear();

        LibraryMarketing.CreateCompanyContact(Contact);
        ContactBackup := Contact;

        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddRMCont();
        LibraryLowerPermissions.AddRMTodo();

        ContactCard.OpenEdit();
        ContactCard.FILTER.SetFilter("No.", Contact."No.");
        ContactCard.Name.AssistEdit();
        ContactCard."Company Name".AssertEquals(ContactBackup."Company Name");
        ContactCard.Close();

        Contact.Find();
        Contact.TestField("Company Name", ContactBackup."Company Name");
        ContactBackup.TestField("Company Name", LibraryVariableStorage.DequeueText());

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('CompanyDetailsModalPageHandler')]
    [Scope('OnPrem')]
    procedure CompanyNameAssistEditOnPersonContactCardWithoutPermissions()
    var
        ContactPerson: Record Contact;
        ContactCompany: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        // [FEATURE] [Permission] [Permission Set] [UI]
        // [SCENARIO 349009] Stan can view person contact's company name on company details page when Stan hasn't modify permissions
        LibraryVariableStorage.Clear();

        // [GIVEN] New contact with "Company Name" = "Name"
        LibraryMarketing.CreatePersonContact(ContactPerson);
        LibraryMarketing.CreateCompanyContact(ContactCompany);
        ContactPerson.Validate("Company No.", ContactCompany."No.");
        ContactPerson.Modify(true);

        // [GIVEN] User without Contact editing permisions
        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddRMCont();
        LibraryLowerPermissions.AddRMTodo();

        // [GIVEN] Open its Card
        ContactCard.OpenEdit();
        ContactCard.FILTER.SetFilter("No.", ContactPerson."No.");

        // [WHEN] User open Name Details assist edit dialog
        ContactCard."Company Name".AssistEdit();
        ContactCard.Close();

        ContactPerson.TestField("Company Name", ContactCompany.Name);
        ContactPerson.TestField("Company Name", LibraryVariableStorage.DequeueText());

        LibraryVariableStorage.AssertEmpty();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure NameDetailsModalPageHandler(var NameDetails: TestPage "Name Details")
    begin
        LibraryVariableStorage.Enqueue(NameDetails."First Name".Value());
        LibraryVariableStorage.Enqueue(NameDetails."Middle Name".Value());
        LibraryVariableStorage.Enqueue(NameDetails.Surname.Value());
        NameDetails.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CompanyDetailsModalPageHandler(var CompanyDetails: TestPage "Company Details")
    begin
        LibraryVariableStorage.Enqueue(CompanyDetails.Name.Value());
        CompanyDetails.OK().Invoke();
    end;
}