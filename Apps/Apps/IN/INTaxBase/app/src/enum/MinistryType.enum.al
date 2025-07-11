// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

enum 18545 "Ministry Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = 'None';
    }
    value(1; Regular)
    {
        Caption = 'Regular';
    }
    value(2; Others)
    {
        Caption = 'Others';
    }
}
