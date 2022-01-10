page 20253 "Tax Rate Filters"
{
    Caption = 'Tax Rate Filters';
    DataCaptionExpression = Rec."Tax Type";
    PageType = StandardDialog;
    SourceTable = "Tax Rate Filter";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Column Name"; Rec."Column Name")
                {
                    Editable = false;
                    Caption = 'Column Name';
                    ApplicationArea = Basic, Suite;
                }
                field("Conditional Operator"; "Conditional Operator")
                {
                    Caption = 'Operator';
                    ApplicationArea = Basic, Suite;
                }
                field(Value; Rec.Value)
                {
                    Caption = 'Value';
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        ValidateValue();
                    end;

                    trigger OnAssistEdit()
                    var
                        AttributeManagement: Codeunit "Tax Attribute Management";
                        NewValue: Text[2000];
                    begin
                        NewValue := Value;
                        AttributeManagement.GetTaxRateAttributeLookupValue("Tax Type", "Column Name", NewValue);
                        Value := Value + NewValue;
                    end;
                }
            }
        }
    }

    var
        TempTaxRateFilter: Record "Tax Rate Filter" temporary;

    trigger OnOpenPage()
    begin
        FillRecords();
    end;

    local procedure ValidateValue()
    var
        ScriptDataTypemgmt: Codeunit "Script Data Type Mgmt.";
    begin
        if Rec.Type <> Rec.Type::Date then
            exit;
        ScriptDataTypemgmt.ConvertLocalToXmlFormat(Rec.Value, "Symbol Data Type"::Date);
        Rec.Modify();
    end;

    local procedure FillRecords()
    begin
        TempTaxRateFilter.Reset();
        if TempTaxRateFilter.FindSet() then
            repeat
                Rec.Init();
                Rec := TempTaxRateFilter;
                Rec.Insert();
            until TempTaxRateFilter.Next() = 0;

        if Rec.FindSet() then;
        CurrPage.Update();
    end;

    procedure UpateCache(var TaxRateFilter: Record "Tax Rate Filter" temporary)
    begin
        TaxRateFilter.Reset();
        if TaxRateFilter.FindSet() then
            repeat
                TempTaxRateFilter.Init();
                TempTaxRateFilter := TaxRateFilter;
                TempTaxRateFilter.Insert();
            until TaxRateFilter.Next() = 0;
    end;

    procedure GetFilterDimension(var TempTaxRateFilter: Record "Tax Rate Filter" temporary)
    begin
        TempTaxRateFilter.Reset();
        TempTaxRateFilter.DeleteAll();

        if Rec.FindSet() then
            repeat
                TempTaxRateFilter.Init();
                TempTaxRateFilter := Rec;
                TempTaxRateFilter.Insert();
            until Rec.Next() = 0;
    end;
}