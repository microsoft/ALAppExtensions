// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;
using Microsoft.eServices.EDocument;

pageextension 10777 "Verifactu E-Document" extends "E-Document"
{
    layout
    {
        addlast(ClearanceInfo)
        {
            field("Verifactu Hash"; VerifactuHash)
            {
                ApplicationArea = All;
                Caption = 'Verifactu Hash';
                Editable = false;
                ToolTip = 'Specifies the Verifactu hash of the e-document received when the document is cleared.';
            }
            field("Submission Id"; VerifactuSubmissionId)
            {
                ApplicationArea = All;
                Caption = 'Submission Id';
                Editable = false;
                ToolTip = 'Specifies the Submission Id of the e-document received when the document is cleared.';
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        VerifactuDocUploadMgt: Codeunit "Verifactu Doc. Upload Mgt.";
    begin
        VerifactuDocUploadMgt.GetVerifactuData(Rec, VerifactuHash, VerifactuSubmissionId);
    end;

    var
        VerifactuHash: Text[64];
        VerifactuSubmissionId: Text[100];
}