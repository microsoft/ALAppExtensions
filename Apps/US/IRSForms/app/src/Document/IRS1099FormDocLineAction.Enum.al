// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10042 "IRS 1099 Form Doc. Line Action"
{
    AssignmentCompatibility = true;
    Extensible = true;

    value(0; "Create") { }
    value(1; "Update") { }
    value(2; "Abandon") { }
}
