// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

enum 5579 "Digital Voucher Entry Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = '';
    }
    value(1; "Sales Document")
    {
        Caption = 'Sales Document';
    }
    value(2; "Purchase Document")
    {
        Caption = 'Purchase Document';
    }
    value(3; "General Journal")
    {
        Caption = 'General Journal';
    }
    value(4; "Sales Journal")
    {
        Caption = 'Sales Journal';
    }
    value(5; "Purchase Journal")
    {
        Caption = 'Purchase Journal';
    }
}
