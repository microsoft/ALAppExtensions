// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

using System.Security.AccessControl;

page 4321 "Select Agent Access Control"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    SourceTable = "Agent Access Control";
    SourceTableTemporary = true;
    Caption = 'Select users that can manage or interact with the Agent';
    MultipleNewLines = false;
    Extensible = false;
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field(UserName; UserName)
                {
                    Caption = 'User Name';
                    ToolTip = 'Specifies the name of the User that can access the agent.';
                    TableRelation = User;

                    trigger OnValidate()
                    begin
                        ValidateUserName(UserName);
                        CurrPage.Update(true);
                    end;
                }
                field(UserFullName; UserFullName)
                {
                    Caption = 'User Full Name';
                    ToolTip = 'Specifies the Full Name of the User that can access the agent.';
                    Editable = false;
                }
                field(Access; Rec.Access)
                {
                    Caption = 'Access';
                    Tooltip = 'Specifies the access level for the user for this agent.';

                    trigger OnValidate()
                    begin
                        if Rec.Access = Rec.Access::User then
                            VerifyOwnerExists();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateGlobalVariables();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateGlobalVariables();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        VerifyOwnerExists();
    end;

    trigger OnOpenPage()
    var
        AgentImpl: Codeunit "Agent Impl.";
    begin
        if Rec.GetFilter("Agent User Security ID") <> '' then
            Evaluate(AgentUserSecurityID, Rec.GetFilter("Agent User Security ID"));

        if Rec.Count() = 0 then
            AgentImpl.InsertCurrentOwner(Rec."Agent User Security ID", Rec);
    end;

    local procedure ValidateUserName(NewUserName: Text)
    var
        User: Record "User";
        UserGuid: Guid;
    begin
        if Evaluate(UserGuid, NewUserName) then begin
            User.Get(UserGuid);
            UpdateUser(User."User Security ID");
            UpdateGlobalVariables();
            exit;
        end;

        User.SetRange("User Name", NewUserName);
        if not User.FindFirst() then begin
            User.SetFilter("User Name", '@*''''' + NewUserName + '''''*');
            User.FindFirst();
        end;

        UpdateUser(User."User Security ID");
        UpdateGlobalVariables();
    end;

    local procedure UpdateUser(NewUserID: Guid)
    var
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        RecordExists: Boolean;
    begin
        RecordExists := Rec.Find();

        if RecordExists then begin
            TempAgentAccessControl.Copy(Rec);
            Rec.Delete();
            Rec.Copy(TempAgentAccessControl);
        end;

        Rec."User Security ID" := NewUserID;
        Rec."Agent User Security ID" := AgentUserSecurityID;
        Rec.Insert(true);
        VerifyOwnerExists();
    end;

    local procedure UpdateGlobalVariables()
    var
        User: Record "User";
    begin
        Clear(UserFullName);
        Clear(UserName);

        if IsNullGuid(Rec."User Security ID") then
            exit;

        if not User.Get(Rec."User Security ID") then
            exit;

        UserName := User."User Name";
        UserFullName := User."Full Name";
    end;

    procedure GetAgentUserAccess(var TempAgentAccessControl: Record "Agent Access Control" temporary)
    begin
        TempAgentAccessControl.Reset();
        TempAgentAccessControl.DeleteAll();

        if Rec.FindSet() then
            repeat
                TempAgentAccessControl.Copy(Rec);
                TempAgentAccessControl.Insert();
            until Rec.Next() = 0;
    end;

    local procedure VerifyOwnerExists()
    var
        TempAgentAccessControl: Record "Agent Access Control" temporary;
    begin
        TempAgentAccessControl.Copy(Rec);
        Rec.SetFilter(Access, '%1|%2', Rec.Access::Owner, Rec.Access::UserAndOwner);
        Rec.SetFilter("User Security ID", '<>%1', Rec."User Security ID");
        if Rec.IsEmpty() then begin
            Rec.Copy(TempAgentAccessControl);
            Error(OneOwnerMustBeDefinedForAgentErr);
        end;

        Rec.Copy(TempAgentAccessControl);
    end;

    var
        UserFullName: Text[80];
        UserName: Code[50];
        AgentUserSecurityID: Guid;
        OneOwnerMustBeDefinedForAgentErr: Label 'One owner must be defined for the agent.';
}