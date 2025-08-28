// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;

page 6118 "E-Document Service Status API"
{
    PageType = API;

    APIGroup = 'edocument';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';

    InherentEntitlements = X;
    InherentPermissions = X;

    EntityCaption = 'E-Document Service Status';
    EntitySetCaption = 'E-Document Service Statuses';
    EntityName = 'eDocumentServiceStatus';
    EntitySetName = 'eDocumentServiceStatuses';

    ODataKeyFields = SystemId;
    SourceTable = "E-Document Service Status";

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
                field(edocumentEntryNumber; Rec."E-Document Entry No")
                {
                }
                field(edocumentServiceCode; Rec."E-Document Service Code")
                {
                }
                field(status; Format(Rec.Status))
                {
                }
                field(importProcessingStatus; Format(Rec."Import Processing Status"))
                {
                }
                part(fileContent; "E-Doc. File Content API")
                {
                    Multiplicity = ZeroOrOne;
                    EntityName = 'eDocumentFileContent';
                    EntitySetName = 'eDocumentFileContent';
                    SubPageLink = "E-Doc Entry No." = field("E-Document Entry No"), "E-Document Service Code" = field("E-Document Service Code");
                }
            }
        }
    }
}