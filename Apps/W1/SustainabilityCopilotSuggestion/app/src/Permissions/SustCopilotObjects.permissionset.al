// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

permissionset 6282 "Sust. Copilot Objects"
{
    Caption = 'Sust. Copilot Objects';
    Access = Internal;
    Assignable = false;

    Permissions =
        table "Emission Source Setup" = X,
        table "Source CO2 Emission" = X,
        table "Source CO2 Emission Buffer" = X,
        table "Sustain. Emission Suggestion" = X,
        table "Sust. Formula Buffer" = X,
        page "Emission Source Setup" = X,
        page "Source CO2 Emission List" = X,
        page "Sustain. Emission Suggestion" = X,
        page "Sust. Emis. Suggestion List" = X,
        page "Sust. Emis. Suggestion Subpage" = X;
}