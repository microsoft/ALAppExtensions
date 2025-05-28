// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;

page 6115 "Create E-Documents API"
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
    Editable = true;
    DeleteAllowed = false;
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
                field(fileType; Rec."File Type")
                {
                }
            }
        }
    }

    var
        fileContent: Text;
        eDocService: Text[20];
        ReceivingNotSupportedErr: Label 'This API does not support the receiving data.';
        ContentOrFileEmptyErr: Label 'File content or E-Document Service Code is empty.';

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        EDocumentsAPIHelper: Codeunit "E-Documents API Helper";
    begin
        if (this.fileContent <> '') and (this.eDocService <> '') then
            EDocumentsAPIHelper.CreateEDocumentFromReceivedFile(this.fileContent, this.eDocService, Rec."File Name")
        else
            Error(ContentOrFileEmptyErr);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        Error(ReceivingNotSupportedErr);
    end;
}