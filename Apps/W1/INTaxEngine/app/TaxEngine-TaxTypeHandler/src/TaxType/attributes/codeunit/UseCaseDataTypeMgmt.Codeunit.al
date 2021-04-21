codeunit 20235 "Use Case Data Type Mgmt."
{
    procedure GetAttributeDataTypeToVariableDataType(AttributeDataType: Option): Enum "Symbol Data Type"
    var
        TaxAttribute: Record "Tax Attribute";
    begin
        case AttributeDataType of
            TaxAttribute.Type::Boolean:
                exit("Symbol Data Type"::BOOLEAN);
            TaxAttribute.Type::Text:
                exit("Symbol Data Type"::STRING);
            TaxAttribute.Type::Date:
                exit("Symbol Data Type"::DATE);
            TaxAttribute.Type::Integer,
            TaxAttribute.Type::Decimal:
                exit("Symbol Data Type"::NUMBER);
            TaxAttribute.Type::Option:
                exit("Symbol Data Type"::OPTION);
        end;
    end;
}