page 6183 "E-Doc. Purchase Draft Subform"
{

    AutoSplitKey = true;
    Caption = 'Lines';
    InsertAllowed = false;
    LinksAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    PageType = ListPart;
    SourceTable = "E-Document Purchase Line";

    layout
    {
        area(Content)
        {
            repeater(DocumentLines)
            {
                field("Line No."; Rec."E-Document Line Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number.';
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Line Type"; EDocumentLineMapping."Purchase Line Type")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = true;
                }
                field("No."; EDocumentLineMapping."Purchase Type No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = true;
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNo();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Unit Of Measure"; EDocumentLineMapping."Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure code.';
                    Editable = true;
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupUOM();
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    Editable = false;
                }
                field("Direct Unit Cost"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the direct unit cost.';
                    Editable = false;
                }
            }
        }
    }

    var
        EDocumentLineMapping: Record "E-Document Line Mapping";
        StyleTxt: Text;

    trigger OnAfterGetRecord()
    begin
        if EDocumentLineMapping.Get(Rec."E-Document Line Id") then;
    end;

    local procedure LookupNo()
    begin
        case EDocumentLineMapping."Purchase Line Type" of
            "Purchase Line Type"::Item:
                LookupItem();
            "Purchase Line Type"::"G/L Account":
                LookupGLAccount();
            else
                exit;
        end;
    end;

    local procedure LookupItem()
    var
        Item: Record Item;
        ItemList: Page "Item List";
    begin
        ItemList.LookupMode := true;
        if ItemList.RunModal() = Action::LookupOK then begin
            ItemList.GetRecord(Item);
            EDocumentLineMapping."Purchase Type No." := Item."No.";
            EDocumentLineMapping.Modify();
        end;
    end;

    local procedure LookupGLAccount()
    var
        GLAccount: Record "G/L Account";
        ChartOfAccounts: Page "Chart of Accounts";
    begin
        ChartOfAccounts.LookupMode := true;
        GLAccount.SetRange("Direct Posting", true);
        ChartOfAccounts.SetTableView(GLAccount);
        if ChartOfAccounts.RunModal() = Action::LookupOK then begin
            ChartOfAccounts.GetRecord(GLAccount);
            EDocumentLineMapping."Purchase Type No." := GLAccount."No.";
            EDocumentLineMapping.Modify();
        end;
    end;

    local procedure LookupUOM()
    var
        UnitOfMeasure: Record "Unit of Measure";
        UnitsOfMeasure: Page "Units of Measure";
    begin
        UnitsOfMeasure.LookupMode := true;
        if UnitsOfMeasure.RunModal() = Action::LookupOK then begin
            UnitsOfMeasure.GetRecord(UnitOfMeasure);
            EDocumentLineMapping."Unit of Measure" := UnitOfMeasure.Code;
            EDocumentLineMapping.Modify();
        end;
    end;

}