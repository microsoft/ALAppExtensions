// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.Environment.Configuration;
using System.Security.AccessControl;

xmlport 4350 "Custom Agent Export"
{
    Direction = Export;
    Format = Xml;
    UseDefaultNamespace = false;
    InherentEntitlements = X;
    InherentPermissions = X;
    Encoding = UTF8;

    schema
    {
        textelement(Agents)
        {
            tableelement(Agent; Agent)
            {
                XmlName = 'Agent';
                fieldelement(Name; Agent."User Name") { }
                fieldelement(DisplayName; Agent."Display Name") { }
                fieldelement(Initials; Agent.Initials) { }
                textelement(Description)
                {
                    trigger OnBeforePassVariable()
                    var
                        CustomAgentSetup: Record "Custom Agent Setup";
                    begin
                        CustomAgentSetup.Get(Agent."User Security ID");
                        Description := CustomAgentSetup.Description;
                    end;
                }
                textelement(Version)
                {
                    trigger OnBeforePassVariable()
                    begin
                        Version := '1.0';
                    end;
                }
                textelement(Export)
                {
                    textattribute(ExportDate)
                    {
                        XmlName = 'Date';

                        trigger OnBeforePassVariable()
                        begin
                            ExportDate := Format(CurrentDateTime, 0, 9);
                        end;
                    }
                }
                textelement(AccessControls)
                {
                    tableelement(AccessControl; "Access Control")
                    {
                        MinOccurs = Once;
                        LinkTable = Agent;
                        LinkFields = "User Security ID" = field("User Security ID");

                        fieldattribute(RoleID; AccessControl."Role ID") { }
                        fieldattribute(Scope; AccessControl.Scope) { }
                        fieldattribute(AppID; AccessControl."App ID") { }
                    }
                }
                tableelement(UserPersonalization; "User Personalization")
                {
                    MaxOccurs = Once;
                    LinkTable = Agent;
                    LinkFields = "User SID" = field("User Security ID");
                    XmlName = 'Profile';

                    fieldattribute(ProfileID; UserPersonalization."Profile ID") { }
                    fieldattribute(AppID; UserPersonalization."App ID") { }
                }
                tableelement(TempUserSettings; "User Settings")
                {
                    MaxOccurs = Once;
                    LinkTable = Agent;
                    UseTemporary = true;
                    LinkFields = "User Security ID" = field("User Security ID");
                    XmlName = 'UserSettings';

                    fieldattribute(LocaleID; TempUserSettings."Locale ID") { }
                    fieldattribute(LanguageID; TempUserSettings."Language ID") { }
                    fieldattribute(TimeZone; TempUserSettings."Time Zone") { }

                    trigger OnPreXmlItem()
                    var
                        UserSettings: Codeunit "User Settings";
                    begin
                        UserSettings.GetUserSettings(Agent."User Security ID", TempUserSettings);
                    end;
                }
                textelement(Instructions)
                {
                    trigger OnBeforePassVariable()
                    var
                        CustomAgentSetup: Record "Custom Agent Setup";
                    begin
                        CustomAgentSetup.Get(Agent."User Security ID");
                        Instructions := CustomAgentSetup.GetInstructions(Agent."User Security ID");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if (Agent."Agent Metadata Provider" <> Agent."Agent Metadata Provider"::"Custom Agent") then
                        Error(CannotExportAgentTypeErr, Format(Agent."Agent Metadata Provider"));

                    Session.LogMessage('0000QF4', StrSubstNo(ExportAgentTelemetryTxt, Agent."Agent Metadata Provider"),
                        Verbosity::Normal,
                        DataClassification::SystemMetadata,
                        TelemetryScope::ExtensionPublisher,
                        'Category', CustomAgentExport.GetTelemetryCategory());
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();
        AgentDesignerPermissions.VerifyCurrentUserCanExportCustomAgents();
    end;

    var
        CustomAgentExport: Codeunit "Custom Agent Export";
        ExportAgentTelemetryTxt: Label 'Exported agent of type %1.', Comment = '%1 = Agent Type';
        CannotExportAgentTypeErr: Label 'Agents of type %1 cannot be exported.', Comment = '%1 = Agent Type';
}