codeunit 20298 "Use Case Variables Mgmt."
{
    procedure GetTaxAttributeValue(CaseID: guid; var RecRef: RecordRef; AttributeID: Integer; var Value: Variant)
    var
        EntityAttributeMapping: Record "Entity Attribute Mapping";
        RecordAttributeMapping: Record "Record Attribute Mapping";
        UseCase: Record "Tax Use Case";
        TaxAttribute: Record "Tax Attribute";
        FldRef: FieldRef;
        OptionString: Text;
    begin
        UseCase.Get(CaseID);
        Clear(ScriptSymbolsMgmt);
        ScriptSymbolsMgmt.SetContext(UseCase."Tax Type", EmptyGuid, EmptyGuid);
        EntityAttributeMapping.Setrange("Attribute ID", AttributeID);
        EntityAttributeMapping.SetRange("Entity ID", RecRef.Number());
        if not EntityAttributeMapping.FindFirst() then
            Error(AttributeTableMappingNotDefinedErr,
                ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::"Tax Attributes", AttributeID),
                AppObjectHelper.GetObjectName(ObjectType::Table, RecRef.Number()), UseCase.Description);

        if EntityAttributeMapping."Mapping Field ID" <> 0 then begin
            FldRef := RecRef.Field(EntityAttributeMapping."Mapping Field ID");
            Value := FldRef.Value()
        end else begin
            RecordAttributeMapping.SetRange("Attribute ID", AttributeID);
            RecordAttributeMapping.SetRange("Attribute Record ID", RecRef.RecordId());
            if not RecordAttributeMapping.FindFirst() then
                Error(AttributeMappingNotDefinedErr,
                ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::"Tax Attributes", AttributeID),
                Format(RecRef.RecordId(), 0, 9),
                UseCase.Description);

            TaxAttribute.SetRange(ID, AttributeID);
            TaxAttribute.FindFirst();
            if TaxAttribute.Type = TaxAttribute.Type::Option then
                OptionString := ScriptDataTypeMgmt.GetFieldOptionString(TaxAttribute."Refrence Table ID", TaxAttribute."Refrence Field ID");

            ScriptDataTypeMgmt.ConvertText2Type(RecordAttributeMapping."Attribute Value", DataTypeMgmt2.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type), OptionString, Value);
        end;
    end;

    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DatatypeMgmt2: Codeunit "Use Case Data Type Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        AppObjectHelper: Codeunit "App Object Helper";
        EmptyGuid: Guid;
        AttributeMappingNotDefinedErr: Label 'You have not defined any value for Attribute : %1 on Record : %2 for Use Case : %3.', Comment = '%1 - Attribute Name,%2 - RecordIDText,%3 - Use Case Name';
        AttributeTableMappingNotDefinedErr: Label 'You have not mapped Attribute : %1 on Table : %2 for Use Case : %3.', Comment = '%1 - Attribute Name,%2 - Table Name,%3 - Use Case Name';
}