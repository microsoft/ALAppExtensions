// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9032 "Microsoft Graph Uri Builder"
{
    Access = Internal;

    var
        ServerName, Namespace : Text;
        Uri: Codeunit Uri;
        MicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version";
        BaseUriLbl: Label 'https://graph.microsoft.com/%1/', Comment = '%1 = Graph API Version', Locked = true;

    procedure Initialize(NewMicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version"; RelativeUrlToResource: Text)
    var
        BaseUrl: Text;
        CombinedUrl: Text;
        UrlCombineTxt: Label '%1/%2', Comment = '%1 = BaseUrl, %2 = relative url to resource';
    begin
        MicrosoftGraphAPIVersion := NewMicrosoftGraphAPIVersion;
        BaseUrl := StrSubstNo(BaseUriLbl, Format(MicrosoftGraphAPIVersion));
        RelativeUrlToResource := RelativeUrlToResource.TrimStart('/');
        CombinedUrl := StrSubstNo(BaseUrl, RelativeUrlToResource);
        Uri.Init(CombinedUrl);
    end;


    procedure GetUri(): Text
    begin
        exit(Uri.GetAbsoluteUri())
    end;


}