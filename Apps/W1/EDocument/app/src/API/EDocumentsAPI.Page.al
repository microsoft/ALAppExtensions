// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;
using Microsoft.eServices.EDocument;

page 6112 "E-Documents API"
{
    PageType = API;

    APIVersion = 'v2.0';
    APIPublisher = 'microsoft';
    APIGroup = 'automate';

    EntityCaption = 'E-Document';
    EntitySetCaption = 'E-Documents';
    EntityName = 'eDocument';
    EntitySetName = 'eDocuments';

    ODataKeyFields = SystemId;
    SourceTable = "E-Document";

    Extensible = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    Caption = 'Id';
                }
                field(documentId; Rec."Document System Id")
                {
                    Caption = 'Document Id';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(direction; Rec.Direction)
                {
                    Caption = 'Direction';
                }
                field(createdAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created At';
                }
                field(createdBy; Rec.SystemCreatedBy)
                {
                    Caption = 'Created By';
                }
                field(serviceId; Rec."Service Id")
                {
                    Caption = 'Service Id';
                }
                part(file; "E-Document Files API")
                {
                    Caption = 'File';
                    SubPageLink = "Related E-Doc. Entry No." = field("Entry No");
                }
            }
        }
    }
}