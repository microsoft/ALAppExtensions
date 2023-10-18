// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

enum 18083 "PAN Status"
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
    value(2; PANINVALID)
    {
        Caption = 'PANINVALID';
    }
    value(3; PANNOTAVBL)
    {
        Caption = 'PANNOTAVBL';
    }
}
