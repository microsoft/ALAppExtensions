codeunit 4789 "Create Whse Item Jnl"
{
    Permissions = tabledata "Item Journal Template" = rim,
        tabledata "Item Journal Batch" = rim,
        tabledata "Warehouse Journal Template" = rim;

    var
        DoInsertTriggers: Boolean;

    trigger OnRun()
    begin
        CreateCollection(false);
    end;

    local procedure CreateItemJournalTemplate(
        Name: Code[10];
        Description: Text[80];
        TestReportID: Integer;
        PageID: Integer;
        PostingReportID: Integer;
        ForcePostingReport: Boolean;
        Type: Enum "Item Journal Template Type";
        SourceCode: Code[10];
        ReasonCode: Code[10];
        Recurring: Boolean;
        NoSeries: Code[20];
        PostingNoSeries: Code[20];
        WhseRegisterReportID: Integer;
        IncrementBatchName: Boolean
    )
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        ItemJournalTemplate.Init();
        ItemJournalTemplate."Name" := Name;
        ItemJournalTemplate."Description" := Description;
        ItemJournalTemplate."Test Report ID" := TestReportID;
        ItemJournalTemplate."Page ID" := PageID;
        ItemJournalTemplate."Posting Report ID" := PostingReportID;
        ItemJournalTemplate."Force Posting Report" := ForcePostingReport;
        ItemJournalTemplate."Type" := Type;
        ItemJournalTemplate."Source Code" := SourceCode;
        ItemJournalTemplate."Reason Code" := ReasonCode;
        ItemJournalTemplate."Recurring" := Recurring;
        ItemJournalTemplate."No. Series" := NoSeries;
        ItemJournalTemplate."Posting No. Series" := PostingNoSeries;
        ItemJournalTemplate."Whse. Register Report ID" := WhseRegisterReportID;
        ItemJournalTemplate."Increment Batch Name" := IncrementBatchName;
        ItemJournalTemplate.Insert(DoInsertTriggers);
    end;

    local procedure CreateItemJournalBatch(
        JournalTemplateName: Code[10];
        Name: Code[10];
        Description: Text[100];
        ReasonCode: Code[10];
        NoSeries: Code[20];
        PostingNoSeries: Code[20]
    )
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalBatch.Init();
        ItemJournalBatch."Journal Template Name" := JournalTemplateName;
        ItemJournalBatch."Name" := Name;
        ItemJournalBatch."Description" := Description;
        ItemJournalBatch."Reason Code" := ReasonCode;
        ItemJournalBatch."No. Series" := NoSeries;
        ItemJournalBatch."Posting No. Series" := PostingNoSeries;
        ItemJournalBatch.Insert(DoInsertTriggers);
    end;

    local procedure CreateWarehouseJournalTemplate(
        Name: Code[10];
        Description: Text[80];
        TestReportID: Integer;
        PageID: Integer;
        RegisteringReportID: Integer;
        ForceRegisteringReport: Boolean;
        Type: Enum "Warehouse Journal Template Type";
        SourceCode: Code[10];
        ReasonCode: Code[10];
        NoSeries: Code[20];
        RegisteringNoSeries: Code[20];
        IncrementBatchName: Boolean
    )
    var
        WarehouseJournalTemplate: Record "Warehouse Journal Template";
    begin
        WarehouseJournalTemplate.Init();
        WarehouseJournalTemplate."Name" := Name;
        WarehouseJournalTemplate."Description" := Description;
        WarehouseJournalTemplate."Test Report ID" := TestReportID;
        WarehouseJournalTemplate."Page ID" := PageID;
        WarehouseJournalTemplate."Registering Report ID" := RegisteringReportID;
        WarehouseJournalTemplate."Force Registering Report" := ForceRegisteringReport;
        WarehouseJournalTemplate."Type" := Type;
        WarehouseJournalTemplate."Source Code" := SourceCode;
        WarehouseJournalTemplate."Reason Code" := ReasonCode;
        WarehouseJournalTemplate."No. Series" := NoSeries;
        WarehouseJournalTemplate."Registering No. Series" := RegisteringNoSeries;
        WarehouseJournalTemplate."Increment Batch Name" := IncrementBatchName;
        WarehouseJournalTemplate.Insert(DoInsertTriggers);
    end;

    local procedure CreateCollection(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreateItemJournalTemplate('ITEM', 'Item Journal', 702, 40, 703, false, Enum::"Item Journal Template Type"::Item, 'ITEMJNL', '', false, 'IJNL-GEN', '', 7303, false);
        CreateItemJournalTemplate('PHYS. INV.', 'Item Journal', 702, 392, 703, false, Enum::"Item Journal Template Type"::"Phys. Inventory", 'PHYSINVJNL', '', false, 'IJNL-PHYS', '', 7303, false);
        CreateItemJournalTemplate('RECLASS', 'Item Reclass. Journal', 702, 393, 703, false, Enum::"Item Journal Template Type"::Item, 'RECLASSJNL', '', false, 'IJNL-RCL', '', 7303, false);
        CreateItemJournalTemplate('RECURRING', 'Recurring Item Journal', 702, 286, 703, false, Enum::"Item Journal Template Type"::Item, 'ITEMJNL', '', true, '', 'IJNL-REC', 7303, false);
        CreateItemJournalTemplate('REVAL', 'Revaluation Journal', 5812, 5803, 5805, false, Enum::"Item Journal Template Type"::Revaluation, 'REVALJNL', '', false, 'IJNL-REVAL', '', 7303, false);

        CreateItemJournalBatch('ITEM', 'DEFAULT', 'Default Journal', '', 'IJNL-GEN', '');
        CreateItemJournalBatch('PHYS. INV.', 'DEFAULT', 'Default Journal', '', 'IJNL-PHYS', '');
        CreateItemJournalBatch('RECLASS', 'DEFAULT', 'Default Journal', '', 'IJNL-RCL', '');
        CreateItemJournalBatch('REVAL', 'DEFAULT', 'Default Journal', '', 'IJNL-REVAL', '');

        CreateWarehouseJournalTemplate('ADJMT', 'Adjustment Journal', 7302, 7324, 7303, false, Enum::"Warehouse Journal Template Type"::Item, 'WHITEM', '', 'WJNL-ADJ', '', false);
        CreateWarehouseJournalTemplate('PHYSINVT', 'Physical Inventory Journal', 7302, 7326, 7303, false, Enum::"Warehouse Journal Template Type"::"Physical Inventory", 'WHPHYSINVT', '', 'WJNL-PHYS', '', false);
        CreateWarehouseJournalTemplate('RECLASS', 'Reclassification Journal', 7302, 7365, 7303, false, Enum::"Warehouse Journal Template Type"::Reclassification, 'WHRCLSSJNL', '', 'WJNL-RCLSS', '', false);
    end;
}
