// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

permissionset 6610 "FS - Edit"
{
    Access = Internal;
    Assignable = false;
    Caption = 'Field Service - Edit';

    IncludedPermissionSets = "FS - Read";

    Permissions = tabledata "FS Connection Setup" = IMD,
                  tabledata "FS Bookable Resource" = IMD,
                  tabledata "FS Bookable Resource Booking" = IMD,
                  tabledata "FS BookableResourceBookingHdr" = IMD,
                  tabledata "FS Booking Status" = IMD,
                  tabledata "FS Customer Asset" = IMD,
                  tabledata "FS Customer Asset Category" = IMD,
                  tabledata "FS Incident Type" = IMD,
                  tabledata "FS Project Task" = IMD,
                  tabledata "FS Resource Pay Type" = IMD,
                  tabledata "FS Warehouse" = IMD,
                  tabledata "FS Work Order" = IMD,
                  tabledata "FS Work Order Incident" = IMD,
                  tabledata "FS Work Order Product" = IMD,
                  tabledata "FS Work Order Service" = IMD,
                  tabledata "FS Work Order Substatus" = IMD,
                  tabledata "FS Work Order Type" = IMD;
}
