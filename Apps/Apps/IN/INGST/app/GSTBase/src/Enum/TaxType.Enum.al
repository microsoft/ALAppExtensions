// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18047 "Tax Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Sales Tax")
    {
        Caption = 'Sales Tax';
    }
    value(2; Excise)
    {
        Caption = 'Excise';
    }
    value(3; "Service Tax")
    {
        Caption = 'Service Tax';
    }
    value(4; "GST Credit")
    {
        Caption = 'GST Credit';
    }
    value(5; "GST Liability")
    {
        Caption = 'GST Liability';
    }
    value(6; "GST TDS Credit")
    {
        Caption = 'GST TDS Credit';
    }
    value(7; "GST TCS Credit")
    {
        Caption = 'GST TCS Credit';
    }
}
