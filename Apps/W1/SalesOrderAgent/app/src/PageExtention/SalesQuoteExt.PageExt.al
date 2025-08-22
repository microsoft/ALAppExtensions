// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Foundation.Reporting;
using Microsoft.Sales.Document;

pageextension 4400 "Sales Quote Ext" extends "Sales Quote"
{
    actions
    {
        addfirst(Action59)
        {
            action(DownloadAsPDF)
            {
                ApplicationArea = All;
                Caption = 'Download as PDF';
                ToolTip = 'Download the sales quote as a PDF file.';
                Image = Download;

                trigger OnAction()
                var
                    ReportSelections: Record "Report Selections";
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.Copy(Rec);
                    SalesHeader.SetRecFilter();
                    ReportSelections.PrintWithDialogForCust(ReportSelections.Usage::"S.Quote", SalesHeader, false, SalesHeader.FieldNo("Bill-to Customer No."));
                end;
            }
            action(ItemAvailability)
            {
                ApplicationArea = All;
                Caption = 'Item Availability';
                ToolTip = 'Open the item availability page to search for available items.';
                Image = ListPage;
                RunObject = Page "SOA Multi Items Availability";
                RunPageMode = Edit;
            }
        }

        addlast(Category_Category9)
        {
            actionref(DownloadAsPDF_Promoted; DownloadAsPDF)
            {

            }
        }
        addlast(Category_Prepare)
        {
            actionref(ItemAvailability_Promoted; ItemAvailability)
            {

            }
        }
    }
}