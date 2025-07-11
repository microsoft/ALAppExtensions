// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18040 "Payment Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Advance)
    {
        Caption = 'Advance';
    }
    value(2; Normal)
    {
        Caption = 'Normal';
    }
}
