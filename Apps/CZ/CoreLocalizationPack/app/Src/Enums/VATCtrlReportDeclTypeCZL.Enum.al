// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 31004 "VAT Ctrl. Report Decl Type CZL"
{
    Extensible = true;

    value(0; Recapitulative)
    {
        Caption = 'Recapitulative';
    }
    value(1; "Recapitulative-Corrective")
    {
        Caption = 'Recapitulative-Corrective';
    }
    value(2; Supplementary)
    {
        Caption = 'Supplementary';
    }
    value(3; "Supplementary-Corrective")
    {
        Caption = 'Supplementary-Corrective';
    }
}
