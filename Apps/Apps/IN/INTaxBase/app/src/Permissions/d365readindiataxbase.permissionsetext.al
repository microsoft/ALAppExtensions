// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using System.Security.AccessControl;

permissionsetextension 18548 "D365 READ - India Tax Base" extends "D365 READ"
{
    Permissions = tabledata "Assessee Code" = R,
                  tabledata "Concessional Code" = R,
                  tabledata "Deductor Category" = R,
                  tabledata "Gen. Journal Narration" = R,
                  tabledata Ministry = R,
                  tabledata Party = R,
                  tabledata "Posting No. Series" = RIMD,
                  tabledata State = R,
                  tabledata "TAN Nos." = R,
                  tabledata "Tax Accounting Period" = R;
}
