// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

permissionset 6611 "FS - Read"
{
    Access = Internal;
    Assignable = false;
    Caption = 'Field Service - Read';

    IncludedPermissionSets = "FS - Objects";

    Permissions = tabledata "FS Connection Setup" = R,
                  tabledata "FS Bookable Resource" = R,
                  tabledata "FS Bookable Resource Booking" = R,
                  tabledata "FS BookableResourceBookingHdr" = R,
                  tabledata "FS Booking Status" = R,
                  tabledata "FS Customer Asset" = R,
                  tabledata "FS Customer Asset Category" = R,
                  tabledata "FS Incident Type" = R,
                  tabledata "FS Project Task" = R,
                  tabledata "FS Resource Pay Type" = R,
                  tabledata "FS Warehouse" = R,
                  tabledata "FS Work Order" = R,
                  tabledata "FS Work Order Incident" = R,
                  tabledata "FS Work Order Product" = R,
                  tabledata "FS Work Order Service" = R,
                  tabledata "FS Work Order Substatus" = R,
                  tabledata "FS Work Order Type" = R;
}
