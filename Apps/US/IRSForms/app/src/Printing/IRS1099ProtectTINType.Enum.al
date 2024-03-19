// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10036 "IRS 1099 Protect TIN Type"
{
    AssignmentCompatibility = true;
    Extensible = true;

    value(0; "None")
    {
        Caption = 'None';
    }
    value(1; "Protect TIN For Vendors")
    {
        Caption = 'Protect TIN For Vendors';
    }
    value(2; "Protect TIN For Vendors and Company")
    {
        Caption = 'Protect TIN For Vendors and Company';
    }
}
