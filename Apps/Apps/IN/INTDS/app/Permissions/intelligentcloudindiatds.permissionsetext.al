// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS;

using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.TDS.TDSForCustomer;
using Microsoft.Finance.TDS.TDSOnPayments;
using Microsoft.Finance.TDS.TDSReturnAndSettlement;

using System.Security.AccessControl;

permissionsetextension 18669 "INTELLIGENT CLOUD - India TDS" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "Acknowledgement Setup" = RIMD,
                  tabledata "Act Applicable" = RIMD,
                  tabledata "Allowed Sections" = RIMD,
                  tabledata "Customer Allowed Sections" = RIMD,
                  tabledata "Provisional Entry" = RIMD,
                  tabledata "TDS Challan Register" = RIMD,
                  tabledata "TDS Concessional Code" = RIMD,
                  tabledata "TDS Customer Concessional Code" = RIMD,
                  tabledata "TDS Entry" = RIMD,
                  tabledata "TDS Journal Batch" = RIMD,
                  tabledata "TDS Journal Line" = RIMD,
                  tabledata "TDS Journal Template" = RIMD,
                  tabledata "TDS Nature Of Remittance" = RIMD,
                  tabledata "TDS Posting Setup" = RIMD,
                  tabledata "TDS Section" = RIMD,
                  tabledata "TDS Setup" = RIMD;
}
