xmlport 130472 "AL Code Coverage Map"
{
    Direction = Export;
    Format = VariableText;
    FieldDelimiter = '';
    FieldSeparator = ',';
    TableSeparator = '<NewLine>';
    TextEncoding = UTF16;

    schema
    {
        textelement(CodeCoverageMap)
        {
            tableelement(ALCodeCoverageMap; "AL Code Coverage Map")
            {
                fieldelement(ALObjectType; ALCodeCoverageMap."Object Type")
                {
                }
                fieldelement(ALObjectID; ALCodeCoverageMap."Object ID")
                {
                }
                fieldelement(ALLineNumber; ALCodeCoverageMap."Line No.")
                {
                }
                fieldelement(ALTestCodeunitID; ALCodeCoverageMap."Test Codeunit ID")
                {
                }
                fieldelement(ALTestMethod; ALCodeCoverageMap."Test Method")
                {
                }
            }
        }
    }
}