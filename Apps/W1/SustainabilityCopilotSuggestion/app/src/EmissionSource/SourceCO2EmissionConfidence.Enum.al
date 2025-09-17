// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

enum 6292 "Source CO2 Emission Confidence"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "None") { Caption = 'None'; }
    value(1; "Low") { Caption = 'Low'; }
    value(2; "Medium") { Caption = 'Medium'; }
    value(3; "High") { Caption = 'High'; }
}