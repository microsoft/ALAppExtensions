// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Setup;

page 6338 "Sustainability Disclaimer"
{
    Caption = 'Disclaimers';
    PageType = List;
    SourceTable = "Sustainability Disclaimer";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field(Disclaimer; Rec.Disclaimer)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Disclaimer field.';
                }
            }
        }
    }
}