// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Agents.Designer.AgentSamples.SalesValidation;

using Microsoft.Sales.RoleCenters;

profile "Sales Validation Agent"
{
    Caption = 'Sales Validation Agent (Copilot)';
    Enabled = false;
    ProfileDescription = 'Functionality for the Sales Validation Agent to efficiently validate and process sales orders.';
    Promoted = false;
    RoleCenter = "Order Processor Role Center";
    Customizations = SVSalesOrder, SVSalesOrderSubform, SVSalesOrderStatistics, SVOrderProcessorRC, SVSOProcessorActivities, SVSalesOrderList;
}