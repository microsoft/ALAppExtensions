#if not CLEAN24
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

interface "Email - Outlook API Client"
{
    ObsoleteReason = 'Replaced by "Email - Outlook API Client" with SecretText data type for AccessToken parameters';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';

    procedure GetAccountInformation(AccessToken: Text; var Email: Text[250]; var Name: Text[250]): Boolean;
    procedure SendEmail(AccessToken: Text; MessageJson: JsonObject);
}
#endif