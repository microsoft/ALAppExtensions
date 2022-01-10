page 20252 "Tax Rates"
{
    Caption = 'Tax Rates';
    PageType = List;
    SourceTable = "Tax Rate";
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(AttributeValue1; AttributeValue[1])
                {

                    Visible = 1 <= ColumnCount;
                    CaptionClass = AttributeCaption[1];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(1, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(1, true);
                    end;
                }
                field(AttributeValue2; AttributeValue[2])
                {
                    Visible = 2 <= ColumnCount;
                    CaptionClass = AttributeCaption[2];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(2, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(2, true);
                    end;
                }
                field(AttributeValue3; AttributeValue[3])
                {
                    Visible = 3 <= ColumnCount;
                    CaptionClass = AttributeCaption[3];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(3, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(3, true);
                    end;
                }
                field(AttributeValue4; AttributeValue[4])
                {
                    Visible = 4 <= ColumnCount;
                    CaptionClass = AttributeCaption[4];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(4, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(4, true);
                    end;
                }
                field(AttributeValue5; AttributeValue[5])
                {
                    Visible = 5 <= ColumnCount;
                    CaptionClass = AttributeCaption[5];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(5, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(5, true);
                    end;
                }
                field(AttributeValue6; AttributeValue[6])
                {
                    Visible = 6 <= ColumnCount;
                    CaptionClass = AttributeCaption[6];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(6, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(6, true);
                    end;
                }
                field(AttributeValue7; AttributeValue[7])
                {
                    Visible = 7 <= ColumnCount;
                    CaptionClass = AttributeCaption[7];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(7, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(7, true);
                    end;
                }
                field(AttributeValue8; AttributeValue[8])
                {
                    Visible = 8 <= ColumnCount;
                    CaptionClass = AttributeCaption[8];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(8, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(8, true);
                    end;
                }
                field(AttributeValue9; AttributeValue[9])
                {
                    Visible = 9 <= ColumnCount;
                    CaptionClass = AttributeCaption[9];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(9, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(9, true);
                    end;
                }
                field(AttributeValue10; AttributeValue[10])
                {
                    Visible = 10 <= ColumnCount;
                    CaptionClass = AttributeCaption[10];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(10, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(10, true);
                    end;
                }
                field(AttributeValue11; AttributeValue[11])
                {
                    Visible = 11 <= ColumnCount;
                    CaptionClass = AttributeCaption[11];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(11, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(11, true);
                    end;
                }
                field(AttributeValue12; AttributeValue[12])
                {
                    Visible = 12 <= ColumnCount;
                    CaptionClass = AttributeCaption[12];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(12, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(12, true);
                    end;
                }
                field(AttributeValue13; AttributeValue[13])
                {
                    Visible = 13 <= ColumnCount;
                    CaptionClass = AttributeCaption[13];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(13, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(13, true);
                    end;
                }
                field(AttributeValue14; AttributeValue[14])
                {
                    Visible = 14 <= ColumnCount;
                    CaptionClass = AttributeCaption[14];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(14, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(14, true);
                    end;
                }
                field(AttributeValue15; AttributeValue[15])
                {
                    Visible = 15 <= ColumnCount;
                    CaptionClass = AttributeCaption[15];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(15, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(15, true);
                    end;
                }
                field(AttributeValue16; AttributeValue[16])
                {
                    Visible = 16 <= ColumnCount;
                    CaptionClass = AttributeCaption[16];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(16, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(16, true);
                    end;
                }
                field(AttributeValue17; AttributeValue[17])
                {
                    Visible = 17 <= ColumnCount;
                    CaptionClass = AttributeCaption[17];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(17, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(17, true);
                    end;
                }
                field(AttributeValue18; AttributeValue[18])
                {
                    Visible = 18 <= ColumnCount;
                    CaptionClass = AttributeCaption[18];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(18, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(18, true);
                    end;
                }
                field(AttributeValue19; AttributeValue[19])
                {
                    Visible = 19 <= ColumnCount;
                    CaptionClass = AttributeCaption[19];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(19, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(19, true);
                    end;
                }
                field(AttributeValue20; AttributeValue[20])
                {
                    Visible = 20 <= ColumnCount;
                    CaptionClass = AttributeCaption[20];
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of column based on the configuration on rate setup.';
                    trigger OnValidate()
                    begin
                        UpdateColumnValue(20, false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UpdateColumnValue(20, true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteAllRates)
            {
                Caption = 'Delete All';
                Image = ExportToExcel;
                ApplicationArea = Basic, Suite;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Deletes all tax rates for the tax type.';
                trigger OnAction();
                var
                    TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
                begin
                    TaxSetupMatrixMgmt.DeleteAllTaxRates(GlobalTaxType, false);
                end;
            }
            action(ExportToExcel)
            {
                Caption = 'Export To Excel';
                Image = ExportToExcel;
                ApplicationArea = Basic, Suite;
                PromotedCategory = Process;
                Promoted = true;
                ToolTip = 'Exports the tax rates to Excel.';
                trigger OnAction();
                var
                    TaxRatesExportMgmt: Codeunit "Tax Rates Export Mgmt.";
                begin
                    TaxRatesExportMgmt.ExportTaxRates(GlobalTaxType);
                end;
            }
            action(ImportFromExcel)
            {
                Caption = 'Import From Excel';
                Image = ImportExcel;
                ApplicationArea = Basic, Suite;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Import the tax rates from Excel.';
                trigger OnAction();
                var
                    TaxRatesImportMgmt: Codeunit "Tax Rates Import Mgmt.";
                begin
                    TaxRatesImportMgmt.ReadAndImportTaxRates(GlobalTaxType);
                end;
            }
            action(FilterRates)
            {
                Caption = 'Filter By Attributes';
                Image = FilterLines;
                ApplicationArea = Basic, Suite;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Filter Tax Rates by attributes.';

                trigger OnAction()
                begin
                    TaxRatesfilterMgmt.OpenTaxRateFilter(Rec);
                end;
            }
            action(ClearFilter)
            {
                Caption = 'Clear Filter';
                Image = ClearFilter;
                ApplicationArea = Basic, Suite;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Clears Filter on Tax Rates.';

                trigger OnAction()
                begin
                    TaxRatesfilterMgmt.ClearTaxRateFilter(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnOpenPage()
    begin
        if GlobalTaxType = '' then
            GlobalTaxType := CopyStr(GetFilter("Tax Type"), 1, 20);
        TaxSetupMatrixMgmt.FillColumnArray(GlobalTaxType, AttributeCaption, AttributeValue, RangeAttribute, AttributeID, ColumnCount);
    end;


    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(AttributeValue);
    end;

    procedure SetTaxType(TaxType: Code[20])
    begin
        GlobalTaxType := TaxType;
    end;

    local procedure FormatLine()
    begin
        TaxSetupMatrixMgmt.FillColumnValue(ID, AttributeValue, RangeAttribute, AttributeID);
    end;

    local procedure InsertRecord(Index: Integer)
    var
        TaxRateValue: Record "Tax Rate Value";
        CurrentCellValue: Text;
    begin
        if IsNullGuid(ID) then begin
            CurrentCellValue := AttributeValue[Index];
            Insert(true);
            TaxSetupMatrixMgmt.InitializeRateValue(Rec, GlobalTaxType);
            TaxSetupMatrixMgmt.FillColumnValue(ID, AttributeValue, RangeAttribute, AttributeID);
            AttributeValue[Index] := CurrentCellValue;
        end else begin
            TaxRateValue.SetRange("Config ID", ID);
            if TaxRateValue.IsEmpty() then begin
                TaxSetupMatrixMgmt.InitializeRateValue(Rec, GlobalTaxType);
                TaxSetupMatrixMgmt.FillColumnValue(ID, AttributeValue, RangeAttribute, AttributeID);
                AttributeValue[Index] := CurrentCellValue;
            end;
        end;
    end;

    local procedure UpdateColumnValue(ColumnIndex: Integer; IsLookup: Boolean)
    var
        UpdateRecord: Boolean;
    begin
        InsertRecord(ColumnIndex);
        UpdateRecord := true;

        if IsLookup then
            UpdateRecord := AttributeManagement.GetTaxRateAttributeLookupValue(GlobalTaxType, AttributeCaption[ColumnIndex], AttributeValue[ColumnIndex]);

        if UpdateRecord then
            TaxSetupMatrixMgmt.UpdateTaxConfigurationValue(ID, GlobalTaxType, AttributeID, ColumnIndex, AttributeValue, RangeAttribute);

        if UpdateRecord then
            CurrPage.Update(true);
    end;

    var
        TaxRatesfilterMgmt: Codeunit "Tax Rate Filter Mgmt.";
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
        AttributeManagement: Codeunit "Tax Attribute Management";
        RangeAttribute: array[1000] of Boolean;
        AttributeValue: array[1000] of Text;
        AttributeCaption: array[1000] of Text;
        AttributeID: array[1000] of Integer;
        GlobalTaxType: Code[20];
        ColumnCount: Integer;
}