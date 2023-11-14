// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

enum 31241 "FA Analysis Period CZF"
{
    Extensible = false;

    value(0; "Before Starting Date")
    {
        Caption = 'Before Starting Date';
    }
    value(1; "Net Change")
    {
        Caption = 'Net Change';
    }
    value(2; "At Ending Date")
    {
        Caption = 'At Ending Date';
    }
}
