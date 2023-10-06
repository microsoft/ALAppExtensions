// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

/// <summary>Holder object for the HTTP request data.</summary>
codeunit 2352 "Http Request Message"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        HttpRequestMessageImpl: Codeunit "Http Request Message Impl.";


    /// <summary>Sets the HTTP method or the HttpRequestMessage object.</summary>
    /// <param name="Method">The HTTP method to use. Valid options are GET, POST, PATCH, PUT, DELETE, HEAD, OPTIONS</param>
    /// <remarks>Default method is GET</remarks>
    procedure SetHttpMethod(Method: Text)
    begin
        HttpRequestMessageImpl.SetHttpMethod(Method);
    end;

    /// <summary>Sets the HTTP method for the HttpRequestMessage object.</summary>
    /// <param name="Method">The HTTP method to use.</param>
    /// <remarks>Default method is GET</remarks>
    procedure SetHttpMethod(Method: Enum "Http Method")
    begin
        HttpRequestMessageImpl.SetHttpMethod(Method);
    end;

    /// <summary>Gets the HTTP method for the HttpRequestMessage object.</summary>
    /// <returns>The HTTP method for the HttpRequestMessage object.</returns>
    procedure GetHttpMethod() Method: Text
    begin
        Method := HttpRequestMessageImpl.GetHttpMethod();
    end;

    /// <summary>Sets the Uri used for the HttpRequestMessage object.</summary>
    /// <param name="Uri">The Uri to use for the HTTP request.</param>
    /// <remarks>The valued must not be a relative URI.</remarks>
    procedure SetRequestUri(Uri: Text)
    begin
        HttpRequestMessageImpl.SetRequestUri(Uri);
    end;

    /// <summary>Gets the Uri used for the HttpRequestMessage object.</summary>
    /// <returns>The Uri used for the HttpRequestMessage object.</returns>
    procedure GetRequestUri() Uri: Text
    begin
        Uri := HttpRequestMessageImpl.GetRequestUri();
    end;

    /// <summary>Sets a new value for an existing header of the Http Request object, or addds the header if it does not already exist.</summary>
    /// <param name="HeaderName">The name of the header to add.</param>
    /// <param name="HeaderValue">The value of the header to add.</param>
    procedure SetHeader(HeaderName: Text; HeaderValue: Text)
    begin
        HttpRequestMessageImpl.SetHeader(HeaderName, HeaderValue);
    end;

    /// <summary>Sets a new value for an existing header of the Http Request object, or addds the header if it does not already exist.</summary>
    /// <param name="HeaderName">The name of the header to add.</param>
    /// <param name="HeaderValue">The value of the header to add.</param>
    procedure SetHeader(HeaderName: Text; HeaderValue: SecretText)
    begin
        HttpRequestMessageImpl.SetHeader(HeaderName, HeaderValue);
    end;

    /// <summary>Sets the HttpRequestMessage that is represented by the HttpRequestMessage object.</summary>
    /// <param name="RequestMessage">The HttpRequestMessage to set.</param>
    procedure SetHttpRequestMessage(var RequestMessage: HttpRequestMessage)
    begin
        HttpRequestMessageImpl.SetHttpRequestMessage(RequestMessage);
    end;

    /// <summary>Gets the HttpRequestMessage that is represented by the HttpRequestMessage object.</summary>
    /// <returns>The HttpRequestMessage that is represented by the HttpRequestMessage object.</returns>
    procedure GetHttpRequestMessage() ReturnValue: HttpRequestMessage
    begin
        ReturnValue := HttpRequestMessageImpl.GetRequestMessage();
    end;

    /// <summary>Sets the content of the HttpRequestMessage that is represented by the HttpRequestMessage object.</summary>
    /// <param name="HttpContent">The Http Content object to set.</param>
    procedure SetContent(HttpContent: Codeunit "Http Content")
    begin
        HttpRequestMessageImpl.SetContent(HttpContent);
    end;
}