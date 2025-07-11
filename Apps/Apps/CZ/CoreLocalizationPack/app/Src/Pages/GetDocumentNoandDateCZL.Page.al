// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 31131 "Get Document No. and Date CZL"
{
    Caption = 'Close Line with Document No.';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ClosedDocNo; ClosedDocumentNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Closed Document No.';
                    ToolTip = 'Specifies no. of the closed document.';
                }
                field(ClosedDate; ClosedDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Closed Date';
                    ToolTip = 'Specifies date of the closed document.';
                }
            }
        }
    }

    var
        ClosedDocumentNo: Code[20];
        ClosedDate: Date;

    procedure SetValues(NewDocNo: Code[20]; NewPostingDate: Date)
    begin
        ClosedDocumentNo := NewDocNo;
        ClosedDate := NewPostingDate;
    end;

    procedure GetValues(var NewDocNo: Code[20]; var NewPostingDate: Date)
    begin
        NewDocNo := ClosedDocumentNo;
        NewPostingDate := ClosedDate;
    end;
}
