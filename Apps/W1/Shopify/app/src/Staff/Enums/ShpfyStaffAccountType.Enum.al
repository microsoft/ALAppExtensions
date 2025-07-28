// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Staff Account Type (ID 30168).
/// </summary>
enum 30168 "Shpfy Staff Account Type"
{
    Extensible = false;

    value(0; " ") { Caption = ' '; }
    value(1; "Collaborator") { Caption = 'Collaborator'; }
    value(2; "Collaborator Team Member") { Caption = 'Collaborator Team Member'; }
    value(3; "Invited") { Caption = 'Invited'; }
    value(4; "Invited Store Owner") { Caption = 'Invited Store Owner'; }
    value(5; "Regular") { Caption = 'Regular'; }
    value(6; "Requested") { Caption = 'Requested'; }
    value(7; "Restricted") { Caption = 'Restricted'; }
    value(8; "SAML") { Caption = 'SAML'; }
}