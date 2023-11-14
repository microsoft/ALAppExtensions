// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

enum 31252 "Multiple Search Result CZB"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; "First Created Entry")
    {
        Caption = 'First Created Entry';
    }
    value(2; "Last Created Entry")
    {
        Caption = 'Last Created Entry';
    }
    value(3; "Earliest Due Date")
    {
        Caption = 'Earliest Due Date';
    }
    value(4; "Latest Due Date")
    {
        Caption = 'Latest Due Date';
    }
    value(5; "Earliest Posting Date")
    {
        Caption = 'Earliest Posting Date';
    }
    value(6; "Latest Posting Date")
    {
        Caption = 'Latest Posting Date';
    }
    value(7; "Smallest Remaining Amount")
    {
        Caption = 'Smallest Remaining Amount';
    }
    value(8; "Greatest Remaining Amount")
    {
        Caption = 'Greatest Remaining Amount';
    }
    value(9; Continue)
    {
        Caption = 'Continue';
    }
}
