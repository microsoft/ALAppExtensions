// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18007 "Composition Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Retailer)
    {
        Caption = 'Retailer';
    }
    value(2; "Works Contract")
    {
        Caption = 'Works Contract';
    }
    value(3; Bakery)
    {
        Caption = 'Bakery';
    }
    value(4; "Restaurant / Club")
    {
        Caption = 'Restaurant / Club';
    }
    value(5; "Second Hand Motor Vehicle")
    {
        Caption = 'Second Hand Motor Vehicle';
    }
}
