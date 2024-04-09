// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

page 11701 "File Mapping CZL"
{
    Caption = 'File Mapping';
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "Acc. Schedule File Mapping CZL";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Excel Cell"; Rec."Excel Cell")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies excel cell in which will be exported the value from system. The value is mapped in format RxCy.';
                }
                field(Split; Rec.Split)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if line splits.';
                    Visible = false;
                }
                field(Offset; Rec.Offset)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies offset of line.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}
