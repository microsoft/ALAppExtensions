// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;

page 6112 "E-Documents API"
{
    PageType = API;

    APIGroup = 'edocument';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';

    InherentEntitlements = X;
    InherentPermissions = X;

    EntityCaption = 'E-Document';
    EntitySetCaption = 'E-Documents';
    EntityName = 'eDocument';
    EntitySetName = 'eDocuments';

    ODataKeyFields = SystemId;
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
                field(systemId; Rec.SystemId)
                {
                }
                field(entryNumber; Rec."Entry No")
                {
                }
                field(documentRecordId; Rec."Document Record ID")
                {
                }
                field(billPayNumber; Rec."Bill-to/Pay-to No.")
                {
                }
                field(documentNumber; Rec."Document No.")
                {
                }
                field(documentType; Format(Rec."Document Type"))
                {
                    Caption = 'Document Type';
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
                field(orderNumber; Rec."Order No.")
                {
                }
                field(postingDate; Rec."Posting Date")
                {
                }
                field(direction; Rec.Direction)
                {
                }
                field(incomingEDocumentNumber; Rec."Incoming E-Document No.")
                {
                }
                field(status; Format(Rec.Status))
                {
                    Caption = 'Electronic Document Status';
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
                field(workflowCode; Rec."Workflow Code")
                {
                }
                field(fileName; Rec."File Name")
                {
                }
                part(edocumentServiceStatus; "E-Document Service Status API")
                {
                    Caption = 'E-Document Service Status';
                    EntityName = 'eDocumentServiceStatus';
                    EntitySetName = 'eDocumentServiceStatuses';
                    SubPageLink = "E-Document Entry No" = field("Entry No");
                }
            }
        }
    }
}