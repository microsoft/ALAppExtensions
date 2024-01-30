codeunit 4779 "Create Mfg Item Jnl Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
        CreateMfgItem: Codeunit "Create Mfg Item";
        ContosoItem: Codeunit "Contoso Item";
        CreateMfgItemJournalSetup: Codeunit "Create Mfg Item Journal Setup";
        ContosoUtilities: Codeunit "Contoso Utilities";
        TemplateName, BatchName : Code[10];
    begin
        ManufacturingDemoDataSetup.Get();

        TemplateName := CreateMfgItemJournalSetup.ItemTemplateName();
        BatchName := CreateMfgItemJournalSetup.StartManufacturingBatchName();

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2001(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2002(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2003(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2004(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1101(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1102(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1103(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1104(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1105(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1106(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1107(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1108(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1109(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM2000(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));

        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1305(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 1000, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1301(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1302(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1303(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateMfgItem.SPBOM1304(), StartManufacturingDocumentNo(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 50, ManufacturingDemoDataSetup."Manufacturing Location", ContosoUtilities.AdjustDate(19020601D));
    end;

    var
        StartManufacturingTok: Label 'START-MANF', MaxLength = 20;

    procedure StartManufacturingDocumentNo(): Code[20]
    begin
        exit(StartManufacturingTok);
    end;
}

