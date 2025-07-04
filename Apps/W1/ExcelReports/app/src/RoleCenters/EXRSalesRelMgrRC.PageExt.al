// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;
using Microsoft.CRM.RoleCenters;

pageextension 4417 "EXR Sales & Rel. Mgr. RC" extends "Sales & Relationship Mgr. RC"
{
    actions
    {
        addafter("Customer - &Order Summary")
        {
            action(EXRCustomerTopListExcel)
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Customer - Top List (Excel)';
                Image = "Report";
                RunObject = Report "EXR Customer Top List";
                ToolTip = 'View which customers purchase the most or owe the most in a selected period. Only customers that have either purchases during the period or a balance at the end of the period will be included.';
            }
        }
    }
}