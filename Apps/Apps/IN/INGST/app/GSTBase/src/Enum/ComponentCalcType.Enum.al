// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18006 "Component Calc Type"
{
    value(0; General)
    {
        Caption = 'General';
    }
    value(1; Threshold)
    {
        Caption = 'Threshold';
    }
    value(2; "Cess %")
    {
        Caption = 'Cess %';
    }
    value(3; "Cess % + Amount / Unit Factor")
    {
        Caption = 'Cess % + Amount / Unit Factor';
    }
    value(4; "Cess % Or Amount / Unit Factor Whichever Higher")
    {
        Caption = 'Cess % Or Amount / Unit Factor Whichever Higher';
    }
    value(5; "Amount / Unit Factor")
    {
        Caption = 'Amount / Unit Factor';
    }
}
