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

permissionsetextension 18667 "D365 READ - India TDS" extends "D365 READ"
{
    Permissions = tabledata "Acknowledgement Setup" = R,
                  tabledata "Act Applicable" = R,
                  tabledata "Allowed Sections" = R,
                  tabledata "Customer Allowed Sections" = R,
                  tabledata "Provisional Entry" = R,
                  tabledata "TDS Challan Register" = R,
                  tabledata "TDS Concessional Code" = R,
                  tabledata "TDS Customer Concessional Code" = R,
                  tabledata "TDS Entry" = R,
                  tabledata "TDS Journal Batch" = R,
                  tabledata "TDS Journal Line" = R,
                  tabledata "TDS Journal Template" = R,
                  tabledata "TDS Nature Of Remittance" = R,
                  tabledata "TDS Posting Setup" = R,
                  tabledata "TDS Section" = R,
                  tabledata "TDS Setup" = R;
}
