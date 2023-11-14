// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

enum 11721 "Assets Liabilities Type CZL"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Assets)
    {
        Caption = 'Assets';
    }
    value(2; Liabilities)
    {
        Caption = 'Liabilities';
    }
}
