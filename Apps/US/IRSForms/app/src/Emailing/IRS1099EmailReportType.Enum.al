// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10034 "IRS 1099 Email Report Type"
{
    AssignmentCompatibility = true;
    Extensible = true;

    value(1; "Copy B")
    {
        Caption = 'Copy B';
    }
    value(3; "Copy 2")
    {
        Caption = 'Copy 2';
    }
}
