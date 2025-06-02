codeunit 139822 "APIV2 - Employees E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Employee]
    end;

    var
        LibraryHumanResource: Codeunit "Library - Human Resource";
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'employees';
        EmptyJSONErr: Label 'The JSON should not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';

    local procedure Initialize()
    var
        LibraryApplicationArea: Codeunit "Library - Application Area";
    begin
        LibraryApplicationArea.EnableBasicHRSetup();

        // Lazy Setup.
        if IsInitialized then
            exit;

        LibraryHumanResource.SetupEmployeeNumberSeries();

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetEmployee()
    var
        Employee: Record "Employee";
        NoSeries: Codeunit "No. Series";
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get an Employee with a GET request to the service.
        Initialize();

        NoSeries.GetNextNo(LibraryHumanResource.SetupEmployeeNumberSeries());

        // [GIVEN] An Employee exists in the system.
        CreateEmployee(Employee);

        // [WHEN] The user makes a GET request for a given Employee.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Employee.SystemId, Page::"APIV2 - Employees", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response text contains the employee information.
        VerifyEmployeeProperties(ResponseText, Employee);
    end;

    [Test]
    procedure TestCreateEmployee()
    var
        Employee: Record "Employee";
        TempEmployee: Record "Employee" temporary;
        EmployeeJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create an Employee through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a simple Employee JSON object to send to the service.
        EmployeeJSON := GetEmployeeJSON(TempEmployee);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Employees", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, EmployeeJSON, ResponseText);

        // [THEN] The response text contains the Employee information.
        VerifyEmployeeProperties(ResponseText, TempEmployee);

        // [THEN] The Employee has been created in the database.
        Employee.Get(TempEmployee."No.");
        VerifyEmployeeProperties(ResponseText, Employee);
    end;

    [Test]
    procedure TestModifyEmployee()
    var
        Employee: Record "Employee";
        TempEmployee: Record "Employee" temporary;
        NoSeries: Codeunit "No. Series";
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can modify an Employee through a PATCH request.
        Initialize();

        NoSeries.GetNextNo(LibraryHumanResource.SetupEmployeeNumberSeries());

        // [GIVEN] An Employee exists.
        CreateEmployee(Employee);
        Employee.Validate("Bank Account No.");
        TempEmployee.TransferFields(Employee);
        TempEmployee."E-Mail" := LibraryUtility.GenerateRandomEmail();
        RequestBody := GetEmployeeJSON(TempEmployee);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Employee.SystemId, Page::"APIV2 - Employees", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response text contains the new values.
        VerifyEmployeeProperties(ResponseText, TempEmployee);

        // [THEN] The record in the database contains the new values.
        Employee.Get(Employee."No.");
        VerifyEmployeeProperties(ResponseText, Employee);
    end;

    [Test]
    procedure TestDeleteEmployee()
    var
        Employee: Record "Employee";
        EmployeeNo: Code[20];
        TargetURL: Text;
        Responsetext: Text;
    begin
        // [SCENARIO 201343] User can delete an Employee by making a DELETE request.
        Initialize();

        // [GIVEN] An Employee exists.
        CreateEmployee(Employee);
        EmployeeNo := Employee."No.";

        // [WHEN] The user makes a DELETE request to the endpoint for the Employee.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Employee.SystemId, Page::"APIV2 - Employees", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Responsetext);

        // [THEN] The response is empty.
        Assert.AreEqual('', Responsetext, 'DELETE response should be empty.');

        // [THEN] The Employee is no longer in the database.
        Employee.SetRange("No.", EmployeeNo);
        Assert.IsTrue(Employee.IsEmpty(), 'Employee should be deleted.');
    end;

    local procedure CreateEmployee(var Employee: Record "Employee")
    begin
        LibraryHumanResource.CreateEmployeeWithBankAccount(Employee);
        Commit();
    end;

    local procedure VerifyEmployeeProperties(EmployeeJSON: Text; Employee: Record "Employee")
    begin
        Assert.AreNotEqual('', EmployeeJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(EmployeeJSON);
        VerifyPropertyInJSON(EmployeeJSON, 'number', Employee."No.");
        VerifyPropertyInJSON(EmployeeJSON, 'givenName', Employee."First Name");
        VerifyPropertyInJSON(EmployeeJSON, 'surname', Employee."Last Name");
        VerifyPropertyInJSON(EmployeeJSON, 'jobTitle', Employee."Job Title");
        VerifyPropertyInJSON(EmployeeJSON, 'addressLine1', Employee.Address);
        VerifyPropertyInJSON(EmployeeJSON, 'city', Employee."City");
        VerifyPropertyInJSON(EmployeeJSON, 'country', Employee."Country/Region Code");
        VerifyPropertyInJSON(EmployeeJSON, 'postalCode', Employee."Post Code");
        VerifyPropertyInJSON(EmployeeJSON, 'mobilePhone', Employee."Mobile Phone No.");
        VerifyPropertyInJSON(EmployeeJSON, 'personalEmail', Employee."E-Mail");
        VerifyPropertyInJSON(EmployeeJSON, 'bankBranchNumber', Employee."Bank Branch No.");
        VerifyPropertyInJSON(EmployeeJSON, 'bankAccountNumber', Employee."Bank Account No.");
        VerifyPropertyInJSON(EmployeeJSON, 'iban', Employee."IBAN");
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, StrSubstNo(WrongPropertyValueErr, PropertyName));
    end;

    local procedure GetEmployeeJSON(var Employee: Record "Employee") EmployeeJSON: Text
    var
        NoSeries: Codeunit "No. Series";
    begin
        if Employee."No." = '' then
            Employee."No." := NoSeries.PeekNextNo(LibraryHumanResource.SetupEmployeeNumberSeries());
        if Employee."First Name" = '' then
            Employee."First Name" := Employee."No.";
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON('', 'number', Employee."No.");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'givenName', Employee."First Name");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'surname', Employee."Last Name");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'jobTitle', Employee."Job Title");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'addressLine1', Employee.Address);
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'city', Employee."City");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'country', Employee."Country/Region Code");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'postalCode', Employee."Post Code");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'mobilePhone', Employee."Mobile Phone No.");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'personalEmail', Employee."E-Mail");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'bankBranchNumber', Employee."Bank Branch No.");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'bankAccountNumber', Employee."Bank Account No.");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'iban', Employee."IBAN");
    end;
}



















