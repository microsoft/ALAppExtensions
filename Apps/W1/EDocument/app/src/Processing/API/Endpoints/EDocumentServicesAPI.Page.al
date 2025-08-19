// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;

page 6113 "E-Document Services API"
{
    PageType = API;

    APIGroup = 'edocument';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';

    InherentEntitlements = X;
    InherentPermissions = X;

    EntityCaption = 'E-Document Service';
    EntitySetCaption = 'E-Document Services';
    EntityName = 'eDocumentService';
    EntitySetName = 'eDocumentServices';

    ODataKeyFields = SystemId;
    SourceTable = "E-Document Service";

    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                }
                field(code; Rec.Code)
                {
                }
                field(description; Rec.Description)
                {
                }
                field(serviceIntegrationV2; Rec."Service Integration V2")
                {
                }
                field(documentFormat; Rec."Document Format")
                {
                }
            }
        }
    }
}
