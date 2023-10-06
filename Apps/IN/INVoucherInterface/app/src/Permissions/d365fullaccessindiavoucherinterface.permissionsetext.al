// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using System.Security.AccessControl;

permissionsetextension 18933 "D365 FULL ACCESS - India Voucher Interface" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "Journal Voucher Posting Setup" = RIMD,
                  tabledata "Posted Narration" = RIMD,
                  tabledata "Voucher Posting Credit Account" = RIMD,
                  tabledata "Voucher Posting Debit Account" = RIMD;
}
