// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

page 18204 "GST Distribution Lines"
{
    AutoSplitKey = true;
    Caption = 'GST Distribution Lines';
    PageType = ListPart;
    SourceTable = "GST Distribution Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the entry''s posting date';
                }
                field("From Location Code"; Rec."From Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'From Location Code';
                    ToolTip = 'Specifies location code from which input will be distributed, input service distribution field needs to be marked true for this location.';
                }
                field("From GSTIN No."; Rec."From GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'From GSTIN No.';
                    ToolTip = 'Specifies from which GSTIN No. input credit will be distributed.';
                }
                field("To Location Code"; Rec."To Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'To Location Code';
                    ToolTip = 'Specifies the location to which input credit will be distributed.';
                }
                field("To GSTIN No."; Rec."To GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'To GSTIN No.';
                    ToolTip = 'Specifies to which GSTIN No. input credit will be distributed.';
                }
                field("Distribution Jurisdiction"; Rec."Distribution Jurisdiction")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Distribution Jurisdiction';
                    ToolTip = 'Specifies the jurisdiction depending on the state code defined in from and to location.';
                }
                field("Distribution %"; Rec."Distribution %")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Distribution %';
                    ToolTip = 'Specifies the relevant Distribution rate which needs to be transferred. Do not enter percent sign, only the number. For example, if the Distribution rate is 10%, enter 10 into this field.';
                }
                field("Distribution Amount"; Rec."Distribution Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Distribution Amount';
                    ToolTip = 'Specifies the amount field as calculated from the defined distribution percent.';
                }
                field("Rcpt. Credit Type"; Rec."Rcpt. Credit Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rcpt. Credit Type';
                    ToolTip = 'Specifies if the received input credit has to be availed or not.';
                }
            }
        }
    }
}
