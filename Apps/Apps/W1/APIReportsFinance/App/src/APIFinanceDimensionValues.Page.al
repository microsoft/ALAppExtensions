namespace Microsoft.API.FinancialManagement;

using Microsoft.Finance.Dimension;

page 30302 "API Finance - Dimension Values"
{
    PageType = API;
    EntityCaption = 'Dimension Values';
    EntityName = 'dimensionValue';
    EntitySetName = 'dimensionValues';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    SourceTable = "Dimension Value";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code';
                }
                field(dimensionValueCode; Rec.Code)
                {
                    Caption = 'Dimension Value Code';
                }
                field(dimensionValueName; Rec.Name)
                {
                    Caption = 'Dimension Value Name';
                }
                field(dimensionValueId; Rec."Dimension Value ID")
                {
                    Caption = 'Dimension Value Id';
                }
                field(dimensionValueType; Rec."Dimension Value Type")
                {
                    Caption = 'Dimension Value Type';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(indentation; Rec.Indentation)
                {
                    Caption = 'Indentation';
                }
                field(consolidationCode; Rec."Consolidation Code")
                {
                    Caption = 'Consolidation Code';
                }
                field(globalDimensionNumber; Rec."Global Dimension No.")
                {
                    Caption = 'Global Dimension Number';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last  Modified Date Time';
                }
                part(dimensionSets; "API Finance - Dim Set Entries")
                {
                    Caption = 'Dimension Set Entries';
                    EntityName = 'dimensionSetEntry';
                    EntitySetName = 'dimensionSetEntries';
                    Multiplicity = Many;
                    SubPageLink = "Dimension Value ID" = field("Dimension Value ID");
                }
            }
        }
    }

}