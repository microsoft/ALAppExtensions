// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.Environment.Configuration;
using System.Reflection;
using System.Security.AccessControl;

xmlport 4351 "Custom Agent Import"
{
    Direction = Import;
    Format = Xml;
    UseDefaultNamespace = false;
    PreserveWhiteSpace = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    Encoding = UTF8;

    schema
    {
        textelement(Agents)
        {
            MaxOccurs = Once;

            tableelement(TempAgent; Agent)
            {
                XmlName = 'Agent';
                UseTemporary = true;
                MinOccurs = Zero;

                fieldelement(Name; TempAgent."User Name") { }
                fieldelement(DisplayName; TempAgent."Display Name") { }
                fieldelement(Initials; TempAgent.Initials) { }
                textelement(Description)
                {
                    MaxOccurs = Once;
                }
                textelement(Version)
                {
                    MaxOccurs = Once;
                }
                textelement(Export)
                {
                    MaxOccurs = Once;
                    textattribute(Date) { }
                }
                textelement(AccessControls)
                {
                    MaxOccurs = Once;

                    tableelement(TempAccessControlBuffer; "Access Control Buffer")
                    {
                        MinOccurs = Zero; // We actually always expect one, but we have dedicated error reporting in the codeunit.
                        XmlName = 'AccessControl';
                        UseTemporary = true;

                        fieldattribute(RoleID; TempAccessControlBuffer."Role ID") { }
                        fieldattribute(Scope; TempAccessControlBuffer."Scope") { }
                        fieldattribute(AppID; TempAccessControlBuffer."App ID") { }
                    }
                }
                tableelement(TempAllProfile; "All Profile")
                {
                    MinOccurs = Zero; // We actually always expect one, but we have dedicated error reporting in the codeunit.
                    MaxOccurs = Once;
                    UseTemporary = true;
                    XmlName = 'Profile';

                    fieldattribute(ProfileID; TempAllProfile."Profile ID") { }
                    fieldattribute(AppID; TempAllProfile."App ID") { }
                }
                tableelement(TempUserSettings; "User Settings")
                {
                    MinOccurs = Zero; // We actually always expect one, but we have dedicated error reporting in the codeunit.
                    MaxOccurs = Once;
                    UseTemporary = true;
                    XmlName = 'UserSettings';

                    fieldattribute(LocaleID; TempUserSettings."Locale ID") { }
                    fieldattribute(LanguageID; TempUserSettings."Language ID") { }
                    fieldattribute(TimeZone; TempUserSettings."Time Zone") { }
                }
                textelement(Instructions)
                {
                    MaxOccurs = Once;
                    TextType = BigText;
                }

                trigger OnBeforeInsertRecord()
                var
                    InstructionsText: Text;
                begin
                    Instructions.GetSubText(InstructionsText, 1, MaxStrLen(InstructionsText));

                    if GlobalUserBuffer then begin
                        CustomAgentImport.AddAgentToBuffer(TempAgent, TempAllProfile, Description, InstructionsText);
                        CustomAgentImport.ValidateAgent(TempAgent, TempAccessControlBuffer, TempAllProfile, TempUserSettings, InstructionsText);
                    end
                    else
                        CustomAgentImport.CreateAgent(TempAgent, TempAccessControlBuffer, TempAllProfile, TempUserSettings, Description, InstructionsText);

                    TempAccessControlBuffer.DeleteAll();
                    TempAllProfile.DeleteAll();
                    TempUserSettings.DeleteAll();
                    TempAgent.DeleteAll();
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
        AgentDesignerPermissions.VerifyCurrentUserCanImportCustomAgents();
    end;

    internal procedure SetImportBufferCodeunit(ImportCodeunit: Codeunit "Custom Agent Import"; UseBuffer: Boolean)
    begin
        CustomAgentImport := ImportCodeunit;
        GlobalUserBuffer := UseBuffer;
    end;

    var
        CustomAgentImport: Codeunit "Custom Agent Import";
        GlobalUserBuffer: Boolean;
}