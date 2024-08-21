// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4323 "API - Agent Task Message"
{
    PageType = API;
    Caption = 'message', Locked = true;
    APIPublisher = 'microsoft';
    APIGroup = 'agent';
    APIVersion = 'v1.0';
    EntityName = 'message';
    EntitySetName = 'messages';
    SourceTable = "Agent Task Message";
    DelayedInsert = true;
    ODataKeyFields = ID;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.ID)
                {
                    Caption = 'Id', Locked = true;

                }

                field(status; Rec.Status)
                {
                    Caption = 'Status', Locked = true;
                }

                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }

                field(messageContent; ContentText)
                {
                    Caption = 'Message Content', Locked = true;
                }

                field(createdAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created At', Locked = true;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TextLine: Text;
        InStream: InStream;
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        ContentText := '';
        Rec.Content.CreateInStream(InStream);
        while not InStream.EOS() do begin
            InStream.ReadText(TextLine);
            ContentText += TextLine + CRLF[1] + CRLF[2];
        end;
    end;

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields(Content);
    end;

    var
        ContentText: Text;
}