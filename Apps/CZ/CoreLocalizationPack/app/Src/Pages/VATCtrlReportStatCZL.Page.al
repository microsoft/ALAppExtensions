// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

#pragma implicitwith disable
page 31113 "VAT Ctrl. Report Stat. CZL"
{
    Caption = 'VAT Control Report Statistics';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPlus;
    SourceTable = "VAT Ctrl. Report Header CZL";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = VAT;
                    Editable = false;
                    ToolTip = 'Specifies the number of VAT Control Report.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = VAT;
                    Editable = false;
                    ToolTip = 'Specifies the description of VAT Control Report.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = VAT;
                    Editable = false;
                    ToolTip = 'Specifies first date for the declaration, which is calculated based of the values of the Period No. a Year fields.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = VAT;
                    Editable = false;
                    ToolTip = 'Specifies end date for the declaration, which is calculated based of the values of the Period No. a Year fields.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = VAT;
                    Editable = false;
                    ToolTip = 'Specifies the status of VAT Control Report.';
                }
            }
            part(SubForm; "VAT Ctrl. Report St. Subf. CZL")
            {
                Caption = 'Lines';
                ApplicationArea = VAT;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("No.", Rec."No.");
        Rec.FilterGroup(0);

        VATCtrlReportMgtCZL.CreateBufferForStatistics(Rec, TempVATCtrlReportBufferCZL, true);
        SetVATCtrlRepBuffer();
    end;

    var
        TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary;
        VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";

    local procedure SetVATCtrlRepBuffer()
    begin
        CurrPage.SubForm.Page.SetTempVATCtrlRepBuffer(TempVATCtrlReportBufferCZL);
    end;
}
