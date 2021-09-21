// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132918 "Stor. Serv. Account SAS Test"
{
    Subtype = Test;

    [Test]
    procedure SASNoParametersTest()
    var
        SASAuthorization: Interface "Storage Service Authorization";
        AccountKey, Uri, NewUri : Text;
        Permissions: List of [Enum "SAS Permission"];
        Services: List of [Enum "SAS Service Type"];
        Resources: List of [Enum "SAS Resource Type"];
        ExpiryDate: DateTime;
    begin
        // [Given] A storage account and an HTTP request with random URI
        AccountKey := '8jOLRYYU9UOaxhW1yeVUbA==';
        StorageAccount := Any.AlphanumericText(15);
        Uri := GenerateRandomUri(StorageAccount);
        ExpiryDate := CurrentDateTime();
        HttpRequest.SetRequestUri(Uri);
        HttpRequest.Method('GET');

        // [When] Authorizing the HTTP request using Account SAS authorization
        Services.Add(Enum::"SAS Service Type"::Blob);
        Resources.Add(Enum::"SAS Resource Type"::Container);
        Permissions.Add(Enum::"SAS Permission"::Read);
        Permissions.Add(Enum::"SAS Permission"::Write);

        SASAuthorization := StorageServiceAuthorization.CreateAccountSAS(AccountKey, Enum::"Storage Service API Version"::"2020-10-02", Services, Resources, Permissions, ExpiryDate);
        SASAuthorization.Authorize(HttpRequest, StorageAccount);

        // [Then] The Authorization header is present on the HTTP request and nothing else has changed
        Assert.AreNotEqual(Uri, HttpRequest.GetRequestUri(), 'The HTTP URI should have changed');
        Assert.AreEqual('GET', HttpRequest.Method(), 'The HTTP request method should not have changed');

        NewUri := HttpRequest.GetRequestUri();
        Assert.IsTrue(StrPos(NewUri, Uri) = 1, StrSubstNo('HTTP Uri has changed. Original URI: %1, New URI: %2', Uri, NewUri));

        Assert.IsTrue(StrPos(NewUri, 'ss=b') > 0, 'SignedServices parameter is missing or is incorrect');
        Assert.IsTrue(StrPos(NewUri, 'srt=c') > 0, 'SignedResources parameter is missing or is incorrect');
        Assert.IsTrue(StrPos(NewUri, 'sp=rw') > 0, 'SignedServices parameter is missing or is incorrect');

    end;

    local procedure GenerateRandomUri(StorageAccount: Text): Text
    begin
        exit(StrSubstNo('https://%1.blob.windows.net/%2/?%3=%4&5=%6', StorageAccount, Any.AlphabeticText(5), Any.AlphanumericText(5), Any.AlphanumericText(5), Any.AlphanumericText(5), Any.AlphanumericText(5)));
    end;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        HttpRequest: HttpRequestMessage;
        StorageAccount: Text;
}