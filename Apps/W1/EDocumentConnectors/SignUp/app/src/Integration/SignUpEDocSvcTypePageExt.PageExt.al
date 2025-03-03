// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

pageextension 6441 "SignUp EDoc. Svc. Type PageExt" extends "E-Doc Service Supported Types"
{
    layout
    {
        addlast(General)
        {
            field("Profile Id"; Rec."Profile Id")
            {
                ApplicationArea = All;
                Visible = ExFlowEInvoicingVisible;
            }
            field("Profile Name"; Rec."Profile Name")
            {
                ApplicationArea = All;
                Visible = ExFlowEInvoicingVisible;
            }
        }

    }

    actions
    {
        addlast(Processing)
        {
            action(PopulateMetaData)
            {
                ApplicationArea = All;
                Caption = 'Retrieve Metadata Profiles';
                ToolTip = 'Retrieves Metadata Profiles from service';
                Promoted = true;
                PromotedCategory = Process;
                Visible = ExFlowEInvoicingVisible;
                Image = Refresh;

                trigger OnAction()
                var
                    SignUpConnection: Codeunit "SignUp Connection";
                begin
                    SignUpConnection.UpdateMetadataProfile();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        SignUpHelpers: Codeunit "SignUp Helpers";
    begin
        ExFlowEInvoicingVisible := SignUpHelpers.IsExFlowEInvoicing(Rec.GetFilter("E-Document Service Code"));
    end;

    var
        ExFlowEInvoicingVisible: Boolean;

}