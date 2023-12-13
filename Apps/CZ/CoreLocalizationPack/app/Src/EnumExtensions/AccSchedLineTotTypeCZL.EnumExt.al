// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

enumextension 11702 "Acc. Sched. Line Tot. Type CZL" extends "Acc. Schedule Line Totaling Type"
{
    value(11701; "Custom CZL")
    {
        Caption = 'Custom';
    }
    value(11702; "Constant CZL")
    {
        Caption = 'Constant';
    }
}
