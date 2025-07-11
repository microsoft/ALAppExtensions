// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.TCS.TCSReturnAndSettlement;

using System.Security.AccessControl;

permissionsetextension 18808 "D365 BUS FULL ACCESS - India TCS" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "Allowed NOC" = RIMD,
                  tabledata "Customer Concessional Code" = RIMD,
                  tabledata "Sales Line Buffer TCS On Pmt." = RIMD,
                  tabledata "T.C.A.N. No." = RIMD,
                  tabledata "TCS Challan Register" = RIMD,
                  tabledata "TCS Entry" = RIMD,
                  tabledata "TCS Journal Batch" = RIMD,
                  tabledata "TCS Journal Line" = RIMD,
                  tabledata "TCS Journal Template" = RIMD,
                  tabledata "TCS Nature Of Collection" = RIMD,
                  tabledata "TCS Posting Setup" = RIMD,
                  tabledata "TCS Setup" = RIMD;
}
