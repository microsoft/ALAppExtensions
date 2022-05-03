codeunit 4779 "Create Mfg Item Jnl Line"
{
    Permissions = tabledata "Item Journal Batch" = rm,
    tabledata "Item Journal Line" = ri;


    trigger OnRun()
    begin
        ManufacturingDemoDataSetup.Get();

        InsertData('SP-BOM2001', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM2002', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM2003', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM2004', 50, ManufacturingDemoDataSetup."Manufacturing Location");

        InsertData('SP-BOM1101', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM1102', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM1103', 50, ManufacturingDemoDataSetup."Manufacturing Location");

        InsertData('SP-BOM1104', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM1105', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM1106', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM1107', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM1108', 50, ManufacturingDemoDataSetup."Manufacturing Location");
        InsertData('SP-BOM1109', 50, ManufacturingDemoDataSetup."Manufacturing Location");
    end;

    var
        ItemJournalBatch: Record "Item Journal Batch";
        ManufacturingDemoDataSetup: Record "Manufacturing Demo Data Setup";
        LineNumber: Integer;
        XITEMTok: Label 'ITEM', MaxLength = 10, Comment = 'Must be the same as XITEMTok in CreateMfgJnlBatch codeunit';
        XDEFAULTTok: Label 'DEFAULT', MaxLength = 10;
        XSTARTMANFTok: Label 'START-MANF', MaxLength = 20;

    local procedure InsertData(ItemNumber: Code[20]; Quantity: Decimal; LocationCode: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
        AdjustManufacturingData: Codeunit "Adjust Manufacturing Data";
    begin
        InitItemJnlLine(ItemJournalLine, XITEMTok, XDEFAULTTok);
        ItemJournalLine.Validate("Item No.", ItemNumber);
        ItemJournalLine.Validate("Posting Date", AdjustManufacturingData.AdjustDate(19020601D));
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", XSTARTMANFTok);
        ItemJournalLine.Validate(Quantity, Quantity);
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine.Insert(true);
    end;

    local procedure InitItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        LastItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", JournalTemplateName);
        ItemJournalLine.Validate("Journal Batch Name", JournalBatchName);
        if (JournalTemplateName <> ItemJournalBatch."Journal Template Name") or
           (JournalBatchName <> ItemJournalBatch.Name)
        then begin
            ItemJournalBatch.Get(JournalTemplateName, JournalBatchName);
            if (ItemJournalBatch."No. Series" <> '') or
               (ItemJournalBatch."Posting No. Series" <> '')
            then begin
                ItemJournalBatch."No. Series" := '';
                ItemJournalBatch."Posting No. Series" := '';
                ItemJournalBatch.Modify();
            end;
        end;

        LastItemJournalLine.Reset();
        LastItemJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        LastItemJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if LastItemJournalLine.FindLast() then
            LineNumber := LastItemJournalLine."Line No." + 10000
        else
            LineNumber := 10000;
        ItemJournalLine.Validate("Line No.", LineNumber);
    end;
}

