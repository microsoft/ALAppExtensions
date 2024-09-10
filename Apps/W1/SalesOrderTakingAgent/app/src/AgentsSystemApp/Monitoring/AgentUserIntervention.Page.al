// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4305 "Agent User Intervention"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'User Intervention';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(Details)
            {
                Caption = 'User Intervention Request Details';
                field(Type; RequestType)
                {
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of user intervention request.';
                    Editable = false;
                }
                field(Title; RequestTitle)
                {
                    Caption = 'Title';
                    ToolTip = 'Specifies the title of the user intervention request.';
                    Editable = false;
                    MultiLine = true;
                }
                field(Message; RequestMessage)
                {
                    Caption = 'Message';
                    ToolTip = 'Specifies the message of the user intervention request.';
                    Editable = false;
                    MultiLine = true;
                }
            }
            group(Input)
            {
                ShowCaption = false;
                field(UserInput; UserInput)
                {
                    Caption = 'Input';
                    ToolTip = 'Specifies the input to provide to the agent.';
                    MultiLine = true;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
    begin
        if not (CloseAction in [Action::Ok, Action::LookupOK, Action::Yes]) then
            exit(true);

        AgentMonitoringImpl.CreateUserInterventionTaskStep(UserInterventionRequestStep, UserInput);
        exit(true);
    end;

    procedure SetUserInterventionRequestStep(var InterventionRequestStep: Record "Agent Task Step")
    var
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        DetailsJson: JsonObject;
        JsonToken: JsonToken;
    begin
        UserInterventionRequestStep := InterventionRequestStep;
        DetailsJson.ReadFrom(AgentMonitoringImpl.GetDetailsForAgentTaskStep(UserInterventionRequestStep));
        DetailsJson.Get('type', JsonToken);
        RequestType := JsonToken.AsValue().AsText();
        DetailsJson.Get('title', JsonToken);
        RequestTitle := JsonToken.AsValue().AsText();
        DetailsJson.Get('message', JsonToken);
        RequestMessage := JsonToken.AsValue().AsText();
        if (DetailsJson.Contains('messageId')) then begin
            DetailsJson.Get('messageId', JsonToken);
            MessageId := JsonToken.AsValue().AsText();
        end;
    end;

    var
        UserInterventionRequestStep: Record "Agent Task Step";
        UserInput: Text;
        RequestType: Text;
        RequestTitle: Text;
        RequestMessage: Text;
        MessageId: Guid;

}