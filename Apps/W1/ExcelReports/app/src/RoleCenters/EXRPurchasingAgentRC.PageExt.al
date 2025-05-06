// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Purchases.ExcelReports;
using Microsoft.Purchases.RoleCenters;

pageextension 4421 "EXR Purchasing Agent RC" extends "Purchasing Agent Role Center"
{
    actions
    {
        addfirst(reporting)
        {
            action(EXRVendorTopListExcel)
            {
                ApplicationArea = Suite;
                Caption = 'Vendor - Top List (Excel)';
                Image = "Report";
                RunObject = Report "EXR Vendor Top List";
                ToolTip = 'View a list of the vendors from whom you purchase the most or to whom you owe the most.';
            }
        }
    }
}