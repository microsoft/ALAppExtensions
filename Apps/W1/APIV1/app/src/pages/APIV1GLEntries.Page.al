page 20018 "APIV1 - G/L Entries"
{
    APIVersion = 'v1.0';
    Caption = 'generalLedgerEntries', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'generalLedgerEntry';
    EntitySetName = 'generalLedgerEntries';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "G/L Entry";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; "Entry No.")
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'postingDate', Locked = true;
                }
                field(documentNumber; "Document No.")
                {
                    Caption = 'documentNumber', Locked = true;
                }
                field(documentType; "Document Type")
                {
                    Caption = 'documentType', Locked = true;
                }
                field(accountId; "Account Id")
                {
                    Caption = 'accountId', Locked = true;
                }
                field(accountNumber; "G/L Account No.")
                {
                    Caption = 'accountNumber', Locked = true;
                }
                field(description; Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(debitAmount; "Debit Amount")
                {
                    Caption = 'debitAmount', Locked = true;
                }
                field(creditAmount; "Credit Amount")
                {
                    Caption = 'creditAmount', Locked = true;
                }
                field(dimensions; DimensionsJSON)
                {
                    Caption = 'dimensions', Locked = true;
                    ODataEDMType = 'Collection(DIMENSION)';
                    ToolTip = 'Specifies Journal Line Dimensions.';
                }
                field(lastModifiedDateTime; "Last Modified DateTime")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    var
        DimensionsJSON: Text;

    local procedure SetCalculatedFields()
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        DimensionsJSON := GraphMgtComplexTypes.GetDimensionsJSON("Dimension Set ID");

    end;
}

