// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Foundation.Reporting;
using Microsoft.Sales.Document;

pageextension 4410 "Sales Order Ext" extends "Sales Order"
{
    actions
    {
        addfirst("&Print")
        {
            action(DownloadAsPDF)
            {
                ApplicationArea = All;
                Caption = 'Download as PDF';
                ToolTip = 'Download the sales order as a PDF file.';
                Image = Download;

                trigger OnAction()
                var
                    ReportSelections: Record "Report Selections";
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.Copy(Rec);
                    SalesHeader.SetRecFilter();
                    ReportSelections.PrintWithDialogForCust(ReportSelections.Usage::"S.Order", SalesHeader, false, SalesHeader.FieldNo("Bill-to Customer No."));
                end;
            }
        }

        addlast(Category_Category9)
        {
            actionref(DownloadAsPDF_Promoted; DownloadAsPDF)
            {

            }
        }
    }
}