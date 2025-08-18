// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Email;

using System.Email;
using System.TestLibraries.Email;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 139775 "Https Mock Email Test"
{
    Subtype = Test;
    Permissions = tabledata "Email Related Record" = r,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Email Address Lookup" = rimd,
                  tabledata "Sent Email" = rid;

    EventSubscriberInstance = Manual;
    TestHttpRequestPolicy = BlockOutboundRequests;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        PermissionsMock: Codeunit "Permissions Mock";
        Email: Codeunit Email;
        MockHttpStatusCode: Integer;
        MockHttpReasonPhrase: Text;

    [Test]
    [HandlerFunctions('HttpRequestMockHandler')]
    procedure SendNewMessageThroughEditorSuccessTest()
    var
        Account: Record "Email Account";
        OutlookAccount: Record "Email - Outlook Account";
        OutlookApiSetup: Record "Email - Outlook API Setup";
        HttpMockEmailMgnt: Codeunit "Library - Email Mock";
        SkipTokenRequest: Codeunit "Skip Outlook API Token Request";
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
    begin
        // [Scenario] When user send the email from the editor with Microsoft 365 connector, the http request mocker returns a 202 to mock the success. All the records are updated correctly.
        BindSubscription(SkipTokenRequest);
        SkipTokenRequest.SetSkipTokenRequest(true);

        // [GIVEN] Set up the email account and Outlook account
        PermissionsMock.Set('Super');
        ConnectorMock.AddAccount(Account, Enum::"Email Connector"::"Microsoft 365");
        SetupOutlookAccount(OutlookAccount, Account);
        SetupOutlookApi(OutlookApiSetup);

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailMessage.Create('', '', '', false);
        Email.OpenInEditor(EmailMessage, Account);
        Editor.ToField.SetValue('testtest@microsoft.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked, the post request is mocked to return a 202 - the email is sent successfully
        SetHttpMockResponse(202, 'Accepted');
        Editor.Send.Invoke();

        // [THEN] The mail is sent and the info is correct
        Assert.IsTrue(HttpMockEmailMgnt.SentEmailExists(EmailMessage.GetId()), 'A Sent Email record should have been inserted.');
        Assert.IsTrue(HttpMockEmailMgnt.CheckSentEmailDescription(EmailMessage.GetId(), 'Test Subject'), 'A different description was expected');
        Assert.IsTrue(HttpMockEmailMgnt.CheckSentEmailAccountId(EmailMessage.GetId(), Account."Account Id"), 'A different account was expected');
        Assert.IsTrue(HttpMockEmailMgnt.CheckSentEmailFrom(EmailMessage.GetId(), Account."Email Address"), 'A different sent was expected');
        Assert.IsTrue(HttpMockEmailMgnt.CheckSentEmailConnector(EmailMessage.GetId(), Enum::"Email Connector"::"Microsoft 365"), 'A different connector was expected');
    end;

    [Test]
    [HandlerFunctions('HttpRequestMockHandler')]
    procedure ScheduledEmailBackgroundSuccessTest()
    var
        Account: Record "Email Account";
        OutlookAccount: Record "Email - Outlook Account";
        OutlookApiSetup: Record "Email - Outlook API Setup";
        HttpMockEmailMgnt: Codeunit "Library - Email Mock";
        SkipTokenRequest: Codeunit "Skip Outlook API Token Request";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
    begin
        // [Scenario] When the email is sent from the background task with Microsoft 365 connector, the http request mocker returns a 202 to mock the success. All the records are updated correctly.
        BindSubscription(SkipTokenRequest);
        SkipTokenRequest.SetSkipTokenRequest(true);

        // [GIVEN] Set up the email account and Outlook account
        PermissionsMock.Set('Super');
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        ConnectorMock.AddAccount(Account, Enum::"Email Connector"::"Microsoft 365");
        SetupOutlookAccount(OutlookAccount, Account);
        SetupOutlookApi(OutlookApiSetup);

        HttpMockEmailMgnt.SetupEmailOutbox(EmailMessage.GetId(), Enum::"Email Connector"::"Microsoft 365", Account."Account Id", 'Test Subject', Account."Email Address", UserSecurityId());

        // [WHEN] The sending task is run from the background, the post request is mocked to return a 202 - the email is sent successfully
        SetHttpMockResponse(202, 'Accepted');
        HttpMockEmailMgnt.RunEmailDispatcher(EmailMessage.GetId());

        // [THEN] No error occurs
        Assert.AreEqual('', GetLastErrorText(), 'There should be no errors when enqueuing an email.');

        // [THEN] The mail is sent and the info is correct
        Assert.IsTrue(HttpMockEmailMgnt.SentEmailExists(EmailMessage.GetId()), 'A Sent Email record should have been inserted.');
        Assert.IsTrue(HttpMockEmailMgnt.CheckSentEmailDescription(EmailMessage.GetId(), 'Test Subject'), 'A different description was expected');
        Assert.IsTrue(HttpMockEmailMgnt.CheckSentEmailAccountId(EmailMessage.GetId(), Account."Account Id"), 'A different account was expected');
        Assert.IsTrue(HttpMockEmailMgnt.CheckSentEmailFrom(EmailMessage.GetId(), Account."Email Address"), 'A different sent was expected');
        Assert.IsTrue(HttpMockEmailMgnt.CheckSentEmailConnector(EmailMessage.GetId(), Enum::"Email Connector"::"Microsoft 365"), 'A different connector was expected');
    end;

    [Test]
    [HandlerFunctions('HttpRequestMockHandler')]
    procedure SendNewMessageThroughEditorFailureTest()
    var
        Account: Record "Email Account";
        OutlookAccount: Record "Email - Outlook Account";
        OutlookApiSetup: Record "Email - Outlook API Setup";
        HttpMockEmailMgnt: Codeunit "Library - Email Mock";
        SkipTokenRequest: Codeunit "Skip Outlook API Token Request";
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
    begin
        // [Scenario] When user send the email from the editor with Microsoft 365 connector, the http request mocker returns a 400 to mock the failure. All the records are updated correctly.
        BindSubscription(SkipTokenRequest);
        SkipTokenRequest.SetSkipTokenRequest(true);

        // [GIVEN] Set up the email account and Outlook account
        PermissionsMock.Set('Super');
        ConnectorMock.AddAccount(Account, Enum::"Email Connector"::"Microsoft 365");
        SetupOutlookAccount(OutlookAccount, Account);
        SetupOutlookApi(OutlookApiSetup);
        HttpMockEmailMgnt.CleanEmailErrors();

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailMessage.Create('', '', '', false);
        Email.OpenInEditor(EmailMessage, Account);
        Editor.ToField.SetValue('testtest@microsoft.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked, the post request is mocked to return a 400 - the email is sent unsuccessfully
        SetHttpMockResponse(400, 'Failed');
        Assert.AreEqual(0, HttpMockEmailMgnt.GetEmailErrorCount(), 'There should be no email errors before sending the email');
        asserterror Editor.Send.Invoke();

        // [THEN] The error occurs
        Assert.ExpectedError('The email was not sent because of the following error');

        // [THEN] The mail is not sent and the error is recorded
        Assert.IsFalse(HttpMockEmailMgnt.SentEmailExists(EmailMessage.GetId()), 'No Sent Email record should have been inserted');
        Assert.AreEqual(1, HttpMockEmailMgnt.GetEmailErrorCount(), 'There should one email error record after sending the email');
        Assert.IsTrue(HttpMockEmailMgnt.CheckEmailOutBoxStatusWithMessageId(EmailMessage.GetId(), Enum::"Email Status"::Failed), 'The email status should be Failed after sending failed');
    end;

    [Test]
    [HandlerFunctions('HttpRequestMockHandler')]
    procedure ScheduledEmailBackgroundFailureTest()
    var
        Account: Record "Email Account";
        OutlookAccount: Record "Email - Outlook Account";
        OutlookApiSetup: Record "Email - Outlook API Setup";
        HttpMockEmailMgnt: Codeunit "Library - Email Mock";
        SkipTokenRequest: Codeunit "Skip Outlook API Token Request";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
    begin
        // [Scenario] When the email is sent from the background task with Microsoft 365 connector, the http request mocker returns a 202 to mock the success. All the records are updated correctly.
        BindSubscription(SkipTokenRequest);
        SkipTokenRequest.SetSkipTokenRequest(true);
        PermissionsMock.Set('Super');
        HttpMockEmailMgnt.CleanEmailErrors();

        // [GIVEN] Set up the email account and Outlook account
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        ConnectorMock.AddAccount(Account, Enum::"Email Connector"::"Microsoft 365");
        SetupOutlookAccount(OutlookAccount, Account);
        SetupOutlookApi(OutlookApiSetup);
        HttpMockEmailMgnt.SetupEmailOutbox(EmailMessage.GetId(), Enum::"Email Connector"::"Microsoft 365", Account."Account Id", 'Test Subject', Account."Email Address", UserSecurityId());

        // [WHEN] The sending task is run from the background, the post request is mocked to return a 400 - the email is sent unsuccessfully
        SetHttpMockResponse(400, 'Failed');
        HttpMockEmailMgnt.RunEmailDispatcher(EmailMessage.GetId());

        // [THEN] An error occurs
        Assert.ExpectedError('Failed to send email.');

        // [THEN] The mail is not sent and the error is recorded
        Assert.IsFalse(HttpMockEmailMgnt.SentEmailExists(EmailMessage.GetId()), 'No Sent Email record should have been inserted');
        Assert.AreEqual(1, HttpMockEmailMgnt.GetEmailErrorCount(), 'There should one email error record after sending the email');
        Assert.IsTrue(HttpMockEmailMgnt.CheckEmailOutBoxStatusWithMessageId(EmailMessage.GetId(), Enum::"Email Status"::Failed), 'The email status should be Failed after sending from the background');
    end;

    local procedure SetupOutlookAccount(var OutlookAccount: Record "Email - Outlook Account"; Account: Record "Email Account")
    begin
        OutlookAccount.Id := Account."Account Id";
        OutlookAccount."Email Address" := Account."Email Address";
        OutlookAccount.Name := Account.Name;
        OutlookAccount."Outlook API Email Connector" := Enum::"Email Connector"::"Microsoft 365";
        OutlookAccount.Insert();
    end;

    local procedure SetupOutlookApi(var OutlookApiSetup: Record "Email - Outlook API Setup")
    begin
        if OutlookApiSetup.FindFirst() then
            exit;
        OutlookApiSetup.ClientId := Any.GuidValue();
        OutlookApiSetup.ClientSecret := Any.GuidValue();
        OutlookApiSetup.RedirectURL := CopyStr(Any.AlphanumericText(50), 1, 250);
        OutlookApiSetup.Insert();
    end;

    local procedure SetHttpMockResponse(StatusCode: Integer; ReasonPhrase: Text)
    begin
        MockHttpStatusCode := StatusCode;
        MockHttpReasonPhrase := ReasonPhrase;
    end;

    [HttpClientHandler]
    procedure HttpRequestMockHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        response.HttpStatusCode := MockHttpStatusCode;
        response.ReasonPhrase := MockHttpReasonPhrase;
    end;
}