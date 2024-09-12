// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

permissionset 6612 "FS - Objects"
{
    Access = Public;
    Assignable = false;
    Caption = 'Field Service - Objects';

    Permissions = codeunit "FS Assisted Setup Subscriber" = X,
                codeunit "FS Data Classification" = X,
                codeunit "FS Install" = X,
                codeunit "FS Integration Mgt." = X,
                codeunit "FS Int. Table Subscriber" = X,
                codeunit "FS Lookup FS Tables" = X,
                codeunit "FS Setup Defaults" = X,
                page "FS Bookable Resource List" = X,
                page "FS Connection Setup" = X,
                page "FS Connection Setup Wizard" = X,
                page "FS Customer Asset List" = X,
                page "FS Item Avail. by Location" = X,
                query "FS Item Avail. by Location" = X,
                table "FS Bookable Resource" = X,
                table "FS Bookable Resource Booking" = X,
                table "FS BookableResourceBookingHdr" = X,
                table "FS Connection Setup" = X,
                table "FS Customer Asset" = X,
                table "FS Customer Asset Category" = X,
                table "FS Project Task" = X,
                table "FS Resource Pay Type" = X,
                table "FS Warehouse" = X,
                table "FS Work Order" = X,
                table "FS Work Order Incident" = X,
                table "FS Work Order Product" = X,
                table "FS Work Order Service" = X,
                table "FS Work Order Substatus" = X,
                table "FS Work Order Type" = X;
}
