// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

enum 31243 "FA Analysis Disposal CZF"
{
    Extensible = false;

    value(0; " ")
    {
    }
    value(1; Disposal)
    {
        Caption = 'Disposal';
    }
    value(2; "Bal. Disposal")
    {
        Caption = 'Bal. Disposal';
    }
}
