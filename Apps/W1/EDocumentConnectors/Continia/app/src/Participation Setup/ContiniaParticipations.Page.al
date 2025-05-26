// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6391 "Continia Participations"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Continia Participations';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "Continia Participation";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(ParticipationsGroup)
            {
                field(RegistrationStatus; Rec."Registration Status") { }
                field(Network; Rec.Network) { }
                field(IdentifierType; Rec."Identifier Scheme Id") { }
                field(IdentifierValue; Rec."Identifier Value") { }
                field(Created; Rec.Created) { }
                field(Updated; Rec.Updated) { }
                field(Id; Rec.Id) { }
            }
        }
        area(FactBoxes)
        {
            part(ActiveProfiles; "Continia Active Profiles")
            {
                SubPageLink = Network = field(Network), "Identifier Type Id" = field("Identifier Type Id"), "Identifier Value" = field("Identifier Value");
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(RegisterNewActionRef; RegisterNewParticipation) { }
            actionref(EditActioNRef; EditParticipation) { }
            actionref(DeleteActioNRef; DeleteParticipation) { }
        }
        area(Processing)
        {
            action(RegisterNewParticipation)
            {
                Caption = 'Register';
                Enabled = CanEditParticipation;
                Image = New;
                ToolTip = 'Register a new participation in the Continia Delivery Network.';

                trigger OnAction()
                var
                    OnboardingGuide: Page "Continia Onboarding Guide";
                begin
                    OnboardingGuide.Run();
                end;
            }
            action(EditParticipation)
            {
                Caption = 'Edit';
                Enabled = ActionsEnabled and CanEditParticipation;
                Image = Edit;
                ToolTip = 'Edit the participation in the Continia Delivery Network.';

                trigger OnAction()
                var
                    OnboardingGuide: Page "Continia Onboarding Guide";
                    RunScenario: Enum "Continia Wizard Scenario";
                begin
                    OnboardingGuide.SetRunScenario(RunScenario::EditParticipation); //Update Participation and profiles 
                    OnboardingGuide.SetParticipation(Rec);
                    OnboardingGuide.Run();
                    CurrPage.Update(false);
                end;

            }
            action(DeleteParticipation)
            {
                Caption = 'Unregister';
                Enabled = ActionsEnabled and CanEditParticipation;
                Image = Delete;
                ToolTip = 'Unregister the participation in the Continia Delivery Network.';

                trigger OnAction()
                var
                    ApiRequests: Codeunit "Continia Api Requests";
                begin
                    if Rec."Registration Status" = Rec."Registration Status"::Draft then
                        Rec.Delete()
                    else
                        ApiRequests.DeleteParticipation(Rec);
                end;
            }
        }
    }

    var
        ActionsEnabled: Boolean;
        CanEditParticipation: Boolean;

    trigger OnOpenPage()
    var
        OnboardingHelper: Codeunit "Continia Onboarding Helper";
    begin
        CanEditParticipation := OnboardingHelper.HasModifyPermissionOnParticipation();
    end;

    trigger OnAfterGetRecord()
    begin
        ActionsEnabled := true;
    end;
}