// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 31002 "VAT Ctrl. Report Mode CZL"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; "par. 89")
    {
        Caption = 'Paragraph 89';
    }
    value(2; "par. 90")
    {
        Caption = 'Paragraph 90';
    }
}
