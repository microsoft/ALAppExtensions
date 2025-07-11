codeunit 139853 "APIV2 - Contacts Inf. E2E"
{
    // version Test,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Contact]
    end;

    var
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit Assert;
        CustomersServiceNameTxt: Label 'customers';
        VendorsServiceNameTxt: Label 'vendors';
        ContactServiceNameTxt: Label 'contact';
        ContactsInformationServiceNameTxt: Label 'contactsInformation';

    [Test]
    [Scope('OnPrem')]
    procedure TestGetCustomerContactsInformation()
    var
        CompanyContact: Record Contact;
        PersonContact: Record Contact;
        Customer: Record Customer;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Get all contact information for a customer

        // [GIVEN] A contact with customer and another contact under same company
        LibraryMarketing.CreateContactWithCustomer(CompanyContact, Customer);
        CreatePersonContactWithCompanyNo(PersonContact, CompanyContact."No.");
        Commit();

        // [WHEN] A GET request for contacts information 
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            Customer.SystemId,
            Page::"APIV2 - Customers",
            CustomersServiceNameTxt,
            ContactsInformationServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] Response contains two contacts
        VerifyContactsInformation(ResponseText, CompanyContact.SystemId, PersonContact.SystemId, Customer.SystemId);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetCustomerContactInformation()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO] Get all contact information for a customer

        // [GIVEN] A contact with customer
        LibraryMarketing.CreateContactWithCustomer(Contact, Customer);
        Commit();

        // [WHEN] A GET request for contacts information 
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            Customer.SystemId,
            Page::"APIV2 - Customers",
            CustomersServiceNameTxt,
            ContactsInformationServiceNameTxt) + '(' + LibraryGraphMgt.StripBrackets(Format(Contact.SystemId)) + ')/' + ContactServiceNameTxt;
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] Response contains two contacts
        VerifyContactInformationContact(ResponseText, Contact);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetVendorContactsInformation()
    var
        CompanyContact: Record Contact;
        PersonContact: Record Contact;
        Vendor: Record Vendor;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Get all contact information for a vendor

        // [GIVEN] A contact with vendor and another contact under same company
        LibraryMarketing.CreateContactWithVendor(CompanyContact, Vendor);
        CreatePersonContactWithCompanyNo(PersonContact, CompanyContact."No.");
        Commit();

        // [WHEN] A GET request for contacts information 
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            Vendor.SystemId,
            Page::"APIV2 - Vendors",
            VendorsServiceNameTxt,
            ContactsInformationServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] Response contains two contacts
        VerifyContactsInformation(ResponseText, CompanyContact.SystemId, PersonContact.SystemId, Vendor.SystemId);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetVendorContactInformation()
    var
        Contact: Record Contact;
        Vendor: Record Vendor;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO] Get all contact information for a Vendor

        // [GIVEN] A contact with Vendor
        LibraryMarketing.CreateContactWithVendor(Contact, Vendor);
        Commit();

        // [WHEN] A GET request for contacts information 
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            Vendor.SystemId,
            Page::"APIV2 - Vendors",
            VendorsServiceNameTxt,
            ContactsInformationServiceNameTxt) + '(' + LibraryGraphMgt.StripBrackets(Format(Contact.SystemId)) + ')/' + ContactServiceNameTxt;
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] Response contains two contacts
        VerifyContactInformationContact(ResponseText, Contact);
    end;

    local procedure VerifyContactsInformation(ResponseText: Text; CompanyContactId: Guid; PersonContactId: Guid; RelatedId: Guid)
    var
        CompanyContactIdTxt: Text;
        PersonContactIdTxt: Text;
        RelatedIdTxt: Text;
        CompanyContactJSON: Text;
        PersonContactJSON: Text;
    begin
        CompanyContactIdTxt := LowerCase(LibraryGraphMgt.StripBrackets(Format(CompanyContactId)));
        PersonContactIdTxt := LowerCase(LibraryGraphMgt.StripBrackets(Format(PersonContactId)));
        RelatedIdTxt := LowerCase(LibraryGraphMgt.StripBrackets(Format(RelatedId)));
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'contactId', CompanyContactIdTxt, PersonContactIdTxt, CompanyContactJSON, PersonContactJSON),
          'Could not find the contacts in JSON');
        LibraryGraphMgt.VerifyPropertyInJSON(CompanyContactJSON, 'relatedId', RelatedIdTxt);
        LibraryGraphMgt.VerifyPropertyInJSON(PersonContactJSON, 'relatedId', RelatedIdTxt);
    end;

    local procedure VerifyContactInformationContact(ResponseText: Text; Contact: Record Contact)
    begin
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseText, 'id', Lowercase(LibraryGraphMgt.StripBrackets(Format(Contact.SystemId))));
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseText, 'number', Format(Contact."No."));
    end;

    local procedure CreatePersonContactWithCompanyNo(var Contact: Record Contact; CompanyNo: Code[20])
    begin
        LibraryMarketing.CreatePersonContact(Contact);
        Contact.Validate("Company No.", CompanyNo);
        Contact.Modify(true);
    end;
}