// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.eServices.EDocument;

pageextension 6144 "E-Doc. Posted Sales Inv." extends "Posted Sales Invoice"
{
    actions
    {
        addafter("&Invoice")
        {
            group("E-Document")
            {
                action("OpenEDocument")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open E-Document';
                    Image = CopyDocument;
                    ToolTip = 'Opens the electronic document card.';

                    trigger OnAction()
                    var
                        EDocument: Record "E-Document";
                    begin
                        EDocument.OpenEdocument(Rec.RecordId);
                    end;
                }
            }
        }
    }
}
