// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;
using Microsoft.eServices.EDocument.API;
using System.Utilities;
using Microsoft.eServices.EDocument;
using System.Text;

page 6115 "E-Documents Insert API"
{
    PageType = API;

    APIVersion = 'v2.0';
    APIPublisher = 'microsoft';
    APIGroup = 'automate';

    EntityCaption = 'E-Document';
    EntitySetCaption = 'E-Documents';
    EntityName = 'newEDocument';
    EntitySetName = 'newEDocuments';

    ODataKeyFields = "Entry No";
    SourceTable = "E-Document";
    SourceTableTemporary = true;

    Extensible = false;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            group(Group)
            {
                field(entryNumber; Rec."Entry No")
                {
                }
                field(service; this.EDocService)
                {
                }
                field(base64file; this.fileContent)
                {
                }
                field(fileName; Rec."File Name")
                {
                }
            }
        }
    }


    var
        fileContent: Text;
        eDocService: Text[20];

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        EDocumentFileEntityBuffer: Codeunit "E-Document File Entity Buffer";
    begin
        if (this.fileContent <> '') and (this.eDocService <> '') then
            EDocumentFileEntityBuffer.CreateEDocumentFromReceivedFile(this.fileContent, this.eDocService, Rec."File Name")
        else
            Error('File content or E-Document Service Code is empty.');
    end;
}