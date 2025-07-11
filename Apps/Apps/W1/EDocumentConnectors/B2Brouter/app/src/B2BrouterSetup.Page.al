// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

page 6490 "B2Brouter Setup"
{
    Caption = 'B2Brouter Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "B2Brouter Setup";
    InsertAllowed = false;
    ModifyAllowed = true;


    layout
    {
        area(Content)
        {

            field("Staging Mode"; Rec."Sandbox Mode")
            {
                Caption = 'Staging Mode';
                ApplicationArea = All;
            }

            group(Production)
            {
                Caption = 'Production Environment';
                Visible = not Rec."Sandbox Mode";

                field("Production API-Key"; ProductionApiKey)
                {
                    Caption = 'API Key';
                    ToolTip = 'Specifies the key that is used for the production environment.';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if ProductionApiKey <> '' then
                            StoreKey(false, ProductionApiKey)
                        else
                            Rec.DeleteApiKey(false);
                    end;
                }

                field("Production Project"; Rec."Production Project")
                {
                    Caption = 'Project';
                    ApplicationArea = All;
                }
            }

            group(Staging)
            {
                Caption = 'Sandbox Environment';
                Visible = rec."Sandbox Mode";

                field("Staging API-Key"; SandboxApiKey)
                {
                    Caption = 'API Key';
                    ToolTip = 'Specifies the key that is used for the staging environment.';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if SandboxApiKey <> '' then
                            StoreKey(true, SandboxApiKey)
                        else
                            Rec.DeleteApiKey(true);
                    end;

                }

                field("Staging Project"; Rec."Sandbox Project")
                {
                    Caption = 'Project';
                    ApplicationArea = All;
                }

            }
        }
    }

    local procedure StoreKey(Sandbox: Boolean; var ApiKey: Text)
    begin
        Rec.StoreApiKey(Sandbox, ApiKey);
        ApiKey := '*';
    end;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();

        Rec.SetKeysIfAvailable(ProductionApiKey, SandboxApiKey);
    end;

    var
        [NonDebuggable]
        ProductionApiKey: Text;
        SandboxApiKey: Text;
}