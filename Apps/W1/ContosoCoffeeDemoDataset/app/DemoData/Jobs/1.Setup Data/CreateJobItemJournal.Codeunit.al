// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Jobs;

using Microsoft.Foundation.AuditCodes;
using Microsoft.DemoTool.Helpers;
using Microsoft.Inventory.Journal;

codeunit 5198 "Create Job Item Journal"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContosoItem: Codeunit "Contoso Item";
        ContosoUtilities: Codeunit "Contoso Utilities";

    begin
        SourceCodeSetup.Get();

        ContosoItem.InsertItemJournalTemplate(ItemTemplate(), ItemJournalLbl, Enum::"Item Journal Template Type"::Item, false, SourceCodeSetup."Item Journal");

        ContosoItem.InsertItemJournalBatch(ItemTemplate(), ContosoUtilities.GetDefaultBatchNameLbl(), '');
    end;

    var
        ItemTok: Label 'ITEM', MaxLength = 10;
        ItemJournalLbl: Label 'Item Journal', MaxLength = 80;
        StartJobTok: Label 'START-PROJ', MaxLength = 10;

    procedure ItemTemplate(): Code[10]
    begin
        exit(ItemTok);
    end;

    procedure StartJobBatch(): Code[10]
    begin
        exit(StartJobTok);
    end;
}
