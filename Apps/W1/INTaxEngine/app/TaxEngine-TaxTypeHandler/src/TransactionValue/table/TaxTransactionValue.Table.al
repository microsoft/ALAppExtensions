table 20261 "Tax Transaction Value"
{
    Caption = 'Tax Transaction Value';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Tax Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Tax Record ID';
        }
        field(3; "Column Name"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Column Name';
        }
        field(4; "Column Value"; Text[2000])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Column Value';
        }
        field(5; "Value Type"; Enum "Transaction Value Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Value Type';
        }
        field(6; "Case ID"; Guid)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Case ID';
        }
        field(7; "Percent"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Percent';
        }
        field(9; "Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Amount';
        }
        field(10; "Table ID Filter"; Integer)
        {
            FieldClass = FlowFilter;
            Caption = 'Table ID Filter';
        }
        field(11; "Document Type Filter"; Integer)
        {
            FieldClass = FlowFilter;
            Caption = 'Document Type Filter';
        }
        field(12; "Document No. Filter"; Text[20])
        {
            FieldClass = FlowFilter;
            Caption = 'Document No. Filter';
        }
        field(13; "Line No. Filter"; Integer)
        {
            FieldClass = FlowFilter;
            Caption = 'Line No. Filter';
        }
        field(14; "Template Name Filter"; Text[10])
        {
            FieldClass = FlowFilter;
            Caption = 'Template Name Filter';
        }
        field(15; "Batch Name Filter"; Text[10])
        {
            FieldClass = FlowFilter;
            Caption = 'Batch Name Filter';
        }
        field(16; "Value ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Value ID';
        }
        field(17; "Visible on Interface"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Visible on Interface';
        }
        field(18; "ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            AutoIncrement = true;
        }
        field(19; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(20; "Option Index"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Option Index';
        }
        field(21; "Amount (LCY)"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Amount (LCY)';
        }
        field(22; "Currency Code"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Currency.Code;
            Caption = 'Currency Code';
        }
        field(23; "Currency Factor"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Currency Factor';
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(K1; "Tax Record ID", "Tax Type")
        {
        }
    }
    procedure GetAttributeColumName(): Text
    var
        TaxAttribute: Record "Tax Attribute";
        TaxComponent: Record "Tax Component";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        case "Value Type" of
            "Value Type"::ATTRIBUTE:
                begin
                    TaxAttribute.SetRange(ID, "Value ID");
                    if TaxAttribute.FindFirst() then
                        exit(TaxAttribute.Name);
                end;
            "Value Type"::COMPONENT, "Value Type"::"COMPONENT PERCENT":
                begin
                    TaxComponent.SetRange("Tax Type", "Tax Type");
                    TaxComponent.SetRange(ID, "Value ID");
                    if TaxComponent.FindFirst() then
                        exit(TaxComponent.Name);
                end;
            "Value Type"::COLUMN:
                begin
                    TaxRateColumnSetup.SetRange("Column ID", "Value ID");
                    if TaxRateColumnSetup.FindFirst() then
                        exit(TaxRateColumnSetup."Column Name");
                end;
        end;
    end;

    procedure ShouldAttributeBeVisible(): Boolean
    var
        TaxAttribute: Record "Tax Attribute";
        TaxComponent: Record "Tax Component";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        case "Value Type" of
            "Value Type"::COMPONENT:
                begin
                    TaxComponent.SetRange("Tax Type", "Tax Type");
                    TaxComponent.SetRange(ID, "Value ID");
                    if TaxComponent.FindFirst() then
                        exit(TaxComponent."Visible On Interface");
                end;
            "Value Type"::COLUMN:
                begin
                    TaxRateColumnSetup.SetRange("Column ID", "Value ID");
                    TaxRateColumnSetup.FindFirst();
                    if TaxRateColumnSetup."Column Type" <> TaxRateColumnSetup."Column Type"::"Tax Attributes" then
                        exit(TaxRateColumnSetup."Visible On Interface");
                end;
            "Value Type"::ATTRIBUTE:
                begin
                    TaxAttribute.SetRange(ID, "Value ID");
                    if TaxAttribute.FindFirst() then
                        exit(TaxAttribute."Visible on Interface");
                end;
        end;
    end;

    procedure GetRecordID(var TaxRecordID: RecordId)
    var
        TableIDFilter: Integer;
        DocumentTypeFilter: Integer;
        DocumentNoFilter: Text;
        TemplateNameFilter: Text;
        BatchFilter: Text;
        LineNoFilter: Integer;
        IsHandled: Boolean;
    begin
        Clear(TaxRecordID);
        FilterGroup(4);

        if GetFilter("Table ID Filter") <> '' then
            TableIDFilter := GetRangeMax("Table ID Filter");
        if GetFilter("Document No. Filter") <> '' then
            DocumentNoFilter := GetRangeMax("Document No. Filter");
        if GetFilter("Line No. Filter") <> '' then
            LineNoFilter := GetRangeMax("Line No. Filter");
        if GetFilter("Document Type Filter") <> '' then
            DocumentTypeFilter := GetRangeMax("Document Type Filter");
        if GetFilter("Template Name Filter") <> '' then
            TemplateNameFilter := GetRangeMax("Template Name Filter");
        if GetFilter("Batch Name Filter") <> '' then
            BatchFilter := GetRangeMax("Batch Name Filter");

        FilterGroup(0);

        case TableIDFilter of
            database::"Sales Line", database::"Sales Invoice Line", database::"Sales Cr.Memo Line":
                GetTaxRecIDForSalesDocument(TableIDFilter, DocumentTypeFilter, DocumentNoFilter, LineNoFilter, TaxRecordID);
            Database::"Purchase Line", Database::"Purch. Inv. Line", database::"Purch. Cr. Memo Line":
                GetTaxRecIDForPurchDocument(TableIDFilter, DocumentTypeFilter, DocumentNoFilter, LineNoFilter, TaxRecordID);
            Database::"Transfer Line", Database::"Transfer Shipment Line", Database::"Transfer Receipt Line":
                GetTaxRecIDForTransferDocument(TableIDFilter, DocumentNoFilter, LineNoFilter, TaxRecordID);
            database::"Gen. Journal Line":
                GetTaxRecIDForGenJnlLine(TemplateNameFilter, BatchFilter, LineNoFilter, TaxRecordID);
            else
                OnBeforeTableFilterApplied(TaxRecordID, IsHandled, TableIDFilter, DocumentTypeFilter, DocumentNoFilter, TemplateNameFilter, BatchFilter, LineNoFilter)
        end;
    end;

    procedure GetTransactionDataType() Datatype: Enum "Symbol Data Type"
    var
        TaxAttribute: Record "Tax Attribute";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        case "Value Type" of
            "Value Type"::ATTRIBUTE:
                begin
                    TaxAttribute.SetFilter("Tax Type", '%1|%2', "Tax Type", '');
                    TaxAttribute.SetRange(ID, "Value ID");
                    TaxAttribute.FindFirst();
                    Datatype := UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type);
                end;
            "Value Type"::COLUMN:
                begin
                    TaxRateColumnSetup.Get("Tax Type", "Value ID");
                    Datatype := UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateColumnSetup.Type);
                end;
        end;
    end;

    local procedure GetTaxRecIDForSalesDocument(TableID: Integer; DocumentTypeFilter: Integer; DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordId)
    var
        SalesLine: Record "Sales Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        case TableID of
            database::"Sales Line":
                if SalesLine.Get(DocumentTypeFilter, DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := SalesLine.RecordId();
            database::"Sales Invoice Line":
                if SalesInvLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := SalesInvLine.RecordId();
            database::"Sales Cr.Memo Line":
                if SalesCrMemoLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := SalesCrMemoLine.RecordId();
        end;
    end;

    local procedure GetTaxRecIDForPurchDocument(TableID: Integer; DocumentTypeFilter: Integer; DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordId)
    var
        PurchaseLine: Record "Purchase Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        case TableID of
            database::"Purchase Line":
                if PurchaseLine.Get(DocumentTypeFilter, DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := PurchaseLine.RecordId();
            database::"Purch. Inv. Line":
                if PurchInvLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := PurchInvLine.RecordId();
            database::"Purch. Cr. Memo Line":
                if PurchCrMemoLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := PurchCrMemoLine.RecordId();
        end;
    end;

    local procedure GetTaxRecIDForTransferDocument(TableID: Integer; DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordId)
    var
        TransferLine: Record "Transfer Line";
        TransferShptLine: Record "Transfer Shipment Line";
        TransferRcptLine: Record "Transfer Receipt Line";
    begin
        case TableID of
            database::"Transfer Line":
                if TransferLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := TransferLine.RecordId();
            database::"Transfer Shipment Line":
                if TransferShptLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := TransferShptLine.RecordId();
            database::"Transfer Receipt Line":
                if TransferRcptLine.Get(DocumentNoFilter, LineNoFilter) then
                    TaxRecordID := TransferRcptLine.RecordId();
        end;
    end;

    local procedure GetTaxRecIDForGenJnlLine(TemplateNameFilter: Text; BatchFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordId)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if GenJnlLine.Get(TemplateNameFilter, BatchFilter, LineNoFilter) then
            TaxRecordID := GenJnlLine.RecordId();
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeTableFilterApplied(var TaxRecordID: RecordId; var IsHandled: Boolean; TableIDFilter: Integer; DocumentTypeFilter: Integer; DocumentNoFilter: Text; TemplateNameFilter: Text; BatchFilter: Text; LineNoFilter: Integer)
    begin
    end;

    var
        UseCaseDataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
}