// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30145 "Shpfy Order Return Status"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Inspection Complete")
    {
        Caption = 'Inspection Complete';
    }
    value(2; "In Progress")
    {
        Caption = 'In Progress';
    }
    value(3; "No Return")
    {
        Caption = 'No Return';
    }
    value(4; "Returned")
    {
        Caption = 'Returned';
    }
    value(5; "Return Failed")
    {
        Caption = 'Return Failed';
    }
    value(6; "Return Requested")
    {
        Caption = 'Return Requested';
    }
}