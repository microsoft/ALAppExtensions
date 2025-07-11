// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Service.Participant;

using Microsoft.eServices.EDocument;

/// <summary>
/// Function for service participant. 
/// </summary>
codeunit 6170 "Service Participant"
{
    Access = Internal;

    procedure GetParticipantIdCount(Type: Enum "E-Document Source Type"; Participant: Code[20]): Integer
    var
        ServiceParticipant: Record "Service Participant";
    begin
        ServiceParticipant.SetRange("Participant Type", Type);
        ServiceParticipant.SetRange(Participant, Participant);
        exit(ServiceParticipant.Count());
    end;

    procedure RunServiceParticipantPage(Type: Enum "E-Document Source Type"; Participant: Code[20]): Action
    var
        ServiceParticipant: Record "Service Participant";
        ServiceParticipantPage: Page "Service Participants";
    begin
        ServiceParticipant.SetRange("Participant Type", Type);
        ServiceParticipant.SetRange(Participant, Participant);
        ServiceParticipantPage.SetTableView(ServiceParticipant);
        exit(ServiceParticipantPage.RunModal());
    end;

}