// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10032 "IRS 1099 Print Value Type"
{
    AssignmentCompatibility = true;
    Extensible = true;

    value(0; Amount)
    {
        Caption = 'Amount';
    }
    value(1; "Yes/No")
    {
        Caption = 'Yes/No';
    }
}
