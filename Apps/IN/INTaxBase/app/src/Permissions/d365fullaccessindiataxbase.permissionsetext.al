// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using System.Security.AccessControl;

permissionsetextension 18547 "D365 FULL ACCESS - India Tax Base" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "Assessee Code" = RIMD,
                  tabledata "Concessional Code" = RIMD,
                  tabledata "Deductor Category" = RIMD,
                  tabledata "Gen. Journal Narration" = RIMD,
                  tabledata Ministry = RIMD,
                  tabledata Party = RIMD,
                  tabledata "Posting No. Series" = RIMD,
                  tabledata State = RIMD,
                  tabledata "TAN Nos." = RIMD,
                  tabledata "Tax Accounting Period" = RIMD;
}
