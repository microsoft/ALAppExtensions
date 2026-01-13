// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.Authentication;

controladdin OAuthAddIn
{
    Scripts = 'src\oauth\js\OAuthIntegration.js';

    procedure StartAuthorization(url: Text);
    event AuthorizationCodeRetrieved(code: Text);
    event AuthorizationErrorOccurred(error: Text; desc: Text);
    event ControlAddInReady();
}
