// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 31001 "VAT Ctrl. Report Corect. CZL"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; "Insolvency Proceedings (p.44)")
    {
        Caption = 'Insolvency Proceedings (p.44)';
    }
    value(2; "Bad Receivable (p.46 resp. 74a)")
    {
        Caption = 'Bad Receivable (p.46 resp. 74a)';
    }
}
