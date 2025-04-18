// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

page 6101 "E-Documents API"
{
    PageType = API;

    APIVersion = 'v2.0';
    APIPublisher = 'microsoft';
    APIGroup = 'automate';

    EntityCaption = 'E-Document';
    EntitySetCaption = 'E-Documents';
    EntityName = 'eDocument';
    EntitySetName = 'eDocuments';

    ODataKeyFields = Id;
    SourceTable = "E-Document Entity Buffer";

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
                    Editable = false;
                }
                field(documentId; Rec."Document System Id")
                {
                    Caption = 'Document Id';
                    Editable = false;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                    Editable = false;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                    Editable = false;
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                    Editable = false;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                field(direction; Rec.Direction)
                {
                    Caption = 'Direction';
                    Editable = false;
                }
                field(createdAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created At';
                    Editable = false;
                }
                field(createdBy; Rec.SystemCreatedBy)
                {
                    Caption = 'Created By';
                    Editable = false;
                }
                field(serviceId; Rec."Service Id")
                {
                    Caption = 'Service Id';
                    Editable = false;
                }
                part(file; "E-Document Files API")
                {
                    Caption = 'File';
                    ApplicationArea = All;
                    SubPageLink = "Related E-Doc. Entry No." = field("Entry No");
                }
            }
        }
    }
}