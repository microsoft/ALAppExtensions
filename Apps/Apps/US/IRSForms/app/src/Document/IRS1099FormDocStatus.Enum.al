// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10030 "IRS 1099 Form Doc. Status"
{
    AssignmentCompatibility = true;
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Released)
    {
        Caption = 'Released';
    }
    value(2; Submitted)
    {
        Caption = 'Submitted';
    }
}
