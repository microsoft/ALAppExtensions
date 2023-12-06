// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

page 6136 "E-Doc. Service Data Exch. Sub"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "E-Doc. Service Data Exch. Def.";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the document type that will use data exchange for importing/exporting the data.';
                }
                field("Impt. Data Exchange Def. Code"; Rec."Impt. Data Exchange Def. Code")
                {
                    ToolTip = 'Specifies the data exchange code that is used for importing the data.';
                }
                field("Impt. Data Exchange Def. Name"; Rec."Impt. Data Exchange Def. Name")
                {
                    ToolTip = 'Specifies the data exchange name that is used for importing the data.';
                }
                field("Expt. Data Exchange Def. Code"; Rec."Expt. Data Exchange Def. Code")
                {
                    ToolTip = 'Specifies the data exchange code that is used for exporting the data.';
                }
                field("Expt. Data Exchange Def. Name"; Rec."Expt. Data Exchange Def. Name")
                {
                    ToolTip = 'Specifies the data exchange name that is used for exporting the data.';
                }
            }
        }
    }
}