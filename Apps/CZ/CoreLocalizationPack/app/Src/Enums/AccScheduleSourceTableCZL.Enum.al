// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

enum 11726 "Acc. Schedule Source Table CZL"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; "VAT Entry")
    {
        Caption = 'VAT Entry';
    }
    value(2; "Value Entry")
    {
        Caption = 'Value Entry';
    }
    value(3; "Customer Entry")
    {
        Caption = 'Customer Entry';
    }
    value(4; "Vendor Entry")
    {
        Caption = 'Vendor Entry';
    }
}
