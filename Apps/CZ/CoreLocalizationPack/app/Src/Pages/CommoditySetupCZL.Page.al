// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 31077 "Commodity Setup CZL"
{
    Caption = 'Commodity Setup';
    DataCaptionFields = "Commodity Code";
    PageType = List;
    SourceTable = "Commodity Setup CZL";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commodity Code"; Rec."Commodity Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies code from reverse charge and control report.';
                    Visible = false;
                }
                field("Valid From"; Rec."Valid From")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the first date for commodity limit amount setup.';
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the last date for commodity limit amount setup.';
                }
                field("Commodity Limit Amount LCY"; Rec."Commodity Limit Amount LCY")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the commodidty limit in LCY. For amounts above the limit has to be used reverse charge.';
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
                Visible = true;
            }
        }
    }
}
