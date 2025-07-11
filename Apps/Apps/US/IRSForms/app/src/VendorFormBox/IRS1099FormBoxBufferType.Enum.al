// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10035 "IRS 1099 Form Box Buffer Type"
{
    AssignmentCompatibility = true;
    Extensible = true;


    value(0; Amount)
    {
    }
    value(1; "Ledger Entry")
    {
    }
}
