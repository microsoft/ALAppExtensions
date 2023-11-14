// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Assembly;

using Microsoft.Assembly.Document;
using Microsoft.Assembly.Posting;
using Microsoft.Assembly.Setup;
using Microsoft.Inventory.Journal;
using Microsoft.Projects.Resources.Journal;

codeunit 31259 "Assembly Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Assembly Header", 'OnAfterInitRecord', '', false, false)]
    local procedure DefaultGenBusPostingGroupOnAfterInitRecord(var AssemblyHeader: Record "Assembly Header")
    var
        AssemblySetup: Record "Assembly Setup";
    begin
        AssemblySetup.Get();
        AssemblyHeader.Validate("Gen. Bus. Posting Group CZA", AssemblySetup."Default Gen.Bus.Post. Grp. CZA");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure GenBusPostingGroupOnAfterValidateNo(var Rec: Record "Assembly Line")
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        if Rec."No." = '' then
            exit;
        if not AssemblyHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        Rec.Validate("Gen. Bus. Posting Group CZA", AssemblyHeader."Gen. Bus. Posting Group CZA");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line Management", 'OnBeforeUpdateExistingLine', '', false, false)]
    local procedure GenBusPostingGroupOnBeforeUpdateExistingLine(var AssemblyLine: Record "Assembly Line"; var AsmHeader: Record "Assembly Header")
    begin
        AssemblyLine.Validate("Gen. Bus. Posting Group CZA", AsmHeader."Gen. Bus. Posting Group CZA");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnBeforePostItemConsumption', '', false, false)]
    local procedure GenBusPostingGroupOnBeforePostItemConsumption(var ItemJournalLine: Record "Item Journal Line"; AssemblyLine: Record "Assembly Line")
    begin
        ItemJournalLine."Gen. Bus. Posting Group" := AssemblyLine."Gen. Bus. Posting Group CZA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterCreateItemJnlLineFromAssemblyHeader', '', false, false)]
    local procedure GenBusPostingGroupOnAfterCreateItemJnlLineFromAssemblyHeader(var ItemJournalLine: Record "Item Journal Line"; AssemblyHeader: Record "Assembly Header")
    begin
        ItemJournalLine."Gen. Bus. Posting Group" := AssemblyHeader."Gen. Bus. Posting Group CZA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterCreateItemJnlLineFromAssemblyLine', '', false, false)]
    local procedure GenBusPostingGroupOnAfterCreateItemJnlLineFromAssemblyLine(var ItemJournalLine: Record "Item Journal Line"; AssemblyLine: Record "Assembly Line")
    begin
        ItemJournalLine."Gen. Bus. Posting Group" := AssemblyLine."Gen. Bus. Posting Group CZA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterCreateResJnlLineFromItemJnlLine', '', false, false)]
    local procedure GenBusPostingGroupOnAfterCreateResJnlLineFromItemJnlLine(var ResJournalLine: Record "Res. Journal Line"; AssemblyLine: Record "Assembly Line")
    begin
        ResJournalLine."Gen. Bus. Posting Group" := AssemblyLine."Gen. Bus. Posting Group CZA";
    end;
}
