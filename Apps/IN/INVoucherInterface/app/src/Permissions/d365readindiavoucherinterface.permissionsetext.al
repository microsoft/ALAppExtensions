// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using System.Security.AccessControl;

permissionsetextension 18934 "D365 READ - India Voucher Interface" extends "D365 READ"
{
    Permissions = tabledata "Journal Voucher Posting Setup" = R,
                  tabledata "Posted Narration" = R,
                  tabledata "Voucher Posting Credit Account" = R,
                  tabledata "Voucher Posting Debit Account" = R;
}
