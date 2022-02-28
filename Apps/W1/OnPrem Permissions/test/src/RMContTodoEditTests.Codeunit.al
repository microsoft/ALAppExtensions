codeunit 139870 "RM Cont/Todo, Edit Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    var
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;

    [Test]
    [Scope('OnPrem')]
    procedure NewContactPersonTypeWithCompanyNoInRMCONTPermissions()
    var
        Contact: Record Contact;
        CompanyContact: Record Contact;
    begin
        // [SCENARIO 379620] User with "RM-CONT, Edit" permissions can set "Company No." field
        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddRMContEdit();

        CompanyContact.Init();
        CompanyContact.Insert(true);
        CompanyContact.Validate(Type, Contact.Type::Company);
        CompanyContact.Modify(true);

        Contact.Init();
        Contact.Insert(true);
        Contact.Validate(Type, Contact.Type::Person);
        Contact.Validate("Company No.", CompanyContact."No.");
        Contact.Modify(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DeleteContactTypePerson()
    var
        Contact: Record Contact;
    begin
        // [SCENARIO 197375] Stan can delete Contact with Type = Person under "D365 Customer, EDIT" permission set
        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddRMContEdit();

        MockContact(Contact, Contact.Type::Person);

        LibraryLowerPermissions.SetCustomerEdit();

        Contact.Delete(true);
        VerifyContactRelatedRecordsDeleted(Contact."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DeleteContactTypeCompany()
    var
        Contact: Record Contact;
    begin
        // [SCENARIO 197375] Stan can delete Contact with Type = Company under "D365 Customer, EDIT" permission set
        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddRMContEdit();

        MockContact(Contact, Contact.Type::Company);

        LibraryLowerPermissions.SetCustomerEdit();

        Contact.Delete(true);
        VerifyContactRelatedRecordsDeleted(Contact."No.");
    end;

     [Test]
    [HandlerFunctions('CompanyDetailsOnChangeModalPageHandler')]
    [Scope('OnPrem')]
    procedure NameAssistEditOnCompanyContactCardWithModifyPermissions()
    var
        Contact: Record Contact;
        ContactCard: TestPage "Contact Card";
        CompanyName: Text;
    begin
        // [FEATURE] [Permission] [Permission Set] [UI]
        // [SCENARIO 349009] Stan can update company contact's name on company details page when Stan has modify permissions
        Initialize();

        CompanyName := LibraryUtility.GenerateGUID();
        LibraryVariableStorage.Enqueue(CompanyName);

        LibraryMarketing.CreateCompanyContact(Contact);

        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddRMContEdit();
        LibraryLowerPermissions.AddRMTodoEdit();

        ContactCard.OpenEdit();
        ContactCard.FILTER.SetFilter("No.", Contact."No.");
        ContactCard.Name.AssistEdit();
        ContactCard."Company Name".AssertEquals(CompanyName);
        ContactCard.Close();

        Contact.Find();
        Contact.TestField("Company Name", CompanyName);

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
        Initialize();

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

    [Test]
    [HandlerFunctions('CompanyDetailsModalPageHandler')]
    [Scope('OnPrem')]
    procedure CompanyNameAssistEditOnPersonContactCardWithPermissions()
    var
        ContactPerson: Record Contact;
        ContactCompany: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        // [FEATURE] [Permission] [Permission Set] [UI]
        // [SCENARIO 349009] Stan can view person contact's company name on company details page when Stan hasn't modify permissions
        Initialize();

        LibraryMarketing.CreatePersonContact(ContactPerson);
        LibraryMarketing.CreateCompanyContact(ContactCompany);
        ContactPerson.Validate("Company No.", ContactCompany."No.");
        ContactPerson.Modify(true);

        LibraryLowerPermissions.SetO365Basic();
        LibraryLowerPermissions.AddRMContEdit();
        LibraryLowerPermissions.AddRMTodoEdit();

        ContactCard.OpenEdit();
        ContactCard.FILTER.SetFilter("No.", ContactPerson."No.");
        ContactCard."Company Name".AssertEquals(ContactPerson."Company Name");
        ContactCard."Company Name".AssistEdit();
        ContactCard."Company Name".AssertEquals(ContactPerson."Company Name");
        ContactCard.Close();

        ContactPerson.Find();
        ContactPerson.TestField("Company Name", ContactCompany."Company Name");
        ContactPerson.TestField("Company Name", LibraryVariableStorage.DequeueText());

        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifyContactRelatedRecordsDeleted(ContactNo: Code[20])
    var
        ContactMailingGroup: Record "Contact Mailing Group";
        RlshpMgtCommentLine: Record "Rlshp. Mgt. Comment Line";
        ContactAltAddress: Record "Contact Alt. Address";
        ContactAltAddrDateRange: Record "Contact Alt. Addr. Date Range";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactMailingGroup.SetRange("Contact No.", ContactNo);
        Assert.RecordIsEmpty(ContactMailingGroup);

        RlshpMgtCommentLine.SetRange("No.", ContactNo);
        Assert.RecordIsEmpty(RlshpMgtCommentLine);

        ContactAltAddress.SetRange("Contact No.", ContactNo);
        Assert.RecordIsEmpty(ContactAltAddress);

        ContactAltAddrDateRange.SetRange("Contact No.", ContactNo);
        Assert.RecordIsEmpty(ContactAltAddrDateRange);

        ContactBusinessRelation.SetRange("Contact No.", ContactNo);
        Assert.RecordIsEmpty(ContactBusinessRelation);
    end;

    local procedure MockContact(var Contact: Record Contact; ContactType: Enum "Contact Type")
    var
        ContactMailingGroup: Record "Contact Mailing Group";
        RlshpMgtCommentLine: Record "Rlshp. Mgt. Comment Line";
        ContactAltAddress: Record "Contact Alt. Address";
        ContactAltAddrDateRange: Record "Contact Alt. Addr. Date Range";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        Contact.Init();
        Contact.Insert(true);
        Contact.Validate(Type, ContactType);
        Contact.Validate(
          Name, CopyStr(LibraryUtility.GenerateRandomText(20), 1, MaxStrLen(Contact.Name)));
        Contact.Modify(true);

        ContactMailingGroup.Init();
        ContactMailingGroup."Contact No." := Contact."No.";
        ContactMailingGroup.Insert(true);

        RlshpMgtCommentLine.Init();
        RlshpMgtCommentLine."Table Name" := RlshpMgtCommentLine."Table Name"::Contact;
        RlshpMgtCommentLine."No." := Contact."No.";
        RlshpMgtCommentLine.Insert(true);

        ContactAltAddress.Init();
        ContactAltAddress."Contact No." := Contact."No.";
        ContactAltAddress.Insert(true);

        ContactAltAddrDateRange.Init();
        ContactAltAddrDateRange."Contact No." := Contact."No.";
        ContactAltAddrDateRange.Insert(true);

        ContactBusinessRelation.Init();
        ContactBusinessRelation."Contact No." := Contact."No.";
        ContactBusinessRelation.Insert(true);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CompanyDetailsOnChangeModalPageHandler(var CompanyDetails: TestPage "Company Details")
    begin
        CompanyDetails.Name.SetValue(LibraryVariableStorage.DequeueText());
        CompanyDetails.OK().Invoke();
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CompanyDetailsModalPageHandler(var CompanyDetails: TestPage "Company Details")
    begin
        LibraryVariableStorage.Enqueue(CompanyDetails.Name.Value);
        CompanyDetails.OK().Invoke();
    end;

}