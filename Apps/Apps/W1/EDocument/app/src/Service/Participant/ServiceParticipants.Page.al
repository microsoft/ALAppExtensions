// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Service.Participant;


/// <summary>
/// Represents the service participant. 
/// Table allows a participant (Customer/Vendor/Etc.) to be associated with multiple services.
/// </summary>
page 6150 "Service Participants"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Service Participant";
    Extensible = true;

    layout
    {
        area(Content)
        {
            repeater(Default)
            {
                field(Service; Rec.Service)
                {
                    ApplicationArea = All;
                    Caption = 'E-Document Service';
                }
                field("Participant Type"; Rec."Participant Type")
                {
                    ApplicationArea = All;
                    Caption = 'Participant Type';
                }
                field(Participant; Rec.Participant)
                {
                    ApplicationArea = All;
                    Caption = 'Participant';
                }
                field("Participant Identifier"; Rec."Participant Identifier")
                {
                    ApplicationArea = All;
                    Caption = 'Participant Identifier';
                }
            }
        }
    }
}