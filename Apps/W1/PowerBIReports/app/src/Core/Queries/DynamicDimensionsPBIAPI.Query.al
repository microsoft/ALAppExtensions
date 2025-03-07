namespace Microsoft.PowerBIReports;

using Microsoft.Finance.Dimension;

query 37016 "Dynamic Dimensions - PBI API"
{
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    Caption = 'Power BI Dynamic Dimensions';
    EntityName = 'dynamicDimension';
    EntitySetName = 'dynamicDimensions';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(DimSetEntry; Microsoft.Finance.Dimension."Dimension Set Entry")
        {
            column(dimensionSetID; "Dimension Set ID") { }
            column(customDimensionValueCode; "Dimension Value Code") { }
            column(modifiedAt; SystemModifiedAt) { }
            dataitem(dimensionValue; "Dimension Value")
            {
                DataItemLink = "Dimension Code" = DimSetEntry."Dimension Code", Code = DimSetEntry."Dimension Value Code";
                SqlJoinType = LeftOuterJoin;
                column(customDimensionValueName; Name) { }
                column(globalDimensionNo; "Global Dimension No.") { }
                dataitem(Dimension; Dimension)
                {
                    DataItemLink = "Code" = DimensionValue."Dimension Code";
                    SqlJoinType = LeftOuterJoin;
                    column(customDimensionName; Name) { }
                    column(customDimensionCode; Code) { }
                    column(modifiedAtDimensionValue; SystemModifiedAt) { }
                    column(noRows)
                    {
                        Method = Count;
                    }
                }
            }
        }
    }
}

