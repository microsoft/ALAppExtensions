// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

enum 18284 NoteType
{
    value(0; Debit)
    {
        Caption = 'Debit';
    }
    value(1; Credit)
    {
        Caption = 'Credit';
    }
}
