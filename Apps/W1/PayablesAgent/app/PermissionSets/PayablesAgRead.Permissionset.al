// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

permissionset 3305 "Payables Ag. - Read"
{
    Caption = 'Payables Agent - Read', Comment = 'Payables Agent is a term, and should not be translated.';
    Assignable = true;
    Permissions = tabledata "Payables Agent Setup" = R;
}