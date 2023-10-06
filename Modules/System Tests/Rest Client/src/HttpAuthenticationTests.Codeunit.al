// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.RestClient;

using System.RestClient;
using System.TestLibraries.Utilities;

codeunit 134973 "Http Authentication Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestAnonymousAuthentication()
    var
        HttpAuthenticationAnonymous: Codeunit "Http Authentication Anonymous";
    begin
        // [GIVEN] An anonymous authentication object

        // [WHEN] The authentication object is asked if authentication is required
        // [THEN] The authentication object should return false
        Assert.IsFalse(HttpAuthenticationAnonymous.IsAuthenticationRequired(), 'Anonymous authentication should report that authentication is not required');

        // [WHEN] The authentication object is asked to return the authorization header
        // [THEN] The authentication object should return an empty list
        Assert.AreEqual(HttpAuthenticationAnonymous.GetAuthorizationHeaders().Count, 0, 'Anonymous authentication should not return an authorization header');
    end;

    [NonDebuggable]
    [Test]
    procedure TestBasicAuthentication()
    var
        HttpAuthenticationBasic: Codeunit "Http Authentication Basic";
        AuthHeader: Dictionary of [Text, SecretText];
        BasicAuthHeaderValue: SecretText;
    begin
        // [GIVEN] A basic authentication object
        HttpAuthenticationBasic.Initialize('USER01', SecretText.SecretStrSubstNo('Password123!'));

        // [WHEN] The authentication object is asked if authentication is required
        // [THEN] The authentication object should return true
        Assert.IsTrue(HttpAuthenticationBasic.IsAuthenticationRequired(), 'Basic authentication should report that authentication is required');

        // [WHEN] The authentication object is asked to return the authorization header
        // [THEN] THe authentication object should return a dictionary with one element that is a base64 encoded string
        AuthHeader := HttpAuthenticationBasic.GetAuthorizationHeaders();
        Assert.AreEqual(AuthHeader.Count, 1, 'Basic authentication should return one authorization header');
        Assert.AreEqual(AuthHeader.ContainsKey('Authorization'), true, 'Basic authentication should return an authorization header');  
        
        BasicAuthHeaderValue := AuthHeader.Get('Authorization');
        Assert.AreEqual(BasicAuthHeaderValue.Unwrap(), 'Basic VVNFUjAxOlBhc3N3b3JkMTIzIQ==', 'Basic authentication should return a base64 encoded string');
    end;
}