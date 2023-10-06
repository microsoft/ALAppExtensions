// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18051 "GST Dependency Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Bill-to Address")
    {
        Caption = 'Bill-to Address';
    }
    value(2; "Ship-to Address")
    {
        Caption = 'Ship-to Address';
    }
    value(3; "Location Address")
    {
        Caption = 'Location Address';
    }
}
