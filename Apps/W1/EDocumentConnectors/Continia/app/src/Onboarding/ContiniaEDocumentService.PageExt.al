// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;

pageextension 6390 "Continia E-Document Service" extends "E-Document Service"
{
    layout
    {
        addlast(General)
        {
            group(NetworkProfiles)
            {
                ShowCaption = false;
                Visible = Rec."Service Integration V2" = Enum::"Service Integration"::Continia;

                field("No. Of Network Profiles"; Rec."No. Of Network Profiles")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of Continia network profiles associated with the E-Document Service.';

                    trigger OnDrillDown()
                    begin
                        OpenNetworkProfiles();
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    local procedure OpenNetworkProfiles()
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        EDocServiceNetProfiles: Page "Con. E-Doc. Serv. Net.Profiles";
    begin
        ActivatedNetProf.SetRange("E-Document Service Code", Rec.Code);
        EDocServiceNetProfiles.SetTableView(ActivatedNetProf);
        EDocServiceNetProfiles.SetEDocumentServiceCode(Rec.Code);
        EDocServiceNetProfiles.RunModal();
    end;
}