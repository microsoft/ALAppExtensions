// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.eServices.EDocument.Extensions;

using Microsoft.Sales.Customer;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Service.Participant;

/// <summary>
/// A page extension for the Customer Card page to show the E-Document service participation.
/// </summary>
pageextension 6163 "E-Doc. Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(Invoicing)
        {
            field("E-Document Service Participation Ids"; ParticipantIdCount)
            {
                ApplicationArea = All;
                Caption = 'E-Document Service Participation';
                DrillDown = true;
                Editable = false;
                ToolTip = 'Specifies the customers participation for the E-Document services.';

                trigger OnDrillDown()
                begin
                    Rec.TestField("No.");
                    ServiceParticipant.RunServiceParticipantPage(Enum::"E-Document Source Type"::Customer, Rec."No.");
                end;
            }
        }
    }


    var
        ServiceParticipant: Codeunit "Service Participant";
        ParticipantIdCount: Integer;


    trigger OnAfterGetCurrRecord()
    begin
        if Rec."No." <> '' then
            ParticipantIdCount := ServiceParticipant.GetParticipantIdCount(Enum::"E-Document Source Type"::Customer, Rec."No.");
    end;

}