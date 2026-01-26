// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 11701 "VAT Report Amount Type CZL"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Base)
    {
        Caption = 'Base';
    }
    value(2; Amount)
    {
        Caption = 'Amount';
    }
    value(3; "Reduced Amount")
    {
        Caption = 'Reduced Amount';
    }
}