// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

enum 6227 "Sust. Item Mat. Comp. Status"
{
    Caption = 'Item Material Composition Status';

    value(0; "New") { Caption = 'New'; }
    value(1; "Certified") { Caption = 'Certified'; }
    value(2; "Under Development") { Caption = 'Under Development'; }
    value(3; "Closed") { Caption = 'Closed'; }
}