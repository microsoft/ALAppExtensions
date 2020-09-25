codeunit 139722 "APIV1 - Employees E2E"
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
        IF IsInitialized THEN
            EXIT;

        LibraryHumanResource.SetupEmployeeNumberSeries();

        IsInitialized := TRUE;
        COMMIT();
    end;

    [Test]
    procedure TestGetEmployee()
    var
        Employee: Record "Employee";
        NoSeriesManagement: Codeunit "NoSeriesManagement";
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get an Employee with a GET request to the service.
        Initialize();

        NoSeriesManagement.GetNextNo(LibraryHumanResource.SetupEmployeeNumberSeries(), WORKDATE(), TRUE);

        // [GIVEN] An Employee exists in the system.
        CreateEmployee(Employee);

        // [WHEN] The user makes a GET request for a given Employee.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Employee.SystemId, PAGE::"APIV1 - Employees", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response text contains the employee information.
        VerifyEmployeeSimpleProperties(ResponseText, Employee);
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
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Employees", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, EmployeeJSON, ResponseText);

        // [THEN] The response text contains the Employee information.
        VerifyEmployeeSimpleProperties(ResponseText, TempEmployee);

        // [THEN] The Employee has been created in the database.
        Employee.GET(TempEmployee."No.");
        VerifyEmployeeSimpleProperties(ResponseText, Employee);
    end;

    [Test]
    procedure TestModifyEmployee()
    var
        Employee: Record "Employee";
        TempEmployee: Record "Employee" temporary;
        NoSeriesManagement: Codeunit "NoSeriesManagement";
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can modify an Employee through a PATCH request.
        Initialize();

        NoSeriesManagement.GetNextNo(LibraryHumanResource.SetupEmployeeNumberSeries(), WORKDATE(), TRUE);

        // [GIVEN] An Employee exists.
        CreateEmployee(Employee);
        TempEmployee.TRANSFERFIELDS(Employee);
        TempEmployee."E-Mail" := LibraryUtility.GenerateGUID();
        RequestBody := GetEmployeeJSON(TempEmployee);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Employee.SystemId, PAGE::"APIV1 - Employees", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response text contains the new values.
        VerifyEmployeeSimpleProperties(ResponseText, TempEmployee);

        // [THEN] The record in the database contains the new values.
        Employee.GET(Employee."No.");
        VerifyEmployeeSimpleProperties(ResponseText, Employee);
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
        TargetURL := LibraryGraphMgt.CreateTargetURL(Employee.SystemId, PAGE::"APIV1 - Employees", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Responsetext);

        // [THEN] The response is empty.
        Assert.AreEqual('', Responsetext, 'DELETE response should be empty.');

        // [THEN] The Employee is no longer in the database.
        Employee.SetRange("No.", EmployeeNo);
        Assert.IsTrue(Employee.IsEmpty(), 'Employee should be deleted.');
    end;

    local procedure CreateEmployee(var Employee: Record "Employee")
    begin
        LibraryHumanResource.CreateEmployee(Employee);
        COMMIT();
    end;

    local procedure VerifyEmployeeSimpleProperties(EmployeeJSON: Text; Employee: Record "Employee")
    begin
        Assert.AreNotEqual('', EmployeeJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(EmployeeJSON);
        VerifyPropertyInJSON(EmployeeJSON, 'number', Employee."No.");
        VerifyPropertyInJSON(EmployeeJSON, 'givenName', Employee."First Name");
        VerifyPropertyInJSON(EmployeeJSON, 'surname', Employee."Last Name");
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, STRSUBSTNO(WrongPropertyValueErr, PropertyName));
    end;

    local procedure GetEmployeeJSON(var Employee: Record "Employee") EmployeeJSON: Text
    var
        NoSeriesManagement: Codeunit "NoSeriesManagement";
    begin
        IF Employee."No." = '' THEN
            Employee."No." := NoSeriesManagement.GetNextNo(LibraryHumanResource.SetupEmployeeNumberSeries(), WORKDATE(), FALSE);
        IF Employee."First Name" = '' THEN
            Employee."First Name" := Employee."No.";
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON('', 'number', Employee."No.");
        EmployeeJSON := LibraryGraphMgt.AddPropertytoJSON(EmployeeJSON, 'givenName', Employee."First Name");
    end;
}



















