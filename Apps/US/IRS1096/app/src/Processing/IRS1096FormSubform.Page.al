// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10020 "IRS 1096 Form Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "IRS 1096 Form Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("IRS Code"; Rec."IRS Code")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the IRS code.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the vendor number.';
                }
                field("Calculated Amount"; Rec."Calculated Amount")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the amount per period and IRS code calculated by the Create Forms action on the list page. This value cannot be changed.';

                    trigger OnDrillDown()
                    var
                        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
                    begin
                        IRS1096FormMgt.ShowRelatedVendorsLedgerEntries(Rec."Form No.", Rec."Line No.");
                    end;
                }
                field("Calculated Adjustment Amount"; Rec."Calculated Adjustment Amount")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the adjustment amount per period and IRS code calculated by the Create Forms action on the list page.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowAdjustments();
                    end;
                }
                field("Manually Changed"; Rec."Manually Changed")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies that the line has been changed manually.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the amount used for printing the form. This value matches the calculated amount minus calculated adjustment amount after clicking the Create Forms action and can be changed manually.';
                }
            }
        }
    }
}
