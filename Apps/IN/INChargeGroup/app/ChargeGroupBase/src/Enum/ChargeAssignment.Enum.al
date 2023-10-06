// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

enum 18503 "Charge Assignment"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Equally)
    {
        Caption = 'Equally';
    }
    value(2; "By Amount")
    {
        Caption = 'By Amount';
    }
    value(3; "By Weight")
    {
        Caption = 'By Weight';
    }
    value(4; "By Volume")
    {
        Caption = 'By Volume';
    }
}
