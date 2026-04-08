// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.PayablesAgent;

using Microsoft.EServices.EDocumentConnector.Microsoft365;
using System.Email;

permissionset 3304 "Payables Ag. - Adm."
{
    Caption = 'Payables Agent - Administration', Comment = 'Payables Agent is a term, and should not be translated.';
    Assignable = true;
    IncludedPermissionSets =
        "Payables Ag. - Read",
        "Email - Admin",
        M365EDocConnEdit;
    Permissions = tabledata "Payables Agent Setup" = IM;
}