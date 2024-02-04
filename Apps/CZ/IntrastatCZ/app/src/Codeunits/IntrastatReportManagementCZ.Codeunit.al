// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
#if not CLEAN24
using Microsoft.Foundation.Company;
#endif
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Transfer;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Reports;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Reports;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Utilities;
using System.Environment.Configuration;
using System.IO;
using System.Reflection;
using System.Utilities;

codeunit 31302 IntrastatReportManagementCZ
{
    Access = Internal;

    #region Init Setup
    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitSetup', '', true, true)]
    local procedure OnBeforeInitSetup(var IntrastatReportSetup: Record "Intrastat Report Setup"; var IsHandled: Boolean)
#if not CLEAN22
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
#endif
    begin
        IsHandled := true;

        CreateDefaultDataExchangeDef();
#if not CLEAN22
#pragma warning disable AL0432
        if StatutoryReportingSetupCZL.Get() then begin
            IntrastatReportSetup."No Item Charges in Int. CZ" := StatutoryReportingSetupCZL."No Item Charges in Intrastat";
            IntrastatReportSetup."Transaction Type Mandatory CZ" := StatutoryReportingSetupCZL."Transaction Type Mandatory";
            IntrastatReportSetup."Transaction Spec. Mandatory CZ" := StatutoryReportingSetupCZL."Transaction Spec. Mandatory";
            IntrastatReportSetup."Transport Method Mandatory CZ" := StatutoryReportingSetupCZL."Transport Method Mandatory";
            IntrastatReportSetup."Shipment Method Mandatory CZ" := StatutoryReportingSetupCZL."Shipment Method Mandatory";
            IntrastatReportSetup."Intrastat Rounding Type CZ" := Enum::"Intrastat Rounding Type CZ".FromInteger(StatutoryReportingSetupCZL."Intrastat Rounding Type");
        end;
#pragma warning restore AL0432
#endif

        IntrastatReportSetup."Report Shipments" := true;
        IntrastatReportSetup."Report Receipts" := true;
        IntrastatReportSetup."Cust. VAT No. on File" := IntrastatReportSetup."Cust. VAT No. on File"::"VAT Reg. No.";
        IntrastatReportSetup."Vend. VAT No. on File" := IntrastatReportSetup."Vend. VAT No. on File"::"VAT Reg. No.";
        IntrastatReportSetup."Company VAT No. on File" := IntrastatReportSetup."Company VAT No. on File"::"VAT Reg. No. Without EU Country Code";
        IntrastatReportSetup."Data Exch. Def. Code" := DefaultDataExchDefCodeLbl;
        IntrastatReportSetup."Data Exch. Def. Code - Receipt" := DefaultDataExchDefCodeLbl;
        IntrastatReportSetup."Data Exch. Def. Code - Shpt." := DefaultDataExchDefCodeLbl;
        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Ship-to Country";
        IntrastatReportSetup."VAT No. Based On" := IntrastatReportSetup."VAT No. Based On"::"Sell-to VAT";
        IntrastatReportSetup."Def. Private Person VAT No." := DefPrivatePersonVATNoLbl;
        IntrastatReportSetup."Def. 3-Party Trade VAT No." := Def3DPartyTradeVATNoLbl;
        IntrastatReportSetup."Def. VAT for Unknown State" := DefUnknowVATNoLbl;
        IntrastatReportSetup."Get Partner VAT For" := IntrastatReportSetup."Get Partner VAT For"::Shipment;
        IntrastatReportSetup."Def. Phys. Trans. - Returns CZ" := true;
        IntrastatReportSetup.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeCreateDefaultDataExchangeDef', '', false, false)]
    local procedure CreateDefaultDataExchDefOnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean)
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if IsHandled then
            exit;
        IsHandled := true;

        CreateDefaultDataExchangeDef();

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Data Exch. Def. Code" := DefaultDataExchDefCodeLbl;
        IntrastatReportSetup.Modify();
    end;

    internal procedure CreateDefaultDataExchangeDef()
    var
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
        DataExchangeXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022-CZ" Name="Intrastat Report 2022" Type="5" ReadingWritingXMLport="31300" ExternalDataHandlingCodeunit="4813" ColumnSeparator="2" FileType="1" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="1" Code="DEFAULT" Name="DEFAULT" ColumnCount="20"><DataExchColumnDef ColumnNo="1" Name="Month of Declaration" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Year of Declaration" Show="false" DataType="0" Length="4" TextPaddingRequired="false" PadCharacter="&amp;#032;" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="VAT Registration Number" Show="false" DataType="0" Length="10" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Arrival/Dispatch" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Partner ID" Show="false" DataType="0" Length="20" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Country of Dispatch/Arrival" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Region of Dispatch/Arrival" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Country of Origin" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Nature of Transaction" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Nature of Transport" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Delivery Terms" Show="false" DataType="0" Length="1" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Code of Movement" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Statistical Sign" Show="false" DataType="0" Length="2" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Item Description" Show="false" DataType="0" Length="80" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="16" Name="Net Mass" Show="false" DataType="2" DataFormattingCulture="cs-CZ" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="17" Name="Quantity in Supplementary Units" Show="false" DataType="2" DataFormattingCulture="cs-CZ" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="18" Name="Invoiced Value" Show="false" DataType="2" DataFormattingCulture="cs-CZ" Length="14" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="19" Name="Internal Note 1" Show="false" DataType="0" Length="40" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="20" Name="Internal Note 2" Show="false" DataType="0" Length="40" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="5" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="41" Optional="true" TransformationRule="INT_STAT_MONTH"><TransformationRules><Code>INT_STAT_MONTH</Code><Description>Transforming intrastat Statistics Period to month.</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>3</StartPosition><Length>2</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="2" FieldID="41" Optional="true" TransformationRule="INT_STAT_YEAR"><TransformationRules><Code>INT_STAT_YEAR</Code><Description>Transforming intrastat Statistics Period to year.</Description><TransformationType>11</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="3" FieldID="31310" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="3" Optional="true" TransformationRule="INT_ARRIVALDISPATCH"><TransformationRules><Code>INT_ARRIVALDISPATCH</Code><Description>Transforming intrastat "Receipt" type to letter ''A'' and "Shipment" type to letter ''D''.</Description><TransformationType>11</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="5" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="6" FieldID="7" Optional="true" TransformationRule="TRIM" /><DataExchFieldMapping ColumnNo="7" FieldID="26" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="24" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="10" FieldID="9" Optional="true" /><DataExchFieldMapping ColumnNo="11" FieldID="31320" Optional="true" /><DataExchFieldMapping ColumnNo="12" FieldID="31305" Optional="true" /><DataExchFieldMapping ColumnNo="13" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="14" FieldID="31300" Optional="true" /><DataExchFieldMapping ColumnNo="15" FieldID="6" Optional="true" TransformationRule="INT_ITEMDESC"><TransformationRules><Code>INT_ITEMDESC</Code><Description>Shorten the item description to the required length.</Description><TransformationType>4</TransformationType><FindValue /><ReplaceValue /><StartPosition>1</StartPosition><Length>80</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="16" FieldID="21" Optional="true" TransformationRule="INT_ROUNDTOINTGTONE"><TransformationRules><Code>INT_ROUNDTOINTGTONE</Code><Description>Round to integer when the decimal is greater than 1.</Description><TransformationType>11</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="17" FieldID="35" Optional="true" TransformationRule="INT_ROUNDTOINTGTONE"><TransformationRules><Code>INT_ROUNDTOINTGTONE</Code><Description>Round to integer when the decimal is greater than 1.</Description><TransformationType>11</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="18" FieldID="13" Optional="true" TransformationRule="INT_ROUNDTOINT"><TransformationRules><Code>INT_ROUNDTOINT</Code><Description>Round to integer and take into account the rounding direction setting in intrastat report setup.</Description><TransformationType>11</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0</Precision><Direction /><ExportFromDateType>0</ExportFromDateType></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="19" FieldID="31315" Optional="true" /><DataExchFieldMapping ColumnNo="20" FieldID="31316" Optional="true" /><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="29" /><DataExchFieldGrouping FieldID="31320" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
    begin
        if DataExchDef.Get(DefaultDataExchDefCodeLbl) then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLTxt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
    end;
    #endregion

    #region Check List
    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeInitCheckList', '', true, true)]
    local procedure OnBeforeInitCheckList(var IsHandled: Boolean)
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
    begin
        IsHandled := true;

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 5);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 7);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 8);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 9);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 13);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 21);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 24);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 28);
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 29);
        IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
        IntrastatReportChecklist.Insert(true);

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", 35);
        IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: True');
        IntrastatReportChecklist.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeValidateReportWithAdvancedChecklist', '', false, false)]
    local procedure OnBeforeValidateReportWithAdvancedChecklist(var IntrastatReportLine: Record "Intrastat Report Line"; IntrastatReportHeader: Record "Intrastat Report Header")
    begin
        if IntrastatReportHeader."Statement Type CZ" = IntrastatReportHeader."Statement Type CZ"::Negative then
            IntrastatReportLine.SetFilter("Line No.", '<0'); // disable validation for negative statement
    end;
    #endregion

    #region Copy fields
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnAfterGetItem', '', false, false)]
    local procedure CopyFromItemOnValidateItemNoOnAfterGetItem(var ItemJournalLine: Record "Item Journal Line"; Item: Record Item)
    begin
        ItemJournalLine."Statistic Indication CZ" := Item."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValuesJobJournalLine(var JobJournalLine: Record "Job Journal Line"; Item: Record Item)
    begin
        JobJournalLine."Statistic Indication CZ" := Item."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValuesPurchLine(var PurchLine: Record "Purchase Line"; Item: Record Item; PurchHeader: Record "Purchase Header")
    begin
        PurchLine."Statistic Indication CZ" := Item."Statistic Indication CZ";
        PurchLine."Physical Transfer CZ" := PurchHeader."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignFixedAssetValues', '', false, false)]
    local procedure CopyFromFixedAssetOnAfterAssignFixedAssetValuesPurchaseLine(var PurchLine: Record "Purchase Line"; FixedAsset: Record "Fixed Asset"; PurchHeader: Record "Purchase Header")
    begin
        PurchLine."Statistic Indication CZ" := FixedAsset."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValuesSalesLine(var SalesLine: Record "Sales Line"; Item: Record Item; SalesHeader: Record "Sales Header")
    begin
        SalesLine."Statistic Indication CZ" := Item."Statistic Indication CZ";
        SalesLine."Physical Transfer CZ" := SalesHeader."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignFixedAssetValues', '', false, false)]
    local procedure CopyFromFixedAssetOnAfterAssignFixedAssetValuesSalesLine(var SalesLine: Record "Sales Line"; FixedAsset: Record "Fixed Asset")
    begin
        SalesLine."Statistic Indication CZ" := FixedAsset."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValuesServiceLine(var ServiceLine: Record "Service Line"; Item: Record Item; ServiceHeader: Record "Service Header")
    begin
        ServiceLine."Statistic Indication CZ" := Item."Statistic Indication CZ";
        ServiceLine."Physical Transfer CZ" := ServiceHeader."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValuesTransferLine(var TransferLine: Record "Transfer Line"; Item: Record Item)
    begin
        TransferLine."Statistic Indication CZ" := Item."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Direct Trans. Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyFromTransferLine(var DirectTransLine: Record "Direct Trans. Line"; TransferLine: Record "Transfer Line")
    begin
        DirectTransLine."Statistic Indication CZ" := TransferLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Transfer", 'OnAfterCreateItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; DirectTransLine: Record "Direct Trans. Line")
    begin
        ItemJnlLine."Statistic Indication CZ" := DirectTransLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Transfer", 'OnInsertDirectTransHeaderOnBeforeDirectTransHeaderInsert', '', false, false)]
    local procedure CopyFieldsOnInsertDirectTransHeaderOnBeforeDirectTransHeaderInsert(TransferHeader: Record "Transfer Header"; var DirectTransHeader: Record "Direct Trans. Header")
    begin
        DirectTransHeader."Intrastat Exclude CZ" := TransferHeader."Intrastat Exclude CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure CopyFieldsOnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        NewItemLedgEntry."Statistic Indication CZ" := ItemJournalLine."Statistic Indication CZ";
        NewItemLedgEntry."Physical Transfer CZ" := ItemJournalLine."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesHeader', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromSalesHeader(var ItemJnlLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header")
    begin
        ItemJnlLine."Physical Transfer CZ" := SalesHeader."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromSalesLine(var ItemJnlLine: Record "Item Journal Line"; SalesLine: Record "Sales Line")
    begin
        ItemJnlLine."Statistic Indication CZ" := SalesLine."Statistic Indication CZ";
        ItemJnlLine."Physical Transfer CZ" := SalesLine."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchHeader', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromPurchHeader(var ItemJnlLine: Record "Item Journal Line"; PurchHeader: Record "Purchase Header")
    begin
        ItemJnlLine."Physical Transfer CZ" := PurchHeader."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromPurchLine(var ItemJnlLine: Record "Item Journal Line"; PurchLine: Record "Purchase Line")
    begin
        ItemJnlLine."Statistic Indication CZ" := PurchLine."Statistic Indication CZ";
        ItemJnlLine."Physical Transfer CZ" := PurchLine."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServHeader', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromServHeader(var ItemJnlLine: Record "Item Journal Line"; ServHeader: Record "Service Header")
    begin
        ItemJnlLine."Physical Transfer CZ" := ServHeader."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromServLine(var ItemJnlLine: Record "Item Journal Line"; ServLine: Record "Service Line")
    begin
        ItemJnlLine."Statistic Indication CZ" := ServLine."Statistic Indication CZ";
        ItemJnlLine."Physical Transfer CZ" := ServLine."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure CopyFieldsOnBeforePostItemJournalLineOnPostReceipt(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    begin
        ItemJournalLine."Statistic Indication CZ" := TransferLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterCreateItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCreateItemJnlLineOnPostShipment(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    begin
        ItemJournalLine."Statistic Indication CZ" := TransferLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServShptLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromServShptLine(var ItemJnlLine: Record "Item Journal Line"; ServShptLine: Record "Service Shipment Line")
    begin
        ItemJnlLine."Statistic Indication CZ" := ServShptLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServShptLineUndo', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromServShptLineUndo(var ItemJnlLine: Record "Item Journal Line"; ServShptLine: Record "Service Shipment Line")
    begin
        ItemJnlLine."Statistic Indication CZ" := ServShptLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromPlanningSalesLineToJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterFromPlanningSalesLineToJnlLine(var JobJnlLine: Record "Job Journal Line"; SalesLine: Record "Sales Line")
    begin
        JobJnlLine."Statistic Indication CZ" := SalesLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromPurchaseLineToJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterFromPurchaseLineToJnlLine(var JobJnlLine: Record "Job Journal Line"; PurchLine: Record "Purchase Line")
    begin
        JobJnlLine."Statistic Indication CZ" := PurchLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromJnlLineToLedgEntry', '', false, false)]
    local procedure CopyFieldsOnAfterFromJnlLineToLedgEntry(var JobLedgerEntry: Record "Job Ledger Entry"; JobJournalLine: Record "Job Journal Line")
    begin
        JobLedgerEntry."Statistic Indication CZ" := JobJournalLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyFromTransferLineTransferReceipt(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    begin
        TransferReceiptLine."Statistic Indication CZ" := TransferLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyFromTransferLineTransferShipment(var TransferShipmentLine: Record "Transfer Shipment Line"; TransferLine: Record "Transfer Line")
    begin
        TransferShipmentLine."Statistic Indication CZ" := TransferLine."Statistic Indication CZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnUpdatePurchLinesByChangedFieldName', '', false, false)]
    local procedure UpdatePurchLinesByChangedFieldName(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; ChangedFieldName: Text[100]; ChangedFieldNo: Integer)
    begin
        case ChangedFieldNo of
            PurchHeader.FieldNo("Physical Transfer CZ"):
                if (PurchLine.Type = PurchLine.Type::Item) and (PurchLine."No." <> '') then
                    PurchLine."Physical Transfer CZ" := PurchHeader."Physical Transfer CZ";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateSalesLineByChangedFieldName', '', false, false)]
    local procedure UpdateSalesLineByChangedFieldName(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldName: Text[100]; ChangedFieldNo: Integer)
    begin
        case ChangedFieldNo of
            SalesHeader.FieldNo("Physical Transfer CZ"):
                if (SalesLine.Type = SalesLine.Type::Item) and (SalesLine."No." <> '') then
                    SalesLine."Physical Transfer CZ" := SalesHeader."Physical Transfer CZ";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnUpdateServLineByChangedFieldName', '', false, false)]
    local procedure UpdateServLineByChangedFieldName(ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; ChangedFieldName: Text[100])
    begin
        case ChangedFieldName of
            ServiceHeader.FieldCaption("Physical Transfer CZ"):
                if (ServiceLine.Type = ServiceLine.Type::Item) and (ServiceLine."No." <> '') then begin
                    ServiceLine."Physical Transfer CZ" := ServiceHeader."Physical Transfer CZ";
                    ServiceLine.Modify(true);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterUpdatePurchLine', '', false, false)]
    local procedure UpdatePurchLineOnAfterUpdatePurchLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line")
    begin
        ToPurchLine."Physical Transfer CZ" := ToPurchHeader."Physical Transfer CZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterUpdateSalesLine', '', false, false)]
    local procedure UpdateSalesLineOnAfterUpdateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line")
    begin
        ToSalesLine."Physical Transfer CZ" := ToSalesHeader."Physical Transfer CZ";
    end;
    #endregion

    #region Statistic Indication
    [EventSubscriber(ObjectType::Table, Database::"Tariff Number", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteStatisticIndicationCZOnAfterDeleteTariffNumber(var Rec: Record "Tariff Number")
    var
        StatisticIndicationCZ: Record "Statistic Indication CZ";
    begin
        if Rec.IsTemporary() then
            exit;
        StatisticIndicationCZ.SetRange("Tariff No.", Rec."No.");
        StatisticIndicationCZ.DeleteAll();
    end;
    #endregion

    #region Intrastat Mandatory Fields
    [EventSubscriber(ObjectType::Report, Report::"Sales Document - Test", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckSalesDocSalesDocumentTest(SalesHeader: Record "Sales Header"; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        MustBeSpecifiedLbl: Label '%1 must be specified.', Comment = '%1 = FieldCaption';
    begin
        if not (SalesHeader.Ship or SalesHeader.Receive) then
            exit;
        if not IntrastatReportSetup.Get() then
            exit;
        if SalesHeader.IsIntrastatTransactionCZL() and SalesHeader.ShipOrReceiveInventoriableTypeItemsCZL() then begin
            if IntrastatReportSetup."Transaction Type Mandatory CZ" then
                if SalesHeader."Transaction Type" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transaction Type")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transaction Spec. Mandatory CZ" then
                if SalesHeader."Transaction Specification" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transaction Specification")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transport Method Mandatory CZ" then
                if SalesHeader."Transport Method" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transport Method")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Shipment Method Mandatory CZ" then
                if SalesHeader."Shipment Method Code" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Shipment Method Code")), ErrorCounter, ErrorText);
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Purchase Document - Test", 'OnAfterCheckPurchaseDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckPurchaseDocPurchaseDocumentTest(PurchaseHeader: Record "Purchase Header"; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        MustBeSpecifiedLbl: Label '%1 must be specified.', Comment = '%1 = FieldCaption';
    begin
        if not (PurchaseHeader.Ship or PurchaseHeader.Receive) then
            exit;
        if not IntrastatReportSetup.Get() then
            exit;
        if PurchaseHeader.IsIntrastatTransactionCZL() and PurchaseHeader.ShipOrReceiveInventoriableTypeItemsCZL() then begin
            if IntrastatReportSetup."Transaction Type Mandatory CZ" then
                if PurchaseHeader."Transaction Type" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transaction Type")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transaction Spec. Mandatory CZ" then
                if PurchaseHeader."Transaction Specification" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transaction Specification")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transport Method Mandatory CZ" then
                if PurchaseHeader."Transport Method" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transport Method")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Shipment Method Mandatory CZ" then
                if PurchaseHeader."Shipment Method Code" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Shipment Method Code")), ErrorCounter, ErrorText);
        end;
    end;

    local procedure AddError(Text: Text[250]; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    begin
        ErrorCounter += 1;
        ErrorText[ErrorCounter] := Text;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterCheckBeforePost', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckBeforePost(var TransferHeader: Record "Transfer Header")
    begin
        TransferHeader.CheckIntrastatMandatoryFieldsCZ();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckSalesDocSalesPost(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CheckIntrastatMandatoryFieldsCZ();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckPurchDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckSalesDocPurchPost(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader.CheckIntrastatMandatoryFieldsCZ();
    end;
    #endregion

    #region Supplementary Unit of Measure
    [EventSubscriber(ObjectType::Table, Database::"Unit of Measure", 'OnAfterDeleteEvent', '', false, false)]
    local procedure UpdateSupplUnitofMeasCodeCZLOnDeleteUnitofMeasure(var Rec: Record "Unit of Measure")
    var
        TariffNumber: Record "Tariff Number";
    begin
        if Rec.IsTemporary() then
            exit;
        TariffNumber.SetRange("Suppl. Unit of Measure", Rec.Code);
        TariffNumber.ModifyAll("Suppl. Unit of Measure", '');
        TariffNumber.ModifyAll("Supplementary Units", false);
        TariffNumber.ModifyAll("Suppl. Conversion Factor", 0);
    end;

    [EventSubscriber(ObjectType::XmlPort, XmlPort::"Import Tariff Numbers CZL", 'OnBeforeInsertTariffNumber', '', false, false)]
    local procedure ImportSuppUnitOfMeasureOnBeforeInsertTariffNumber(var TariffNumber: Record "Tariff Number"; LineDataDictionary: Dictionary of [Text, Text])
    var
        ImportTariffNumbersCZL: XmlPort "Import Tariff Numbers CZL";
        UnitOfMeasureCode: Text;
    begin
        if not LineDataDictionary.Get(ImportTariffNumbersCZL.GetUoMToken(), UnitOfMeasureCode) then
            exit;
        TariffNumber."Suppl. Unit of Measure" := CopyStr(UnitOfMeasureCode, 1, MaxStrlen(TariffNumber."Suppl. Unit of Measure"));
    end;

    [EventSubscriber(ObjectType::XmlPort, XmlPort::"Import Tariff Numbers CZL", 'OnAfterCopyFromTemp', '', false, false)]
    local procedure CopySuppUnitOfMeasureOnBeforeInsertTariffNumber(var TariffNumber: Record "Tariff Number"; TempTariffNumber: Record "Tariff Number" temporary; UoMMappingDictionary: Dictionary of [Code[10], Code[10]])
    var
        ImportTariffNumbersCZL: XmlPort "Import Tariff Numbers CZL";
        UnitofMeasureCode: Code[10];
    begin
        if TempTariffNumber."Suppl. Unit of Measure" = '' then
            exit;
        if TempTariffNumber."Suppl. Unit of Measure" = ImportTariffNumbersCZL.GetDummyUoMToken() then
            exit;
        if UoMMappingDictionary.Get(TempTariffNumber."Suppl. Unit of Measure", UnitofMeasureCode) then begin
            TariffNumber."Suppl. Unit of Measure" := UnitofMeasureCode;
            TariffNumber."Supplementary Units" := true;
        end;
    end;
    #endregion

    #region Guided Experience
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup()
    begin
        RegisterStatisticIndications();
        RegisterSpecificMovements();
        RegisterIntrastatDeliveryGroups();
    end;

    local procedure RegisterStatisticIndications()
    var
        StatisticIndicationsNameTxt: Label 'Statistic Indications';
        StatisticIndicationsDescriptionTxt: Label 'Set up or update Statistic Indications.';
        StatisticIndicationsKeywordsTxt: Label 'Intrastat';
    begin
        GuidedExperience.InsertManualSetup(StatisticIndicationsNameTxt, StatisticIndicationsNameTxt, StatisticIndicationsDescriptionTxt,
          2, ObjectType::Page, Page::"Statistic Indications CZ", ManualSetupCategory::"Intrastat CZ", StatisticIndicationsKeywordsTxt);
    end;

    local procedure RegisterSpecificMovements()
    var
        SpecificMovementsNameTxt: Label 'Specific Movements';
        SpecificMovementsDescriptionTxt: Label 'Set up or update Specific Movements.';
        SpecificMovementsKeywordsTxt: Label 'Intrastat';
    begin
        GuidedExperience.InsertManualSetup(SpecificMovementsNameTxt, SpecificMovementsNameTxt, SpecificMovementsDescriptionTxt,
          2, ObjectType::Page, Page::"Specific Movements CZ", ManualSetupCategory::"Intrastat CZ", SpecificMovementsKeywordsTxt);
    end;

    local procedure RegisterIntrastatDeliveryGroups()
    var
        IntrastatDeliveryGroupsNameTxt: Label 'Intrastat Delivery Groups';
        IntrastatDeliveryGroupsDescriptionTxt: Label 'Set up or update Intrastat Delivery Groups.';
        IntrastatDeliveryGroupsKeywordsTxt: Label 'Intrastat';
    begin
        GuidedExperience.InsertManualSetup(IntrastatDeliveryGroupsNameTxt, IntrastatDeliveryGroupsNameTxt, IntrastatDeliveryGroupsDescriptionTxt,
          1, ObjectType::Page, Page::"Intrastat Delivery Groups CZ", ManualSetupCategory::"Intrastat CZ", IntrastatDeliveryGroupsKeywordsTxt);
    end;
    #endregion

    #region Get Lines
    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnAfterSkipValueEntry', '', false, false)]
    local procedure OnAfterSkipValueEntry(ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsSkipped: Boolean)
    var
        ItemCharge: Record "Item Charge";
        ShipmentMethod: Record "Shipment Method";
    begin
        if IsSkipped then
            exit;
        if not ShipmentMethod.Get(ItemLedgerEntry."Shpt. Method Code") then
            exit;
        if not ItemCharge.Get(ValueEntry."Item Charge No.") then
            exit;
        IsSkipped := IsSkipped or
            not ShipmentMethod."Incl. Item Charges (Amt.) CZ" or
            not ItemCharge."Incl. in Intrastat Amount CZ";
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeHasCrossedBorder', '', false, false)]
    local procedure CheckIntrastatTransactionOnBeforeHasCrossedBorder(ItemLedgerEntry: Record "Item Ledger Entry"; var Result: Boolean; var IsHandled: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        if IsHandled then
            exit;
        if not ItemLedgerEntry.GetDocumentCZ(SalesHeader) then
            exit;
        if SalesHeader."EU 3-Party Intermed. Role CZL" or
           SalesHeader."Intrastat Exclude CZ"
        then begin
            Result := false;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnAfterGetAmtRoundingDirection', '', false, false)]
    local procedure SetRoundingDirectionOnAfterGetAmtRoundingDirection(var Direction: Text[1])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        Direction := IntrastatReportSetup.GetRoundingDirectionCZ();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertItemLedgerLine', '', false, false)]
    local procedure OnBeforeInsertItemLedgerLine(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        SpecificMovementCZ: Record "Specific Movement CZ";
        TempSalesHeader: Record "Sales Header" temporary;
        IntrastatReportManagement: Codeunit IntrastatReportManagement;
        RoundingDirection: Text[1];
    begin
        IntrastatReportHeader.Get(IntrastatReportLine."Intrastat No.");
        IntrastatReportLine."Partner VAT ID" := '';
        IntrastatReportLine."Statistics Period" := IntrastatReportHeader."Statistics Period";
        IntrastatReportLine."Company VAT Reg. No. CZ" := IntrastatReportManagement.GetCompanyVATRegNo();
        IntrastatReportLine.Type := ItemLedgerEntry.GetIntrastatReportLineType();
        IntrastatReportLine.Amount := ItemLedgerEntry.GetIntrastatAmountSign() * IntrastatReportLine.Amount;
        IntrastatReportLine.Validate(Quantity, ItemLedgerEntry.GetIntrastatQuantitySign() * IntrastatReportLine.Quantity);
        IntrastatReportLine.Validate("Shpt. Method Code");
        IntrastatReportLine.Validate("Source Type");
        if IntrastatReportLine."Specific Movement CZ" = '' then begin
            SpecificMovementCZ.GetOrCreate(SpecificMovementCZ.GetStandardCode());
            IntrastatReportLine."Specific Movement CZ" := SpecificMovementCZ.Code;
        end;

        if ItemLedgerEntry.GetDocumentCZ(TempSalesHeader) and (TempSalesHeader."Currency Code" <> '') then begin
            RoundingDirection := IntrastatReportSetup.GetRoundingDirectionCZ();
            IntrastatReportLine.Amount :=
                Round(
                    CalculateExchangeAmount(
                        IntrastatReportLine.Amount,
                        TempSalesHeader."Currency Factor",
                        TempSalesHeader."VAT Currency Factor CZL"),
                    1, RoundingDirection);
            IntrastatReportLine."Indirect Cost" :=
                Round(
                    CalculateExchangeAmount(
                        IntrastatReportLine."Indirect Cost",
                        TempSalesHeader."Currency Factor",
                        TempSalesHeader."VAT Currency Factor CZL"),
                    1, RoundingDirection);
        end;
    end;

#if not CLEAN24
    [Obsolete('Generates false quantity in a period where an item is not moved', '24.0')]
    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertValueEntryLine', '', false, false)]
    local procedure OnBeforeInsertValueEntryLine(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        SpecificMovementCZ: Record "Specific Movement CZ";
        TempSalesHeader: Record "Sales Header" temporary;
        DocumentType: Enum "Item Ledger Document Type";
        RoundingDirection: Text[1];
    begin
        IntrastatReportHeader.Get(IntrastatReportLine."Intrastat No.");
        IntrastatReportLine."Partner VAT ID" := '';
        IntrastatReportLine."Statistics Period" := IntrastatReportHeader."Statistics Period";
        IntrastatReportLine.Type := ItemLedgerEntry.GetIntrastatReportLineType();
        IntrastatReportLine.Amount := ItemLedgerEntry.GetIntrastatAmountSign() * IntrastatReportLine.Amount;
        IntrastatReportLine.Validate(Quantity, ItemLedgerEntry.GetIntrastatQuantitySign() * IntrastatReportLine.Quantity);
        IntrastatReportLine.Validate("Source Type");
        if IntrastatReportLine."Specific Movement CZ" = '' then begin
            SpecificMovementCZ.GetOrCreate(SpecificMovementCZ.GetStandardCode());
            IntrastatReportLine."Specific Movement CZ" := SpecificMovementCZ.Code;
        end;

        DocumentType := GetDocumentType(IntrastatReportLine.Date, IntrastatReportLine."Document No.");
        if GetDocument(DocumentType, IntrastatReportLine."Document No.", TempSalesHeader) and
           (TempSalesHeader."Currency Code" <> '')
        then begin
            RoundingDirection := IntrastatReportSetup.GetRoundingDirectionCZ();
            IntrastatReportLine.Amount :=
                Round(
                    CalculateExchangeAmount(
                        IntrastatReportLine.Amount,
                        TempSalesHeader."Currency Factor",
                        TempSalesHeader."VAT Currency Factor CZL"),
                    1, RoundingDirection);
            IntrastatReportLine."Indirect Cost" :=
                Round(
                    CalculateExchangeAmount(
                        IntrastatReportLine."Indirect Cost",
                        TempSalesHeader."Currency Factor",
                        TempSalesHeader."VAT Currency Factor CZL"),
                    1, RoundingDirection);
        end;
    end;
#endif
    procedure GetDocument(DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20]; var SalesHeader: Record "Sales Header") IsDocumentExist: Boolean
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
    begin
        Clear(SalesHeader);

        case DocumentType of
            DocumentType::"Sales Shipment":
                begin
                    IsDocumentExist := SalesShipmentHeader.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := SalesShipmentHeader."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := SalesShipmentHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := SalesShipmentHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := SalesShipmentHeader."Currency Factor";
                end;
            DocumentType::"Sales Invoice":
                begin
                    IsDocumentExist := SalesInvoiceHeader.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := SalesInvoiceHeader."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := SalesInvoiceHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := SalesInvoiceHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := SalesInvoiceHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Sales Credit Memo":
                begin
                    IsDocumentExist := SalesCrMemoHeader.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := SalesCrMemoHeader."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := SalesCrMemoHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := SalesCrMemoHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := SalesCrMemoHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Sales Return Receipt":
                begin
                    IsDocumentExist := ReturnReceiptHeader.Get(DocumentNo);
                    SalesHeader."Intrastat Exclude CZ" := ReturnReceiptHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := ReturnReceiptHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := ReturnReceiptHeader."Currency Factor";
                end;
            DocumentType::"Service Shipment":
                begin
                    IsDocumentExist := ServiceShipmentHeader.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := ServiceShipmentHeader."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := ServiceShipmentHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := ServiceShipmentHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := ServiceShipmentHeader."Currency Factor";
                end;
            DocumentType::"Service Invoice":
                begin
                    IsDocumentExist := ServiceInvoiceHeader.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := ServiceInvoiceHeader."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := ServiceInvoiceHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := ServiceInvoiceHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := ServiceInvoiceHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Service Credit Memo":
                begin
                    IsDocumentExist := ServiceCrMemoHeader.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := ServiceCrMemoHeader."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := ServiceCrMemoHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := ServiceCrMemoHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := ServiceCrMemoHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Purchase Receipt":
                begin
                    IsDocumentExist := PurchRcptHeader.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := PurchRcptHeader."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := PurchRcptHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := PurchRcptHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := PurchRcptHeader."Currency Factor";
                end;
            DocumentType::"Purchase Invoice":
                begin
                    IsDocumentExist := PurchInvHeader.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := PurchInvHeader."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := PurchInvHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := PurchInvHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := PurchInvHeader."VAT Currency Factor CZL";
                end;
            DocumentType::"Purchase Credit Memo":
                begin
                    IsDocumentExist := PurchCrMemoHdr.Get(DocumentNo);
                    SalesHeader."EU 3-Party Intermed. Role CZL" := PurchCrMemoHdr."EU 3-Party Intermed. Role CZL";
                    SalesHeader."Intrastat Exclude CZ" := PurchCrMemoHdr."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := PurchCrMemoHdr."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := PurchCrMemoHdr."VAT Currency Factor CZL";
                end;
            DocumentType::"Purchase Return Shipment":
                begin
                    IsDocumentExist := ReturnShipmentHeader.Get(DocumentNo);
                    SalesHeader."Intrastat Exclude CZ" := ReturnShipmentHeader."Intrastat Exclude CZ";
                    SalesHeader."Currency Factor" := ReturnShipmentHeader."Currency Factor";
                    SalesHeader."VAT Currency Factor CZL" := ReturnShipmentHeader."Currency Factor";
                end;
            else
                exit(false);
        end;
    end;

    local procedure GetDocumentType(PostingDate: Date; DocumentNo: Code[20]): Enum "Item Ledger Document Type"
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
    begin
        SalesShipmentHeader.Reset();
        SalesShipmentHeader.SetFilter("No.", DocumentNo);
        SalesShipmentHeader.SetRange("Posting Date", PostingDate);
        if not SalesShipmentHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Sales Shipment");

        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetFilter("No.", DocumentNo);
        SalesInvoiceHeader.SetRange("Posting Date", PostingDate);
        if not SalesInvoiceHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Sales Invoice");

        SalesCrMemoHeader.Reset();
        SalesCrMemoHeader.SetFilter("No.", DocumentNo);
        SalesCrMemoHeader.SetRange("Posting Date", PostingDate);
        if not SalesCrMemoHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Sales Credit Memo");

        ReturnReceiptHeader.Reset();
        ReturnReceiptHeader.SetFilter("No.", DocumentNo);
        ReturnReceiptHeader.SetRange("Posting Date", PostingDate);
        if not ReturnReceiptHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Sales Return Receipt");

        PurchRcptHeader.Reset();
        PurchRcptHeader.SetFilter("No.", DocumentNo);
        PurchRcptHeader.SetRange("Posting Date", PostingDate);
        if not PurchRcptHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Purchase Receipt");

        PurchInvHeader.Reset();
        PurchInvHeader.SetFilter("No.", DocumentNo);
        PurchInvHeader.SetRange("Posting Date", PostingDate);
        if not PurchInvHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Purchase Invoice");

        PurchCrMemoHdr.Reset();
        PurchCrMemoHdr.SetFilter("No.", DocumentNo);
        PurchCrMemoHdr.SetRange("Posting Date", PostingDate);
        if not PurchCrMemoHdr.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Purchase Credit Memo");

        ReturnShipmentHeader.Reset();
        ReturnShipmentHeader.SetFilter("No.", DocumentNo);
        ReturnShipmentHeader.SetRange("Posting Date", PostingDate);
        if not ReturnShipmentHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Purchase Return Shipment");

        ServiceShipmentHeader.Reset();
        ServiceShipmentHeader.SetFilter("No.", DocumentNo);
        ServiceShipmentHeader.SetRange("Posting Date", PostingDate);
        if not ServiceShipmentHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Service Shipment");

        ServiceInvoiceHeader.Reset();
        ServiceInvoiceHeader.SetFilter("No.", DocumentNo);
        ServiceInvoiceHeader.SetRange("Posting Date", PostingDate);
        if not ServiceInvoiceHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Service Invoice");

        ServiceCrMemoHeader.Reset();
        ServiceCrMemoHeader.SetFilter("No.", DocumentNo);
        ServiceCrMemoHeader.SetRange("Posting Date", PostingDate);
        if not ServiceCrMemoHeader.IsEmpty() then
            exit(Enum::"Item Ledger Document Type"::"Service Credit Memo");
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertJobLedgerLine', '', false, false)]
    local procedure OnBeforeValidateJobLedgerLineFields(var IntrastatReportLine: Record "Intrastat Report Line"; JobLedgerEntry: Record "Job Ledger Entry")
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        SpecificMovementCZ: Record "Specific Movement CZ";
    begin
        IntrastatReportHeader.Get(IntrastatReportLine."Intrastat No.");
        IntrastatReportLine."Partner VAT ID" := '';
        IntrastatReportLine."Statistics Period" := IntrastatReportHeader."Statistics Period";
        IntrastatReportLine.Type := JobLedgerEntry.GetIntrastatReportLineType();
        IntrastatReportLine.Amount := JobLedgerEntry.GetIntrastatAmountSign() * IntrastatReportLine.Amount;
        IntrastatReportLine.Validate(Quantity, JobLedgerEntry.GetIntrastatQuantitySign() * IntrastatReportLine.Quantity);
        IntrastatReportLine.Validate("Shpt. Method Code");
        IntrastatReportLine.Validate("Source Type");
        if IntrastatReportLine."Specific Movement CZ" = '' then begin
            SpecificMovementCZ.GetOrCreate(SpecificMovementCZ.GetStandardCode());
            IntrastatReportLine."Specific Movement CZ" := SpecificMovementCZ.Code;
        end;
    end;

    local procedure CalculateExchangeAmount(Amount: Decimal; DocumentCurrencyFactor: Decimal; IntrastatCurrencyFactor: Decimal): Decimal
    begin
        if (IntrastatCurrencyFactor <> 0) and (DocumentCurrencyFactor <> 0) then
            exit(Amount * DocumentCurrencyFactor / IntrastatCurrencyFactor);
        exit(Amount);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnAfterGetIntrastatReportLineType', '', false, false)]
    local procedure SetReceiptForCustom2OnAfterGetIntrastatReportLineType(FALedgerEntry: Record "FA Ledger Entry"; var IntrastatReportLineType: Enum "Intrastat Report Line Type")
    begin
        if (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Custom 2") and
           (FALedgerEntry."Document Type" = FALedgerEntry."Document Type"::Invoice)
        then
            IntrastatReportLineType := Enum::"Intrastat Report Line Type"::Receipt;
    end;
    #endregion

    #region Export
    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnBeforeDefineFileNames', '', false, false)]
    local procedure ChangeTXTToCSV(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    var
        FileNameLbl: Label 'Intrastat-%1.csv', Comment = '%1 - Statistics Period';
        ReceptFileNameLbl: Label 'Receipt-%1.csv', Comment = '%1 - Statistics Period';
        ShipmentFileNameLbl: Label 'Shipment-%1.csv', Comment = '%1 - Statistics Period';
        ZipFileNameLbl: Label 'Intrastat-%1.zip', Comment = '%1 - Statistics Period';
    begin
        FileName := StrSubstNo(FileNameLbl, IntrastatReportHeader."Statistics Period");
        ReceptFileName := StrSubstNo(ReceptFileNameLbl, IntrastatReportHeader."Statistics Period");
        ShipmentFileName := StrSubstNo(ShipmentFileNameLbl, IntrastatReportHeader."Statistics Period");
        ZipFileName := StrSubstNo(ZipFileNameLbl, IntrastatReportHeader."Statistics Period");
        IsHandled := true;
    end;
    #endregion

    #region Update Documents
    [EventSubscriber(ObjectType::Page, Page::"Pstd. Purch. Cr.Memo - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure CheckPurchCrMemoHdrPhysicalTransferOnAfterRecordChanged(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; xPurchCrMemoHdrGlobal: Record "Purch. Cr. Memo Hdr."; var IsChanged: Boolean)
    begin
        IsChanged := IsChanged or (PurchCrMemoHdr."Physical Transfer CZ" <> xPurchCrMemoHdrGlobal."Physical Transfer CZ");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Return Receipt - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure CheckPostedReturnReceiptPhysicalTransferOnAfterRecordChanged(var ReturnReceiptHeader: Record "Return Receipt Header"; xReturnReceiptHeaderGlobal: Record "Return Receipt Header"; var IsChanged: Boolean)
    begin
        IsChanged := IsChanged or (ReturnReceiptHeader."Physical Transfer CZ" <> xReturnReceiptHeaderGlobal."Physical Transfer CZ");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Pstd. Sales Cr. Memo - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure CheckSalesCrMemoHeaderPhysicalTransferOnAfterRecordChanged(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; xSalesCrMemoHeader: Record "Sales Cr.Memo Header"; var IsChanged: Boolean)
    begin
        IsChanged := IsChanged or (SalesCrMemoHeader."Physical Transfer CZ" <> xSalesCrMemoHeader."Physical Transfer CZ");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Return Shpt. - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure CheckPostedReturnShipmentPhysicalTransferOnAfterRecordChanged(var ReturnShipmentHeader: Record "Return Shipment Header"; xReturnShipmentHeaderGlobal: Record "Return Shipment Header"; var IsChanged: Boolean)
    begin
        IsChanged := IsChanged or (ReturnShipmentHeader."Physical Transfer CZ" <> xReturnShipmentHeaderGlobal."Physical Transfer CZ");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Cr. Memo. Hdr. - Edit", 'OnBeforePurchCrMemoHdrModify', '', false, false)]
    local procedure CopyPhysicalTransferOnBeforePurchCrMemoHdrModify(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchCrMemoHdrRec: Record "Purch. Cr. Memo Hdr.")
    begin
        PurchCrMemoHdr."Physical Transfer CZ" := PurchCrMemoHdrRec."Physical Transfer CZ";
#if not CLEAN22
#pragma warning disable AL0432
        PurchCrMemoHdr."Physical Transfer CZL" := PurchCrMemoHdrRec."Physical Transfer CZ";
#pragma warning restore AL0432
#endif
        PurchCrMemoHdr."Transaction Type" :=
            GetDefaultTransactionType(
                GetVendorBasedOnSetup(PurchCrMemoHdrRec."Buy-from Vendor No.", PurchCrMemoHdrRec."Pay-to Vendor No."),
                PurchCrMemoHdrRec."Physical Transfer CZ", true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Return Receipt Header - Edit", 'OnBeforeReturnReceiptHeaderModify', '', false, false)]
    local procedure CopyPhysicalTransferOnBeforeReturnReceiptHeaderModify(var ReturnReceiptHeader: Record "Return Receipt Header"; ReturnReceiptHeaderRec: Record "Return Receipt Header")
    begin
        ReturnReceiptHeader."Physical Transfer CZ" := ReturnReceiptHeaderRec."Physical Transfer CZ";
#if not CLEAN22
#pragma warning disable AL0432
        ReturnReceiptHeader."Physical Transfer CZL" := ReturnReceiptHeaderRec."Physical Transfer CZ";
#pragma warning restore AL0432
#endif
        ReturnReceiptHeader."Transaction Type" :=
            GetDefaultTransactionType(
                GetCustomerBasedOnSetup(ReturnReceiptHeaderRec."Sell-to Customer No.", ReturnReceiptHeaderRec."Bill-to Customer No."),
                ReturnReceiptHeaderRec."Physical Transfer CZ", true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Credit Memo Hdr. - Edit", 'OnBeforeSalesCrMemoHeaderModify', '', false, false)]
    local procedure CopyPhysicalTransferOnBeforeSalesCrMemoHeaderModify(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; FromSalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        SalesCrMemoHeader."Physical Transfer CZ" := FromSalesCrMemoHeader."Physical Transfer CZ";
#if not CLEAN22
#pragma warning disable AL0432
        SalesCrMemoHeader."Physical Transfer CZL" := FromSalesCrMemoHeader."Physical Transfer CZ";
#pragma warning restore AL0432
#endif
        SalesCrMemoHeader."Transaction Type" :=
            GetDefaultTransactionType(
                GetCustomerBasedOnSetup(FromSalesCrMemoHeader."Sell-to Customer No.", FromSalesCrMemoHeader."Bill-to Customer No."),
                FromSalesCrMemoHeader."Physical Transfer CZ", true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Return Shipment Header - Edit", 'OnBeforeReturnShipmentHeaderModify', '', false, false)]
    local procedure CopyPhysicalTransferOnBeforeReturnShipmentHeaderModify(var ReturnShipmentHeader: Record "Return Shipment Header"; ReturnShipmentHeaderRec: Record "Return Shipment Header")
    begin
        ReturnShipmentHeader."Physical Transfer CZ" := ReturnShipmentHeaderRec."Physical Transfer CZ";
#if not CLEAN22
#pragma warning disable AL0432
        ReturnShipmentHeader."Physical Transfer CZL" := ReturnShipmentHeaderRec."Physical Transfer CZ";
#pragma warning restore AL0432
#endif
        ReturnShipmentHeader."Transaction Type" :=
            GetDefaultTransactionType(
                GetVendorBasedOnSetup(ReturnShipmentHeaderRec."Buy-from Vendor No.", ReturnShipmentHeaderRec."Pay-to Vendor No."),
                ReturnShipmentHeaderRec."Physical Transfer CZ", true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Cr. Memo. Hdr. - Edit", 'OnRunOnAfterPurchCrMemoHdrEdit', '', false, false)]
    local procedure UpdateItemLedgerEntryOnRunOnAfterPurchCrMemoHdrEdit(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        UpdateItemLedgerEntry(Enum::"Item Ledger Document Type"::"Purchase Credit Memo", PurchCrMemoHdr."No.", PurchCrMemoHdr."Physical Transfer CZ");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Return Receipt Header - Edit", 'OnRunOnAfterReturnReceiptHeaderEdit', '', false, false)]
    local procedure UpdateItemLedgerEntryOnRunOnAfterReturnReceiptHeaderEdit(var ReturnReceiptHeader: Record "Return Receipt Header")
    begin
        UpdateItemLedgerEntry(Enum::"Item Ledger Document Type"::"Sales Return Receipt", ReturnReceiptHeader."No.", ReturnReceiptHeader."Physical Transfer CZ");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Credit Memo Hdr. - Edit", 'OnRunOnAfterSalesCrMemoHeaderEdit', '', false, false)]
    local procedure UpdateItemLedgerEntryOnRunOnAfterSalesCrMemoHeaderEdit(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        UpdateItemLedgerEntry(Enum::"Item Ledger Document Type"::"Sales Credit Memo", SalesCrMemoHeader."No.", SalesCrMemoHeader."Physical Transfer CZ");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Return Shipment Header - Edit", 'OnRunOnAfterReturnShipmentHeaderEdit', '', false, false)]
    local procedure UpdateItemLedgerEntryOnRunOnAfterReturnShipmentHeaderEdit(var ReturnShipmentHeader: Record "Return Shipment Header")
    begin
        UpdateItemLedgerEntry(Enum::"Item Ledger Document Type"::"Purchase Return Shipment", ReturnShipmentHeader."No.", ReturnShipmentHeader."Physical Transfer CZ");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Ledger Entry-Edit CZL", 'OnRunOnBeforeItemLedgEntryModify', '', false, false)]
    local procedure CopyPhysicalTransferOnRunOnBeforeItemLedgEntryModify(var ItemLedgerEntry: Record "Item Ledger Entry"; FromItemLedgerEntry: Record "Item Ledger Entry")
    begin
        ItemLedgerEntry."Physical Transfer CZ" := FromItemLedgerEntry."Physical Transfer CZ";
#if not CLEAN22
#pragma warning disable AL0432
        ItemLedgerEntry."Physical Transfer CZL" := FromItemLedgerEntry."Physical Transfer CZ";
#pragma warning restore AL0432
#endif
        ItemLedgerEntry."Transaction Type" := FromItemLedgerEntry."Transaction Type";
    end;

    local procedure UpdateItemLedgerEntry(DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20]; PhysicalTransfer: Boolean)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Partner: Variant;
    begin
        ItemLedgerEntry.SetCurrentKey("Document No.", "Document Type");
        ItemLedgerEntry.SetRange("Document No.", DocumentNo);
        ItemLedgerEntry.SetRange("Document Type", DocumentType);
        if ItemLedgerEntry.FindSet() then
            repeat
                ItemLedgerEntry."Physical Transfer CZ" := PhysicalTransfer;
#if not CLEAN22
#pragma warning disable AL0432
                ItemLedgerEntry."Physical Transfer CZL" := PhysicalTransfer;
#pragma warning restore AL0432
#endif
                case ItemLedgerEntry."Source Type" of
                    ItemLedgerEntry."Source Type"::Customer:
                        Partner := GetCustomerBasedOnSetup(ItemLedgerEntry."Source No.", ItemLedgerEntry."Invoice-to Source No. CZA");
                    ItemLedgerEntry."Source Type"::Vendor:
                        Partner := GetVendorBasedOnSetup(ItemLedgerEntry."Source No.", ItemLedgerEntry."Invoice-to Source No. CZA");
                end;

                ItemLedgerEntry."Transaction Type" :=
                    GetDefaultTransactionType(
                        Partner, ItemLedgerEntry."Physical Transfer CZ", ItemLedgerEntry.IsCreditDocType());
                Codeunit.Run(Codeunit::"Item Ledger Entry-Edit CZL", ItemLedgerEntry);
            until ItemLedgerEntry.Next() = 0;
    end;
    #endregion

    #region Intrastat Exclude
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeUpdateGlobalIsIntrastatTransaction', '', false, false)]
    local procedure CheckIntrastatExcludeOnBeforeUpdateGlobalIsIntrastatTransactionPurchase(PurchaseHeader: Record "Purchase Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if PurchaseHeader."Intrastat Exclude CZ" then begin
            Result := false;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeUpdateGlobalIsIntrastatTransaction', '', false, false)]
    local procedure CheckIntrastatExcludeOnBeforeUpdateGlobalIsIntrastatTransactionSales(SalesHeader: Record "Sales Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if SalesHeader."Intrastat Exclude CZ" then begin
            Result := false;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeIsIntrastatTransactionCZL', '', false, false)]
    local procedure CheckIntrastatExcludeOnBeforeIsIntrastatTransactionCZL(ServiceHeader: Record "Service Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if ServiceHeader."Intrastat Exclude CZ" then begin
            Result := false;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnBeforeUpdateGlobalIsIntrastatTransactionCZL', '', false, false)]
    local procedure CheckIntrastatExcludeOnBeforeUpdateGlobalIsIntrastatTransactionCZLTransfer(TransferHeader: Record "Transfer Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if TransferHeader."Intrastat Exclude CZ" then begin
            Result := false;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Direct Trans. Header", 'OnBeforeUpdateGlobalIsIntrastatTransactionCZL', '', false, false)]
    local procedure CheckIntrastatExcludeOnBeforeUpdateGlobalIsIntrastatTransactionCZLDirectTransfer(DirectTransHeader: Record "Direct Trans. Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if DirectTransHeader."Intrastat Exclude CZ" then begin
            Result := false;
            IsHandled := true;
        end;
    end;
    #endregion

    #region Helper functions
    internal procedure GetCustomerBasedOnSetup(SellTo: Code[20]; BillTo: Code[20]) Customer: Record Customer
    begin
        Customer.Get(GetPartnerNoBasedOnSetup(SellTo, BillTo));
    end;

    internal procedure GetVendorBasedOnSetup(SellTo: Code[20]; BillTo: Code[20]) Vendor: Record Vendor
    begin
        Vendor.Get(GetPartnerNoBasedOnSetup(SellTo, BillTo));
    end;

    internal procedure GetPartnerNoBasedOnSetup(SellTo: Code[20]; BillTo: Code[20]) PartnerNo: Code[20]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        IntrastatReportSetup.Get();
        case IntrastatReportSetup."VAT No. Based On" of
            IntrastatReportSetup."VAT No. Based On"::"Sell-to VAT":
                PartnerNo := SellTo;
            IntrastatReportSetup."VAT No. Based On"::"Bill-to VAT":
                PartnerNo := BillTo;
        end;
    end;

    internal procedure GetDefaultTransactionType(ServiceHeader: Record "Service Header"): Code[10]
    begin
        exit(GetDefaultTransactionType(
            ServiceHeader.GetPartnerBasedOnSetupCZ(),
            ServiceHeader."Physical Transfer CZ",
            ServiceHeader.IsCreditDocType()));
    end;

    internal procedure GetDefaultTransactionType(SalesHeader: Record "Sales Header"): Code[10]
    begin
        exit(GetDefaultTransactionType(
            SalesHeader.GetPartnerBasedOnSetupCZ(),
            SalesHeader."Physical Transfer CZ",
            SalesHeader.IsCreditDocType()));
    end;

    internal procedure GetDefaultTransactionType(PurchaseHeader: Record "Purchase Header"): Code[10]
    begin
        exit(GetDefaultTransactionType(
            PurchaseHeader.GetPartnerBasedOnSetupCZ(),
            PurchaseHeader."Physical Transfer CZ",
            PurchaseHeader.IsCreditDocType()));
    end;

    internal procedure GetDefaultTransactionType(Partner: Variant; IsPhysicalTransfer: Boolean; IsCreditDocType: Boolean) DefaultTransactionType: Code[10]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Customer: Record Customer;
        Vendor: Record Vendor;
        DataTypeManagement: Codeunit "Data Type Management";
        PartnerRecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(Partner, PartnerRecRef) then
            exit;

        case PartnerRecRef.Number of
            Database::Customer:
                begin
                    Customer := Partner;
                    DefaultTransactionType := Customer.GetDefaultTransactionTypeCZ(IsPhysicalTransfer, IsCreditDocType);
                end;
            Database::Vendor:
                begin
                    Vendor := Partner;
                    DefaultTransactionType := Vendor.GetDefaultTransactionTypeCZ(IsPhysicalTransfer, IsCreditDocType);
                end;
        end;

        if DefaultTransactionType = '' then
            DefaultTransactionType := IntrastatReportSetup.GetDefaultTransactionTypeCZ(IsPhysicalTransfer, IsCreditDocType);
    end;
    #endregion

    var
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";
        DefaultDataExchDefCodeLbl: Label 'INTRA-2022-CZ', Locked = true;
        DefPrivatePersonVATNoLbl: Label 'QV123', Locked = true;
        Def3DPartyTradeVATNoLbl: Label 'QV123', Locked = true;
        DefUnknowVATNoLbl: Label 'QV123', Locked = true;
}