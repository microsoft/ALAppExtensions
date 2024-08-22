// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

using System.Security.AccessControl;

page 4320 "Agent Access Control"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Agent Access Control";
    Caption = 'Agent Access Control';
    MultipleNewLines = false;
    Extensible = false;

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
                    var
                        AgentImpl: Codeunit "Agent Impl.";
                    begin
                        if Rec.Access = Rec.Access::User then
                            AgentImpl.VerifyOwnerExists(Rec);
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
    var
        AgentImpl: Codeunit "Agent Impl.";
    begin
        AgentImpl.VerifyOwnerExists(Rec);
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
        RecordExists: Boolean;
    begin
        RecordExists := Rec.Find();

        if RecordExists then
            Error(CannotUpdateUserErr);

        Rec."User Security ID" := NewUserID;
        Rec.Insert(true);
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

    var
        UserFullName: Text[80];
        UserName: Code[50];
        CannotUpdateUserErr: Label 'You cannot change the User. Delete and create the entry again.';
}