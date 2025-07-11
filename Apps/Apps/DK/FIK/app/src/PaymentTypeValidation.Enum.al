// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

enum 13620 "Payment Type Validation"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "FIK 71")
    {
        Caption = 'FIK 71';
    }
    value(2; "FIK 73")
    {
        Caption = 'FIK 73';
    }
    value(3; "FIK 01")
    {
        Caption = 'FIK 01';
    }
    value(4; "FIK 04")
    {
        Caption = 'FIK 04';
    }
    value(5; Domestic)
    {
        Caption = 'Domestic';
    }
    value(6; International)
    {
        Caption = 'International';
    }
}