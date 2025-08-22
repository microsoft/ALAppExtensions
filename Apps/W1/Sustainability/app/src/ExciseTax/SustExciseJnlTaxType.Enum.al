// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

enum 6226 "Sust. Excise Jnl. Tax Type"
{
    Extensible = true;

    value(0; CBAM)
    {
        Caption = 'CBAM';
    }
    value(1; EPR)
    {
        Caption = 'EPR';
    }
    value(2; Excises)
    {
        Caption = 'Excises';
    }
}