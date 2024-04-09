// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.TCS.TCSReturnAndSettlement;

using System.Security.AccessControl;

permissionsetextension 18820 "D365 READ - India TCS" extends "D365 READ"
{
    Permissions = tabledata "Allowed NOC" = R,
                  tabledata "Customer Concessional Code" = R,
                  tabledata "Sales Line Buffer TCS On Pmt." = RIMD,
                  tabledata "T.C.A.N. No." = R,
                  tabledata "TCS Challan Register" = RIMD,
                  tabledata "TCS Entry" = R,
                  tabledata "TCS Journal Batch" = R,
                  tabledata "TCS Journal Line" = R,
                  tabledata "TCS Journal Template" = R,
                  tabledata "TCS Nature Of Collection" = R,
                  tabledata "TCS Posting Setup" = R,
                  tabledata "TCS Setup" = R;
}
