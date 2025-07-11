// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

using System.Security.AccessControl;

permissionsetextension 24718 "D365 READ - C5 2012 Data Migration" extends "D365 READ"
{
    Permissions = tabledata "C5 Centre" = R,
                  tabledata "C5 CN8Code" = R,
                  tabledata "C5 Country" = R,
                  tabledata "C5 CustContact" = R,
                  tabledata "C5 CustDiscGroup" = R,
                  tabledata "C5 CustGroup" = R,
                  tabledata "C5 CustTable" = R,
                  tabledata "C5 CustTrans" = R,
                  tabledata "C5 Data Loader Status" = R,
                  tabledata "C5 Delivery" = R,
                  tabledata "C5 Department" = R,
                  tabledata "C5 Employee" = R,
                  tabledata "C5 ExchRate" = R,
                  tabledata "C5 InvenBOM" = R,
                  tabledata "C5 InvenCustDisc" = R,
                  tabledata "C5 InvenDiscGroup" = R,
                  tabledata "C5 InvenItemGroup" = R,
                  tabledata "C5 InvenLocation" = R,
                  tabledata "C5 InvenPrice" = R,
                  tabledata "C5 InvenPriceGroup" = R,
                  tabledata "C5 InvenTable" = R,
                  tabledata "C5 InvenTrans" = R,
                  tabledata "C5 ItemTrackGroup" = R,
                  tabledata "C5 LedTable" = R,
                  tabledata "C5 LedTrans" = R,
                  tabledata "C5 Payment" = R,
                  tabledata "C5 ProcCode" = R,
                  tabledata "C5 Purpose" = R,
                  tabledata "C5 Schema Parameters" = R,
                  tabledata "C5 UnitCode" = R,
                  tabledata "C5 VatGroup" = R,
                  tabledata "C5 VendContact" = R,
                  tabledata "C5 VendDiscGroup" = R,
                  tabledata "C5 VendGroup" = R,
                  tabledata "C5 VendTable" = R,
                  tabledata "C5 VendTrans" = R;
}
