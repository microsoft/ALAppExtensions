// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 11700 "VAT Report Type CZL"
{
    Extensible = true;

    value(0; Normal)
    {
        Caption = 'Normal';
    }
    value(1; Corrective)
    {

        Caption = 'Corrective';
    }
    value(2; "Supplementary")
    {
        Caption = 'Supplementary';
    }
}