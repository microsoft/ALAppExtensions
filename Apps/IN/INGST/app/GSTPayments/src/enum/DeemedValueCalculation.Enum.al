// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

enum 18243 "Deemed Value Calculation"
{
    Extensible = true;
    value(0; "Deemed %")
    {
        Caption = 'Deemed %';
    }
    value(1; "Fixed")
    {
        Caption = 'Fixed';
    }
    value(2; Comparative)
    {
        Caption = 'Comparative';
    }
    value(3; "Fixed + Deemed %")
    {
        Caption = 'Fixed + Deemed %';
    }
    value(4; "Fixed + Comparative")
    {
        Caption = 'Fixed + Comparative';
    }
}
