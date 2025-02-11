// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;

pageextension 6102 "E-Doc. Select Sending Options" extends "Select Sending Options"
{
    layout
    {
        modify("Electronic Document")
        {
            Visible = ElectronicDocumentVisible;
        }
        modify(Control18)
        {
            Visible = Rec."Electronic Document" = Rec."Electronic Document"::"Through Document Exchange Service";
        }
        modify(Control14)
        {
            Visible = ElectronicDocumentFormatEmailVisible;
        }
        modify("E-Mail Attachment")
        {
            trigger OnAfterValidate()
            begin
                SetEmailElectronicDocumentVisibility();
            end;
        }
    }

    var
        ElectronicDocumentVisible: Boolean;
        ElectronicDocumentFormatEmailVisible: Boolean;

    trigger OnOpenPage()
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        EDocumentService: Record "E-Document Service";
    begin
        ElectronicDocumentVisible := not ElectronicDocumentFormat.IsEmpty() or not EDocumentService.IsEmpty();
    end;

    trigger OnAfterGetRecord()
    begin
        SetEmailElectronicDocumentVisibility();
    end;

    local procedure SetEmailElectronicDocumentVisibility()
    begin
        ElectronicDocumentFormatEmailVisible := not (Rec."E-Mail Attachment" in [Rec."E-Mail Attachment"::PDF,
            Rec."E-Mail Attachment"::"E-Document", Rec."E-Mail Attachment"::"PDF & E-Document"]);
    end;
}
