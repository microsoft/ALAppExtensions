// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18033 "GST Reason Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Sales Return")
    {
        Caption = 'Sales Return';
    }
    value(2; "Post Sale Discount")
    {
        Caption = 'Post Sale Discount';
    }
    value(3; "Deficiency in Service")
    {
        Caption = 'Deficiency in Service';
    }
    value(4; "Correction in Invoice")
    {
        Caption = 'Correction in Invoice';
    }
    value(5; "Change in POS")
    {
        Caption = 'Change in POS';
    }
    value(6; "Finalization of Provisional Assessment")
    {
        Caption = 'Finalization of Provisional Assessment';
    }
    value(7; Others)
    {
        Caption = 'Others';
    }
}
