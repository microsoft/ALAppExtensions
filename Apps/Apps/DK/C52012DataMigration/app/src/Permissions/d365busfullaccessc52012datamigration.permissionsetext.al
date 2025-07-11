// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

using System.Security.AccessControl;

permissionsetextension 25311 "D365 BUS FULL ACCESS - C5 2012 Data Migration" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "C5 Centre" = RIMD,
                  tabledata "C5 CN8Code" = RIMD,
                  tabledata "C5 Country" = RIMD,
                  tabledata "C5 CustContact" = RIMD,
                  tabledata "C5 CustDiscGroup" = RIMD,
                  tabledata "C5 CustGroup" = RIMD,
                  tabledata "C5 CustTable" = RIMD,
                  tabledata "C5 CustTrans" = RIMD,
                  tabledata "C5 Data Loader Status" = RIMD,
                  tabledata "C5 Delivery" = RIMD,
                  tabledata "C5 Department" = RIMD,
                  tabledata "C5 Employee" = RIMD,
                  tabledata "C5 ExchRate" = RIMD,
                  tabledata "C5 InvenBOM" = RIMD,
                  tabledata "C5 InvenCustDisc" = RIMD,
                  tabledata "C5 InvenDiscGroup" = RIMD,
                  tabledata "C5 InvenItemGroup" = RIMD,
                  tabledata "C5 InvenLocation" = RIMD,
                  tabledata "C5 InvenPrice" = RIMD,
                  tabledata "C5 InvenPriceGroup" = RIMD,
                  tabledata "C5 InvenTable" = RIMD,
                  tabledata "C5 InvenTrans" = RIMD,
                  tabledata "C5 ItemTrackGroup" = RIMD,
                  tabledata "C5 LedTable" = RIMD,
                  tabledata "C5 LedTrans" = RIMD,
                  tabledata "C5 Payment" = RIMD,
                  tabledata "C5 ProcCode" = RIMD,
                  tabledata "C5 Purpose" = RIMD,
                  tabledata "C5 Schema Parameters" = RIMD,
                  tabledata "C5 UnitCode" = RIMD,
                  tabledata "C5 VatGroup" = RIMD,
                  tabledata "C5 VendContact" = RIMD,
                  tabledata "C5 VendDiscGroup" = RIMD,
                  tabledata "C5 VendGroup" = RIMD,
                  tabledata "C5 VendTable" = RIMD,
                  tabledata "C5 VendTrans" = RIMD;
}
