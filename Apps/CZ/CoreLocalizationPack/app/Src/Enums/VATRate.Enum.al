// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

enum 31003 "VAT Rate CZL"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Base)
    {
        Caption = 'Base';
    }
    value(2; Reduced)
    {
        Caption = 'Reduced';
    }
    value(3; "Reduced 2")
    {
        Caption = 'Reduced 2';
    }
}
