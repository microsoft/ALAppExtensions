// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

enum 11780 "Default VAT Date CZL"
{
    Extensible = true;
    Access = Internal;

    value(0; "Posting Date")
    {
        Caption = 'Posting Date';
    }
    value(1; "Document Date")
    {
        Caption = 'Document Date';
    }
    value(2; Blank)
    {
        Caption = 'Blank';
    }
}
