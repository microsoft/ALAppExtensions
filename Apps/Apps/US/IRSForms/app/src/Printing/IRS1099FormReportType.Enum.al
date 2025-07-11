// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10033 "IRS 1099 Form Report Type"
{
    AssignmentCompatibility = true;
    Extensible = true;


    value(1; "Copy B")
    {
        Caption = 'Copy B: goes to the recipient.';
    }
    value(2; "Copy C")
    {
        Caption = 'Copy C: stays with the employer for record keeping.';
    }
    value(3; "Copy 2")
    {
        Caption = 'Copy 2: goes to the recipient in some states.';
    }
}
