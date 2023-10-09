// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9132 "Microsoft Graph Uri Builder"
{
    Access = Internal;

    var
        Uri: Codeunit Uri;
        MicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version";
        BaseUriLbl: Label 'https://graph.microsoft.com/%1/', Comment = '%1 = Graph API Version', Locked = true;
        Namespace,
        ServerName : Text;

    procedure Initialize(NewMicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version"; RelativeUriToResource: Text)
    var
        BaseUri: Text;
        CombinedUri: Text;
    begin
        MicrosoftGraphAPIVersion := NewMicrosoftGraphAPIVersion;

        BaseUri := StrSubstNo(BaseUriLbl, Format(MicrosoftGraphAPIVersion));
        CombinedUri := CombineUri(BaseUri, RelativeUriToResource);
        Uri.Init(CombinedUri);
    end;


    procedure GetUri(): Text
    begin
        exit(Uri.GetAbsoluteUri())
    end;

    local procedure CombineUri(BaseUri: Text; RelativeUriToResource: Text) CombinedUrl: Text
    var
        UrlCombineTxt: Label '%1/%2', Comment = '%1 = BaseUrl, %2 = relative url to resource', Locked = true;
    begin
        RelativeUriToResource := RelativeUriToResource.TrimStart('/');
        CombinedUrl := StrSubstNo(UrlCombineTxt, BaseUri, RelativeUriToResource);
    end;
}