// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;
using Microsoft.Sales.RoleCenters;

pageextension 4415 "EXR Sales Manager RC" extends "Sales Manager Role Center"
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