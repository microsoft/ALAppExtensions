// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

interface "Email - Outlook API Client v2"
{
    procedure GetAccountInformation(AccessToken: SecretText; var Email: Text[250]; var Name: Text[250]): Boolean;
    procedure SendEmail(AccessToken: SecretText; MessageJson: JsonObject);
}