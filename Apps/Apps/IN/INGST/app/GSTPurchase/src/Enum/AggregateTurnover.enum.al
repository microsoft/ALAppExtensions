// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

enum 18080 "Aggregate Turnover"
{
    Extensible = true;

    value(0; "More than 20 lakh")
    {
        Caption = 'More than 20 lakh';
    }
    value(1; "Less than 20 lakh")
    {
        Caption = 'Less than 20 lakh';
    }
}
