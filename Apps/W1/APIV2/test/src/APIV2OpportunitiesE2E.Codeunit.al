codeunit 139855 "APIV2 - Opportunities E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Opportunity]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        ServiceNameTxt: Label 'opportunities';
        OpportunityNoPrefixTxt: Label 'GRAPHOP';
        SalespersonCodeCannotBeChangedErr: Label 'The "salespersonCode" of a Won or Lost Opportunity cannot be changed', Comment = 'salespersonCode is a field name and should not be translated';
        ContactNoCannotBeChangedWonLostErr: Label 'The "contactNumber of a Won or Lost Opportunity cannot be changed', Comment = 'contactNumber is a field name and should not be translated';

    [Test]
    procedure TestGetOpportunities()
    var
        Opportunity: Record Opportunity;
        ContactNo: Code[20];
        TargetURL: Text;
        ResponseText: Text;
        OpportunityId: Text;
    begin
        // [SCENARIO] Create an opportunity and use a GET method to retrieve them
        // [GIVEN] An opportunity
        ContactNo := LibraryMarketing.CreateCompanyContactNo();
        LibraryMarketing.CreateOpportunity(Opportunity, ContactNo);
        Commit();
        OpportunityId := Format(Opportunity.SystemId);

        // [WHEN] we GET all the entries from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(Opportunity.SystemId, Page::"APIV2 - Opportunities", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] entry should exist in the response
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', OpportunityId),
          'Could not find oppportunity');
    end;

    [Test]
    procedure TestCreateOpportunity()
    var
        OpportunityDescription: Text[100];
        OpportunityJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO 184721] Create an opportunity through a POST method and check if it was created
        // [GIVEN] a JSON text with an Opportunity only with a Description property
        OpportunityJSON := CreateMinimalOpportunityJSON(OpportunityDescription);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Opportunities", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OpportunityJSON, ResponseText);

        // [THEN] the response text should contain the opportunity information
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyOpportunityDescriptionInJSON(ResponseText, OpportunityDescription);
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
    end;

    [Test]
    procedure TestCreateOpportunityContactNo()
    var
        Opportunity: Record Opportunity;
        Contact: Record Contact;
        ContactNo: Code[20];
        OpportunityNo: Code[20];
        OpportunityJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO 184721] Create an opportunity through a POST method and check if it was created
        // [GIVEN] a JSON text with an Opportunity only with a contact no
        ContactNo := LibraryMarketing.CreateCompanyContactNo();
        Commit();
        OpportunityNo := NextOpportunityNo();
        OpportunityJSON := CreateOpportunityJSON(OpportunityNo, ContactNo);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Opportunities", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, OpportunityJSON, ResponseText);

        // [THEN] the response text should contain the opportunity information
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        // [THEN] the created opportunity has correct Contact Name and Contact Company Name
        Opportunity.Reset();
        Opportunity.SetRange("No.", OpportunityNo);
        Assert.IsTrue(Opportunity.Get(OpportunityNo), 'The opportunity does not exist.');
        Opportunity.CalcFields("Contact Name");
        Opportunity.CalcFields("Contact Company Name");
        Contact.Reset();
        Contact.Get(ContactNo);
        Assert.AreEqual(Opportunity."Contact Name", Contact.Name, 'The contact name is wrong');
        Assert.AreEqual(Opportunity."Contact Company Name", Contact."Company Name", 'The contact company name is wrong');
        Assert.AreEqual(Opportunity."Contact Company No.", Contact."Company No.", 'The contact company number is wrong');

        // [THEN] The opportunity is Not Started
        Assert.AreEqual(Opportunity.Status, Opportunity.Status::"Not Started", 'The opportunity should be Not Started.');
    end;

    [Test]
    procedure TestCreateOpportunityWrongContactNo()
    var
        ContactNo: Code[20];
        OpportunityNo: Code[20];
        OpportunityJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO 184721] Create an opportunity through a POST method
        // [GIVEN] a JSON text with an Opportunity only with a contact number that does not exist
        ContactNo := 'wrongContNo';
        OpportunityNo := NextOpportunityNo();
        OpportunityJSON := CreateOpportunityJSON(OpportunityNo, ContactNo);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Opportunities", ServiceNameTxt);
        // [THEN] the POST is not successfull
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, OpportunityJSON, ResponseText);
    end;

    [Test]
    procedure TestCreateOpportunityWrongSPNo()
    var
        SalespersonNo: Code[20];
        OpportunityNo: Code[20];
        OpportunityJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO 184721] Create an opportunity through a POST method
        // [GIVEN] a JSON text with an Opportunity only with a salesperson number that does not exist
        SalespersonNo := 'wrongSPNo';
        OpportunityNo := NextOpportunityNo();
        OpportunityJSON := CreateOpportunitySalespersonNoJSON(OpportunityNo, SalespersonNo);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Opportunities", ServiceNameTxt);
        // [THEN] the POST is not successfull
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, OpportunityJSON, ResponseText);
    end;

    [Test]
    procedure TestPatchOpportunity()
    var
        Opportunity: Record Opportunity;
        ContactNo: Code[20];
        OpportunityDescription: Text[100];
        OpportunityJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
        OpportunityId: Guid;
    begin
        // [SCENARIO] Use a PATCH method to change the description of an opportunity
        // [GIVEN] An opportunity
        ContactNo := LibraryMarketing.CreateCompanyContactNo();
        LibraryMarketing.CreateOpportunity(Opportunity, ContactNo);
        Commit();
        OpportunityId := Opportunity.SystemId;

        // [WHEN] we PATCH the description of the opportunity
        OpportunityJSON := CreateMinimalOpportunityJSON(OpportunityDescription);
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(OpportunityId, Page::"APIV2 - Opportunities", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, OpportunityJSON, ResponseText);

        // [THEN] The description of the opportunity should have changed
        Opportunity.Reset();
        Opportunity.GetBySystemId(OpportunityId);
        Assert.AreEqual(OpportunityDescription, Opportunity.Description, 'The description should have changed');
    end;

    [Test]
    procedure TestCannotPatchContactNoOfWonOpportunity()
    var
        Opportunity: Record Opportunity;
        CompanyContactNo: Code[20];
        ContactNo: Code[20];
        OpportunityJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
        OpportunityId: Guid;
    begin
        // [SCENARIO] Use a PATCH method to change the contact no of a Won opportunity
        // [GIVEN] An won opportunity
        CompanyContactNo := LibraryMarketing.CreateCompanyContactNo();
        ContactNo := CreatePersonContactWithCompanyNo(CompanyContactNo);
        CreateWonOpportunity(Opportunity, ContactNo);
        Commit();

        OpportunityId := Opportunity.SystemId;

        // [WHEN] we PATCH the contact no of the opportunity
        OpportunityJSON := CreateContactNoJSON(ContactNo);
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(OpportunityId, Page::"APIV2 - Opportunities", ServiceNameTxt);
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, OpportunityJSON, ResponseText);
        Assert.ExpectedError(ContactNoCannotBeChangedWonLostErr);
    end;

    [Test]
    procedure TestCannotPatchSPCodeOfWonOpportunity()
    var
        Opportunity: Record Opportunity;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesPersonCode: Code[20];
        ContactNo: Code[20];
        OpportunityJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
        OpportunityId: Guid;
    begin
        // [SCENARIO] Use a PATCH method to change the salesperson code of a Won opportunity
        // [GIVEN] An won opportunity
        SalesPersonCode := CreateSalesperson(SalespersonPurchaser);
        ContactNo := LibraryMarketing.CreateCompanyContactNo();
        CreateWonOpportunity(Opportunity, ContactNo);
        Commit();

        OpportunityId := Opportunity.SystemId;

        // [WHEN] we PATCH the salesperson code of the opportunity
        OpportunityJSON := CreateSalespersonCodeJSON(SalesPersonCode);
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(OpportunityId, Page::"APIV2 - Opportunities", ServiceNameTxt);
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, OpportunityJSON, ResponseText);
        Assert.ExpectedError(SalespersonCodeCannotBeChangedErr);
    end;

    [Test]
    procedure TestCannotPatchContactNoOfStartedOpportunityToADifferentCompany()
    var
        Opportunity: Record Opportunity;
        CompanyContactNo1: Code[20];
        CompanyContactNo2: Code[20];
        OpportunityJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
        OpportunityId: Guid;
    begin
        // [SCENARIO] Use a PATCH method to change the contact no of an opportunity in progress to a contact of a different company
        // [GIVEN] An won opportunity
        CompanyContactNo1 := LibraryMarketing.CreateCompanyContactNo();
        CompanyContactNo2 := LibraryMarketing.CreateCompanyContactNo();
        CreateInProgressOpportunity(Opportunity, CompanyContactNo1);
        Commit();

        OpportunityId := Opportunity.SystemId;

        // [WHEN] we PATCH the contact no of the opportunity
        OpportunityJSON := CreateContactNoJSON(CompanyContactNo2);
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(OpportunityId, Page::"APIV2 - Opportunities", ServiceNameTxt);
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, OpportunityJSON, ResponseText);
    end;

    local procedure CreateOpportunityJSON(OpportunityNo: Code[20]; ContactNo: Code[20]): Text
    var
        OpportunityJson: Text;
    begin
        OpportunityJson := LibraryGraphMgt.AddPropertytoJSON(OpportunityJson, 'number', OpportunityNo);
        OpportunityJson := LibraryGraphMgt.AddPropertytoJSON(OpportunityJson, 'contactNumber', ContactNo);

        exit(OpportunityJson);
    end;

    local procedure CreateContactNoJSON(ContactNo: Code[20]): Text
    var
        OpportunityJson: Text;
    begin
        OpportunityJson := LibraryGraphMgt.AddPropertytoJSON(OpportunityJson, 'contactNumber', ContactNo);

        exit(OpportunityJson);
    end;

    local procedure CreateSalespersonCodeJSON(SalespersonCode: Code[20]): Text
    var
        OpportunityJson: Text;
    begin
        OpportunityJson := LibraryGraphMgt.AddPropertytoJSON(OpportunityJson, 'salespersonCode', SalespersonCode);

        exit(OpportunityJson);
    end;

    local procedure CreateOpportunitySalespersonNoJSON(OpportunityNo: Code[20]; SalespersonCode: Code[20]): Text
    var
        OpportunityJson: Text;
    begin
        OpportunityJson := LibraryGraphMgt.AddPropertytoJSON(OpportunityJson, 'number', OpportunityNo);
        OpportunityJson := LibraryGraphMgt.AddPropertytoJSON(OpportunityJson, 'salespersonCode', SalespersonCode);

        exit(OpportunityJson);
    end;

    local procedure CreateMinimalOpportunityJSON(var OpportunityDescription: Text[100]): Text
    var
        OpportunityJson: Text;
    begin
        OpportunityDescription := CopyStr(LibraryRandom.RandText(5), 1, 100);
        OpportunityJson := LibraryGraphMgt.AddPropertytoJSON('', 'description', OpportunityDescription);

        exit(OpportunityJson);
    end;

    local procedure NextOpportunityNo(): Code[20]
    var
        Opportunity: Record Opportunity;
    begin
        Opportunity.SetFilter("No.", StrSubstNo('%1*', OpportunityNoPrefixTxt));
        if Opportunity.FindLast() then
            exit(IncStr(Opportunity."No."));

        exit(CopyStr(OpportunityNoPrefixTxt + '0001', 1, 20));
    end;

    local procedure CreateWonOpportunity(var Opportunity: Record Opportunity; ContactNo: Code[20])
    var
        Contact: Record Contact;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesCycle: Record "Sales Cycle";
    begin
        with Opportunity do begin
            Init();
            "No." := LibraryUtility.GenerateGUID();
            Validate("Contact No.", ContactNo);
            Contact.Get(ContactNo);
            if Contact."Salesperson Code" <> '' then
                SalespersonPurchaser.Code := Contact."Salesperson Code"
            else
                SalespersonPurchaser.FindFirst();
            Validate("Salesperson Code", SalespersonPurchaser.Code);
            Validate(Description, "No." + "Contact No.");  // Validating No. as Description because value is not important.
            SalesCycle.FindFirst();
            Validate("Sales Cycle Code", SalesCycle.Code);
            Validate(Status, Status::Won);
            Insert(true);
        end;
    end;

    local procedure CreateInProgressOpportunity(var Opportunity: Record Opportunity; ContactNo: Code[20])
    var
        Contact: Record Contact;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesCycle: Record "Sales Cycle";
    begin
        with Opportunity do begin
            Init();
            "No." := LibraryUtility.GenerateGUID();
            Validate("Contact No.", ContactNo);
            Contact.Get(ContactNo);
            if Contact."Salesperson Code" <> '' then
                SalespersonPurchaser.Code := Contact."Salesperson Code"
            else
                SalespersonPurchaser.FindFirst();
            Validate("Salesperson Code", SalespersonPurchaser.Code);
            Validate(Description, "No." + "Contact No.");  // Validating No. as Description because value is not important.
            SalesCycle.FindFirst();
            Validate("Sales Cycle Code", SalesCycle.Code);
            Validate(Status, Status::"In Progress");
            Insert(true);
        end;
    end;

    local procedure CreatePersonContactWithCompanyNo(CompanyNo: Code[20]): Code[20]
    var
        Contact: Record Contact;
    begin
        LibraryMarketing.CreatePersonContact(Contact);
        Commit();
        Contact.Validate("Company No.", CompanyNo);
        Contact.Modify(true);
        exit(Contact."No.");
    end;

    local procedure CreateSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser"): Code[20]
    begin
        SalespersonPurchaser.Init();
        SalespersonPurchaser.Validate(
          Code, LibraryUtility.GenerateRandomCode(SalespersonPurchaser.FieldNo(Code), DATABASE::"Salesperson/Purchaser"));
        SalespersonPurchaser.Validate(Name, SalespersonPurchaser.Code);  // Validating Name as Code because value is not important.
        SalespersonPurchaser.Insert(true);
        exit(SalespersonPurchaser.Code);
    end;

    local procedure VerifyOpportunityDescriptionInJSON(JSONTxt: Text; ExpectedDesc: Text)
    var
        Opportunity: Record Opportunity;
        DescriptionValue: Text;
    begin
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, 'description', DescriptionValue), 'Could not find the description');
        Assert.AreEqual(ExpectedDesc, DescriptionValue, 'Description does not match');
        Opportunity.SetRange(Description, DescriptionValue);
        Assert.IsFalse(Opportunity.IsEmpty(), 'Opportunity does not exist');
    end;
}















