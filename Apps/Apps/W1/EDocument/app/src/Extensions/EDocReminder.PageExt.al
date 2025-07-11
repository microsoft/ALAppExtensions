// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

using Microsoft.eServices.EDocument;

pageextension 6141 "E-Doc. Reminder" extends Reminder
{
    actions
    {
        addafter("&Issuing")
        {
            group("E-Document")
            {
                action("PreviewEDocumentMapping")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview E-Document Mapping';
                    Image = ViewDetails;
                    ToolTip = 'Preview E-Document Mapping';
                    trigger OnAction()
                    var
                        ReminderLine: Record "Reminder Line";
                        EDocMapping: Codeunit "E-Doc. Mapping";
                    begin
                        ReminderLine.SetRange("Document No.", Rec."No.");
                        EDocMapping.PreviewMapping(Rec, ReminderLine, ReminderLine.FieldNo("Line No."));
                    end;
                }
            }
        }
    }
}
