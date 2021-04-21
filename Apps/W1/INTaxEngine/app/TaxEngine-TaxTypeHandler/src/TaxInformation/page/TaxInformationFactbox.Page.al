page 20240 "Tax Information Factbox"
{
    PageType = ListPart;
    Caption = 'Tax Information';
    SourceTable = "Tax Transaction Value";
    Editable = false;
    layout
    {
        area(Content)
        {
            usercontrol(TaxInformation; "Tax Information Addin")
            {
                ApplicationArea = All;
                trigger AddInLoaded()
                var
                    TaxRecordID: RecordId;
                begin
                    Loaded := true;
                    GetRecordID(TaxRecordID);
                    SetFilterOnTaxEntryRecord(TaxRecordID);
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        TaxRecordID: RecordId;
    begin
        if Loaded and GuiAllowed then begin
            GetRecordID(TaxRecordID);
            SetFilterOnTaxEntryRecord(TaxRecordID);
        end;

        exit(Find(Which));
    end;

    local procedure SetFilterOnTaxEntryRecord(TaxRecordID: RecordId): Boolean
    var
        AttributeJobject: JsonObject;
        ComponentJobject: JsonObject;
    begin
        if (not Loaded) or (not GuiAllowed) then
            exit;
        GetTaxAttributesInJson(TaxRecordID, AttributeJobject);
        GetTaxComponentsInJson(TaxRecordID, ComponentJobject);
        CurrPage.TaxInformation.RenderTaxInformation(AttributeJobject, ComponentJobject);

        CurrPage.Update(false);
        exit(FindSet());
    end;

    local procedure GetTaxAttributesInJson(TaxRecordID: RecordId; var JObject: JsonObject)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        Datatype: Enum "Symbol Data Type";
        JArray: JsonArray;
        AttributeJObject: JsonObject;
    begin
        if not GuiAllowed then
            exit;

        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '<>%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        if TaxTransactionValue.FindSet() then
            repeat
                Clear(AttributeJObject);
                AttributeJObject.Add('AttributeName', TaxTransactionValue.GetAttributeColumName());
                Datatype := TaxTransactionValue.GetTransactionDataType();
                if TaxTransactionValue."Column Value" <> '' then
                    AttributeJObject.Add('Value', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(TaxTransactionValue."Column Value", Datatype))
                else
                    AttributeJObject.Add('Value', '');
                JArray.Add(AttributeJObject);
            until TaxTransactionValue.Next() = 0;

        JObject.Add('TaxInformation', JArray);
    end;

    local procedure GetTaxComponentsInJson(TaxRecordID: RecordId; var JObject: JsonObject)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmt: Decimal;
        JArray: JsonArray;
        ComponentJObject: JsonObject;
    begin
        if not GuiAllowed then
            exit;

        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        if TaxTransactionValue.FindSet() then
            repeat
                Clear(ComponentJObject);
                ComponentJObject.Add('Component', TaxTransactionValue.GetAttributeColumName());
                ComponentJObject.Add('Percent', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(TaxTransactionValue.Percent, 0, 9), "Symbol Data Type"::NUMBER));
                ComponentAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
                ComponentJObject.Add('Amount', ScriptDatatypeMgmt.ConvertXmlToLocalFormat(format(ComponentAmt, 0, 9), "Symbol Data Type"::NUMBER));
                JArray.Add(ComponentJObject);
            until TaxTransactionValue.Next() = 0;

        JObject.Add('TaxInformation', JArray);
    end;

    local procedure RoundAmount(Amt: Decimal; Precision: Decimal; Direction: Enum "Rounding Direction"): Decimal
    begin
        case Direction of
            Direction::Down:
                Amt := ROUND(Amt, Precision, '<');
            Direction::Up:
                Amt := ROUND(Amt, Precision, '>');
            Direction::Nearest:
                Amt := ROUND(Amt, Precision, '=');
        end;

        exit(Amt);
    end;

    var
        ScriptDatatypeMgmt: Codeunit "Script Data Type Mgmt.";
        Loaded: Boolean;
}