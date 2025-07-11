// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Payroll;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 13641 "DK General Journal" extends "General Journal"
{
    actions
    {
        modify(ImportPayrollFile)
        {
            Visible = True;
        }
    }
}
