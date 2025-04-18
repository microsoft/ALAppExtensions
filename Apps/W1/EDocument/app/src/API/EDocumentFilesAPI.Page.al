// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

page 6102 "E-Document Files API"
{
    PageType = API;
    Caption = 'eDocumentsFileAPI';

    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    APIGroup = 'automate';

    EntityCaption = 'E-Document File';
    EntitySetCaption = 'E-Document Files';
    EntityName = 'eDocumentFile';
    EntitySetName = 'eDocumentFiles';

    SourceTable = "E-Document File Entity Buffer";

    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(relatedEDocumentEntryNo; Rec."Related E-Document Id")
                {
                    Caption = 'Related E-Document Id';
                }
                field(byteSize; Rec."Byte Size")
                {
                    Caption = 'Byte Size';
                }
                field(fileContent; Rec.Content)
                {
                    Caption = 'Content';
                }
                field(fileName; Rec."File Name")
                {
                    Caption = 'File Name';
                }
                field(serviceId; Rec."Service Id")
                {
                    Caption = 'Service Id';
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        EDocumentsAPIHelper: Codeunit "E-Documents API Helper";
        EDocumentNoFilter: Text;
    begin
        EDocumentNoFilter := Rec.GetFilter("Related E-Doc. Entry No.");
        EDocumentsAPIHelper.LoadEDocumentFile(Rec, EDocumentNoFilter);

        exit(Rec.FindSet());
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        this.EDocumentsFileBuffer.CreateEDocumentFromReceivedFile(Rec);
    end;

    var
        EDocumentsFileBuffer: Codeunit "E-Document File Entity Buffer";
}
