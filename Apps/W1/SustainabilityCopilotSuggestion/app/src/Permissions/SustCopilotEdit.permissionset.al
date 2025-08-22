// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

permissionset 6281 "Sust. Copilot Edit"
{
    Assignable = true;
    Caption = 'Sust. Copilot Edit';

    IncludedPermissionSets = "Sust. Copilot Read";

    Permissions =
        tabledata "Emission Source Setup" = IMD,
        tabledata "Source CO2 Emission" = IMD,
        tabledata "Source CO2 Emission Buffer" = IMD,
        tabledata "Sustain. Emission Suggestion" = IMD,
        tabledata "Sust. Formula Buffer" = IMD;
}