codeunit 139804 "APIV2 - Payment Terms E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Payment Terms]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit "Assert";
        ServiceNameTxt: Label 'paymentTerms';
        IsInitialized: Boolean;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestVerifyIDandLastDateModified()
    var
        PaymentTerms: Record "Payment Terms";
        PaymentTermCode: Code[10];
        PaymentTermsId: Guid;
    begin
        // [SCENARIO] Create a payment term and verify it has Id and LastDateTimeModified
        // [GIVEN] a modified Payment Term record
        Initialize();
        PaymentTermCode := CreatePaymentTerm();

        // [WHEN] we retrieve the payment term from the database
        PaymentTerms.Reset();
        PaymentTerms.Get(PaymentTermCode);
        PaymentTermsId := PaymentTerms.SystemId;

        // [THEN] the payment term should have last date time modified
        PaymentTerms.TestField("Last Modified Date Time");
    end;

    [Test]
    procedure TestGetPaymentTerms()
    var
        PaymentTermCode: array[2] of Code[10];
        PaymentTermJSON: array[2] of Text;
        TargetURL: Text;
        ResponseText: Text;
        "Count": Integer;
    begin
        // [SCENARIO] User can retrieve all Payment Terms records from the Payment Terms API.
        // [GIVEN] 2 payment terms in the Payment Terms Table
        Initialize();
        for Count := 1 to 2 do
            PaymentTermCode[Count] := CreatePaymentTerm();
        Commit();

        // [WHEN] A GET request is made to the Payment Terms API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Payment Terms", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 payment terms should exist in the response
        for Count := 1 to 2 do
            GetAndVerifyIDFromJSON(ResponseText, PaymentTermCode[Count], PaymentTermJSON[Count]);
    end;

    [Normal]
    local procedure CreatePaymentTerm(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        LibraryERM.CreatePaymentTerms(PaymentTerms);

        exit(PaymentTerms.Code);
    end;

    [Normal]
    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; PaymentTermCode: Text; var PaymentTermJSON: Text)
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, 'code', PaymentTermCode, PaymentTermCode,
            PaymentTermJSON, PaymentTermJSON), 'Could not find the payment term in JSON');
        LibraryGraphMgt.VerifyIDInJson(PaymentTermJSON);
    end;
}







