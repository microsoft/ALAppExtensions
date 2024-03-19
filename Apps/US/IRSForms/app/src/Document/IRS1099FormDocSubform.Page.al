// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10047 "IRS 1099 Form Doc. Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "IRS 1099 Form Doc. Line";
    ApplicationArea = BasicUS;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("Form Box No."; Rec."Form Box No.")
                {
                    Tooltip = 'Specifies the number of the 1099 form box.';
                }
                field("Calculated Amount"; Rec."Calculated Amount")
                {
                    Tooltip = 'Specifies the calculated amount of the document line. This amount cannot be changed manually.';

                    trigger OnDrillDown()
                    var
                        IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
                    begin
                        IRS1099FormDocument.DrillDownCalculatedAmountInLine(Rec);
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    Tooltip = 'Specifies the amount of the document line. This amount can be changed manually.';
                }
                field("Minimum Reportable Amount"; Rec."Minimum Reportable Amount")
                {
                    ToolTip = 'Specifies the minimum reportable amount of the document line.';
                }
                field("Adjustment Amount"; Rec."Adjustment Amount")
                {
                    Tooltip = 'Specifies the calculated adjustment amount of the document line. This amount cannot be changed manually.';
                }
                field("Include In 1099"; Rec."Include In 1099")
                {
                    ToolTip = 'Specifies if the document line should be included in the 1099. The line is included in the 1099 if the amount is more than or equal the minimum reportable amount.';
                }
            }
        }
    }
}
