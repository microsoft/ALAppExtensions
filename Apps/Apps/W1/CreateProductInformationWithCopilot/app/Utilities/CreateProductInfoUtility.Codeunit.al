// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using System.AI;
using Microsoft.Inventory.Item;
using System.Environment;

codeunit 7345 "Create Product Info. Utility"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ProcessingLinesLbl: Label 'Processing lines... \#1#########################################################################################', Comment = '#1 = PreparingSalesLineLbl or InsertingSalesLineLbl ';
        InsertingLineLbl: Label 'Inserting %1 of %2', Comment = '%1 = Counter, %2 = Total Lines';
        ChatCompletionResponseErr: Label 'Sorry, something went wrong. Please rephrase and try again.';

    procedure CopyItemSubstLines(Item: Record Item; var TempItemSubst: Record "Item Substitution" temporary)
    var
        ItemSubstitution: Record "Item Substitution";
        ProgressDialog: Dialog;
        Counter: Integer;
        TotalLines: Integer;
    begin
        if TempItemSubst.FindSet() then begin
            OpenProgressWindow(ProgressDialog);
            TotalLines := TempItemSubst.Count();
            repeat
                ItemSubstitution.Init();
                ItemSubstitution.Validate(Type, ItemSubstitution.Type::Item);
                ItemSubstitution.Validate("No.", Item."No.");
                ItemSubstitution.Validate("Variant Code", '');
                ItemSubstitution.Validate("Substitute Type", TempItemSubst."Substitute Type");
                ItemSubstitution.Validate("Substitute No.", TempItemSubst."Substitute No.");
                ItemSubstitution.Validate("Substitute Variant Code", TempItemSubst."Substitute Variant Code");
                ItemSubstitution.Insert(true);

                Counter += 1;
                ProgressDialog.Update(1, StrSubstNo(InsertingLineLbl, Counter, TotalLines));
            until TempItemSubst.Next() = 0;
            ProgressDialog.Close();
        end;
    end;

    local procedure OpenProgressWindow(var ProgressDialog: Dialog)
    begin
        ProgressDialog.Open(ProcessingLinesLbl);
        ProgressDialog.Update(1, '');
    end;

    internal procedure GetFeatureName(): Text
    begin
        exit('Create product information with Copilot');
    end;

    internal procedure GetChatCompletionResponseErr(): Text
    begin
        exit(ChatCompletionResponseErr);
    end;

    internal procedure GetMaxTokens(): Integer
    begin
        exit(4096);
    end;

    internal procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        DocUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2282370', Locked = true;
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Create Product Information") then
                CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Create Product Information", DocUrlLbl);
    end;
}
