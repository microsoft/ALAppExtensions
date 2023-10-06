// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

enum 18546 "P.A.N.Status"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; PANAPPLIED)
    {
        Caption = 'PANAPPLIED';
    }
    value(2; PANNOTAVBL)
    {
        Caption = 'PANNOTAVBL';
    }
    value(3; PANINVALID)
    {
        Caption = 'PANINVALID';
    }
}
