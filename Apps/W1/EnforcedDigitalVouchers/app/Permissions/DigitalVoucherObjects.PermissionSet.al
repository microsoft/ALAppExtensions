// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

permissionset 5583 "Digital Voucher - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "Digital Voucher Entry Setup" = X,
                  table "Digital Voucher Setup" = X,
                  table "Voucher Entry Source Code" = X,
                  page "Digital Voucher Entry Setup" = X,
                  page "Digital Voucher Setup" = X,
                  page "Digital Voucher Guide" = X,
                  page "Voucher Entry Source Codes" = X,
                  codeunit "Voucher Attach Or Note Check" = X,
                  codeunit "Voucher Attachment Check" = X,
                  codeunit "Voucher No Check" = X,
                  codeunit "Voucher Unknown Check" = X,
                  codeunit "Digital Voucher Impl." = X,
                  codeunit "Digital Voucher Feature" = X,
                  codeunit "Digital Voucher Entry" = X;
}
