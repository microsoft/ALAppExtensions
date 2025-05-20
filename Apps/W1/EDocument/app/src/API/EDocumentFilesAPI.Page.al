// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using System.Text;
using Microsoft.eServices.EDocument.Integration.Receive;

page 6111 "E-Document Files API"
{
    PageType = API;
    Caption = 'eDocumentsFileAPI';

    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    APIGroup = 'automate';

    EntityCaption = 'E-Document File';
    EntitySetCaption = 'E-Document Files';
    EntityName = 'documentFile';
    EntitySetName = 'documentFiles';
    ODataKeyFields = Id;

    SourceTable = "E-Document File Entity Buffer";

    Extensible = false;
    DelayedInsert = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.Id)
                {
                    // Caption = 'Id';
                }
                field(relatedEDocumentEntryNo; Rec."Related E-Document Id")
                {
                    // Caption = 'Related E-Document Id';
                }
                field(byteSize; Rec."Byte Size")
                {
                    // Caption = 'Byte Size';
                }
                field(base64Content; Base64Content)
                {

                }
                field(fileContent; Rec.Content)
                {
                    // Caption = 'Content';
                }
                field(fileName; Rec."File Name")
                {
                    // Caption = 'File Name';
                }
                field(serviceId; Rec."Service Id")
                {
                    // Caption = 'Service Id';
                }
            }
        }
    }

    var
        EDocumentsFileBuffer: Codeunit "E-Document File Entity Buffer";
        Base64Content: Text;
        FileContentEmptyErr: Label 'File content is empty.';

    // trigger OnFindRecord(Which: Text): Boolean
    // var
    //     EDocumentsAPIHelper: Codeunit "E-Documents API Helper";
    //     EDocumentNoFilter: Text;
    // begin
    //     // EDocumentNoFilter := Rec.GetFilter("Related E-Doc. Entry No.");
    //     // EDocumentsAPIHelper.LoadEDocumentFile(Rec, EDocumentNoFilter);

    //      exit(Rec.FindSet());
    // end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
    begin
        if Base64Content <> '' then begin
            Rec.Content.CreateOutStream(OutStr);
            Base64Convert.FromBase64(Base64Content, OutStr);
            if Rec.Content.HasValue() then
                this.EDocumentsFileBuffer.CreateEDocumentFromReceivedFile(Rec);
        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if (Rec."Related E-Doc. Entry No." = 0) and Rec.Content.HasValue() then
            this.EDocumentsFileBuffer.CreateEDocumentFromReceivedFile(Rec);
    end;

    [ServiceEnabled]
    procedure Upload(var ActionContext: Codeunit ActionContext)
    begin
        // Rec.Init();
        // Rec.Content.
        if Rec.Content.HasValue() then begin
            this.EDocumentsFileBuffer.CreateEDocumentFromReceivedFile(Rec);
            // ActionContext.SetResultCode(WebServiceActionResultCode::Created);
        end else
            Error(FileContentEmptyErr);
    end;
}
