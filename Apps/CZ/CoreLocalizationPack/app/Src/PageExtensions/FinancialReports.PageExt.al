// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

pageextension 11702 "Financial Reports CZL" extends "Financial Reports"
{
    actions
    {
        addlast(processing)
        {
            action("Set up Custom Functions CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set up Custom Functions';
                Ellipsis = true;
                Image = NewSum;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                RunObject = page "Acc. Schedule Extensions CZL";
                ToolTip = 'Specifies acc. schedule extensions page';
            }
            action("File Mapping CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'File Mapping';
                Image = ExportToExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                ToolTip = 'File Mapping allows to set up export to Excel. You can see three dots next to the field with Amount.';

                trigger OnAction()
                var
                    AccScheuledFileMappingCZL: Page "Acc. Schedule File Mapping CZL";
                begin
                    AccScheuledFileMappingCZL.SetAccSchedName(Rec."Financial Report Row Group");
                    AccScheuledFileMappingCZL.SetColumnLayoutName(Rec."Financial Report Column Group");
                    AccScheuledFileMappingCZL.RunModal();
                end;
            }
            action("Results CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Results';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                RunObject = page "Acc. Sched. Res. Hdr. List CZL";
                RunPageLink = "Acc. Schedule Name" = field("Financial Report Row Group");
                ToolTip = 'Opens acc. schedule res. header list';
            }
        }
    }
}
