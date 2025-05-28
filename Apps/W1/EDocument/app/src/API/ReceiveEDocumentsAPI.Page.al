// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;

page 6112 "Receive E-Documents API"
{
    PageType = API;

    APIVersion = 'v2.0';
    APIPublisher = 'microsoft';
    APIGroup = 'automate';

    EntityCaption = 'E-Document';
    EntitySetCaption = 'E-Documents';
    EntityName = 'eDocument';
    EntitySetName = 'eDocuments';

    ODataKeyFields = "Entry No";
    SourceTable = "E-Document";

    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(entryNumber; Rec."Entry No")
                {
                }
                field(documentRecordId; Rec."Document Record ID")
                {
                }
                field(billPayNumber; Rec."Bill-to/Pay-to No.")
                {
                }
                field(documentNo; Rec."Document No.")
                {
                }
                field(documentType; Rec."Document Type")
                {
                }
                field(documentDate; Rec."Document Date")
                {
                }
                field(dueDate; Rec."Due Date")
                {
                }
                field(amountInclVat; Rec."Amount Incl. VAT")
                {
                }
                field(amountExclVat; Rec."Amount Excl. VAT")
                {
                }
                field(orderNo; Rec."Order No.")
                {
                }
                field(postingDate; Rec."Posting Date")
                {
                }
                field(direction; Rec.Direction)
                {
                }
                field(incommingEDocumentNumber; Rec."Incoming E-Document No.")
                {
                }
                field(status; Rec.Status)
                {
                }
                field(sourceType; Rec."Source Type")
                {
                }
                field(recCompanyVat; Rec."Receiving Company VAT Reg. No.")
                {
                }
                field(recCompanyGLN; Rec."Receiving Company GLN")
                {
                }
                field(recCompanyName; Rec."Receiving Company Name")
                {
                }
                field(recCompanyAddress; Rec."Receiving Company Address")
                {
                }
                field(currencyCode; Rec."Currency Code")
                {
                }
                field(service; Rec.Service)
                {
                }
                field(workflowCode; Rec."Workflow Code")
                {
                }
                field(fileName; Rec."File Name")
                {
                }
                field(fileType; Rec."File Type")
                {
                }
                field(fileByteSize; this.fileSize)
                {
                }
                field(fileContent; this.fileContent)
                {
                }
            }
        }
    }

    var
        fileContent: Text;
        fileSize: Integer;

    trigger OnAfterGetCurrRecord()
    var
        EDocumentsAPIHelper: Codeunit "E-Documents API Helper";
    begin
        EDocumentsAPIHelper.LoadEDocumentFile(Rec."Entry No", this.fileContent, this.fileSize);
    end;
}