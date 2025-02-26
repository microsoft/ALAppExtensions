// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

page 71107792 "B2Brouter Setup"
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
            group(Production)
            {
                Caption = 'Production Environment';

                field("Production API-Key"; ProductionApiKey)
                {
                    Caption = 'API Key';
                    ToolTip = 'The key that is used for the production environment.';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if ProductionApiKey <> '' then
                            Rec.StoreApiKey(false, ProductionApiKey)
                        else
                            Rec.DeleteApiKey(false);
                    end;
                }

                field("Production Project"; Rec."Production Project")
                {
                    Caption = 'Project';
                    ApplicationArea = All;
                    ToolTip = 'The name of the project';
                }
            }

            group(Staging)
            {
                Caption = 'Sandbox Environment';

                field("Staging API-Key"; SandboxApiKey)
                {
                    Caption = 'API Key';
                    ToolTip = 'The key that is used for the staging environment.';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if SandboxApiKey <> '' then
                            Rec.StoreApiKey(true, SandboxApiKey)
                        else
                            Rec.DeleteApiKey(true);
                    end;

                }

                field("Staging Project"; Rec."Sandbox Project")
                {
                    Caption = 'Project';
                    ToolTip = 'The project name for the staging environment.';
                    ApplicationArea = All;
                }

                field("Staging Mode"; Rec."Sandbox Mode")
                {
                    Caption = 'Staging Mode';
                    ToolTip = 'If true, the extension is working in non production mode.';
                    ApplicationArea = All;
                }
            }
        }
    }

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