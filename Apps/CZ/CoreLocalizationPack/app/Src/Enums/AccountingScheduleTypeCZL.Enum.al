// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

enum 11719 "Accounting Schedule Type CZL"
{
    Extensible = true;

    value(0; "Standard")
    {
        Caption = 'Standard';
    }
    value(1; "Balance Sheet")
    {
        Caption = 'Balance Sheet';
    }
    value(2; "Income Statement")
    {
        Caption = 'Income Statement';
    }
}
