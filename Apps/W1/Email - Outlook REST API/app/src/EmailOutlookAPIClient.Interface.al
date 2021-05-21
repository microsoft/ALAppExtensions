// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

interface "Email - Outlook API Client"
{
    procedure GetAccountInformation(AccessToken: Text; var Email: Text[250]; var Name: Text[250]): Boolean;
    procedure SendEmail(AccessToken: Text; MessageJson: JsonObject);
}