// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;
using System.Utilities;

codeunit 148200 "Test Request Creation"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestGetSandboxDataWhenAllDataIsGiven()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ProdApiKey: Text;
        StagApiKey: Text;
    begin
        Initialize();
        //[GIVEN] Both API Key and Project are given for both modes. Staing Mode enabled
        ProdApiKey := CreateGuid();
        StagApiKey := CreateGuid();

        B2BrouterSetup.StoreApiKey(false, ProdApiKey);
        B2BrouterSetup."Production Project" := 'Prod';

        B2BrouterSetup.StoreApiKey(true, StagApiKey);
        B2BrouterSetup."Sandbox Project" := 'Sandbox';

        B2BrouterSetup."Sandbox Mode" := true;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] InitRequestData
        APIMgmt.InitRequestData();

        //[THEN] 
        // ApiKeyArg = StagApiKey
        // ProjectArg = 'Sandbox'
        AssertThat.AreEqual(APIMgmt.GetApiKey().Unwrap(), StagApiKey, IncorrectValueErr);
        AssertThat.AreEqual(APIMgmt.GetProject(), 'Sandbox', IncorrectValueErr);
        AssertThat.AreEqual(APIMgmt.GetBaseURL(), SandboxBaseUrlLbl, IncorrectValueErr);
        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestGetProdDataWhenAllDataIsGiven()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ProdApiKey: Text;
        StagApiKey: Text;
    begin
        Initialize();
        //[GIVEN] Both API Key and Project are given for both modes. Staing Mode disabled

        ProdApiKey := CreateGuid();
        StagApiKey := CreateGuid();

        B2BrouterSetup.StoreApiKey(false, ProdApiKey);
        B2BrouterSetup."Production Project" := 'Prod';

        B2BrouterSetup.StoreApiKey(true, StagApiKey);
        B2BrouterSetup."Sandbox Project" := 'Sandbox';

        B2BrouterSetup."Sandbox Mode" := false;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] InitRequestData
        APIMgmt.InitRequestData();

        //[THEN] 
        // ApiKeyArg = ProdApiKey
        // ProjectArg = 'Prod'
        AssertThat.AreEqual(ProdApiKey, APIMgmt.GetApiKey().Unwrap(), IncorrectValueErr);
        AssertThat.AreEqual('Prod', APIMgmt.GetProject(), IncorrectValueErr);
        AssertThat.AreEqual(ProdBaseUrlLbl, APIMgmt.GetBaseURL(), IncorrectValueErr);
        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestGetProdDataWhenProjectIsMissing()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ProdApiKey: Text;
        StagApiKey: Text;

    begin
        Initialize();
        //[GIVEN] Both API Key and Project are given for both modes. Staing Mode disabled

        ProdApiKey := CreateGuid();
        StagApiKey := CreateGuid();

        B2BrouterSetup.StoreApiKey(false, ProdApiKey);

        B2BrouterSetup.StoreApiKey(true, StagApiKey);
        B2BrouterSetup."Sandbox Project" := 'Sandbox';

        B2BrouterSetup."Sandbox Mode" := false;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] InitRequestData
        asserterror APIMgmt.InitRequestData();

        if B2BrouterSetup.Get() then
            B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestGetProdDataWhenApiKeyIsMissing()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ProdApiKey: Text;
        StagApiKey: Text;

    begin
        Initialize();
        //[GIVEN] Both API Key and Project are given for both modes. Sandbox Mode disabled

        ProdApiKey := CreateGuid();
        StagApiKey := CreateGuid();

        B2BrouterSetup."Production Project" := 'Prod';

        B2BrouterSetup.StoreApiKey(true, StagApiKey);
        B2BrouterSetup."Sandbox Project" := 'Sandbox';

        B2BrouterSetup."Sandbox Mode" := false;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] InitRequestData
        asserterror APIMgmt.InitRequestData();

        if B2BrouterSetup.Get() then
            B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointImportSandbox()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app-staging.b2brouter.net/projects/%1/invoices/import.json/?send_after_import=true', Comment = '%1 => project', Locked = true;
        HttpRequest: HttpRequestMessage;
    begin
        Initialize();

        //[GIVEN] given
        StoreApiKey(true, CreateGuid());
        B2BrouterSetup."Sandbox Project" := 'Sandbox';
        B2BrouterSetup."Sandbox Mode" := true;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Impor
        APIMgmt.InitImportRequest(HttpRequest);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, 'Sandbox'), HttpRequest.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('POST', HttpRequest.Method(), 'Method must be "POST".');
        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointReceiveSandbox()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app-staging.b2brouter.net/projects/%1/received.json', Comment = '%1 => project', Locked = true;
        HttpRequest: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(true, CreateGuid());
        B2BrouterSetup."Sandbox Project" := 'Sandbox';
        B2BrouterSetup."Sandbox Mode" := true;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Import
        APIMgmt.InitReceiveRequest(HttpRequest);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, 'Sandbox'), HttpRequest.GetRequestUri, UrlDoesNotMatchErr);
        AssertThat.AreEqual('GET', HttpRequest.Method(), 'Method must be "GET".');
        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointConvertSandbox()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app-staging.b2brouter.net/invoices/%1/as/%2', Comment = '%1 => document id; %2 => format', Locked = true;
        HttpRequest: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(true, CreateGuid());
        B2BrouterSetup."Sandbox Project" := 'Sandbox';
        B2BrouterSetup."Sandbox Mode" := true;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();


        //[WHEN] Import
        APIMgmt.InitDownloadRequest(HttpRequest, 987653);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, '987653', 'xml.ubl.invoice.bis3'), HttpRequest.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('GET', HttpRequest.Method(), 'Method must be "GET".');
        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointSendSandbox()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app-staging.b2brouter.net/invoices/send_invoice/%1.json', Comment = '%1 => document id', Locked = true;
        HttpRequest: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(true, CreateGuid());
        B2BrouterSetup."Sandbox Project" := 'Sandbox';
        B2BrouterSetup."Sandbox Mode" := true;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Import
        APIMgmt.InitSendRequest(HttpRequest, 987653);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, '987653'), HttpRequest.GetRequestUri(), IncorrectValueErr);
        AssertThat.AreEqual('POST', HttpRequest.Method(), 'Method must be "POST.');
        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointSpecificSandbox()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app-staging.b2brouter.net/invoices/%1.json', Comment = '%1 => document id', Locked = true;
        HttpRequest: HttpRequestMessage;
        HttpRequest2: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(true, CreateGuid());
        B2BrouterSetup."Sandbox Project" := 'Sandbox';
        B2BrouterSetup."Sandbox Mode" := true;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Import
        APIMgmt.InitGetResponseRequest(HttpRequest, 987653);
        APIMgmt.InitCancelRequest(HttpRequest2, 987653);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, '987653'), HttpRequest.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('GET', HttpRequest.Method(), 'Method must be "GET"');

        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, '987653'), HttpRequest2.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('DELETE', HttpRequest2.Method(), 'Method must be "DELETE"');
        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointImportProduction()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app.b2brouter.net/projects/%1/invoices/import.json/?send_after_import=true', Comment = '%1 => project', Locked = true;
        HttpRequest: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(false, CreateGuid());
        B2BrouterSetup."Production Project" := 'Production';
        B2BrouterSetup."Sandbox Mode" := false;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Import
        APIMgmt.InitImportRequest(HttpRequest);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, 'Production'), HttpRequest.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('POST', HttpRequest.Method(), 'Method must be "POST"');
        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointReceiveProduction()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app.b2brouter.net/projects/%1/received.json', Comment = '%1 => document id', Locked = true;
        HttpRequest: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(false, CreateGuid());
        B2BrouterSetup."Production Project" := 'Production';
        B2BrouterSetup."Sandbox Mode" := false;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Import
        APIMgmt.InitReceiveRequest(HttpRequest);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, 'Production'), HttpRequest.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('GET', HttpRequest.Method(), 'Method must be "GET"');

        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointConvertProduction()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app.b2brouter.net/invoices/%1/as/%2', Comment = '%1 => document id; %2 => format', Locked = true;
        HttpRequest: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(false, CreateGuid());
        B2BrouterSetup."Production Project" := 'Production';
        B2BrouterSetup."Sandbox Mode" := false;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Import
        APIMgmt.InitDownloadRequest(HttpRequest, 987653);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, '987653', 'xml.ubl.invoice.bis3'), HttpRequest.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('GET', HttpRequest.Method(), 'Method must be "GET"');

        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointSendProduction()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app.b2brouter.net/invoices/send_invoice/%1.json', Comment = '%1 => document id', Locked = true;
        HttpRequest: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(false, CreateGuid());
        B2BrouterSetup."Production Project" := 'Production';
        B2BrouterSetup."Sandbox Mode" := false;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Import
        APIMgmt.InitSendRequest(HttpRequest, 987653);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, '987653'), HttpRequest.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('POST', HttpRequest.Method(), 'Method must be "POST"');

        B2BrouterSetup.Delete();
    end;

    [Test]
    procedure TestCreatingEndpointSpecificProduction()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        ExpectedUrlLbl: Label 'https://app.b2brouter.net/invoices/%1.json', Comment = '%1 => document id', Locked = true;
        HttpRequest: HttpRequestMessage;
        HttpRequest2: HttpRequestMessage;
    begin
        Initialize();
        //[GIVEN] given
        StoreApiKey(false, CreateGuid());
        B2BrouterSetup."Production Project" := 'Production';
        B2BrouterSetup."Sandbox Mode" := false;
        if not B2BrouterSetup.Insert() then
            B2BrouterSetup.Modify();

        //[WHEN] Import
        APIMgmt.InitGetResponseRequest(HttpRequest, 987653);
        APIMgmt.InitCancelRequest(HttpRequest2, 987653);

        //[THEN] then
        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, '987653'), HttpRequest.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('GET', HttpRequest.Method(), 'Method must be "GET"');

        AssertThat.AreEqual(StrSubstNo(ExpectedUrlLbl, '987653'), HttpRequest2.GetRequestUri(), UrlDoesNotMatchErr);
        AssertThat.AreEqual('DELETE', HttpRequest2.Method(), 'Method must be "DELETE"');
        B2BrouterSetup.Delete();
    end;

    [Test]
    [NonDebuggable]
    procedure TestStoringMultipleKeys()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
        APIMgmt: Codeunit "B2Brouter Api Management";
        Key1: Text;
        Key2: Text;
    begin
        //[GIVEN] Given Production Key
        Initialize();
        Key1 := CreateGuid();
        Key2 := CreateGuid();
        AssertThat.AreNotEqual(Key1, Key2, 'Keys should not be equal.');
        B2BrouterSetup."Production Project" := 'Production';
        B2BrouterSetup.StoreApiKey(false, Key1);
        B2BrouterSetup.Insert();

        //[WHEN] A new ApiKey is set
        B2BrouterSetup.StoreApiKey(false, Key2);
        APIMgmt.InitRequestData();

        //[THEN] New api key should be returned
        AssertThat.AreEqual(Key2, APIMgmt.GetApiKey().Unwrap(), IncorrectValueErr);
    end;

    local procedure Initialize()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
    begin
        if B2BrouterSetup.Get() then
            B2BrouterSetup.Delete();
        B2BrouterSetup.DeleteApiKeys();
    end;

    local procedure StoreApiKey(Sandbox: Boolean; ApiKeyTxt: Text)
    var
        B2BrouterSetup: Record "B2Brouter Setup";
    begin
        ApiKeyTxt := CreateGuid();
        B2BrouterSetup.StoreApiKey(Sandbox, ApiKeyTxt);
    end;

    var
        AssertThat: Codeunit System.TestLibraries.Utilities."Library Assert";
        UrlDoesNotMatchErr: Label 'Url does not match.';
        IncorrectValueErr: Label 'Wrong value';
        SandboxBaseUrlLbl: Label 'https://app-staging.b2brouter.net', Locked = true;
        ProdBaseUrlLbl: Label 'https://app.b2brouter.net', Locked = true;
}