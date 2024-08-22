// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Sales.Document;
using Microsoft.Foundation.Reporting;

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
        }

        addlast(Category_Category9)
        {
            actionref(DownloadAsPDF_Promoted; DownloadAsPDF)
            {

            }
        }
    }
}