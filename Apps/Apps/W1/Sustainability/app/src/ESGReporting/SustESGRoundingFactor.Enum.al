// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

enum 6223 "Sust. ESG Rounding Factor"
{
    Caption = 'Rounding Factor';
    AssignmentCompatibility = true;
    Extensible = true;

    value(0; "None") { Caption = 'None'; }
    value(1; "1") { Caption = '1'; }
}