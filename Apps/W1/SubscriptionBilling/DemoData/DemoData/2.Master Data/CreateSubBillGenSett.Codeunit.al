namespace Microsoft.SubscriptionBilling;

using System.IO;
using System.Utilities;

codeunit 8115 "Create Sub. Bill. Gen. Sett."
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Data Exch." = rd,
        tabledata "Sub. Billing Module Setup" = r;

    trigger OnRun()
    var
        SubBillingModuleSetup: Record "Sub. Billing Module Setup";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CreateSubBillSupplier: Codeunit "Create Sub. Bill. Supplier";
    begin
        SubBillingModuleSetup.Get();
        if SubBillingModuleSetup."Import Data Exch. Definition" then begin
            ImportGenericDataExchangeDefinition();
            ContosoSubscriptionBilling.InsertGenericImportSettings(CreateSubBillSupplier.Generic(), UsageDataGenericUsTok, false, true, Enum::"Additional Processing Type"::None, false);
        end else
            ContosoSubscriptionBilling.InsertGenericImportSettings(CreateSubBillSupplier.Generic(), '', false, true, Enum::"Additional Processing Type"::None, false);
    end;

    local procedure ImportGenericDataExchangeDefinition()
    var
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin

        if DataExchDef.Get(UsageDataGenericUsTok) then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(UsageDataGenericUsTxt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        Clear(TempBlob);
    end;

    var
        UsageDataGenericUsTok: Label 'USAGE-GENERIC-US', Locked = true;
        UsageDataGenericUsTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="USAGE-GENERIC-US" Name="Usage Data Generic (US format)" Type="3" ReadingWritingXMLport="1220" HeaderLines="1" ColumnSeparator="2" FileEncoding="1" FileType="1" LineSeparator="0"><DataExchLineDef LineType="0" Code="LINES" Name="Usage data" ColumnCount="15"><DataExchColumnDef ColumnNo="1" Name="Customer ID" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="2" Name="Customer Name" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="3" Name="Subscription ID" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="4" Name="Product ID" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="5" Name="Product Name" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="6" Name="Subscription Start Date" Show="false" DataType="1" DataFormat="MM-dd-yyyy" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="7" Name="Subscription End Date" Show="false" DataType="1" DataFormat="MM-dd-yyyy" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="8" Name="Billing Period Start Date" Show="false" DataType="1" DataFormat="MM-dd-yyyy" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="9" Name="Billing Period End Date" Show="false" DataType="1" DataFormat="MM-dd-yyyy" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="10" Name="Quantity" Show="false" DataType="2" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="11" Name="Unit Cost" Show="false" DataType="2" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="12" Name="Unit Price" Show="false" DataType="2" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="13" Name="Cost Amount" Show="false" DataType="2" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="14" Name="Amount" Show="false" DataType="2" DataFormattingCulture="en-US" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchColumnDef ColumnNo="15" Name="Currency" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" UseNodeNameAsValue="false" BlankZero="false" ExportIfNotBlank="false" /><DataExchMapping TableId="8018" Name="Usage data" MappingCodeunit="8030"><DataExchFieldMapping ColumnNo="1" FieldID="7" /><DataExchFieldMapping ColumnNo="2" FieldID="8" /><DataExchFieldMapping ColumnNo="3" FieldID="10" /><DataExchFieldMapping ColumnNo="4" FieldID="17" OverwriteValue="true" /><DataExchFieldMapping ColumnNo="5" FieldID="18" /><DataExchFieldMapping ColumnNo="6" FieldID="13" /><DataExchFieldMapping ColumnNo="7" FieldID="14" /><DataExchFieldMapping ColumnNo="8" FieldID="15" /><DataExchFieldMapping ColumnNo="9" FieldID="16" /><DataExchFieldMapping ColumnNo="10" FieldID="21" /><DataExchFieldMapping ColumnNo="11" FieldID="19" /><DataExchFieldMapping ColumnNo="12" FieldID="20" /><DataExchFieldMapping ColumnNo="13" FieldID="27" /><DataExchFieldMapping ColumnNo="14" FieldID="24" /><DataExchFieldMapping ColumnNo="15" FieldID="25" /></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
}