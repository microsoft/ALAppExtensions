// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Codes;

page 6326 "Product Classification List"
{
    PageType = List;
    SourceTable = "Product Classification Code";
    Caption = 'Product Classification Codes';
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportUNSPSC)
            {
                Caption = 'Import UNSPSC from API';
                ToolTip = 'Fetches UNSPSC data from the UNGM API and imports it into the table.';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                begin
                    ImportUNSPSCFromAPI();
                end;
            }
            action(ClearUNSPSC)
            {
                Caption = 'Clear UNSPSC';
                ToolTip = 'Clears all UNSPSC data from the table.';
                ApplicationArea = All;
                Image = Delete;

                trigger OnAction()
                begin
                    ClearUNSPSCData();
                end;
            }

        }
    }

    local procedure ClearUNSPSCData()
    var
        ProductClassificationCode: Record "Product Classification Code";
        DeleteSuccessMsg: Label 'All UNSPSC records have been deleted successfully.';
    begin
        ProductClassificationCode.SetRange(Type, ProductClassificationCode.Type::UNSPSC);
        ProductClassificationCode.DeleteAll();
        Message(DeleteSuccessMsg);
    end;

    local procedure ImportUNSPSCFromAPI()
    var
        ProductClassificationCode: Record "Product Classification Code";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        JsonObj: JsonObject;
        Response: Text;
        UrlTok: Label 'https://www.ungm.org/API/UNSPSCs', Locked = true;
        HttpErr: Label 'HTTP request failed with status code %1', Comment = '%1 - HTTP status code';
        ImportSuccessMsg: Label 'UNSPSC import completed successfully.';
    begin

        // Call API
        HttpClient.Get(UrlTok, HttpResponseMessage);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(HttpErr, HttpResponseMessage.HttpStatusCode());

        // Parse JSON
        HttpResponseMessage.Content.ReadAs(Response);
        JsonObj.ReadFrom(Response);
        JsonArray := JsonObj.GetArray('value');

        foreach JsonToken in JsonArray do begin
            JsonObj := JsonToken.AsObject();

            Clear(ProductClassificationCode);
            ProductClassificationCode.Type := ProductClassificationCode.Type::UNSPSC;
            ProductClassificationCode.Code := CopyStr(JsonObj.GetText('UNSPSCode'), 1, 50);
            ProductClassificationCode.Name := CopyStr(JsonObj.GetText('Title'), 1, 250);
            if ProductClassificationCode.Insert() then;
        end;

        Message(ImportSuccessMsg);
    end;

}