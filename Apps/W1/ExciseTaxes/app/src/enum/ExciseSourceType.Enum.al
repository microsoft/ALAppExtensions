// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

enum 7413 "Excise Source Type"
{
    Caption = 'Excise Source Type';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Item)
    {
        Caption = 'Item';
    }
    value(2; "Fixed Asset")
    {
        Caption = 'Fixed Asset';
    }
}