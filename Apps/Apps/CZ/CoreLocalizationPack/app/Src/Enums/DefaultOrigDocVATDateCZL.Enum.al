// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

enum 11781 "Default Orig.Doc. VAT Date CZL"
{
    Extensible = true;

    value(0; "Blank")
    {
        Caption = 'Blank';
    }
    value(1; "Posting Date")
    {
        Caption = 'Posting Date';
    }
    value(2; "VAT Date")
    {
        Caption = 'VAT Date';
    }
    value(3; "Document Date")
    {
        Caption = 'Document Date';
    }
}
