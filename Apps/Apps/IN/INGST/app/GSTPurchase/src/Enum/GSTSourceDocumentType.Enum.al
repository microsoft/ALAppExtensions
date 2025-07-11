// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

enum 18082 "GST Source Document Type"
{
    Extensible = true;

    value(0; "Posted Invoice")
    {
        Caption = 'Posted Invoice';
    }
    value(1; "Posted Credit Memo")
    {
        Caption = 'Posted Credit Memo';
    }
}
