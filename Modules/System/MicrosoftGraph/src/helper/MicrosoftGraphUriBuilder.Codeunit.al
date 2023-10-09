// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9352 "Microsoft Graph Uri Builder"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Uri: Codeunit Uri;
        MicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version";
        BaseUriLbl: Label 'https://graph.microsoft.com/%1/', Comment = '%1 = Graph API Version', Locked = true;


    procedure Initialize(NewMicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version"; RelativeUriToResource: Text)
    var
        QueryParameters: Dictionary of [Text, Text];
    begin
        Initialize(NewMicrosoftGraphAPIVersion, RelativeUriToResource, QueryParameters);
    end;

    procedure Initialize(NewMicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version"; RelativeUriToResource: Text; QueryParameters: Dictionary of [Text, Text])
    var
        UriBuilder: Codeunit "Uri Builder";
        BaseUri: Text;
        CombinedUri: Text;
        QueryParameterKey: Text;
    begin
        MicrosoftGraphAPIVersion := NewMicrosoftGraphAPIVersion;

        BaseUri := StrSubstNo(BaseUriLbl, Format(MicrosoftGraphAPIVersion));
        CombinedUri := CombineUri(BaseUri, RelativeUriToResource);
        Uri.Init(CombinedUri);
        UriBuilder.Init(Uri.GetAbsoluteUri());
        foreach QueryParameterKey in QueryParameters.Keys() do
            UriBuilder.AddQueryParameter(QueryParameterKey, QueryParameters.Get(QueryParameterKey));
    end;


    procedure GetUri(): Text
    begin
        exit(Uri.GetAbsoluteUri())
    end;

    local procedure CombineUri(BaseUri: Text; RelativeUriToResource: Text) CombinedUrl: Text
    var
        UrlCombineTxt: Label '%1/%2', Comment = '%1 = BaseUrl, %2 = relative url to resource', Locked = true;
    begin
        BaseUri := BaseUri.TrimEnd('/');
        RelativeUriToResource := RelativeUriToResource.TrimStart('/');
        CombinedUrl := StrSubstNo(UrlCombineTxt, BaseUri, RelativeUriToResource);
    end;
}