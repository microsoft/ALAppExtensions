codeunit 139814 "APIV2 - Payment Methods E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Payment Method]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'paymentMethods';
        PaymentMethodPrefixTxt: Label 'GRAPH';
        EmptyJSONErr: Label 'The JSON should not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';

    [Test]
    procedure TestVerifyIDandLastModifiedDateTime()
    var
        PaymentMethod: Record "Payment Method";
        PaymentMethodCode: Text;
        PaymentMethodId: Guid;
    begin
        // [SCENARIO] Create a Payment Method and verify it has Id and LastDateTimeModified.
        Initialize();

        // [GIVEN] a modified Payment Method record
        PaymentMethodCode := CreatePaymentMethod();

        // [WHEN] we retrieve the Payment Method from the database
        PaymentMethod.Get(PaymentMethodCode);
        PaymentMethodId := PaymentMethod.SystemId;

        // [THEN] the Payment Method should have last date time modified
        PaymentMethod.TestField("Last Modified Date Time");
    end;

    [Test]
    procedure TestGetPaymentMethods()
    var
        PaymentMethodCode: array[2] of Text;
        PaymentMethodJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
        "Count": Integer;
    begin
        // [SCENARIO] User can retrieve all Payment Method records from the paymentMethods API.
        Initialize();

        // [GIVEN] 2 payment methods in the Payment Method Table
        for Count := 1 to 2 do
            PaymentMethodCode[Count] := CreatePaymentMethod();

        // [WHEN] A GET request is made to the Payment Method API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Payment Methods", ServiceNameTxt);

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 Payment Method should exist in the response
        for Count := 1 to 2 do
            GetAndVerifyIDFromJSON(ResponseText, PaymentMethodCode[Count], PaymentMethodJSON[Count]);
    end;

    [Test]
    procedure TestCreatePaymentMethods()
    var
        PaymentMethod: Record "Payment Method";
        TempPaymentMethod: Record "Payment Method" temporary;
        PaymentMethodJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a Payment Method through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a Payment Method JSON object to send to the service.
        PaymentMethodJSON := GetPaymentMethodJSON(TempPaymentMethod);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Payment Methods", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, PaymentMethodJSON, ResponseText);

        // [THEN] The response text contains the Payment Method information.
        VerifyPaymentMethodProperties(ResponseText, TempPaymentMethod);

        // [THEN] The Payment Method has been created in the database.
        PaymentMethod.Get(TempPaymentMethod.Code);
        VerifyPaymentMethodProperties(ResponseText, PaymentMethod);
    end;

    [Test]
    procedure TestModifyPaymentMethods()
    var
        PaymentMethod: Record "Payment Method";
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
        PaymentMethodCode: Text;
    begin
        // [SCENARIO] User can modify a Payment Method through a PATCH request.
        Initialize();

        // [GIVEN] A Payment Method exists.
        PaymentMethodCode := CreatePaymentMethod();
        PaymentMethod.Get(PaymentMethodCode);
        PaymentMethod.Description := LibraryUtility.GenerateGUID();
        RequestBody := GetPaymentMethodJSON(PaymentMethod);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(PaymentMethod.SystemId, Page::"APIV2 - Payment Methods", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response text contains the new values.
        VerifyPaymentMethodProperties(ResponseText, PaymentMethod);

        // [THEN] The record in the database contains the new values.
        PaymentMethod.Get(PaymentMethod.Code);
        VerifyPaymentMethodProperties(ResponseText, PaymentMethod);
    end;

    [Test]
    procedure TestDeletePaymentMethods()
    var
        PaymentMethod: Record "Payment Method";
        PaymentMethodCode: Text;
        TargetURL: Text;
        Responsetext: Text;
    begin
        // [SCENARIO] User can delete a Payment Method by making a DELETE request.
        Initialize();

        // [GIVEN] An Payment Method exists.
        PaymentMethodCode := CreatePaymentMethod();
        PaymentMethod.Get(PaymentMethodCode);

        // [WHEN] The user makes a DELETE request to the endpoint for the Payment Method.
        TargetURL := LibraryGraphMgt.CreateTargetURL(PaymentMethod.SystemId, Page::"APIV2 - Payment Methods", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Responsetext);

        // [THEN] The response is empty.
        Assert.AreEqual('', Responsetext, 'DELETE response should be empty.');

        // [THEN] The Payment Method is no longer in the database.
        PaymentMethod.SetRange(Code, PaymentMethodCode);
        Assert.IsTrue(PaymentMethod.IsEmpty(), 'Payment Method should be deleted.');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
    end;

    local procedure CreatePaymentMethod(): Text
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        Commit();

        exit(PaymentMethod.Code);
    end;

    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; PaymentMethodCode: Text; PaymentMethodJSON: Text)
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, 'code', PaymentMethodCode, PaymentMethodCode,
            PaymentMethodJSON, PaymentMethodJSON), 'Could not find the Payment Method in JSON');
        LibraryGraphMgt.VerifyIDInJson(PaymentMethodJSON);
    end;

    local procedure GetNextPaymentMethodID(): Code[10]
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.SetFilter(Code, StrSubstNo('%1*', PaymentMethodPrefixTxt));
        if PaymentMethod.FindLast() then
            exit(IncStr(PaymentMethod.Code));

        exit(CopyStr(PaymentMethodPrefixTxt + '00001', 1, 10));
    end;

    local procedure GetPaymentMethodJSON(var PaymentMethod: Record "Payment Method") PaymentMethodJSON: Text
    begin
        if PaymentMethod.Code = '' then
            PaymentMethod.Code := GetNextPaymentMethodID();
        if PaymentMethod.Description = '' then
            PaymentMethod.Description := LibraryUtility.GenerateGUID();
        PaymentMethodJSON := LibraryGraphMgt.AddPropertytoJSON('', 'code', PaymentMethod.Code);
        PaymentMethodJSON := LibraryGraphMgt.AddPropertytoJSON(PaymentMethodJSON, 'displayName', PaymentMethod.Description);
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, StrSubstNo(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyPaymentMethodProperties(PaymentMethodJSON: Text; PaymentMethod: Record "Payment Method")
    begin
        Assert.AreNotEqual('', PaymentMethodJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(PaymentMethodJSON);
        VerifyPropertyInJSON(PaymentMethodJSON, 'code', PaymentMethod.Code);
        VerifyPropertyInJSON(PaymentMethodJSON, 'displayName', PaymentMethod.Description);
    end;
}
















