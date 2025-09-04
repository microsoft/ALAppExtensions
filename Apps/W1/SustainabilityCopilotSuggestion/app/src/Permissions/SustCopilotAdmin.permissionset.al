// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability;

permissionset 6280 "Sust. Copilot Admin"
{
    Assignable = true;
    Caption = 'Sust. Copilot Admin';

    IncludedPermissionSets = "Sust. Copilot Edit", "Sustainability Admin";
}