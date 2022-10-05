// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132977 "SharePoint Authorization Test"
{
    Subtype = Test;

    var
        SharePointAuthSubscription: Codeunit "SharePoint Auth. Subscription";
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        IsInitialized: Boolean;

    [Test]
    procedure TestAuthorizationCodeAuthorization()
    var
        SharepointAuth: Codeunit "SharePoint Auth.";
        HttpRequestMessage: HttpRequestMessage;
        HttpHehaders: HttpHeaders;
        Values: array[100] of Text;
        SharepointAuthorization: Interface "SharePoint Authorization";
    begin
        // [Scenario] Request is succesfully authorized with authorization code
        Initialize();

        SharePointAuthSubscription.SetParameters(false, '');
        SharepointAuthorization := SharepointAuth.CreateAuthorizationCode(CreateGuid(), Any.AlphanumericText(10), Any.AlphabeticText(20), Any.AlphabeticText(20));
        SharepointAuthorization.Authorize(HttpRequestMessage);

        Assert.IsTrue(HttpRequestMessage.GetHeaders(HttpHehaders), 'Headers expected');
        Assert.IsTrue(HttpHehaders.GetValues('Authorization', Values), 'Authorization header expected');
        Assert.IsTrue(Values[1].StartsWith('Bearer '), 'Incorrecte header value');
        Assert.IsTrue(StrLen(Values[1].Remove(1, StrLen('Bearer '))) > 0, 'Missing token');
    end;

    [Test]
    procedure TestAuthorizationCodeAuthorizationFail()
    var
        SharepointAuth: Codeunit "SharePoint Auth.";
        HttpRequestMessage: HttpRequestMessage;
        SharepointAuthorization: Interface "SharePoint Authorization";
        ErrorText: Text;
    begin
        // [Scenario] Request is succesfully authorized with authorization code
        Initialize();
        ErrorText := Any.AlphanumericText(50);
        SharePointAuthSubscription.SetParameters(true, ErrorText);
        SharepointAuthorization := SharepointAuth.CreateAuthorizationCode(CreateGuid(), Any.AlphanumericText(10), Any.AlphabeticText(20), Any.AlphabeticText(20));
        asserterror SharepointAuthorization.Authorize(HttpRequestMessage);

        Assert.AreEqual(ErrorText, GetLastErrorText(), 'Error expected');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        BindSubscription(SharePointAuthSubscription);
    end;
}