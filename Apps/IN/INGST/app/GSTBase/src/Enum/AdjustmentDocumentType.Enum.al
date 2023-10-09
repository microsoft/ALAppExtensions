// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18000 "Adjustment Document Type"
{
    value(0; Invoice)
    {
        Caption = 'Invoice';
    }
    value(1; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
}
