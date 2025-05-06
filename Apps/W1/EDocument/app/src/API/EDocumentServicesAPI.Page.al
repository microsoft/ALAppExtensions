// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;

page 6113 "E-Document Services API"
{
    PageType = API;

    APIGroup = 'automate';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';

    EntityCaption = 'E-Document Service';
    EntitySetCaption = 'E-Document Services';
    EntityName = 'eDocumentService';
    EntitySetName = 'eDocumentServices';

    ODataKeyFields = SystemId;
    SourceTable = "E-Document Service";

    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(serviceIntegrationV2; Rec."Service Integration V2")
                {
                    Caption = 'Service Integration V2';
                }
                field(documentFormat; Rec."Document Format")
                {
                    Caption = 'Document Format';
                }
            }
        }
    }
}
