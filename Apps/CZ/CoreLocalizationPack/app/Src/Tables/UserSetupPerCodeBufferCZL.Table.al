// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

using System.Security.AccessControl;

table 11719 "User Setup per Code Buffer CZL"
{
    Caption = 'User Setup per Code Buffer';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the user ID.';
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName(Rec."User ID");
            end;
        }
        field(3; "User Name"; Text[100])
        {
            Caption = 'User Name';
            ToolTip = 'Specifies the user name.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(User."Full Name" where("User Name" = field("User ID")));
        }
        field(10; "Post Quantity Increase"; Boolean)
        {
            Caption = 'Post Quantity Increase';
            ToolTip = 'Specifies if the user has rights for posting the quantity increase at the location.';

            trigger OnValidate()
            begin
                ValidateUserSetupValue(Enum::"User Setup Line Type CZL"::"Location (quantity increase)", Rec."Post Quantity Increase");
            end;
        }
        field(11; "Post Quantity Decrease"; Boolean)
        {
            Caption = 'Post Quantity Decrease';
            ToolTip = 'Specifies if the user has rights for posting the quantity decrease at the location.';

            trigger OnValidate()
            begin
                ValidateUserSetupValue(Enum::"User Setup Line Type CZL"::"Location (quantity decrease)", Rec."Post Quantity Decrease");
            end;
        }
        field(12; "Release Quantity Increase"; Boolean)
        {
            Caption = 'Release Quantity Increase';
            ToolTip = 'Specifies if the user has rights to release a quantity increase document at the location.';

            trigger OnValidate()
            begin
                ValidateUserSetupValue(Enum::"User Setup Line Type CZL"::"Release Location (quantity increase)", Rec."Release Quantity Increase");
            end;
        }
        field(13; "Release Quantity Decrease"; Boolean)
        {
            Caption = 'Release Quantity Decrease';
            ToolTip = 'Specifies if the user has rights to release a quantity decrease document at the location.';

            trigger OnValidate()
            begin
                ValidateUserSetupValue(Enum::"User Setup Line Type CZL"::"Release Location (quantity decrease)", Rec."Release Quantity Decrease");
            end;
        }

    }

    keys
    {
        key(PK; Code, "User ID")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        ValidateUserSetupValue(Enum::"User Setup Line Type CZL"::"Location (quantity increase)", false);
        ValidateUserSetupValue(Enum::"User Setup Line Type CZL"::"Location (quantity decrease)", false);
        ValidateUserSetupValue(Enum::"User Setup Line Type CZL"::"Release Location (quantity increase)", false);
        ValidateUserSetupValue(Enum::"User Setup Line Type CZL"::"Release Location (quantity decrease)", false);
        OnAfterDelete(Rec);
    end;

    var
        TempDeleteBuffer: Record "User Setup Line CZL" temporary;
        TempInsertBuffer: Record "User Setup Line CZL" temporary;

    procedure ReadFrom(var UserSetupLineCZL: Record "User Setup Line CZL")
    begin
        TempDeleteBuffer.Reset();
        TempDeleteBuffer.DeleteAll();
        TempInsertBuffer.Reset();
        TempInsertBuffer.DeleteAll();

        if UserSetupLineCZL.FindSet() then
            repeat
                if not Get(UserSetupLineCZL."Code / Name", UserSetupLineCZL."User ID") then begin
                    Init();
                    CopyFrom(UserSetupLineCZL);
                    Insert();
                end else begin
                    SetUserSetupValues(UserSetupLineCZL);
                    Modify();
                end;
            until UserSetupLineCZL.Next() = 0;
    end;

    procedure WriteChanges()
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        TempDeleteBuffer.Reset();
        if TempDeleteBuffer.FindSet() then
            repeat
                UserSetupLineCZL.SetRange("User ID", TempDeleteBuffer."User ID");
                UserSetupLineCZL.SetRange(Type, TempDeleteBuffer.Type);
                UserSetupLineCZL.SetRange("Code / Name", TempDeleteBuffer."Code / Name");
                UserSetupLineCZL.DeleteAll(true);
            until TempDeleteBuffer.Next() = 0;

        TempInsertBuffer.Reset();
        if TempInsertBuffer.FindSet() then
            repeat
                UserSetupLineCZL.Init();
                UserSetupLineCZL := TempInsertBuffer;
                UserSetupLineCZL."Line No." := FindLastUserSetupLineNo(TempInsertBuffer."User ID", TempInsertBuffer.Type) + 10000;
                UserSetupLineCZL.Insert(true);
            until TempInsertBuffer.Next() = 0;
    end;

    procedure CopyFrom(UserSetupLineCZL: Record "User Setup Line CZL")
    begin
        Code := UserSetupLineCZL."Code / Name";
        "User ID" := UserSetupLineCZL."User ID";
        SetUserSetupValues(UserSetupLineCZL);
    end;

    procedure SetUserSetupValues(UserSetupLineCZL: Record "User Setup Line CZL")
    begin
        "Post Quantity Increase" := "Post Quantity Increase" or (UserSetupLineCZL.Type = UserSetupLineCZL.Type::"Location (quantity increase)");
        "Post Quantity Decrease" := "Post Quantity Decrease" or (UserSetupLineCZL.Type = UserSetupLineCZL.Type::"Location (quantity decrease)");
        "Release Quantity Increase" := "Release Quantity Increase" or (UserSetupLineCZL.Type = UserSetupLineCZL.Type::"Release Location (quantity increase)");
        "Release Quantity Decrease" := "Release Quantity Decrease" or (UserSetupLineCZL.Type = UserSetupLineCZL.Type::"Release Location (quantity decrease)");
        OnAfterSetUserSetupValues(Rec, UserSetupLineCZL);
    end;

    protected procedure ValidateUserSetupValue(Type: Enum "User Setup Line Type CZL"; Value: Boolean)
    begin
        if Value then
            if IsDeleteBufferExist(Type) then
                RemoveFromDeleteBuffer(Type)
            else
                AddToInsertBuffer(Type)
        else
            if IsInsertBufferExist(Type) then
                RemoveFromInsertBuffer(Type)
            else
                AddToDeleteBuffer(Type);
    end;

    local procedure AddToInsertBuffer(Type: Enum "User Setup Line Type CZL")
    begin
        AddToBuffer(Type, TempInsertBuffer);
    end;

    local procedure AddToDeleteBuffer(Type: Enum "User Setup Line Type CZL")
    begin
        AddToBuffer(Type, TempDeleteBuffer);
    end;

    local procedure AddToBuffer(Type: Enum "User Setup Line Type CZL"; var TempUserSetupLineCZL: Record "User Setup Line CZL" temporary)
    begin
        TempUserSetupLineCZL.Init();
        TempUserSetupLineCZL."User ID" := Rec."User ID";
        TempUserSetupLineCZL.Type := Type;
        TempUserSetupLineCZL."Code / Name" := Rec.Code;
        TempUserSetupLineCZL.Insert();
    end;

    local procedure RemoveFromInsertBuffer(Type: Enum "User Setup Line Type CZL")
    begin
        RemoveFromBuffer(Type, TempInsertBuffer);
    end;

    local procedure RemoveFromDeleteBuffer(Type: Enum "User Setup Line Type CZL")
    begin
        RemoveFromBuffer(Type, TempDeleteBuffer);
    end;

    local procedure RemoveFromBuffer(Type: Enum "User Setup Line Type CZL"; var TempUserSetupLineCZL: Record "User Setup Line CZL" temporary)
    begin
        TempUserSetupLineCZL.SetRange("User ID", Rec."User ID");
        TempUserSetupLineCZL.SetRange(Type, Type);
        TempUserSetupLineCZL.SetRange("Code / Name", Rec.Code);
        TempUserSetupLineCZL.DeleteAll();
    end;

    local procedure IsInsertBufferExist(Type: Enum "User Setup Line Type CZL"): Boolean
    begin
        exit(IsBufferExist(Type, TempInsertBuffer));
    end;

    local procedure IsDeleteBufferExist(Type: Enum "User Setup Line Type CZL"): Boolean
    begin
        exit(IsBufferExist(Type, TempDeleteBuffer));
    end;

    local procedure IsBufferExist(Type: Enum "User Setup Line Type CZL"; var TempUserSetupLineCZL: Record "User Setup Line CZL" temporary): Boolean
    begin
        TempUserSetupLineCZL.SetRange("User ID", Rec."User ID");
        TempUserSetupLineCZL.SetRange(Type, Type);
        TempUserSetupLineCZL.SetRange("Code / Name", Rec.Code);
        exit(not TempUserSetupLineCZL.IsEmpty());
    end;

    local procedure FindLastUserSetupLineNo(UserID: Code[50]; Type: Enum "User Setup Line Type CZL"): Integer
    var
        LastUserSetupLineCZL: Record "User Setup Line CZL";
    begin
        LastUserSetupLineCZL.SetRange("User ID", UserID);
        LastUserSetupLineCZL.SetRange(Type, Type);
        if LastUserSetupLineCZL.FindLast() then
            exit(LastUserSetupLineCZL."Line No.");
        exit(0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetUserSetupValues(var UserSetupPerCodeBufferCZL: Record "User Setup per Code Buffer CZL"; UserSetupLineCZL: Record "User Setup Line CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDelete(var UserSetupPerCodeBufferCZL: Record "User Setup per Code Buffer CZL")
    begin
    end;
}