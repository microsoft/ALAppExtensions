// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

enum 18551 "Cust Aggregate Turnover"
{
    Extensible = true;
    value(0; "Less than 10 Crores")
    {
        Caption = 'Less than 10 Crores';
    }
    value(1; "More than 10 Crores")
    {
        Caption = 'More than 10 Crores';
    }
}
