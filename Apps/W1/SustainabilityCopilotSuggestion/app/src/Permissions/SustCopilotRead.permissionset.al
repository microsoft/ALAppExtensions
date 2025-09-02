// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

permissionset 6283 "Sust. Copilot Read"
{
    Caption = 'Sust. Copilot Read';
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "Sust. Copilot Objects";

    Permissions =
        tabledata "Emission Source Setup" = R,
        tabledata "Source CO2 Emission" = R,
        tabledata "Source CO2 Emission Buffer" = R,
        tabledata "Sustain. Emission Suggestion" = R,
        tabledata "Sust. Formula Buffer" = R;
}