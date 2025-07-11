// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

page 18008 "Tax Type Setup"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "GST Setup";
    Caption = 'GST Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(code; Rec."GST Tax Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the tax type. Tax type can be TDS, TCS and GST.';
                }
                field("Cess Tax Type"; Rec."Cess Tax Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the Cess tax type.';
                }
                field("Generate E-Inv. on Ser. Post"; Rec."Generate E-Inv. on Ser. Post")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the function through which e-invoice will be generated at the time of service post.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then
            Rec.Insert();
    end;
}
