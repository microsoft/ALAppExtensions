// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// provides functionality for feature management
/// </summary>
codeunit 2610 "Feature Management Impl."
{
    Access = Internal;

    /// <summary>
    /// Gets the url to let users try out a feature
    /// <param name=FeatureKey>The feature key for the feature to try</param>
    /// </summary>
    procedure GetFeatureKeyUrlForWeb(FeatureKey: Text[50]): Text
    var
        DotNetUriBuilder: DotNet UriBuilder;
        DotNetUri: DotNet Uri;
        QueryString: Text;
        ClientUrl: Text;
        QueryStringLbl: Label '%1&%2', Comment = '%1 - Query string, %2 - Preview feature parameter', Locked = true;
    begin
        ClientUrl := GetUrl(ClientType::Web);
        DotNetUriBuilder := DotNetUriBuilder.UriBuilder(ClientUrl);
        QueryString := DotNetUriBuilder.Query();

        QueryString := DelChr(QueryString, '<', '?');
        if StrLen(QueryString) > 0 then
            QueryString := StrSubstNo(QueryStringLbl,
                QueryString,
                StrSubstNo(PreviewFeatureParameterTxt, DotNetUri.EscapeDataString(FeatureKey)))
        else
            QueryString := StrSubstNo(PreviewFeatureParameterTxt, DotNetUri.EscapeDataString(FeatureKey));

        DotNetUriBuilder.Query := QueryString;
        DotNetUri := DotNetUriBuilder.Uri();
        exit(DotNetUri.AbsoluteUri());
    end;

    /// <summary>
    /// Sends a notification to ask user to sign out and sign in again to make the changes take effect
    /// </summary>
    procedure SendSignInAgainNotification()
    var
        SignInAgainNotification: Notification;
    begin
        SignInAgainNotification.Id := SignInAgainNotificationGuidTok;
        SignInAgainNotification.Message := SignInAgainMsg;
        SignInAgainNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        SignInAgainNotification.Send();
    end;

    var
        SignInAgainMsg: Label 'You must sign out and then sign in again to make the changes take effect.', Comment = '"sign out" and "sign in" are the same terms as shown in the Business Central client.';
        SignInAgainNotificationGuidTok: Label '63b6f5ec-6db4-4e87-b103-c4bcb539f09e', Locked = true;
        PreviewFeatureParameterTxt: Label 'previewfeatures=%1', Comment = '%1 = the feature ID for the feature to be previewed', Locked = true;
}