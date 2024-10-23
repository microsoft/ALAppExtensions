codeunit 4779 "Create Mfg Item Jnl Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
        CreateMfgItem: Codeunit "Create Mfg Item";
        ContosoItem: Codeunit "Contoso Item";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateMfgItemJournalSetup: Codeunit "Create Mfg Item Journal Setup";
        TemplateName, BatchName : Code[10];
    begin
        ManufacturingDemoDataSetup.Get();

        ItemJournalTemplate.Get(CreateMfgItemJournalSetup.ItemTemplateName());
        ItemJournalBatch.Get(ItemJournalTemplate.Name, ContosoUtilities.GetDefaultBatchNameLbl());

        BatchName := ItemJournalBatch.Name;
        TemplateName := ItemJournalTemplate.Name;

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2001(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2002(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2003(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2004(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1101(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1102(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1103(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1104(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1105(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1106(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1107(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1108(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1109(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2000(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1305(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 1000, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1301(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1304(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1302(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1303(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if ItemJournalLine.FindFirst() then
            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
    end;

    var
        StartManufacturingTok: Label 'START-MANF', MaxLength = 20;

    procedure StartManufacturingDocumentNo(): Code[20]
    begin
        exit(StartManufacturingTok);
    end;
}

